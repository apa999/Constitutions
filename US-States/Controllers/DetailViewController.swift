//
//  DetailViewController.swift
//  StandardLists1
//
//  Created by Anthony Abbott on 10/03/2022.
//

import UIKit

class DetailViewController: UIViewController {
  
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var titleLabel1: UILabel!
  @IBOutlet weak var titleLabel2: UILabel!
  @IBOutlet weak var titleLabel3: UILabel!
  
  weak var masterViewController: MasterViewController?
  weak var searchViewController: SearchViewController?
  
  //MARK: - Class properties
  var entry: CalEntry! {
    didSet {
      configureScreen()
    }
  }
  
  var currentPage : CalPage?
  
  //MARK: - Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setUp()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    assignMasterViewController()
  }
  
  // MARK: - Action handlers
  @objc func handleSwipes(_ sender:UISwipeGestureRecognizer)
  {
    // Use the goingForward flag to update the selected row in the list
    var goingForward = false
    
    if (sender.direction == .left) {
      // Show the next page
      entry = calDocument.getNext(entry: entry)
      goingForward = true
    }
    
    else if (sender.direction == .right) {
      // Show the previous page
      entry = calDocument.getPrev(entry: entry)
    }
    
    if let masterViewController = masterViewController {
      masterViewController.updateSelectedItem(entry: entry, forward: goingForward)
    }
  }
  
  @objc func search()
  {
    guard let svc = storyboard?.instantiateViewController(withIdentifier: "SearchViewController") as? SearchViewController else {
      fatalError("Unable to load SearchViewController from storyboard.")
    }
    
    searchViewController = svc
    
    searchViewController?.entry = entry
    searchViewController?.masterViewController = masterViewController
    navigationController?.pushViewController(searchViewController!, animated: true)
  }
  
  // MARK: - Private functions
  
  /// Assigns the master view controller
  private func assignMasterViewController() {
    
    if splitViewController?.children.count == 2 {
      if let navController = splitViewController?.children[0] as? UINavigationController {
        guard navController.children.count > 0 else {
          fatalError("Navigation controller does not contain detail view controller")
        }
        
        masterViewController = navController.children[0] as? MasterViewController
      }
      else if let _ = splitViewController?.children[0] as? MasterViewController {
        masterViewController = splitViewController?.children[0] as? MasterViewController
      }
    }
  }
  
  /// Configures the screen
  private func configureScreen() {
    
    loadViewIfNeeded()
    
    if calDocument.mode == .fullList {
      // Update the user interface for the detail item.
      if let entry = entry {
        if let _ = titleLabel3 {
          setLabels(entry: entry)
          
          if let page = entry.page {
            currentPage = page
            let pageAsAttributedText = CalAttributableString.calPageAsAttributedString(calPage: page)
            textView.text = ""
            textView.attributedText  = NSMutableAttributedString(attributedString: pageAsAttributedText).setFont(textView.font!)
          } else {
//            titleLabelH3.text = ""
//            titleLabelH4.text = ""
            textView.attributedText  = NSMutableAttributedString()
          }
        }
      }
    } else {
      if let svc = searchViewController {
        svc.entry = entry
      }
    }
  }
  
  /// Sets the title and labels for the entry
  private func setLabels(entry: CalEntry) {
    
    let parents = calDocument.getParentsFor(entry: entry)
    
    var titleToDisplay = ""
    for p in parents {
      titleToDisplay += "\(p.title) - "
    }
    
    title = "\(titleToDisplay)"
  
    switch entry.type {
      case .H1: break
      case .H2:
        titleLabel1.text = ""
        titleLabel2.text = ""
        titleLabel3.text = ""
      case .H3:
        titleLabel2.text = entry.title
      case .H4:
        titleLabel2.text = parents[3].title
        titleLabel3.text = entry.title
      default: break
    }
  }
  
  private func setUp() {
    let leftSwipe  = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
    let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
    
    leftSwipe.direction  = .left
    rightSwipe.direction = .right
    
    view.addGestureRecognizer(leftSwipe)
    view.addGestureRecognizer(rightSwipe)
    
    textView.text = ""
    
    if let entry = entry {
      let pageAsAttributedText = CalAttributableString.calPageAsAttributedString(calPage: entry.page!)
      textView.text = ""
      textView.attributedText  = NSMutableAttributedString(attributedString: pageAsAttributedText).setFont(textView.font!)
    }
    
    // Add the search bar button item
    navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .search,
                                                        target: self,
                                                        action: #selector(search))
  }
}

extension DetailViewController: CalEntrySelectionDelegate {
  func entrySelected(_ newEntry: CalEntry) {
    entry = newEntry
  }
}
