//
//  WelcomeViewController.swift
//  Shooter Alert
//
//  Created by Akira on 7/3/17.
//  Copyright © 2017 mypc. All rights reserved.
//

import UIKit
import CoreLocation

class WelcomeViewController: UIViewController, UIScrollViewDelegate{
    
    @IBOutlet var scrollView: UIScrollView!
    @IBOutlet var pageControl: UIPageControl!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.edgesForExtendedLayout = []
        
        self.scrollView.frame = CGRect(x:0, y:0, width:self.view.frame.width, height:self.view.frame.height)
        let scrollViewWidth:CGFloat = self.scrollView.frame.width
        let scrollViewHeight:CGFloat = self.scrollView.frame.height
        
        let imgOne = UIImageView(frame: CGRect(x:0, y:0,width:scrollViewWidth, height:scrollViewHeight))
        imgOne.image = UIImage(named: "slide1")
        let imgTwo = UIImageView(frame: CGRect(x:scrollViewWidth, y:0,width:scrollViewWidth, height:scrollViewHeight))
        imgTwo.image = UIImage(named: "slide2")
        let imgThree = UIImageView(frame: CGRect(x:scrollViewWidth*2, y:0,width:scrollViewWidth, height:scrollViewHeight))
        imgThree.image = UIImage(named: "slide3")
        
        imgOne.contentMode = .scaleAspectFill
        imgTwo.contentMode = .scaleAspectFill
        imgThree.contentMode = .scaleAspectFill
        
        self.scrollView.addSubview(imgOne)
        self.scrollView.addSubview(imgTwo)
        self.scrollView.addSubview(imgThree)
        //4
        self.scrollView.contentSize = CGSize(width:self.scrollView.frame.width * 3, height:self.scrollView.frame.height)
        self.scrollView.delegate = self
        self.pageControl.currentPage = 0
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    func moveToNextPage (){
        
        let pageWidth:CGFloat = self.scrollView.frame.width
        let maxWidth:CGFloat = pageWidth * 3
        let contentOffset:CGFloat = self.scrollView.contentOffset.x
        
        let slideToX = contentOffset + pageWidth
        
        if  (contentOffset + pageWidth == maxWidth) {
            AppManager.sharedInstance.setFirstTime(isfirst: true)
            
            if CLLocationManager.locationServicesEnabled() {
                if CLLocationManager.authorizationStatus() == .denied {
                    let alertController = UIAlertController (title: "Allow \"Shooter Alert\" to access your location even when you are not using the app?", message: "This app requires location access to function property", preferredStyle: .alert)
                    
                    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                print("Settings opened: \(success)") // Prints true
                            })
                        }
                    }
                    alertController.addAction(settingsAction)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    present(alertController, animated: true, completion: nil)
                }
                else if CLLocationManager.authorizationStatus() == .notDetermined || CLLocationManager.authorizationStatus() == .restricted {
                    LocationManager.sharedInstance.doLocationTrack()
                }
            }
        }
        else if (contentOffset == 0) {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            appDelegate.pushNotification()
        }
        
        DispatchQueue.main.async {
            UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions.curveLinear, animations: {
                self.scrollView.scrollRectToVisible(CGRect(x:slideToX, y:0, width:pageWidth, height:self.scrollView.frame.height), animated: false)
            }, completion: {
                (value: Bool) in
                self.checkCurrentImage()
            })
        }
    }
    
    func checkCurrentImage()
    {
        let pageWidth:CGFloat = scrollView.frame.width
        let currentPage:CGFloat = floor((scrollView.contentOffset.x-pageWidth/2)/pageWidth)+1

        self.pageControl?.currentPage = Int(currentPage)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        checkCurrentImage()
    }
    
    @IBAction func onCloseBut(_ sender: Any) {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        appDelegate.createMenuView()
    }
   
    @IBAction func onNextBut(_ sender: Any) {
        moveToNextPage()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

    }
}

