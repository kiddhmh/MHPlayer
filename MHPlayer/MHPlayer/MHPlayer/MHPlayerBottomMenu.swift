//
//  MHPlayerBottomMenu.swift
//  MHPlayer
//
//  Created by kidd on 16/11/25.
//  Copyright © 2016年 CMCC. All rights reserved.
//

import UIKit

class MHPlayerBottomMenu: UIView {
    
    var mhFull: Bool?
    
    var mhPlay: Bool? { // 双击播放暂停
        didSet {
            guard mhPlay != nil else { return }
            playOrPauseAction()
        }
    }
        
    var mhPlayEnd: Bool? {
        didSet {
            guard let isEnd = mhPlayEnd else { return }
            if isEnd == true {
                isPlay = false
                playOrPauseBtn.setImage(UIImage(named: "play"), for: .normal)
                playSlider.setValue(0.0, animated: true)
                loadProgressView.setProgress(0.0, animated: true)
                let time = mhPlayerTimeStyle(mhTotalTime!)
                timeLabel.text = "00:00:00/00:\(time)"
            }
        }
    }
    
    var mhLoadedTimeRanges: CGFloat? {  //已加载
        didSet {
            guard let LoadedTimeRanges = mhLoadedTimeRanges else { return }
            loadProgressView.setProgress(Float(LoadedTimeRanges), animated: true)
        }
    }
    
    var mhCurrentTime: CGFloat? {   //已播放
        didSet {
            guard let CurrentTime = mhCurrentTime else { return }
            playSlider.setValue(Float(CurrentTime), animated: true)
            let time1 = mhPlayerTimeStyle(CurrentTime)
            let time2 = mhPlayerTimeStyle(mhTotalTime!)
            if isHour == true {
                timeLabel.text = "\(time1)/\(time2)"
            }else {
                timeLabel.text = "00:\(time1)/00:\(time2)"
            }
        }
    }
    
    var mhTotalTime: CGFloat? { //总时长
        
        didSet {
            
            guard let totalTime = mhTotalTime else { return }
            let time = mhPlayerTimeStyle(totalTime)
            if isHour == true {
                timeLabel.text = "00:00:00/\(time)"
            }else {
                timeLabel.text = "00:00:00/00:\(time)"
            }
            //设置slider的最大值就是总时长
            playSlider.maximumValue = Float(totalTime)
        }
    }
    
    /// 播放/暂停
    var mhPlayOrPauseBlock: ((_ flag: Bool) -> Void)?
    /// 下一个
    var mhNextPlayerBlock: (() -> ())?
    /// 滑动条滑动时
    var mhSliderValueChangeBlock: ((_ value: CGFloat) -> Void)?
    /// 滑动条滑动完成
    var mhSliderValueChangeEndBlock: ((_ value: CGFloat) -> Void)?
    /// 放大/缩小
    var mhFullOrSmallBlock: ((_ flag: Bool) -> Void)?
    
    fileprivate var isPlay: Bool = false
    fileprivate var isHour: Bool = false
    
    ///播放/暂停
    fileprivate lazy var playOrPauseBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "play"), for: .normal)
        button.contentMode = UIViewContentMode.center
        button.addTarget(self, action: #selector(playOrPauseAction), for: .touchUpInside)
        return button
    }()
    
    ///下一个视屏（全屏时有）
    fileprivate lazy var nextPlayerBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "next"), for: .normal)
        button.contentMode = UIViewContentMode.center
        button.addTarget(self, action: #selector(nextPlayerAction), for: .touchUpInside)
        return button
    }()
    
    ///缓冲进度条
    fileprivate lazy var loadProgressView: UIProgressView = {
        let progressView = UIProgressView()
        return progressView
    }()
    
    ///播放滑动条
    fileprivate lazy var playSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0.0
        UIGraphicsBeginImageContextWithOptions(CGSize(width: 1, height: 1), false, 0.0)
        let transparentImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        slider.setThumbImage(UIImage(named: "progressDot"), for: .normal)
        slider.setMaximumTrackImage(transparentImage, for: .normal)
        slider.setMinimumTrackImage(transparentImage, for: .normal)
        
        slider.addTarget(self, action: #selector(playSliderValueChanging(_:)), for: .valueChanged)
        slider.addTarget(self, action: #selector(playSliderValueDidChanged(_:)), for: .touchUpInside)
        return slider
    }()
    
    ///时间标签
    fileprivate lazy var timeLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.white
        label.font = UIFont.systemFont(ofSize: 11.0)
        label.textAlignment = .center
        label.text = "00:00:00/00:00:00"
        return label
    }()
    
    ///放大/缩小按钮
    fileprivate lazy var fullOrSmallBtn: UIButton = {
        let button = UIButton()
        button.setImage(UIImage(named: "fullScreen"), for: .normal)
        button.contentMode = UIViewContentMode.center
        button.addTarget(self, action: #selector(fullOrSmallAction), for: .touchUpInside)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addAllView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addAllView() {
        addSubview(playOrPauseBtn)
        addSubview(nextPlayerBtn)
        addSubview(loadProgressView)
        addSubview(playSlider)
        addSubview(timeLabel)
        addSubview(fullOrSmallBtn)
    }
    
}


// MARK: - 控制事件
extension MHPlayerBottomMenu {
    
    /// 开始/暂停
    @objc fileprivate func playOrPauseAction() {
        
        if isPlay == true {
            isPlay = false
            playOrPauseBtn.setImage(UIImage(named: "play"), for: .normal)
        }else {
            isPlay = true
            playOrPauseBtn.setImage(UIImage(named: "pause"), for: .normal)
        }
        if mhPlayOrPauseBlock != nil {
            mhPlayOrPauseBlock!(isPlay)
        }
    }
    
    
    /// 下一个
    @objc fileprivate func nextPlayerAction() {
        
        if mhNextPlayerBlock != nil {
            mhNextPlayerBlock!()
        }
    }

    /// 定义视频时长样式
    fileprivate func mhPlayerTimeStyle(_ time: CGFloat) -> String {
        
        let date = Date(timeIntervalSince1970: TimeInterval(time))
        let formatter = DateFormatter()
        if time / 3600 > 1 {
            isHour = true
            formatter.dateFormat = "HH:mm:ss"
        }else {
            formatter.dateFormat = "mm:ss"
        }
        return formatter.string(from: date)
    }
    
    /// 放大/缩小
    @objc fileprivate func fullOrSmallAction() {
        mhFull = !mhFull!
        if mhFullOrSmallBlock != nil {
            mhFullOrSmallBlock!(mhFull!)
        }
    }
    
    /// slider拖动时
    @objc fileprivate func playSliderValueChanging(_ sender: AnyObject) {
        isPlay = false
        let slider = sender as! UISlider
        if mhSliderValueChangeBlock != nil {
            mhSliderValueChangeBlock!(CGFloat(slider.value))
        }
    }
    
    /// slider完成拖动时
    @objc fileprivate func playSliderValueDidChanged(_ sender: AnyObject) {
        let slider = sender as! UISlider
        if mhSliderValueChangeEndBlock != nil {
            mhSliderValueChangeEndBlock!(CGFloat(slider.value))
        }
        playOrPauseAction()
    }
    
}


// MARK: - 布局信息
extension MHPlayerBottomMenu {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        playOrPauseBtn.frame = CGRect(x: self.left, y: 8, width: 25, height: 25)
        if mhFull == true {
            nextPlayerBtn.frame = CGRect(x: playOrPauseBtn.right, y: 8, width: 25, height: 25)
            fullOrSmallBtn.setImage(UIImage(named: "exitFullScreen"), for: .normal)
        }else {
            nextPlayerBtn.frame = CGRect(x: playOrPauseBtn.right + 5, y: 5, width: 0, height: 0)
            fullOrSmallBtn.setImage(UIImage(named: "fullScreen"), for: .normal)
        }
        
        fullOrSmallBtn.frame = CGRect(x: self.width - 35, y: (self.height - 25) / 2 , width: 25, height: 25)
        timeLabel.frame = CGRect(x: fullOrSmallBtn.left - 108, y: 10, width: 108, height: 20)
        loadProgressView.frame = CGRect(x: playOrPauseBtn.right + nextPlayerBtn.width + 7, y: 20, width: timeLabel.left - playOrPauseBtn.right - nextPlayerBtn.width - 14, height: 20)
        playSlider.frame = CGRect(x: playOrPauseBtn.right + nextPlayerBtn.width + 5, y: 5, width: loadProgressView.width + 4, height: 31)
    }
}




