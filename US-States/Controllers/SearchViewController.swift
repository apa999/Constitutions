//
//  SearchViewController.swift
//  US-States
//
//  Created by Anthony Abbott on 09/03/2022.
//

import UIKit
import AVFoundation

class SearchViewController: UIViewController, UISearchBarDelegate {
  @IBOutlet weak var searchBar: UISearchBar!
  @IBOutlet weak var textView: UITextView!
  @IBOutlet weak var titleLabelH3: UILabel!
  @IBOutlet weak var titleLabelH4: UILabel!
  
  var entry: CalEntry? {
    didSet{
      configureScreen()
    }
  }
  
  weak var masterViewController: MasterViewController?
  
  var currentPage : CalPage?
  
  enum SearchType {
    case all, h1, h2, h3, h4, h5, h6
  }
  
  var searchType = SearchType.all {
    didSet {
      if searchType == .all {
        title = "Searching all states"
      } else {
        title = "Searching \(entry!.title)"
      }
    }
  }
  
  //MARK: - Life cycle
  override func viewDidLoad() {
    
    super.viewDidLoad()
    
    setUp()
    setSearchType()
  }
  
  override func viewDidAppear(_ animated: Bool) {
  }
  
  override func viewDidDisappear(_ animated: Bool) {
    calDocument.mode = .fullList
  }
  
  //MARK: - Search bar delegate
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    if let searchText = searchBar.text
    {
      calDocument.search(forString: searchText)
   
      calDocument.mode = .search
    }
  }
  
  // MARK: - Action handlers
  @objc func completedSearch(_ notification: NSNotification) {
    
    if let firstEntry = notification.userInfo?[Notifications.firstSearchEntry] as? CalEntry {
      entry = firstEntry
     }
  }
  
  @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
    // Use the goingForward flag to update the selected row in the list
    var goingForward = false
    
    if let _ = entry {
      if (sender.direction == .left) {
        // Show the next page
        entry = calDocument.getNext(entry: entry!)
        goingForward = true
      }
      
      else if (sender.direction == .right) {
        // Show the previous page
        entry = calDocument.getPrev(entry: entry!)
      }
      
      if let masterViewController = masterViewController {
        masterViewController.updateSelectedItemForSearch(entry: entry!, forward: goingForward)
      }
    }
  }
  
  //MARK: - Private functions
  
  /// Configures the screen
  private func configureScreen() {
    
    
    // Update the user interface for the detail item.
    if let entry = entry {
      if let _ = titleLabelH3 {
        setLabels(entry: entry)
        
        if let page = entry.page {
          currentPage = page
          let pageAsAttributedText = CalAttributableString.calPageAsAttributedString(calPage: page)
          textView.text = ""
          textView.attributedText  = NSMutableAttributedString(attributedString: pageAsAttributedText).setFont(textView.font!)
        } else {
          // No page
          titleLabelH3.text = ""
          titleLabelH4.text = ""
          textView.attributedText  = NSMutableAttributedString()
        }
      }
    }
  }
  
  /// Sets the title and labels for the entry
  private func setLabels(entry: CalEntry) {
    
    title = "\(entry.title) - \(entry.id)"
    
    switch entry.type {
      case .H1: break
      case .H2:
        titleLabelH3.text = ""
        titleLabelH4.text = ""
      case .H3: titleLabelH3.text = entry.title
      case .H4: titleLabelH4.text = entry.title
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
    
    searchBar.delegate = self
    searchBar.searchTextField.textColor = UIColor.systemBlue
    
    if let entry = entry {
      if let page = entry.page {
        let pageAsAttributedText = CalAttributableString.calPageAsAttributedString(calPage: page)
        
        textView.text = ""
        textView.attributedText  = NSMutableAttributedString(attributedString: pageAsAttributedText).setFont(textView.font!)
      }
    }
    
    NotificationCenter.default.addObserver(self, selector: #selector(completedSearch(_:)),
                                           name: Notification.Name(Notifications.completedSearch),
                                           object: nil)
  }
  
  /// Set the search type depending on the user's selection; if the user has select 'A', 'B' etc
  /// and the section is not expanded, then this means search everywhere
  private func setSearchType() {
    if let entry = entry {
      switch entry.type {
        case .H1: searchType = entry.isExpanded == false ? .all : .h1
        case .H2: searchType = .h2
        case .H3: searchType = .h3
        case .H4: searchType = .h4
        case .H5: searchType = .h5
        case .H6: searchType = .h6
        default: break
      }
    }
  }
}
