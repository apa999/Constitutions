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
    
    showOnboarding()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if masterViewController == nil {
      assignMasterViewController()
    }
  }
  
  // MARK: - Action handlers
  @objc func handleBookmarkTapGesture()
  {
    if let entry = entry {
      calDocument.toggleIsBookmarked(entry: entry)
      
      masterViewController?.tableView.reloadData()
    }
  }
  
  @objc func handleSwipes(_ sender:UISwipeGestureRecognizer)
  {
    // Use the goingForward flag to update the selected row in the list
    var goingForward = false
    
    //If we're speaking, stop it
    TextToVoice.stopSpeaking()
    
    if let _ = entry {
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
        masterViewController.updateSelectedItem(newEntry: entry, forward: goingForward)
      }
    }
  }
  
  @objc func searchTapped()
  {
    performSegue(withIdentifier: SegueConstants.showSearchViewController, sender: nil)
  }
  
  // Share the text
  @objc func shareTapped() {
    
    if let textToShare = textView.text {
      let vc = UIActivityViewController(activityItems: [textToShare], applicationActivities: [])
      vc.popoverPresentationController?.barButtonItem = navigationItem.leftBarButtonItem
      present(vc, animated: true)
    }
  }
  
  @objc func speakTapped()
  {
    TextToVoice.speak(text: textView.text ?? "")
  }
  
  /**
   The user has long-pressed in the home screen so show the onboarding
   */
  @objc func showOnboardingByRequest(_ recogniser: UITapGestureRecognizer) {
    if (recogniser.state == UITapGestureRecognizer.State.ended ) {
      showOnBoardingLaunch()
    }
  }
  
  // MARK: - Navigation
  override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
    if segue.identifier == SegueConstants.showSearchViewController {
      if let searchViewController = segue.destination  as? SearchViewController {
        self.searchViewController = searchViewController
        searchViewController.masterViewController = masterViewController
      }
    } else {
      fatalError("Unrecognised segue.identifier: \(segue.identifier ?? "Nil")")
    }
  }
  
  // MARK: - Private functions
  
  /// Assigns the master view controller - this works when we have a split view
  /// but if running on an iPhone, then the svc has one child, and we can't get the master
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
    
    titleLabel1.isHidden = false
    titleLabel2.isHidden = false
    titleLabel3.isHidden = false
    
    let parents = calDocument.getParentsFor(entry: entry)
    
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
    let search = UIBarButtonItem(barButtonSystemItem: .search, target: self, action: #selector(searchTapped))
    let speak  = UIBarButtonItem(barButtonSystemItem: .play,   target: self, action: #selector(speakTapped))
    // Add the share, search and speak bar button item to the right
    navigationItem.rightBarButtonItems = [share, search, speak]
    
    let leftSwipe  = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
    let rightSwipe = UISwipeGestureRecognizer(target: self, action: #selector(handleSwipes(_:)))
    
    leftSwipe.direction  = .left
    rightSwipe.direction = .right
    
    view.addGestureRecognizer(leftSwipe)
    view.addGestureRecognizer(rightSwipe)
    
    // Add the double tap gesture for the emailer
    let bookmarkTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleBookmarkTapGesture))
    bookmarkTapGesture.numberOfTapsRequired = 2
    view.addGestureRecognizer(bookmarkTapGesture)
    textView.addGestureRecognizer(bookmarkTapGesture)
    
    textView.text = ""
    
    if let entry = entry {
      let pageAsAttributedText = CalAttributableString.calPageAsAttributedString(calPage: entry.page!)
      textView.text = ""
      textView.attributedText  = NSMutableAttributedString(attributedString: pageAsAttributedText).setFont(textView.font!)
    }
    
    
    /// Long pause for onboarding
    view.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(showOnboardingByRequest)))
  }
  
  /**
   Show onboading if it is a new installation or upgrade
   */
  private func showOnboarding() {
    let defaults = Defaults()
    
    let (versionNumber, buildNumber) = defaults.getBundle()
    
    if let rvn = Bundle.main.releaseVersionNumber, let rbn = Bundle.main.buildVersionNumber {
      if rvn != versionNumber || rbn != buildNumber {
        defaults.setBundle()
        
        showOnBoardingLaunch()
      }
    } else {
      /// Fail safe - we've not been able to find version number/build number
      defaults.setBundle()
      
      showOnBoardingLaunch()
    }
  }
  
  private func showOnBoardingLaunch() {
    guard let ovc = storyboard?.instantiateViewController(withIdentifier: "OnboardingViewController") as? OnboardingViewController else {
      fatalError("Unable to load OnboardingViewController from storyboard.")
    }
    
    navigationController?.pushViewController(ovc, animated: true)
  }
}

extension DetailViewController: CalEntrySelectionDelegate {
  func entrySelected(_ newEntry: CalEntry) {
    entry = newEntry
  }
}
