//
//  AppDelegate.swift
//  Shooter Alert
//
//  Created by Akira on 7/3/17.
//  Copyright © 2017 mypc. All rights reserved.
//

import UIKit
import GoogleMaps
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    var window: UIWindow?
    
    func createMenuView() {
        
        // create viewController code...
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        
        let mainViewController = storyboard.instantiateViewController(withIdentifier: "HomeViewController") as! HomeViewController
        
        //UINavigationBar.appearance().tintColor = KColorBasic
        self.window?.backgroundColor = UIColor(red: 236.0, green: 238.0, blue: 241.0, alpha: 1.0)
        self.window?.rootViewController = mainViewController
        self.window?.makeKeyAndVisible()
    }
    
    func pushNotification() {
        let center  = UNUserNotificationCenter.current()
        center.delegate = self
        // set the type as sound or badge
        center.requestAuthorization(options: [.sound,.alert,.badge]) { (granted, error) in
            // Enable or disable features based on authorization
            
        }
        UIApplication.shared.registerForRemoteNotifications()
    }
    
    func getMetadata() {
        let date = Date()
        let calendar = Calendar.current
        let year = calendar.component(.year, from: date)
        
        //MBProgressHUD.showAdded(to: self.view, animated: true)
        
        let params = [ "year": year ]
        
        NetworkManager.sharedClient.getRequest(tag: "metadata.php", parameters: params) { (error, result) in
            //MBProgressHUD.hide(for: self.view, animated: true);
            if (error != "") {
                //self.showAlert(withTitle: "Error", message: error)
            }
            else{
                AppManager.sharedInstance.shootArray.removeAll(keepingCapacity: false)
                
                var items = result.value(forKey: "shoot") as! Array<Dictionary<String, AnyObject>>
                
                for i in 0 ..< items.count {
                    
                    let item = (items[i] as Dictionary<String, AnyObject>)
                    
                    let shootInfo = ShootModel()
                    shootInfo.initWithDictionary(data: item)
                    AppManager.sharedInstance.shootArray.append(shootInfo)
                }
            }
        }
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        UIApplication.shared.isStatusBarHidden = false
        GMSServices.provideAPIKey("AIzaSyAMK9lFbb4QVlLIlqhuZd0hkseiWq3VUcM")
        
        getMetadata();
        
        if (AppManager.sharedInstance.getFirstTime()) {
            createMenuView()
        }
        return true
    }
    
    func application(_ application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        var token = ""
        for i in 0..<deviceToken.count {
            token += String(format: "%02.2hhx", arguments: [deviceToken[i]])
        }
        
        print("Registration succeeded!")
        print("Token: ", token)
    }
    
    func application(_ application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("Registration failed!")
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter,  willPresent notification: UNNotification, withCompletionHandler   completionHandler: @escaping (_ options:   UNNotificationPresentationOptions) -> Void) {
        print("Handle push from foreground")
        // custom code to handle push while app is in the foreground
        print("\(notification.request.content.userInfo)")
        
        getMetadata()
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        print("Handle push from background or closed")
        // if you set a member variable in didReceiveRemoteNotification, you  will know if this is from closed or background
        print("\(response.notification.request.content.userInfo)")
        
        getMetadata()
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

