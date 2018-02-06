//
//  CarouselViewController.swift
//  Shooter Alert
//
//  Created by Akira on 7/25/17.
//  Copyright © 2017 mypc. All rights reserved.
//

import UIKit
import iCarousel

class CarouselViewController: UIViewController, iCarouselDataSource, iCarouselDelegate {

    @IBOutlet weak var carousel: iCarousel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        carousel.type = iCarouselType.rotary
        carousel.reloadData()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    func numberOfItems(in carousel: iCarousel) -> Int {
        return 10
    }
    
    func carousel(_ carousel: iCarousel, viewForItemAt index: Int, reusing view: UIView?) -> UIView {
        var itemView: CustomView
        if (view == nil)
        {
            itemView = CustomView(frame:CGRect(x:0, y:0, width:300, height:400))
        }
        else
        {
            itemView = view as! CustomView;
        }
        
        return itemView
    }
    
    func carousel(_ carousel: iCarousel, valueFor option: iCarouselOption, withDefault value: CGFloat) -> CGFloat {
        switch option {
        case .wrap:
            return 0
        case .spacing:
            return value * 1.2
        case .fadeMax:
            if carousel.type == .custom {
                return 0
            }
            return value
        default:
            return value
        }
    }

}
