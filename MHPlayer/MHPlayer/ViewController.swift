//
//  ViewController.swift
//  MHPlayer
//
//  Created by kidd on 16/11/25.
//  Copyright © 2016年 CMCC. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    var mhPlayer: MHAVPlayerSDK?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.white
        
        mhPlayer = MHAVPlayerSDK(frame: CGRect(x: 0, y: 40, width: view.frame.size.width, height: view.frame.size.width / 2))
        mhPlayer?.mhPlayerURL = "http://static.tripbe.com/videofiles/20121214/9533522808.f4v.mp4"
        mhPlayer?.mhPlayerTitle = "MHPlayer"
        mhPlayer?.mhAutoOrient = true
        mhPlayer?.MHAVPlayerSDKDelegate = self
        mhPlayer?.mhLastTime = 50
        
        view.addSubview(mhPlayer!)
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}


extension ViewController: MHAVPlayerSDKDelegate {
    
    func mhGoBack() {
//            mhPlayer?.mhStopPlayer()
//            self.dismiss(animated: true, completion: nil)
    }
    
    func mhNextPlayer() {
        mhPlayer?.mhPlayerURL = "http://www.jxgbwlxy.gov.cn/tm/course/041629011/sco1/1.mp4";
        mhPlayer?.mhPlayerTitle = "谢军是傻逼";
    }
    
}
