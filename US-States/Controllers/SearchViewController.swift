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
  @IBOutlet weak var titleLabel1: UILabel!
  @IBOutlet weak var titleLabel2: UILabel!
  @IBOutlet weak var titleLabel3: UILabel!
  @IBOutlet weak var textView: UITextView!
 
  var spinnerViewController : SpinnerViewController?
  
  var entry: CalEntry? {
    didSet{
      configureScreen()
    }
  }
  
  weak var masterViewController: MasterViewController?
  
  var currentPage : CalPage?
  
  var searchText = ""
  
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
    /// - Important: CalDocument.search() updated the mode to ".search", but we  must reset it here
    calDocument.mode = .fullList
  }
  
  //MARK: - Search bar delegate
  func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
    
    // Dismiss the keyboard
    searchBar.resignFirstResponder()
    
  
    if let searchText = searchBar.text {
      self.searchText = searchText
      
      if searchText.lowercased() == "@bookmarks" {
        calDocument.mode = .bookmarks
      } else {
        showSpinner()
        
        /// - Important: CalDocument.search() will update the mode to ".search"
        calDocument.search(forString: searchText)
      }
    }
  }
  
  // MARK: - Action handlers
  @objc func completedSearch(_ notification: NSNotification) {
    
    if let firstEntry = notification.userInfo?[Notifications.firstSearchEntry] as? CalEntry {
      entry = firstEntry
     }
    
    if let spinnerViewController = spinnerViewController {
      spinnerViewController.willMove(toParent: nil)
      spinnerViewController.view.removeFromSuperview()
      spinnerViewController.removeFromParent()
    }
  }
  
  @objc func handleBookmarkTapGesture()
  {
    if let entry = entry {
      calDocument.toggleIsBookmarked(entry: entry)
      
      masterViewController?.tableView.reloadData()
    }
  }
  
  @objc func handleSwipes(_ sender:UISwipeGestureRecognizer) {
    // Use the goingForward flag to update the selected row in the list
    var goingForward = false
    
    //If we're speaking, stop it
    TextToVoice.stopSpeaking()
    
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
  
  // Share the text
  @objc func shareTapped() {
    
    if let textToShare = textView.text {
      let vc = UIActivityViewController(activityItems: [textToShare], applicationActivities: [])
      vc.popoverPresentationController?.barButtonItem = navigationItem.rightBarButtonItem
      present(vc, animated: true)
    }
  }
  
  @objc func speakTapped()
  {
    TextToVoice.speak(text: textView.text ?? "")
  }
  
  //MARK: - Private functions
  
  /// Configures the screen
  private func configureScreen() {
    
    loadViewIfNeeded()
    
    // Update the user interface for the detail item.
    // Update the user interface for the detail item.
    if let entry = entry {
      if let _ = titleLabel3 {
        setLabels(entry: entry)
        
        if let page = entry.page {
          currentPage = page
          let pageAsAttributedText = CalAttributableString.calPageAsAttributedString(calPage: page)
          let highlightedText      = generateAttributedString(with: searchText,
                                                              targetString: pageAsAttributedText)
          textView.text = ""
          textView.attributedText  = NSMutableAttributedString(attributedString: highlightedText ?? pageAsAttributedText).setFont(textView.font!)
        } else {
          textView.attributedText  = NSMutableAttributedString()
        }
      }
    }
  }
  
  private func showSpinner() {
    spinnerViewController = SpinnerViewController()
    
    if let spinnerViewController = spinnerViewController {
      // Add the spinner view controller
      addChild(spinnerViewController)
      spinnerViewController.view.frame = view.frame
      view.addSubview(spinnerViewController.view)
      spinnerViewController.didMove(toParent: self)
    }
  }
  
  
  /// Highlights the search string in the text
  private func generateAttributedString(with searchTerm: String,
                                        targetString: NSAttributedString) -> NSAttributedString? {
      let attributedString = NSMutableAttributedString(attributedString: targetString)
      do {
        let regex = try NSRegularExpression(pattern:  NSRegularExpression.escapedPattern(for: searchTerm).trimmingCharacters(in: .whitespacesAndNewlines).folding(options: .regularExpression, locale: .current), options: .caseInsensitive)
          
        let range = NSRange(location: 0, length: targetString.string.utf16.count)
          attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.clear, range: range)
        
        for match in regex.matches(in: targetString.string.folding(options: .regularExpression, locale: .current), options: .withTransparentBounds, range: range) {
              attributedString.addAttribute(NSAttributedString.Key.backgroundColor, value: UIColor.yellow, range: match.range)
          }
          return attributedString
      } catch {
          NSLog("Error creating regular expresion: \(error)")
          return nil
      }
  }
  
  /// Sets the title and labels for the entry
  /// Sets the title and labels for the entry
  private func setLabels(entry: CalEntry) {
    
    titleLabel1.isHidden = false
    titleLabel2.isHidden = false
    titleLabel3.isHidden = false
    
    var parents = [CalEntry]()
    
    if let originalEntry = calDocument.getEntryWith(id: entry.copiedId) {
      parents = calDocument.getParentsFor(entry: originalEntry)
    }
    else {
      parents = [entry]
    }
    
    var titleToDisplay = ""
    for p in parents {
      titleToDisplay += "\(p.title) - "
    }
    
    title            = ""
    titleLabel1.text = ""
    titleLabel2.text = ""
    titleLabel3.text = ""
    
    let h2 = parents.first(where: {$0.type == .H2 })
    let h3 = parents.first(where: {$0.type == .H3 })
    let h4 = parents.first(where: {$0.type == .H4 })
    let h5 = parents.first(where: {$0.type == .H5 })
    
    if let h2 = h2 { title            = "\(h2.title)" }
    if let h3 = h3 { titleLabel1.text = "\(h3.title)" } else {titleLabel1.isHidden = true }
    if let h4 = h4 { titleLabel2.text = "\(h4.title)" } else {titleLabel2.isHidden = true }
    if let h5 = h5 { titleLabel3.text = "\(h5.title)" } else {titleLabel3.isHidden = true }
  }
  
  private func setUp() {
    let share  = UIBarButtonItem(barButtonSystemItem: .action, target: self, action: #selector(shareTapped))
    let speak  = UIBarButtonItem(barButtonSystemItem: .play,   target: self, action: #selector(speakTapped))
    // Add the share and speak bar button item to the right
    navigationItem.rightBarButtonItems = [share, speak]
    
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
    
    
    // Add the double tap gesture for the emailer
    let bookmarkTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBookmarkTapGesture))
    bookmarkTapGesture.numberOfTapsRequired = 2
    view.addGestureRecognizer(bookmarkTapGesture)
    textView.addGestureRecognizer(bookmarkTapGesture)
    
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
