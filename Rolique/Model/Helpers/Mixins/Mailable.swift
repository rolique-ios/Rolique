//
//  Mailable.swift
//  Rolique
//
//  Created by Maks on 9/23/19.
//  Copyright © 2019 Rolique. All rights reserved.
//

import UIKit
import Utils
import MessageUI

protocol Mailable: class {
  func sendEmail(to: [String], body: String)
  func openMailApp()
  var from: UIViewController? { get }
}

extension UIViewController: MFMailComposeViewControllerDelegate {
  public func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
    controller.dismiss(animated: true)
  }
}

extension Mailable where Self: UIViewController {
  var from: UIViewController? { return self }
  func sendEmail(to recipients: [String], body: String = "") {
    guard MFMailComposeViewController.canSendMail() else {
      Spitter.showOkAlert("Cannot open Mail app", viewController: self)
      return
    }
    
    let mail = MFMailComposeViewController()
    mail.mailComposeDelegate = self
    mail.setToRecipients(recipients)
    mail.setMessageBody(body, isHTML: true)
    
    from?.present(mail, animated: true)
  }
  
  func openMailApp() {
    if let url = URL(string: "mailto:") {
      UIApplication.shared.open(url)
    }
  }
}
