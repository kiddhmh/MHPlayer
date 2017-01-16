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
        mhPlayer?.mhPlayerURL = "http://baobab.wdjcdn.com/14562919706254.mp4"
        mhPlayer?.mhPlayerTitle = "第一部"
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
        mhPlayer?.mhPlayerURL = "http://baobab.wdjcdn.com/1455782903700jy.mp4"
        mhPlayer?.mhPlayerTitle = "第二部";
    }
    
}
