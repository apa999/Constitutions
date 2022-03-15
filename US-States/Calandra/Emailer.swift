//
//  Emailer.swift
//  US-States
//
//  Created by Anthony Abbott on 15/03/2022.
//

import MessageUI

class Emailer:  NSObject, MFMailComposeViewControllerDelegate
{
  weak var viewController: UIViewController?
  
  
  /**
   - Important:If this function is not present, then the mail will window will not be dismissed
   */
  func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    
    switch (result) {
    case .sent: break
    case .cancelled: break
    case .failed: break
    default: break
    }
    
    viewController?.dismiss(animated: true, completion: nil)
  }
  
  func sendEmail(emailAddress: String) {
    if MFMailComposeViewController.canSendMail() {
      let mail = MFMailComposeViewController()
      mail.mailComposeDelegate = self
      
      mail.setToRecipients([emailAddress])
      
      viewController?.present(mail, animated: true)
    } else {
      NSLog("Mail is not allowed on this device (MFMailComposeViewController.canSendMail() returns False)")
    }
  }
  
  func sendEmail(entry: CalEntry) {
    if MFMailComposeViewController.canSendMail() {
      let mail = MFMailComposeViewController()
      mail.mailComposeDelegate = self
      
      let title = calDocument.getTitleFor(entry: entry)
        
      mail.title = title
      mail.setSubject(title)
      
      if let text = entry.page?.getTextForDisplay() {
        mail.setMessageBody(text, isHTML: false)
      }
      
      viewController?.present(mail, animated: true)
    } else {
      NSLog("Mail is not allowed on this device (MFMailComposeViewController.canSendMail() returns False)")
    }
  }
  
 
}
