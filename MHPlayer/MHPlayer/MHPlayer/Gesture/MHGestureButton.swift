//
//  MHGestureButton.swift
//  MHPlayer
//
//  Created by 胡明昊 on 16/11/28.
//  Copyright © 2016年 CMCC. All rights reserved.
//

import UIKit
import MediaPlayer

enum Direction {
    
    case leftOrRight, upOrDown, none
}

class MHGestureButton: UIButton {
    
    /// 单击时/双击时,判断tap的numberOfTapsRequired
    var userTapGestureBlock: ((_ number: NSInteger, _ flag: Bool) -> Void)?
    
    /// 开始触摸
    var touchesBeganWithPointBlock: (() -> CGFloat)?
    
    /// 结束触摸
    var touchesEndWithPointBlock: ((_ rate: CGFloat) -> Void)?
    
    fileprivate var isGesHidden: Bool?
    
    /// 上下左右手势操作
    fileprivate var direction: Direction?

    /// 手势触摸起始位置
    fileprivate var startPoint: CGPoint?
    
    /// 记录当前音量/亮度
    fileprivate var startVB: CGFloat?
    
    /// 控制音量的view
    fileprivate lazy var volumeView: MPVolumeView = { [weak self] in
        
        let volumeView = MPVolumeView()
        volumeView.sizeToFit()
        for subview in volumeView.subviews {
           if subview.self.classForCoder.description() == "MPVolumeSlider" {
                self?.volumeViewSlider = subview as? UISlider
                break
            }
        }
        return volumeView
    }()
    
    /// 控制音量
    fileprivate var volumeViewSlider: UISlider?
    
    /// 开始进度
    fileprivate var startVideoRate: CGFloat?
    
    /// 当期视频播放的进度
    fileprivate var currentRate: CGFloat?
    
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        addGestureAction()
        isGesHidden = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        volumeView.frame = CGRect(x: 0, y: 0, width: frame.size.width, height: frame.size.width * 9.0 / 16.0);
    }
    
    private func addGestureAction() {
        
        let mhTapGesture = UITapGestureRecognizer(target: self, action: #selector(userTapGestureAction(_:)))
        
        mhTapGesture.numberOfTapsRequired = 1
        mhTapGesture.delegate = self
        addGestureRecognizer(mhTapGesture)
        
        let mhTwoTapGesture = UITapGestureRecognizer(target: self, action: #selector(userTapGestureAction(_:)))
        mhTwoTapGesture.numberOfTapsRequired = 2
        mhTwoTapGesture.delegate = self
        addGestureRecognizer(mhTwoTapGesture)
        
        //没有检测到双击才进行单击事件
        mhTapGesture.require(toFail: mhTwoTapGesture)
    }
}


// MARK: - 手势事件
extension MHGestureButton {
    
    @objc fileprivate func userTapGestureAction(_ tap: UITapGestureRecognizer) {
        
        if tap.numberOfTapsRequired == 1 {
            isGesHidden = !isGesHidden!
        }
        if userTapGestureBlock != nil {
            userTapGestureBlock!(tap.numberOfTapsRequired, isGesHidden!)
        }
    }
    
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        //获取触摸开始的坐标
        let touch = touches.first
        let point = touch?.location(in: self)
        
        //记录首次触摸坐标
        startPoint = point
        //检测用户是触摸屏幕的左边还是右边，以此判断用户是要调节音量还是亮度，左边是音量，右边是亮度
        if (startPoint?.x)! <= frame.size.width / 2.0 {
            // 音量
            startVB = CGFloat((volumeViewSlider?.value)!)
        }else { //亮度
            startVB = UIScreen.main.brightness
        }
        
        //方向置为无
        direction = .none
        
        if touchesBeganWithPointBlock != nil {
            startVideoRate = touchesBeganWithPointBlock!()
        }
    }
    
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        let touch = touches.first
        let panPoint = touch?.location(in: self)
        
        //得出手指在Button上移动的距离
        let point = CGPoint(x: (panPoint?.x)! - (startPoint?.x)!, y: (panPoint?.y)! - (startPoint?.y)!)
        
        // 分析出用户滑动的方向
        if direction == .none {
            
            if point.x >= 30 || point.x <= -30 {
                //进度
                direction = .leftOrRight
            }else if point.y >= 30 || point.y <= -30 { // 音量和亮度
                direction = .upOrDown
            }
            
        }
        
        if direction == .none {
            return
        }else if direction == .upOrDown {
            // 音量和亮度
            if (startPoint?.x)! <= frame.size.width / 2.0 { //音量
                if point.y < 0 { // 增加音量
                    let value = Float(startVB! + (-point.y / 30.0 / 10))
                    volumeViewSlider?.setValue(value, animated: true)
                    if value - (volumeViewSlider?.value)! >= 0.1 {
                        volumeViewSlider?.setValue(0.1, animated: false)
                        volumeViewSlider?.setValue(value, animated: true)
                    }
                } else { //减少音量
                    let value = Float(startVB! - (point.y / 30.0 / 10))
                    volumeViewSlider?.setValue(value, animated: true)
                }
            } else { // 调节亮度
                
                if point.y < 0 {
                    // 增加亮度
                    let value = startVB! + (-point.y / 30.0 / 10)
                    UIScreen.main.brightness = value
                }else { // 减少亮度
                    let value = startVB! - (-point.y / 30.0 / 10)
                    UIScreen.main.brightness = value
                }
            }
        }else if direction == .leftOrRight { //进度
            
            var rate = startVideoRate! + (point.x / 30.0 / 20.0)
            if rate > 1 {
                rate = 1
            }else if rate < 0 {
                rate = 0
            }
            currentRate = rate
        }
    }
    
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        if direction == .leftOrRight {
            
            if touchesEndWithPointBlock != nil {
                touchesEndWithPointBlock!(currentRate!)
            }
        }
    }
    
}


// MARK: - UIGestureRecognizerDelegate
extension MHGestureButton: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        for subView in subviews {
            
            if (touch.view?.isDescendant(of: subView))! {
                return false
            }
        }
        return true
    }
    
}
