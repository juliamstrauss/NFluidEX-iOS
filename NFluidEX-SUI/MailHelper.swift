//
//  MailView.swift
//  NFluidEX-SUI
//
//  Created by Julia Strauss on 6/30/22.
//

import MessageUI
import Foundation

class MailHelper: NSObject, MFMailComposeViewControllerDelegate {
   
    public static let shared = MailHelper()
     private override init() {
         //
     }
     
     func sendEmail(subject:String, body:String, to:String){
         if !MFMailComposeViewController.canSendMail() {
             print("No mail account found")
             // Todo: Add a way to show banner to user about no mail app found or configured
             //Utilities.showErrorBanner(title: "No mail account found", subtitle: "Please setup a mail account")
             return //EXIT
         }
         
         let picker = MFMailComposeViewController()
         
         picker.setSubject(subject)
         picker.setMessageBody(body, isHTML: true)
         picker.setToRecipients([to])
         picker.mailComposeDelegate = self
         
         MailHelper.getRootViewController()?.present(picker, animated: true, completion: nil)
     }
     
     func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
         MailHelper.getRootViewController()?.dismiss(animated: true, completion: nil)
     }
     
    //might have to completely redo - we don't have view controllers!!!
     static func getRootViewController() -> UIViewController? {
         UIApplication.shared.windows.first?.rootViewController
     }
    
}

