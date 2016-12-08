//
//  ViewController.swift
//  Timer
//
//  Created by 胡明昊 on 16/12/7.
//  Copyright © 2016年 CMCC. All rights reserved.
//

import UIKit
private var time: Int = 5
class ViewController: UIViewController {
    @IBOutlet weak var label: UILabel!
    
    fileprivate lazy var label1: UILabel = {
        let label = UILabel()
        label.backgroundColor = UIColor.red
        return label
    }()

    fileprivate var timer: DispatchSourceTimer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(label1)
        
        label1.frame = CGRect(x:10,y:10,width:100,height:100)
        
        // 创建定时任务
        timer = DispatchSource.makeTimerSource(flags: [], queue: DispatchQueue.global())
        timer?.scheduleRepeating(deadline: .now(), interval: .seconds(1), leeway: .seconds(0))
        timer?.setEventHandler { [weak self] in
            time -= 1
            
            DispatchQueue.main.sync { [weak self] in
                self?.label1.text = "跳过\(time)s"
                
                if time == 0 {
                    self?.timer?.cancel()
                }
            }
        }
        
        timer?.resume()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

