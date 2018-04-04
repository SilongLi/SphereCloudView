//
//  SphereCloudViewController.swift
//  SphereGame
//
//  Created by lisilong on 2018/4/3.
//  Copyright © 2018年 lisilong. All rights reserved.
//

import UIKit

class SphereCloudViewController: UIViewController {
    fileprivate let duration = 0.25
    
    lazy var sphereView: SphereView = {
        let view = SphereView()
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(sphereView)
        setupDataSource()
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let width = self.view.frame.size.width - 40.0
        sphereView.frame  = CGRect.init(x: 0.0, y: 0.0, width: width, height: width)
        sphereView.center = self.view.center
    }
    
    // MARK: - setupDataSource
    func setupDataSource() {
        var subviews = [UIButton]()
        for i in 0..<100 {
            let btn = UIButton.init(type: .custom)
            let title = i % 2 == 0 ? "🐲" : "🐯"
            btn.setTitle(title, for: .normal)
            btn.setTitleColor(UIColor.darkGray, for: .normal)
            btn.titleLabel?.font = UIFont.systemFont(ofSize: 24)
            btn.frame = CGRect(x: 0, y: 0, width: 40, height: 20)
            btn.addTarget(self, action: #selector(sphereBtnClicked), for: .touchUpInside)
            subviews.append(btn)
            sphereView.addSubview(btn)
        }
        sphereView.setupCloudSubviews(subviews)
    }
    
    // MARK: - actions
    @objc func sphereBtnClicked(btn: UIButton) {
        sphereView.stopAniamtion()
        UIView.animate(withDuration: duration, animations: {
            btn.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        }) { (_) in
            UIView.animate(withDuration: self.duration, animations: {
                btn.transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
            }) { (_) in
                self.sphereView.startAniamtion()
            }
        }
    }
    
}
