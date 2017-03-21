//
//  MHConfig.swift
//  MHPlayer
//
//  Created by kidd on 16/11/25.
//  Copyright © 2016年 CMCC. All rights reserved.
//

import UIKit

struct MHClosure {
    
    /// 播放成功回调
    static var mhSuccessClosure: (() ->())?
    
    /// 播放失败回调
    static var mhPlayerFailClosure: (() ->())?
    
    /// 取得加载进度
    static var mhLoadTimeClosure: ((_ time: CGFloat) -> ())?
    
    /// 取得当前播放时间(回调，刷新时间栏)
    static var mhCurrentTimeClosure: ((_ time: CGFloat) -> ())?
    
    /// 取得媒体总时长（为了回调）
    static var mhTotalTimeClosure: ((_ time: CGFloat) -> ())?
    
    /// 播放完
    static var mhPlayEndClosure: (() ->())?
    
    /// 播放器关闭回调
    static var mhPlayerStopClosure: (() ->())?

    /// 方向改变
    static var mhDirectionChangeClosure: ((_ origent: UIDeviceOrientation) -> ())?
    
    /// 播放是否延迟
    static var mhDelayPlay: ((_ flag: Bool) -> ())?
    
    /// 是否自动横屏
    static var mhAutoOrigin: (() -> ())?
}
