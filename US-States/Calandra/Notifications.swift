//
//  Notifications.swift
//  StandardLists1
//
//  Created by Anthony Abbott on 10/03/2022.
//

/**
 
 __ To Post __
 NotificationCenter.default.post(name: Notification.Name(Notifications.dataIsLoaded),
                                 object: nil)
 
 __ To Observe __
 NotificationCenter.default.addObserver(self, selector: #selector(myFunc),
                                        name: Notification.Name(Notifications.dataIsLoaded),
                                        object: nil)
 
 
** To Pass Information **
 let imageDataDict:[String: UIImage] = ["image": image]

 // Post a notification
 NotificationCenter.default.post(name: NSNotification.Name(rawValue: "notificationName"), object: nil, userInfo: imageDataDict)

// Register to receive notification in your class
NotificationCenter.default.addObserver(self, selector: #selector(self.showSpinningWheel(_:)), name: NSNotification.Name(rawValue: "notificationName"), object: nil)

// Handle notification
 @objc func showSpinningWheel(_ notification: NSNotification) {
 if let image = notification.userInfo?["image"] as? UIImage {
 // do something with your image
 }
}
 
 */

import Foundation

struct Notifications
{
  static let dataIsLoaded     = "dataIsLoaded"
  static let modeHasChanged   = "modeHasChanged"
  static let completedSearch  = "completedSearch"
  static let firstSearchEntry = "firstSearchEntry"
}
