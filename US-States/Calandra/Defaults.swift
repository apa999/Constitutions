//
//  Defaults.swift
//  US-States
//
//  Created by Anthony Abbott on 13/03/2022.
//

import Foundation

class Defaults {
  var defaults         = UserDefaults.standard
  var bundleIdentifier : NSString!
  var userName         : NSString!
  var homeDirectory    : NSString!
  var keys             : CFArray!
  
  
  //MARK:- Static func
  static func exists(key: String) -> Bool {
    return UserDefaults.standard.object(forKey: key) != nil
  }

  typealias VersionInformation = (version: String, build: String)
  
  struct Keys {
    static let ProVersionKey    = "ProVersionKey"
    static let RevenueCatUser   = "RevenueCatUser"
    static let SearchFromLatest = "SearchFromLatest"
    static let NumberOfMemories = "NumberOfMemories"
    static let NumberOfGoes     = "NumberOfGoes"        // Number of times the user has used the app on this device
  }
  
  //MARK-: Set up
  
  init() {
    bundleIdentifier = NSString(string: Bundle.main.bundleIdentifier!)
    userName         = NSString(string: NSUserName())
    homeDirectory    = NSString(string: NSHomeDirectory())
    keys             = CFPreferencesCopyKeyList(kCFPreferencesCurrentApplication, kCFPreferencesCurrentUser, homeDirectory)
  }
  
 
  
  func flush() {
    defaults.synchronize()
  }
  
  //MARK:- Bundle
  func getBundle() -> VersionInformation {
    var versionNumber = ""
    var buildNumber   = ""
    let f             = ""
    
    let k = "releaseVersionNumber" as CFString
    
    if let v = CFPreferencesCopyAppValue(k, bundleIdentifier) {
      versionNumber = v as! String
    } else {
      CFPreferencesSetAppValue(k, f as Any as CFPropertyList , kCFPreferencesCurrentApplication)
      
      versionNumber = ""
    }
    
    let l = "releaseBuildNumber" as CFString
    
    if let v = CFPreferencesCopyAppValue(l, bundleIdentifier) {
      buildNumber = v as! String
    } else {
      CFPreferencesSetAppValue(l, f as Any as CFPropertyList , kCFPreferencesCurrentApplication)
      
      buildNumber = ""
    }
    
    let versionInformation = VersionInformation(versionNumber, buildNumber)
    
    return(versionInformation)
  }
  
  func setBundle() {
    let rvn = Bundle.main.releaseVersionNumber
    let rbn = Bundle.main.buildVersionNumber
    
    let rvK = "releaseVersionNumber" as CFString
    let rbK = "releaseBuildNumber"  as CFString
    
    CFPreferencesSetAppValue(rvK, rvn as AnyObject, kCFPreferencesCurrentApplication)
    CFPreferencesSetAppValue(rbK, rbn as AnyObject, kCFPreferencesCurrentApplication)
  }
  
  
  //MARK:- Always Display Onboarding
  func getAlwaysDisplayOnboardingValue() -> Bool {
    var alwaysDisplayOnboarding = false
    let f                       = false as CFBoolean
    
    let k = "AlwaysDisplayOnboarding" as CFString
    
    if let v = CFPreferencesCopyAppValue(k, bundleIdentifier) {
      alwaysDisplayOnboarding = v as! Bool
    } else {
      CFPreferencesSetAppValue(k, f, kCFPreferencesCurrentApplication)
      
      alwaysDisplayOnboarding = false
    }
    
    return alwaysDisplayOnboarding
  }
  
  func setAlwaysDisplayOnboardingValue(alwaysDisplayOnboarding: Bool) {
    let v = alwaysDisplayOnboarding as CFBoolean
    
    let k = "AlwaysDisplayOnboarding" as CFString
    
    CFPreferencesSetAppValue(k, v, kCFPreferencesCurrentApplication)
  }
  
  func getLastSelectDate() -> Date {
    let lastSlectDate = UserDefaults.standard.double(forKey: "lastSelectDate")
 
    if lastSlectDate != 0 {
      return Date(timeIntervalSince1970: lastSlectDate)
    } else {
      return Date().yesterday
    }
  }
  
  func setLastSelectDate(lastSelectDate: Date) {
    UserDefaults.standard.set(lastSelectDate.timeIntervalSince1970, forKey: "lastSelectDate")
  }
  
 
}

//MARK:- Extensions and Structs


