//
//  MHTopMenu.swift
//  MHPlayer
//
//  Created by kidd on 16/11/25.
//  Copyright © 2016年 CMCC. All rights reserved.
//

import UIKit

class MHTopMenu: UIView {
    
    /// 标题
    var mhAVTitle: String? {
        didSet {
            guard let title = mhAVTitle else { return }
            titleLabel.text = title
        }
    }
    
    /// 隐藏返回按钮,默认为NO
    var mhHiddenBackBtn: Bool?
    /// 返回按钮操作
    var mhTopGoBack: (() ->Void)?
    
    fileprivate lazy var backButton: UIButton = {
        let button = UIButton()
        button.setBackgroundImage(UIImage(named: "BackBtn"), for: .normal)
        button.addTarget(self, action: #selector(goBack), for: .touchUpInside)
        return button
    }()
    
    fileprivate lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 18)
        label.textColor = UIColor.white
        return label
    }()
    
    override init(frame: CGRect) {
        
        super.init(frame: frame)
        addAllView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }


    private func addAllView() {
        addSubview(backButton)
        addSubview(titleLabel)
    }
}


// MARK: - 控制事件
extension MHTopMenu {
    
    @objc fileprivate func goBack() {
        
        if mhTopGoBack != nil {
            mhTopGoBack!()
        }
    }

}


// MARK: - 布局
extension MHTopMenu {
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if mhHiddenBackBtn == true {
            backButton.removeFromSuperview()
            titleLabel.frame = CGRect(x: 10, y: 5, width: 200, height: 30)
        }else {
            backButton.frame = CGRect(x: 10, y: 10, width: 18, height: 18)
            backButton.contentMode = .center
            titleLabel.frame = CGRect(x: 50, y: 5, width: 200, height: 30)
        }
    }
    
}
