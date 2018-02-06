//
//  HomeViewController.swift
//  Shooter Alert
//
//  Created by Akira on 7/3/17.
//  Copyright © 2017 mypc. All rights reserved.
//

import UIKit
import CarbonKit
import MBProgressHUD
import Alamofire

class HomeViewController: UIViewController {
    
    @IBOutlet weak var toolBar: UIToolbar!

    @IBOutlet weak var contentView: UIView!
    var carbonTabSwipeNavigation:CarbonTabSwipeNavigation?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initPageMenu()
        
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)) {
            statusBar.backgroundColor = UIColor.white
        }
       
        LocationManager.sharedInstance.doLocationTrack()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func initPageMenu() {
        let items = ["Stats", "Map" , "Settings"]
        //carbonTabSwipeNavigation = CarbonTabSwipeNavigation.init(items: items, delegate: self)
        //carbonTabSwipeNavigation?.insert(intoRootViewController: self)
        carbonTabSwipeNavigation = CarbonTabSwipeNavigation.init(items: items, toolBar: self.toolBar, delegate: self)
        carbonTabSwipeNavigation?.insert(intoRootViewController: self, andTargetView: self.contentView);
        
        //Style
      
        carbonTabSwipeNavigation?.toolbar.isTranslucent = false
        carbonTabSwipeNavigation?.toolbar.barTintColor = KColorGrey
        carbonTabSwipeNavigation?.setTabBarHeight(44);
        carbonTabSwipeNavigation?.setIndicatorColor(UIColor.white)
        
        
        let width = self.view.frame.size.width;
        let space = 0.0;
        let w = (Double(width) - 3.0 * space) / 3.0
        carbonTabSwipeNavigation?.setTabExtraWidth(CGFloat(space))
        carbonTabSwipeNavigation?.carbonSegmentedControl?.setWidth(CGFloat(w), forSegmentAt: 0)
        carbonTabSwipeNavigation?.carbonSegmentedControl?.setWidth(CGFloat(w), forSegmentAt: 1)
        carbonTabSwipeNavigation?.carbonSegmentedControl?.setWidth(CGFloat(w), forSegmentAt: 2)

        
        // Custimize segmented control
        carbonTabSwipeNavigation?.setNormalColor(UIColor.lightGray, font: UIFont.boldSystemFont(ofSize: 25))
        carbonTabSwipeNavigation?.setSelectedColor(UIColor.white, font: UIFont.boldSystemFont(ofSize: 25))
        
        carbonTabSwipeNavigation?.currentTabIndex = 1
        carbonTabSwipeNavigation?.pagesScrollView?.isScrollEnabled = false
    }

}
extension HomeViewController: CarbonTabSwipeNavigationDelegate{
    func carbonTabSwipeNavigation(_ carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAt index: UInt) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        switch index {
        case 0:
            return storyboard.instantiateViewController(withIdentifier: "StatsViewController")
        case 1:
            return storyboard.instantiateViewController(withIdentifier: "MapViewController")
        case 2:
            return storyboard.instantiateViewController(withIdentifier: "SettingViewController")
        default:
            return storyboard.instantiateViewController(withIdentifier: "StatsViewController")
        }
    }

}

extension UIViewController {
    func showAlert(withTitle title: String, message: String?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
}
