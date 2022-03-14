//
//  OnboardingViewController.swift
//  US-States
//
//  Created by Anthony Abbott on 13/03/2022.
//

import UIKit
import PaperOnboarding

class OnboardingViewController: UIViewController,
                                  PaperOnboardingDelegate,
                                  PaperOnboardingDataSource {
  var onboarding  : PaperOnboarding?

  var defaults = Defaults()
  
  //MARK:- Life cycle
  override func viewDidLoad() {
    super.viewDidLoad()
    
    title = "Onboarding"
    
    if onboarding == nil {
      pb()
    }
  }
  
  override func viewWillAppear(_ animated: Bool) {
    super.viewWillAppear(animated)
    navigationController?.setNavigationBarHidden(true, animated: animated)
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    navigationController?.setNavigationBarHidden(false, animated: animated)
    self.tabBarController?.tabBar.layer.zPosition = 0
  }
  
  //MARK: Delegates
  func onboardingItemsCount() -> Int {
    return 4
  }
  
  func onboardingWillTransitonToLeaving() {
    self.navigationController?.popViewController(animated: true)
  }
  
  //MARK:- PaperOnboarding
  func pb() {
    onboarding             = PaperOnboarding()
    onboarding!.delegate   = self
    onboarding!.dataSource = self
    
    onboarding!.translatesAutoresizingMaskIntoConstraints = false
    
    view.addSubview(onboarding!)
    
    // add constraints
    for attribute: NSLayoutConstraint.Attribute in [.left, .right, .top, .bottom] {
      let constraint = NSLayoutConstraint(item: onboarding as Any,
                                          attribute: attribute,
                                          relatedBy: .equal,
                                          toItem: view,
                                          attribute: attribute,
                                          multiplier: 1,
                                          constant: 0)
      view.addConstraint(constraint)
    }
  }
  
  func onboardingItem(at index: Int) -> OnboardingItemInfo {
    let mainImage = UIImage(named: "Onboarding1.png")!
    let iconImage = UIImage(named: "Onboarding1.png")!
    
    let titleFontSize : CGFloat = Env.isIpad ? 34.0 : 18.0
    let descFontSize  : CGFloat = Env.isIpad ? 28.0 : 18.0
    
    let titleFont = UIFont.systemFont(ofSize: titleFontSize)
    let descFont  = UIFont.systemFont(ofSize: descFontSize)
    
    let (version,build) = defaults.getBundle()
    
    let pageText0 = """
        Constitutions is a complete list of all the constitutions for the fifty states of America, which is presented in an easy to read and search format.
        
        Constitutions offers complete off-line access, and there is no need for an internet connection.
    """
    
    let versionLabel = "Version: \(version), Build: \(build)"
  
    let pageText1 = """
       The user can browse the provisions of the constitution by selecting from the list, or by swiping left and right in the detail screen.

       The user can search all the documents using the search option, (top right of the detail screen), and the matched words are high-lighted.
    """
    
    let pageText2 = """
    The user can select sections and email the sections, either in plain text or as an xml document.

    """

    let pageText3 = """
        This onboarding screen is shown the first time that the app is installed or reinstalled and may be seen at any time optionally by long-pressing in the detail screen.
    """

    
    return [
      OnboardingItemInfo(informationImage: mainImage,
                         title: "Constitutions",
                         description: "\(pageText0)\n\(versionLabel)",
                         pageIcon: iconImage,
                         color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) ,
                         titleColor: #colorLiteral(red: 0.1215686277, green: 0.01176470611, blue: 0.4235294163, alpha: 1) ,
                         descriptionColor: #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1),
                         titleFont: titleFont,
                         descriptionFont: descFont),
      
      OnboardingItemInfo(informationImage: mainImage,
                         title: "Browsing",
                         description: pageText1,
                         pageIcon: iconImage,
                         color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) ,
                         titleColor: #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1) ,
                         descriptionColor: #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1),
                         titleFont: titleFont,
                         descriptionFont: descFont),

      OnboardingItemInfo(informationImage: mainImage,
                         title: "Emails and downloads",
                         description: pageText2,
                         pageIcon: iconImage,
                         color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) ,
                         titleColor: #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1) ,
                         descriptionColor: #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1),
                         titleFont: titleFont,
                         descriptionFont: descFont),

      OnboardingItemInfo(informationImage: mainImage,
                         title: "Onboarding",
                         description: pageText3,
                         pageIcon: iconImage,
                         color: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) ,
                         titleColor: #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1) ,
                         descriptionColor: #colorLiteral(red: 0.09019608051, green: 0, blue: 0.3019607961, alpha: 1),
                         titleFont: titleFont,
                         descriptionFont: descFont)

     
    ][index]
  }
}
