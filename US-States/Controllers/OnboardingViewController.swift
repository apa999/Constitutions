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
    return 7
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
    Tired of being angry?  Tired of holding on to a grudge about something that happened years ago?
    
    Let's get rid of these crippling grudges that are doing us far more harm then they are anyone else.
    
    """
    
    let versionLabel = "Version: \(version), Build: \(build)"
  
    let pageText1 = """
    Start by giving the grudge a name. Next, imagine that whatever it was, it happened to your best friend.
    
    Describe it in as much detail as you can. Where were you? Who was there? What was the weather like?
    
    You may find it useful to read it out aloud.
    """
    
    let pageText2 = """
    Pretend that your best friend told you about a grudge she's been holding on to for years.
    
    What advice would you give her?
    
    Would you tell her that it's time to move on, time to let go?
    """

    let pageText3 = """
    On a scale of 0 to 10, how bad was the slight?
    
    When did this awful thing happen? How old was your friend at the time?
    
    Is it really worth upsetting yourself so much about it, or holding on to something that happened decades ago?
    """

    let pageText4 = """
    What about me? Have I ever done something as bad, or even worse? The chances are that I have.
    
    What about the other guy? Was he really that bad?
    """

    let pageText5 = """
    Once you've written down all the gory details, it's now time for you to banish the blasted grudge once and for all.

    Click the button, and set yourself free.
    """

    let pageText6 = """
    This help screen is displayed the first time the app is installed. It can be displayed at any time by long-pressing in the home screen.

    Thereafter, long-pressing on any screen will show screen specific help.
    """

      
    
    return [
      OnboardingItemInfo(informationImage: mainImage,
                         title: "Grudge Buster",
                         description: "\(pageText0)\n\(versionLabel)",
                         pageIcon: iconImage,
                         color: #colorLiteral(red: 0, green: 0.4196325541, blue: 0.6542028785, alpha: 1) ,
                         titleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) ,
                         descriptionColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
                         titleFont: titleFont,
                         descriptionFont: descFont),
      
      OnboardingItemInfo(informationImage: mainImage,
                         title: "How it works",
                         description: pageText1,
                         pageIcon: iconImage,
                         color: #colorLiteral(red: 0, green: 0.4196325541, blue: 0.6542028785, alpha: 1) ,
                         titleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) ,
                         descriptionColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
                         titleFont: titleFont,
                         descriptionFont: descFont),

      OnboardingItemInfo(informationImage: mainImage,
                         title: "What would your best friend say?",
                         description: pageText2,
                         pageIcon: iconImage,
                         color: #colorLiteral(red: 0, green: 0.4196325541, blue: 0.6542028785, alpha: 1) ,
                         titleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) ,
                         descriptionColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
                         titleFont: titleFont,
                         descriptionFont: descFont),

      OnboardingItemInfo(informationImage: mainImage,
                         title: "Just how bad was it?",
                         description: pageText3,
                         pageIcon: iconImage,
                         color: #colorLiteral(red: 0, green: 0.4196325541, blue: 0.6542028785, alpha: 1) ,
                         titleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) ,
                         descriptionColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
                         titleFont: titleFont,
                         descriptionFont: descFont),

      OnboardingItemInfo(informationImage: mainImage,
                         title: "Me too?",
                         description: pageText4,
                         pageIcon: iconImage,
                         color: #colorLiteral(red: 0, green: 0.4196325541, blue: 0.6542028785, alpha: 1) ,
                         titleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) ,
                         descriptionColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
                         titleFont: titleFont,
                         descriptionFont: descFont),

      OnboardingItemInfo(informationImage: mainImage,
                         title: "Bin that grudge",
                         description: pageText5,
                         pageIcon: iconImage,
                         color: #colorLiteral(red: 0, green: 0.4196325541, blue: 0.6542028785, alpha: 1) ,
                         titleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) ,
                         descriptionColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
                         titleFont: titleFont,
                         descriptionFont: descFont),

      OnboardingItemInfo(informationImage: mainImage,
                         title: "Housekeeping",
                         description: pageText6,
                         pageIcon: iconImage,
                         color: #colorLiteral(red: 0, green: 0.4196325541, blue: 0.6542028785, alpha: 1) ,
                         titleColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1) ,
                         descriptionColor: #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1),
                         titleFont: titleFont,
                         descriptionFont: descFont)
    ][index]
  }
}
