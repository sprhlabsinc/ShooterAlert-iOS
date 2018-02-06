//
//  SettingViewController.swift
//  Shooter Alert
//
//  Created by Akira on 7/4/17.
//  Copyright © 2017 mypc. All rights reserved.
//

import UIKit
import MessageUI

class SettingViewController: UIViewController, MFMailComposeViewControllerDelegate {

    @IBOutlet weak var notificationSwich: UISwitch!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func onFeedbackBut(_ sender: Any) {
        
        let mailComposeViewController = configuredMailComposeViewController()
        if MFMailComposeViewController.canSendMail() {
            self.present(mailComposeViewController, animated: true, completion: nil)
        } else {
            self.showSendMailErrorAlert()
        }
    }
    
    func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["alex@infusionti.com"])
        mailComposerVC.setSubject("Feedback")
        mailComposerVC.setMessageBody("Dear ...,", isHTML: false)
        
        return mailComposerVC
    }
    
    func showSendMailErrorAlert() {
        
        let alert = UIAlertController(title: "Could Not Send Email", message:"Your device could not send e-mail.  Please check e-mail configuration and try again.", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in })
        self.present(alert, animated: true){}
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
    @IBAction func onWriteReviewBut(_ sender: Any) {
        rateApp(appId: "id1226245555") { success in
            print("RateApp \(success)")
        }
    }
    
    @IBAction func onChangeStatus(_ sender: Any) {
        AppManager.sharedInstance.setNotificationSetting(notification: !notificationSwich.isOn)
    }
    
    func rateApp(appId: String, completion: @escaping ((_ success: Bool)->())) {
        guard let url = URL(string : "itms-apps://itunes.apple.com/app/" + appId) else {
            completion(false)
            return
        }
        guard #available(iOS 10, *) else {
            completion(UIApplication.shared.openURL(url))
            return
        }
        UIApplication.shared.open(url, options: [:], completionHandler: completion)
    }
}

extension NSObject {
    func getNumberFromData(data:Any) -> Int {
        if let strData = data as? String {
            if(strData == ""){
                return 0
            }else{
                return Int("\(String(describing: strData))")!
            }
            
        }
        else if let strData = data as? Int {
            return strData
        }else{
            return 0
        }
    }
    func getDoubleFromData(data:Any) -> Double {
        if let strData = data as? String {
            if(strData == ""){
                return 0
            }else{
                return Double("\(String(describing: strData))")!
            }
        }
        else if let strData = data as? Double {
            return strData
        }else{
            return 0
        }
    }
    func getStringFromData(data:Any) -> String {
        if let strData = data as? String {
            return String(describing: strData)
        }
        else if let strData = data as? Int {
            return String(strData)
        }else{
            return ""
        }
    }
    
}
