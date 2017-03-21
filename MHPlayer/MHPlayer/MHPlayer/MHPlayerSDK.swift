//
//  MHPlayerSDK.swift
//  MHPlayer
//
//  Created by kidd on 16/11/25.
//  Copyright © 2016年 CMCC. All rights reserved.
//

import UIKit

@objc protocol MHAVPlayerSDKDelegate: NSObjectProtocol {
    /// 返回按钮
    @objc optional func mhGoBack()
    
    /// 下一个
    @objc optional func mhNextPlayer()
}

class MHAVPlayerSDK: UIView {
    /// 代理
    weak var MHAVPlayerSDKDelegate: MHAVPlayerSDKDelegate?
    
    /// 视频播放链接
    var mhPlayerURL: String? {
        didSet{
            guard let url = mhPlayerURL else { return }
            saveURL = url
            mhPlayer.mhPlayerURL = url
        }
    }
    
    /// 视频标题
    var mhPlayerTitle: String? {
        didSet {
            guard let title = mhPlayerTitle else { return }
            saveTitle = title
            topMenu.mhAVTitle = title
        }
    }
    
    /// 定位上次播放时间
    var mhLastTime: Float? {
        didSet{
            guard let lastTime = mhLastTime else { return }
            mhPlayer.mhSeekToTimeWithSeconds(Float(lastTime))
        }
    }
    
    /// 是否开启自动横屏,默认NO
    var mhAutoOrient: Bool = false
    
    ///是否关闭过播放器（关闭，不是暂停）
    fileprivate var isStop: Bool?
    
    fileprivate lazy var mhPlayer: MHPlayer = {
        let mhPlayer = MHPlayer()
        return mhPlayer
    }()
    
    fileprivate lazy var backView: MHGestureButton = {
        let backView = MHGestureButton()
        return backView
    }()
    
    fileprivate lazy var topMenu: MHTopMenu = {
        let topMenu = MHTopMenu()
        topMenu.backgroundColor = UIColor(red: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        topMenu.isHidden = true
        return topMenu
    }()
    
    fileprivate lazy var bottomMenu: MHPlayerBottomMenu = {
        let bottomMenu = MHPlayerBottomMenu()
        bottomMenu.backgroundColor = UIColor(colorLiteralRed: 50.0/255.0, green: 50.0/255.0, blue: 50.0/255.0, alpha: 1.0)
        bottomMenu.isHidden = true
        return bottomMenu
    }()
    
    /// 初始化的视屏大小
    fileprivate var firstFrame: CGRect!
    /// 保存url
    fileprivate var saveURL: String?
    /// 保存标题
    fileprivate var saveTitle: String?
    /// 等待指示器
    fileprivate lazy var loadingView: UIActivityIndicatorView = {
       let loadingView = UIActivityIndicatorView.init(activityIndicatorStyle: UIActivityIndicatorViewStyle.whiteLarge)
        loadingView.startAnimating()
        return loadingView
    }()
    
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        UIDevice.setOrientation(false)
        self.firstFrame = frame
        addAllView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addAllView() {
        backView.addSubview(topMenu)
        backView.addSubview(bottomMenu)
        backView.addSubview(loadingView)
        mhPlayer.addSubview(backView)
        addSubview(mhPlayer)
        
        mhAVPlayerBLock()
        mhGestureButtonBlock()
        mhTopMenuBlock()
        mhBottomMenuBlock()
    }
    
    /// 关闭播放器
    public func mhStopPlayer() {
        mhPlayer.mhStop()
    }
    
    
    /// 获取当前播放时间
    public func mhCurrentTime() -> CGFloat {
        return mhPlayer.mhCurrentTime()
    }
    
    
    /// 获取视屏总长
    public func mhTotalTime() -> CGFloat {
        return mhPlayer.mhTotalTime()
    }
    
}


// MARK: - MHPlayer 方法
extension MHAVPlayerSDK {
    
    fileprivate func mhAVPlayerBLock() {
        
        //加载成功回调
        MHClosure.mhSuccessClosure = { [weak self] in
            guard let sself = self else {return}
//            sself.bottomMenu.mhPlay = true //如果想一进来就播放，就放开注释
            sself.loadingView.stopAnimating()
            sself.loadingView.hidesWhenStopped = true
        }
        
        //播放失败回调
        MHClosure.mhPlayerFailClosure = { [weak self] in
            guard let sself = self else {return}
            sself.isStop = true //保证点击播放按钮能播放
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 5.0, execute: {
                sself.loadingView.stopAnimating()
                sself.loadingView.hidesWhenStopped = true
            })
        }

        // 加载进度
        MHClosure.mhLoadTimeClosure = { [weak self] (time) in
            guard let sself = self else {return}
            sself.bottomMenu.mhLoadedTimeRanges = time
        }
        
        // 视屏总长
        MHClosure.mhTotalTimeClosure = { [weak self] (time) in
            guard let sself = self else {return}
            sself.bottomMenu.mhTotalTime = time
        }
        
        
        // 当前时间
        MHClosure.mhCurrentTimeClosure = { [weak self] (time) in
            guard let sself = self else {return}
            sself.bottomMenu.mhCurrentTime = time
        }
        
       
        // 播放完
        MHClosure.mhPlayEndClosure = { [weak self] in
            guard let sself = self else {return}
            sself.bottomMenu.mhPlayEnd = true
            if (sself.MHAVPlayerSDKDelegate?.responds(to: NSSelectorFromString("mhNextPlayer")))! {
                sself.MHAVPlayerSDKDelegate?.mhNextPlayer!()
            }
        }
        
    
        //关闭控件
        MHClosure.mhPlayerStopClosure = { [weak self] in
            guard let sself = self else {return}
            sself.isStop = true
            sself.bottomMenu.mhPlayEnd = true
        }
        
        
        //方向改变
        MHClosure.mhDirectionChangeClosure = {[weak self] (origent) in
            guard let sself = self else {return}
            if sself.mhAutoOrient == true {
                if origent == UIDeviceOrientation.portrait {
                    sself.frame = sself.firstFrame
                    sself.bottomMenu.mhFull = false
                }else if origent == UIDeviceOrientation.landscapeLeft || origent == UIDeviceOrientation.landscapeRight {
                    sself.frame = UIScreen.main.bounds
                    sself.bottomMenu.mhFull = true
                }
            }
        }
        
        
        // 自动改变屏幕方向
        MHClosure.mhAutoOrigin = { [weak self] in
            guard let sself = self else {return}
            UIDevice.setOrientation(sself.mhAutoOrient)
        }
        
        //播放延迟
        MHClosure.mhDelayPlay = { [weak self] (flag) in
            guard let sself = self else {return}
            if flag == true && sself.isStop == true {
                sself.loadingView.startAnimating()
            }else {
                sself.loadingView.stopAnimating()
                sself.loadingView.hidesWhenStopped = true
            }
        }
        
    }
    
}


// MARK: - GestureButton方法
extension MHAVPlayerSDK {
    
    fileprivate func mhGestureButtonBlock() {
        //单击/双击事件
        backView.userTapGestureBlock = {[weak self] (number, flag) in
            guard let sself = self else {return}
            if number == 1 {
                UIView.animate(withDuration: 0.3, animations: {
                    sself.topMenu.isHidden = flag
                    sself.bottomMenu.isHidden = flag
                })
            }else if number == 2 {
                sself.bottomMenu.mhPlay = flag  //不受flag影响
            }
        }
        
        func open(_ blovk: () -> CGFloat) {
            
        }
        
        //开始触摸
        backView.touchesBeganWithPointBlock = { [weak self] () -> CGFloat in
            guard let sself = self else {return 0}
            //返回当前播放进度
            return sself.mhPlayer.mhCurrentRate()
        }
        
        //结束触摸
        backView.touchesEndWithPointBlock = { [weak self] (rate) in
            guard let sself = self else {return}
            //进度
            let seconds = sself.mhPlayer.mhTotalTime() * rate
            sself.mhPlayer.mhSeekToTimeWithSeconds(Float(seconds))
        }
    }
    
}

// MARK: - TopMenu方法
extension MHAVPlayerSDK {
    
    fileprivate func mhTopMenuBlock() {
        
        topMenu.mhTopGoBack = { [weak self] in
            guard let sself = self else {return}
            //返回
            if sself.bottomMenu.mhFull == true {
                UIDevice.setOrientation(false)
                sself.frame = sself.firstFrame
                sself.bottomMenu.mhFull = false
            }else {
                if (sself.MHAVPlayerSDKDelegate?.responds(to: NSSelectorFromString("mhGoBack")))! {
                    sself.MHAVPlayerSDKDelegate?.mhGoBack!()
                }
            }
        }
    }
    
}


// MARK: - BottomMenu方法
extension MHAVPlayerSDK {
    
    fileprivate func mhBottomMenuBlock() {
        
        //播放/暂停
        bottomMenu.mhPlayOrPauseBlock = { [weak self] (isPlay) in
            guard let sself = self else {return}
            if sself.isStop == true {
                sself.isStop = false
                sself.mhPlayer.mhPlayerURL = sself.saveURL
                sself.topMenu.mhAVTitle = sself.saveTitle
            }
            if isPlay == true {
                sself.mhPlayer.mhPlaye()
            }else {
                sself.mhPlayer.mhPause()
            }
        }
        
        //下一个
        bottomMenu.mhNextPlayerBlock = { [weak self] in
            guard let sself = self else {return}
            sself.bottomMenu.mhPlayEnd = true
            if (sself.MHAVPlayerSDKDelegate?.responds(to: NSSelectorFromString("mhNextPlayer")))! {
                sself.MHAVPlayerSDKDelegate?.mhNextPlayer!()
            }
        }
        
        //滑动条滑动时
        bottomMenu.mhSliderValueChangeBlock = { [weak self] (time) in
            guard let sself = self else {return}
            sself.mhPlayer.mhSeekToTimeWithSeconds(Float(time))
            sself.mhPlayer.mhPause()
        }
        
        //滑动条拖动完成
        bottomMenu.mhSliderValueChangeEndBlock = { [weak self] (time) in
            guard let sself = self else {return}
            sself.mhPlayer.mhSeekToTimeWithSeconds(Float(time))
        }
        
        //放大/缩小
        bottomMenu.mhFullOrSmallBlock = { [weak self] (isFull) in
            guard let sself = self else {return}
            UIDevice.setOrientation(isFull)
            if isFull == true {
                sself.frame = (sself.window?.bounds)!
            }else {
                sself.frame = sself.firstFrame
            }
        }
    }
    
}


// MARK: - 布局信息
extension MHAVPlayerSDK {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        mhPlayer.frame = CGRect(x: 0, y: 0, width: self.width, height: self.height)
        backView.frame = mhPlayer.frame
        topMenu.frame = CGRect(x: 0, y: backView.top, width: backView.width, height: 40)
        bottomMenu.frame = CGRect(x: 0, y: backView.height - 40, width: backView.width, height: 40)
        loadingView.center = CGPoint(x: backView.centerX, y: backView.centerY)
        
        mhPlayer.setPlayLayerBounds(self.layer.bounds)
    }
    
}

