//
//  styles.swift
//  KaFa Radio
//
//  Created by Emre Işık on 7.03.2019.
//  Copyright © 2019 emreisik.com.tr. All rights reserved.
//

import Foundation
import UIKit

struct Theme {
    
    static var backgroundColor:UIColor?
    static var nowPlayColor:UIColor?
    static var backgroundImage:UIImage?
    static var backgroundImageView:UIImageView?


    static public func defaultTheme() {
        backgroundColor = UIColor.init(red: 251/255, green: 94/255, blue: 47/255, alpha: 1)
        nowPlayColor = UIColor.init(red: 195/255, green: 40/255, blue: 45/255, alpha: 1)
        backgroundImage = UIImage(named: "background")
        backgroundImageView = UIImageView(image: backgroundImage)
        update()
    }
    static public func darkTheme() {
        backgroundColor = .black
        nowPlayColor = .black
        backgroundImage = UIImage(named: "background2")
        backgroundImageView = UIImageView(image: backgroundImage)
        update()
    }
    static public func pinkTheme() {
        backgroundColor = UIColor.init(red: 200/255, green: 170/255, blue: 196/255, alpha: 1)
        nowPlayColor = UIColor.init(red: 192/255, green: 141/255, blue: 96/255, alpha: 1)
        backgroundImage = UIImage(named: "background3")
        backgroundImageView = UIImageView(image: backgroundImage)
        update()
    }
    static public func update(){
        let windows = UIApplication.shared.windows
        for window in windows {
            for view in window.subviews {
                view.removeFromSuperview()
                window.addSubview(view)
            }
        }
    }
}
