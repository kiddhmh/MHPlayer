//
//  MHPlayer.swift
//  MHPlayer
//
//  Created by kidd on 16/11/25.
//  Copyright © 2016年 CMCC. All rights reserved.
//

import UIKit
import AVFoundation

class MHPlayer: UIView {

// MARK: - 属性
    /// 视频链接
    open var mhPlayerURL: String? {
        didSet {
            mhPlayerInit()
        }
    }

    
    fileprivate var isSuccess: Bool?
    fileprivate var isPlayNow: Bool?
    
    fileprivate var mhPlayer: AVPlayer?
    fileprivate var mhPlayerItem: AVPlayerItem?
    fileprivate var videoURLAsset: AVURLAsset?
    fileprivate var mhPlayerLayer: AVPlayerLayer?
    
    fileprivate var playbackTimeObserver: Any? //界面更新时间ID
    fileprivate var link: CADisplayLink? //以屏幕刷新率进行定时操作
    
    fileprivate var lastTime: TimeInterval?
    
    fileprivate var filePath: URL?

// MARK: - 方法
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.black
        
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setCategory(AVAudioSessionCategoryPlayback)
        NotificationCenter.default.addObserver(self, selector: #selector(orientChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil) //注册监听，屏幕方向改变
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    
// MARK: - Open Function
    /// 播放
    public func mhPlaye() {
        
        mhPlayer?.play()
        isPlayNow = true
        if link == nil {
            link = CADisplayLink(target: self, selector: #selector(upadte)) //和屏幕频率刷新相同的定时器
            link?.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
        }
    }
    
    
    /// 暂停
    public func mhPause() {
        
        isPlayNow = false
        if link != nil {
            link?.remove(from: RunLoop.main, forMode: .defaultRunLoopMode)
            link = nil
        }
        
        mhPlayer?.pause()
    }

    /// 关闭
    public func mhStop() {
        // 开启锁屏
        UIApplication.shared.isIdleTimerDisabled = false
        mhRemoveObserver()
        mhPause()
        isPlayNow = false
        mhPlayer?.rate = 0
        mhPlayer?.replaceCurrentItem(with: nil)
        mhPlayerItem = nil
        mhPlayer = nil
        
        if MHClosure.mhPlayerStopClosure != nil {
            MHClosure.mhPlayerStopClosure!()
        }
    }
    
    /// 定位视频播放时间
    ///
    /// - parameter seconds: 定位的时间
    public func mhSeekToTimeWithSeconds(_ seconds: Float) {
        mhPlayer?.seek(to: CMTime.init(seconds: Double(seconds), preferredTimescale: CMTimeScale(NSEC_PER_SEC)))
    }
    
    
    /// 取得当前播放时间
    public func mhCurrentTime() -> CGFloat {
        return CGFloat(CMTimeGetSeconds(mhPlayer!.currentTime()))
    }
    
    
    /// 取得视频总时长
    public func mhTotalTime() -> CGFloat {
        return CGFloat(CMTimeGetSeconds((mhPlayer!.currentItem?.duration)!))
    }
    
    /// 当前视屏播放进度
    ///
    /// - returns: 进度
    public func mhCurrentRate() -> CGFloat {
        
        let cTime = mhPlayer?.currentTime()
        if isSuccess == true {
            return CGFloat((cTime?.value)!) / CGFloat((cTime?.timescale)!) / CGFloat(CMTimeGetSeconds((mhPlayer?.currentItem?.duration)!))
        }else {
            return 0
        }
    }
    
    public func setPlayLayerBounds(_ Bounds: CGRect) {
        mhPlayerLayer?.frame = Bounds
    }
}


extension MHPlayer {
    
    /// 初始化
    fileprivate func mhPlayerInit() {
        // 限制锁屏
        UIApplication.shared.isIdleTimerDisabled = true
        
        if mhPlayer != nil {
            mhPlayer = nil
            mhRemoveObserver()
        }
        
        fileExistsAtPath(mhPlayerURL!)
        
        videoURLAsset = AVURLAsset(url: filePath!, options: nil)
        mhPlayerItem = AVPlayerItem(asset: videoURLAsset!)
        
        if mhPlayer?.currentItem != nil {
            mhPlayer?.replaceCurrentItem(with: mhPlayerItem)
        }else {
            mhPlayer = AVPlayer(playerItem: mhPlayerItem)
        }
        
        if mhPlayerLayer != nil {
            let playerLayer = self.layer.sublayers?.first
            (playerLayer as! AVPlayerLayer).player = mhPlayer
        }else {
            mhPlayerLayer = AVPlayerLayer(player: mhPlayer)
            self.layer.insertSublayer(mhPlayerLayer!, at: 0)
        }
        
        
        //监听status属性变化
        mhPlayerItem?.addObserver(self, forKeyPath: "status", options: .new, context: nil)
        //监听loadedTimeRanges属性变化
        mhPlayerItem?.addObserver(self, forKeyPath: "loadedTimeRanges", options: .new, context: nil)
        //注册监听，视屏播放完成
        NotificationCenter.default.addObserver(self, selector: #selector(mhPlayerEndPlay(_:)), name: Notification.Name.AVPlayerItemDidPlayToEndTime, object: mhPlayerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: Notification.Name.UIApplicationWillResignActive, object: mhPlayerItem)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterPlayGround), name: Notification.Name.UIApplicationDidBecomeActive, object: mhPlayerItem)
    }
    
}


// MARK: - 监听事件
extension MHPlayer {
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        
        let playerItem = object as? AVPlayerItem
        if keyPath == "status" {
            
            if MHClosure.mhAutoOrigin != nil {
                MHClosure.mhAutoOrigin!()
            }
            
            if playerItem?.status == .readyToPlay {
                print("播放成功")
                isSuccess = true
                
                let duration = mhPlayerItem?.duration // 获取视屏总长
                let totalSecond = CMTimeGetSeconds(duration!) //转换成秒
                if MHClosure.mhTotalTimeClosure != nil {
                    MHClosure.mhTotalTimeClosure!(CGFloat(totalSecond))
                }
                
                if MHClosure.mhSuccessClosure != nil {
                    MHClosure.mhSuccessClosure!()
                }
                
                let currentSecond = CGFloat((mhPlayerItem?.currentTime().value)!) / CGFloat((mhPlayerItem?.currentTime().timescale)!) // 获得当前时间
                if MHClosure.mhCurrentTimeClosure != nil {
                    MHClosure.mhCurrentTimeClosure!(currentSecond)
                }
                
                monitoringXjPlayerBack() //监听播放状态
                
            }else if playerItem?.status == .unknown {
                print("播放未知")
                isSuccess = false
                if MHClosure.mhPlayerFailClosure != nil {
                    MHClosure.mhPlayerFailClosure!()
                }
            }else if playerItem?.status == .failed {
                print("播放失败")
                isSuccess = false
                if MHClosure.mhPlayerFailClosure != nil {
                    MHClosure.mhPlayerFailClosure!()
                }
            }
        }else if keyPath == "loadedTimeRanges" {
            
            let timeInterval = mhPlayerAvailableDuration()
            let duration = mhPlayerItem?.duration
            let totalDuration = CMTimeGetSeconds(duration!)
            
            if MHClosure.mhLoadTimeClosure != nil {
                MHClosure.mhLoadTimeClosure!(CGFloat(timeInterval / totalDuration))
            }
        }
    }
    
    
    
    /// 屏幕方向改变时的监听
    @objc fileprivate func orientChange(_ notification: NSNotification) {
        
        let origent = (notification.object as! UIDevice).orientation
        if MHClosure.mhDirectionChangeClosure != nil{
            MHClosure.mhDirectionChangeClosure!(origent)
        }
    }
    
    
    /// 视屏播放完后的通知事件。从头开始播放
    @objc fileprivate func mhPlayerEndPlay(_ notification: NSNotification) {
        
        mhPlayer?.seek(to: kCMTimeZero, completionHandler: {_ in 
            MHClosure.mhPlayEndClosure!()
        })
        
    }
    
    /// 程序进入后台（如果播放，则暂停，否则不管）
    @objc fileprivate func appDidEnterBackground() {
        if isPlayNow == true {
            mhPlayer?.pause()
        }
    }
    
    
    /// 程序进入前台（退出前播放，进来后继续播放，否则不管）
    @objc fileprivate func appDidEnterPlayGround() {
        if isPlayNow == true {
            mhPlayer?.play()
        }
    }
    
    
    /// 实时监听播放状态
    fileprivate func monitoringXjPlayerBack() {
        
        playbackTimeObserver = mhPlayer?.addPeriodicTimeObserver(forInterval: CMTime(value: 1, timescale: 1), queue: nil, using: { [weak self](time) in
            guard let sself = self else {return}
            let currentSecond = CGFloat((sself.mhPlayerItem?.currentTime().value)!) / CGFloat((sself.mhPlayerItem?.currentTime().timescale)!) // 获得当前时间
            
            if MHClosure.mhCurrentTimeClosure != nil {
                MHClosure.mhCurrentTimeClosure!(currentSecond)
            }
            
        })
    }
    
    
    /// 刷新，看播放是否卡顿
    @objc fileprivate func upadte() {
        let current: TimeInterval = CMTimeGetSeconds((mhPlayer?.currentTime())!)
        if current == lastTime {
            // 卡顿
            if MHClosure.mhDelayPlay != nil {
                MHClosure.mhDelayPlay!(true)
            }
        }else { //不卡顿
            if MHClosure.mhDelayPlay != nil {
                MHClosure.mhDelayPlay!(false)
            }
        }
        
        lastTime = current
    }
    
}


extension MHPlayer {
    
    /// 计算缓冲区
    fileprivate func mhPlayerAvailableDuration() -> TimeInterval {
        
        let loadedTimeRanges = mhPlayer?.currentItem?.loadedTimeRanges
        let timeRange = (loadedTimeRanges?.first)?.timeRangeValue   //获取缓冲区域
        let startSeconds = CMTimeGetSeconds((timeRange?.start)!)
        let durationSeconds = CMTimeGetSeconds((timeRange?.duration)!)
        let result = startSeconds + durationSeconds //尖酸缓冲进度
        
        return result
    }
    
    /// 判断是否存在已下载好的文件
    fileprivate func fileExistsAtPath(_ url: String) {
        let fileManager = FileManager.default
        
        if fileManager.fileExists(atPath: url) == true {
            filePath = URL(fileURLWithPath: url)
            print(filePath ?? "url为空")
        }else {
            filePath = NSURL(string: url) as URL?
            print("没有本地文件")
        }
    }
    
    
    fileprivate func mhRemoveObserver() {
        
        if link != nil {
            link?.remove(from: RunLoop.main, forMode: .defaultRunLoopMode)
            link = nil
        }
        mhPlayerItem?.removeObserver(self, forKeyPath: "status", context: nil)
        mhPlayerItem?.removeObserver(self, forKeyPath: "loadedTimeRanges", context: nil)
        mhPlayer?.removeTimeObserver(playbackTimeObserver!)
        playbackTimeObserver = nil
        NotificationCenter.default.removeObserver(self)
        
        NotificationCenter.default.addObserver(self, selector: #selector(orientChange(_:)), name: NSNotification.Name.UIDeviceOrientationDidChange, object: nil) //注册监听，屏幕方向改变
    }
}



extension MHPlayer {
//    
//    fileprivate func player() -> AVPlayer? {
//        
//        for sublayer in layer.sublayers! {
//            if sublayer.classForCoder == AVPlayerLayer.self {
//                return (sublayer as! AVPlayerLayer).player
//            }
//        }
//        
//        return nil
//    }
//    
//    fileprivate func setPlayer(_ p: AVPlayer) {
//        
//        for sublayer in layer.sublayers! {
//            if sublayer.classForCoder == AVPlayerLayer.self {
//                sublayer.removeFromSuperlayer()
//            }
//        }
//        
//        let playLayer = AVPlayerLayer(player: p)
//        layer.insertSublayer(playLayer, at: 0)
//    }
    
}

