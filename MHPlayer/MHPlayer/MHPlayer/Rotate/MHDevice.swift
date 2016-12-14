//
//  MHDevice.swift
//  MHPlayer
//
//  Created by kidd on 16/11/28.
//  Copyright © 2016年 CMCC. All rights reserved.
//

import UIKit
import Foundation

extension UIDevice {
    
    class func setOrientation(_ isFull: Bool) {
        
        if isFull == true {
            
            UIDevice.current.setValue(UIInterfaceOrientation.landscapeRight.rawValue, forKey: "orientation")
        }else {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKey: "orientation")
        }
    }
    
}
