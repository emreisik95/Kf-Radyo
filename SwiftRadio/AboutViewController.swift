//
//  AboutViewController.swift
//  Swift Radio
//
//  Created by Matthew Fecher on 7/9/15.
//  Copyright (c) 2015 MatthewFecher.com. All rights reserved.
//
// Last update 3/4/2019 by Emre Işık

import UIKit
import MessageUI

class AboutViewController: UIViewController {
    
    //*****************************************************************
    // MARK: - ViewDidLoad
    //*****************************************************************
    @IBOutlet weak var themeBackground: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        themeBackground.image = Theme.backgroundImage
    }
   
    //*****************************************************************
    // MARK: - IBActions
    //*****************************************************************
    
    @IBAction func emailButtonDidTouch(_ sender: UIButton) {
        
        // Use your own email address & subject
        let receipients = ["emre@emreisik.com.tr"]
        let subject = "Kafa Radyo Uygulaması aracılığıyla gönderildi"
        let messageBody = ""
        
        let configuredMailComposeViewController = configureMailComposeViewController(recepients: receipients, subject: subject, messageBody: messageBody)
        
        if canSendMail() {
            present(configuredMailComposeViewController, animated: true, completion: nil)
        } else {
            showSendMailErrorAlert()
        }
    }
    
    @IBAction func websiteButtonDidTouch(_ sender: UIButton) {
        // Use your own website here
        guard let url = URL(string: "https://emreisik.com.tr") else { return }
        if #available(iOS 10.0, *) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        } else {
            // Fallback on earlier versions
        }
    }

  }

//*****************************************************************
// MARK: - MFMailComposeViewController Delegate
//*****************************************************************

extension AboutViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    func canSendMail() -> Bool {
        return MFMailComposeViewController.canSendMail()
    }
    
    func configureMailComposeViewController(recepients: [String], subject: String, messageBody: String) -> MFMailComposeViewController {
        
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self
        
        mailComposerVC.setToRecipients(recepients)
        mailComposerVC.setSubject(subject)
        mailComposerVC.setMessageBody(messageBody, isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertController(title: "Gönderilemedi", message: "Lütfen cihazınızın mail ayarlarını kontrol edip tekrar deneyin.", preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Tamam", style: .cancel, handler: nil)

        sendMailErrorAlert.addAction(cancelAction)
        present(sendMailErrorAlert, animated: true, completion: nil)
    }
}
