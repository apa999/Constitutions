//
//  ViewController.swift
//  StandardLists1
//
//  Created by Anthony Abbott on 09/03/2022.
//

import UIKit

class MasterViewController: UITableViewController {
  weak var detailViewController: DetailViewController?
  weak var delegate: CalEntrySelectionDelegate?
  
  var firstEntry: CalEntry?
  
  var spinnerViewController : SpinnerViewController?
  
  // MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    setUp()
    
    if calDocument.dataLoaded == true {
      tableView.reloadData()
    } else {
      createSpinnerView()
    }
  }
  
  override func viewDidAppear(_ animated: Bool) {
    assignDetailViewController()
  }
  // MARK: - Table view data source
  
  /// Number of Sections
  ///
  /// A section is defined as type H1.
  /// (The parent id of a section is also -1)
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    let numberOfSections = calDocument.getNumberOfSections()

    return numberOfSections
  }

  /// Number of Rows in Section
  ///
  /// The number of rows in a section are the number of **visible** rows.
  /// This means that if the row is not expanded, then it counts as one, regardless
  /// of how many children it may have.
  /// If a row is **is expanded** (i.e. the children are visible) then the children
  /// will be counted, and so forth.
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    let numberOfRowsInSection = calDocument.getNumberOfVisibleRowsFor(section: section)
  
    return numberOfRowsInSection
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: "CalDocumentCell", for: indexPath)
    
    cell.textLabel?.textColor                 = UIColor.systemBlue
    cell.textLabel?.adjustsFontSizeToFitWidth = false
    cell.textLabel?.font                      = UIFont.systemFont(ofSize: 18)
    
    if let entry = calDocument.getEntryForRowAt(section: indexPath.section, rowToGet: indexPath.row)
    {
      cell.textLabel?.text = entry.title
      
      let offset = 14.0
      
      switch entry.type {
        case .H2: cell.layoutMargins.left = CGFloat(offset * 1.5)
        case .H3: cell.layoutMargins.left = CGFloat(offset * 2.0)
        case .H4: cell.layoutMargins.left = CGFloat(offset * 2.5)
        case .H5: cell.layoutMargins.left = CGFloat(offset * 3.0)
        case .H6: cell.layoutMargins.left = CGFloat(offset * 3.5)
        default:  cell.layoutMargins.left = 0.0
      }
      
      cell.accessoryType = entry.isExpandable == true ? .disclosureIndicator : .none
    }
  
    return cell
  }
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    if let entry = calDocument.getEntryForRowAt(section: indexPath.section, rowToGet: indexPath.row) {
      // If the selected row is expandable then toggle its "is expanded" status
      if entry.isExpandable == true {
        calDocument.toggleIsExpanded(entry: entry)
        
        // Reload the table
        tableView.reloadData()
      }
      
      delegate?.entrySelected(entry)
      
      if let detailViewController = delegate as? DetailViewController,
         let detailNavigationController = detailViewController.navigationController {
        
        if entry.type != .H1 &&  entry.type != .H2 {
          splitViewController?.showDetailViewController(detailNavigationController, sender: nil)
        }
      }
      
      // Highlight the selected row
      self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
    }
  }
  
  
  
  //MARK: - Observers
  
  @objc func completedSearch(_ notification: NSNotification) {
    
    if let firstEntry = notification.userInfo?[Notifications.firstSearchEntry] as? CalEntry {
      updateSelectedItemForSearch(entry: firstEntry, forward: true)
     }
  }
  
  @objc func dataIsLoaded() {
    tableView.reloadData()
    
    // This is the first time the data has been loaded.
    // Get the first entry in the list and set the detail view controller
    
    if let entry = calDocument.getEntryForRowAt(section: 0, rowToGet: 0) {
      firstEntry = entry
      detailViewController?.entry = entry
    }
    
    if let spinnerViewController = spinnerViewController {
      spinnerViewController.willMove(toParent: nil)
      spinnerViewController.view.removeFromSuperview()
      spinnerViewController.removeFromParent()
    }
  }
  
  @objc func modeHasChanged(){
    tableView.reloadData()
  }
  
  //MARK: - Public functions
  
  /// Update the selected row when the user has moved by swiping
  /// If we're going forward, and the header that we've moved on to is not expanded,
  /// then expand it.
  func updateSelectedItem(newEntry: CalEntry, forward: Bool) {
    let previousEntry = forward ? calDocument.getPrev(entry: newEntry) : calDocument.getNext(entry: newEntry)
    
    if forward == true {
      if previousEntry.id != newEntry.id {
        if previousEntry.isExpanded == false {
          calDocument.toggleIsExpanded(entry: previousEntry)
        }
      }
    } else {
      // Going backwards -
      // Collapse the row behind us as we move up this list
      
      // If we're at the top of the list then collapse the list
      let atTopOfList = calDocument.atTopOfList(entry: newEntry)
      
      if atTopOfList == true {
        // At the top of the list - collapse the list
        if newEntry.isExpanded == true {
          calDocument.toggleIsExpanded(entry: newEntry)
        }
        
        if previousEntry.isExpanded == true {
          calDocument.toggleIsExpanded(entry: previousEntry)
        }
      }
      else {
        if previousEntry.isExpandable == true {
          // The previous row was a header
          // If it was expanded, then collapse it
         
          if previousEntry.isExpanded == true {
            calDocument.toggleIsExpanded(entry: previousEntry)
          }
        }
        
        calDocument.makeVisible(entry: newEntry)
      }
    }
    
    tableView.reloadData()
    
    // Highlight the selected row
    let rowOfEntry = calDocument.getRowNumOfThis(entry: newEntry)
    let indexPath  = IndexPath(row: rowOfEntry, section: newEntry.sectionId)
    self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
  }
  
  /// Special select row version for search
  func updateSelectedItemForSearch(entry: CalEntry, forward: Bool){
    
    let searchSection = calDocument.getSearchSectionForThis(entry: entry)
    let indexPath  = IndexPath(row: 0, section: searchSection)
    self.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .middle)
  }
  
  //MARK: - Private functions
  
  /// Get the detail view controller - watch out for navigation controllers
  private func assignDetailViewController() {
    
    if splitViewController?.children.count == 2 {
      if let navController = splitViewController?.children[1] as? UINavigationController {
        guard navController.children.count > 0 else {
          fatalError("Navigation controller does not contain detail view controller")
        }
        
        detailViewController = navController.children[0] as? DetailViewController
      }
      else if let _ = splitViewController?.children[1] as? DetailViewController {
        detailViewController = splitViewController?.children[0] as? DetailViewController
      }
    }
    
    if let _ = detailViewController {
      detailViewController?.entry = calDocument.getEntryForRowAt(section: 0, rowToGet: 0)
    }
  }
  
  func createSpinnerView() {
    spinnerViewController = SpinnerViewController()
    
    if let spinnerViewController = spinnerViewController {
      // Add the spinner view controller
      addChild(spinnerViewController)
      spinnerViewController.view.frame = view.frame
      view.addSubview(spinnerViewController.view)
      spinnerViewController.didMove(toParent: self)
    }
  }
  
  /// Set up
  private func setUp() {
    NotificationCenter.default.addObserver(self, selector: #selector(dataIsLoaded),
                                           name: Notification.Name(Notifications.dataIsLoaded),
                                           object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(modeHasChanged),
                                           name: Notification.Name(Notifications.modeHasChanged),
                                           object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(completedSearch(_:)),
                                           name: Notification.Name(Notifications.completedSearch),
                                           object: nil)
    
  }
}
