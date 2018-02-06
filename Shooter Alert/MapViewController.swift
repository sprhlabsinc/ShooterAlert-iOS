//
//  MapViewController.swift
//  Shooter Alert
//
//  Created by Akira on 7/4/17.
//  Copyright © 2017 mypc. All rights reserved.
//

import UIKit
import GoogleMaps
import ScalingCarousel

protocol ScaleCellDelegate {
    func url1ButtonClicked(url:String)
    func url2ButtonClicked(url:String)
    func otherEventClicked()
}

class Cell: ScalingCarouselCell {
    
    var shootInfo: ShootModel? {
        didSet {
            if let shoot = shootInfo {
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "yyyy-MM-dd"
                let date: Date = dateFormatter.date(from: shoot.incident_date)!
                dateFormatter.dateFormat = "MMM dd, yyyy"
                
                self.cityLabel.text = shoot.city
                self.dateLabel.text = dateFormatter.string(from: date)
                self.killsLabel.text = String.init(format: "%d", shoot.killed)
                self.injuriesLabel.text = String.init(format: "%d", shoot.injured)
                
                self.url1But.setTitle(shoot.url1.replacingOccurrences(of: "http://", with: "").replacingOccurrences(of: "https://", with: ""), for: UIControlState.normal)
                self.url2But.setTitle(shoot.url2.replacingOccurrences(of: "http://", with: "").replacingOccurrences(of: "https://", with: ""), for: UIControlState.normal)

                mainView.layer.cornerRadius = 2
                //                let radius: CGFloat = mainView.frame.width  / 2.0 //change it to .height if you need spread for height
                //                let radius1: CGFloat = mainView.frame.height / 2.0 //change it to .height if you need spread for height
                let shadowPath = UIBezierPath(rect: CGRect(x: 0, y: 0, width: mainView.frame.width, height: mainView.frame.height))
                //                mainView.layer.cornerRadius = 2
                mainView.layer.shadowColor = UIColor.gray.cgColor
                mainView.layer.shadowOffset = CGSize(width: 0.5, height: 0.5)  //Here you control x and y
                mainView.layer.shadowOpacity = 0.5
                mainView.layer.shadowRadius = 5.0 //Here your control your blur
                mainView.layer.masksToBounds =  true
                mainView.layer.shadowPath = shadowPath.cgPath
            }
        }
    }

    var delegate : ScaleCellDelegate?
    
    @IBOutlet weak var url2But: UIButton!
    @IBOutlet weak var url1But: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cityLabel: UILabel!
    @IBOutlet weak var injuriesLabel: UILabel!
    @IBOutlet weak var killsLabel: UILabel!
    
    @IBAction func onUrl1But(_ sender: Any) {
        delegate?.url1ButtonClicked(url: (shootInfo?.url1)!)
    }
    @IBAction func onUrl2But(_ sender: Any) {
        delegate?.url2ButtonClicked(url: (shootInfo?.url2)!)
    }
    @IBAction func OtherEventBut(_ sender: Any) {
        delegate?.otherEventClicked()
    }
}

class MapViewController: UIViewController, GMSMapViewDelegate {

    @IBOutlet weak var mapView: GMSMapView!
    @IBOutlet weak var wrapView: UIView!
    @IBOutlet weak var carouselView: ScalingCarouselView!
    
    var mShootArray: Array<ShootModel> = []
    var mPosition: Int = 0
    var mFirst: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()

        mapView.isMyLocationEnabled = true
        mapView.delegate = self
        mapView.settings.myLocationButton = true
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(slideDown(gestureRecognizer:)))
        swipeDown.direction = .down
        carouselView.addGestureRecognizer(swipeDown)
    }
    
    func slideDown(gestureRecognizer: UISwipeGestureRecognizer) {
        self.wrapView.frame = self.view.frame
        self.wrapView.alpha = 1
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.wrapView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: 0, height: 0)
            self.wrapView.alpha = 0
        }, completion: { finished in
            self.wrapView.isHidden = true
        })
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
//        self.onCloseBut((Any).self);
        self.wrapView.isHidden = true
        loadMarkers();
    }
    func loadMarkers() {
        let shootArray = AppManager.sharedInstance.shootArray
        
        if shootArray.count == 0 {
            let delayInSeconds = 1.0
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayInSeconds) {
                
                self.loadMarkers();
            }
        }
        else {
            mapView.clear()
            var bounds = GMSCoordinateBounds()
            
            for i in 0..<shootArray.count {
                let shoot = shootArray[i]
                
                let marker = GMSMarker()
                marker.position = CLLocationCoordinate2D(latitude: shoot.latitude, longitude: shoot.longitude)
                marker.title = String.init(format: "%@ %@ %@", shoot.address, shoot.city, shoot.state)
                marker.icon = UIImage(named: "mapicon")
                marker.map = mapView
                marker.userData = shoot
                
                bounds = bounds.includingCoordinate(marker.position)
            }
            if !mFirst && shootArray.count != 0 {
                mapView.animate(with: GMSCameraUpdate.fit(bounds))
                mFirst = true
            }
        }
    }
    
    func mapView(_ mapView: GMSMapView, didTap marker: GMSMarker) -> Bool {
        let sel_shoot = marker.userData as! ShootModel
        let coordinate1 = CLLocation(latitude: sel_shoot.latitude, longitude: sel_shoot.longitude)
        mShootArray.removeAll(keepingCapacity: false)
        
        sel_shoot.distance = 0;
        sel_shoot.inside = true;
        mShootArray.append(sel_shoot)
        for i in 0..<AppManager.sharedInstance.shootArray.count {
            let shoot = AppManager.sharedInstance.shootArray[i]
            if shoot.id == sel_shoot.id { continue }
            shoot.inside = false
            
            let coordinate2 = CLLocation(latitude: shoot.latitude, longitude: shoot.longitude)
            let distance = coordinate1.distance(from: coordinate2) * 0.000621371
            
            if distance <= 50 {
                shoot.inside = true
            }
            shoot.distance = distance
            mShootArray.append(shoot)
        }
        mShootArray.sort(by: { (first: ShootModel, second: ShootModel) -> Bool in
            first.distance < second.distance
        })
        var j: Int = 0
        for i in (0..<mShootArray.count) {
            let shoot = mShootArray[i]
            if j >= 5 && shoot.inside == false {
                for _ in (i..<mShootArray.count) {
                    mShootArray.removeLast()
                }
                break
            }
            j += 1
        }
        
        let target = CLLocationCoordinate2D(latitude: sel_shoot.latitude, longitude: sel_shoot.longitude)
        //mapView.camera = GMSCameraPosition.camera(withTarget: target, zoom: 9)
        mapView.animate(toLocation: target)
        mapView.animate(toZoom: 9)
        
        carouselView.reloadData()
        mPosition = 0
        
        self.carouselView.invisibleScrollView.contentOffset.x = 1
        self.wrapView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: 0, height: 0)
        self.wrapView.isHidden = false
        
        UIView.animate(withDuration: 0, delay: 0, options: .curveEaseInOut, animations: {
            
        }, completion: { finished in
            self.wrapView.alpha = 0
            self.carouselView.invisibleScrollView.contentOffset.x = 0
            UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
                self.wrapView.frame = self.view.frame
                self.wrapView.alpha = 1
            }, completion: { finished in
                
            })
        })
        
        return true;
    }
    
    @IBAction func onShareBut(_ sender: Any) {
        let shoot = mShootArray[mPosition]
        let share_txt = String.init(format: "Shooter Alert: shooting at %@. Read more at %@.", shoot.address, shoot.url2)
        let textToShare = [ share_txt ]
        let activityViewController = UIActivityViewController(activityItems: textToShare, applicationActivities: nil)
        activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
        
        // exclude some activity types from the list (optional)
        activityViewController.excludedActivityTypes = [ UIActivityType.airDrop ]
        
        // present the view controller
        self.present(activityViewController, animated: true, completion: nil)
    }

    @IBAction func onCloseBut(_ sender: Any) {
        self.wrapView.frame = self.view.frame
        self.wrapView.alpha = 1
        UIView.animate(withDuration: 0.5, delay: 0, options: .curveEaseInOut, animations: {
            self.wrapView.frame = CGRect(x: 0, y: self.view.frame.size.height, width: 0, height: 0)
            self.wrapView.alpha = 0
        }, completion: { finished in
            self.wrapView.isHidden = true
        })
    }
}

typealias CarouselDatasource = MapViewController
extension CarouselDatasource: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return mShootArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "carouselCell", for: indexPath)
        
        if let scalingCell = cell as? Cell {
            let shoot = mShootArray[indexPath.row]
            
            scalingCell.delegate = self
            scalingCell.shootInfo = shoot
        }
        
        return cell
    }
}

typealias CarouselDelegate = MapViewController
extension MapViewController: UICollectionViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        carouselView.didScroll()
        
        mPosition = Int(carouselView.invisibleScrollView.contentOffset.x / carouselView.invisibleScrollView.frame.size.width)
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let shoot = mShootArray[mPosition]
        let target = CLLocationCoordinate2D(latitude: shoot.latitude, longitude: shoot.longitude)
        //mapView.camera = GMSCameraPosition.camera(withTarget: target, zoom: 9)
        mapView.animate(toLocation: target)
        mapView.animate(toZoom: 9)
    }
}

extension MapViewController: ScaleCellDelegate{
    func url1ButtonClicked(url:String) {
        if url != "" {
            let url = URL(string: url)!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func url2ButtonClicked(url:String) {
        if url != "" {
            let url = URL(string: url)!
            if #available(iOS 10.0, *) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            } else {
                UIApplication.shared.openURL(url)
            }
        }
    }
    
    func otherEventClicked() {
        if mShootArray.count > mPosition + 1 {
            
            self.carouselView.invisibleScrollView.setContentOffset(CGPoint(x: self.carouselView.invisibleScrollView.contentOffset.x + self.carouselView.invisibleScrollView.frame.size.width, y: 0), animated: true)
            let shoot = self.mShootArray[mPosition + 1]
            let target = CLLocationCoordinate2D(latitude: shoot.latitude, longitude: shoot.longitude)
            //self.mapView.camera = GMSCameraPosition.camera(withTarget: target, zoom: 9)
            self.mapView.animate(toLocation: target)
            self.mapView.animate(toZoom: 9)


//            
//            DispatchQueue.main.async {
//                UIView.animate(withDuration: 0, delay: 0.3, options: UIViewAnimationOptions.curveEaseOut, animations: {
//                    
//             //       self.carouselView.invisibleScrollView.contentOffset.x += self.carouselView.invisibleScrollView.frame.size.width
//                    
//                    let shoot = self.mShootArray[self.mPosition ]
//                    let target = CLLocationCoordinate2D(latitude: shoot.latitude, longitude: shoot.longitude)
//                    //self.mapView.camera = GMSCameraPosition.camera(withTarget: target, zoom: 9)
//                    self.mapView.animate(toLocation: target)
//                    self.mapView.animate(toZoom: 9)
//                }, completion: nil)
//            }
        }
    }
}
