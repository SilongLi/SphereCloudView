//
//  SphereView.swift
//  SphereGame
//
//  Created by lisilong on 2018/4/3.
//  Copyright © 2018年 lisilong. All rights reserved.
//

import UIKit

struct SpherePoint {
    var x: CGFloat = 0.0
    var y: CGFloat = 0.0
    var z: CGFloat = 0.0
    
    init(_ x: CGFloat, _ y: CGFloat, _ z: CGFloat) {
        self.x = x
        self.y = y
        self.z = z
    }
}


class SphereView: UIView {
    var velocity: CGFloat = 0.0         // 速度
    var last: CGPoint?                  // 开始拖动时的点
    var timer: CADisplayLink?           // 默认
    var inertia: CADisplayLink?         // 拖动时
    var btns: [UIButton]?               // 标签集合
    var coordinate = [SpherePoint]()    // 标签坐标集合
    var normalPoint: SpherePoint?       // 默认坐标
    
    convenience init() {
        self.init(frame: CGRect.zero)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.lightGray.withAlphaComponent(0.5)
        let gest = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        self.addGestureRecognizer(gest)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - setup
    public func setupCloudSubviews(_ subviews: [UIButton]) {
        btns = subviews
        
        // 重置view的中心点,便于计算
        for item in subviews {
            item.center = self.center
        }
        let p1: CGFloat = CGFloat(.pi * (3.0 - sqrt(5.0)))
        let p2: CGFloat = 2.0 / CGFloat(subviews.count)
        
        for (i, _) in subviews.enumerated() {
            let p3: CGFloat = CGFloat(i) * p1
            let y: CGFloat  = CGFloat(i) * p2 - 1.0 + (p2 / 2.0)
            let r: CGFloat  = sqrt(1.0 - y * y)
            let x: CGFloat  = cos(p3) * r
            let z: CGFloat  = sin(p3) * r
            let point = SpherePoint(x, y, z)
            coordinate.append(point)
            
            let duration: CGFloat = (CGFloat(arc4random() % 10) + 10.0) / 20.0
            UIView.animate(withDuration: TimeInterval(duration), animations: {
                self.setupSubview(point: point, index: i)
            })
        }
       
        let a: CGFloat = CGFloat(arc4random() % 10) - 5.0
        let b: CGFloat = CGFloat(arc4random() % 10) - 5.0
        normalPoint = SpherePoint(CGFloat(a), CGFloat(b), 0)
        startAniamtion()
    }
    
    private func setupSubview(point: SpherePoint, index: NSInteger) {
        guard let subViews = btns else {
            return
        }
        let btn = subViews[index]
        let x = (point.x + 1.0) * (self.frame.size.width / 2.0)
        let y = (point.y + 1.0) * self.frame.size.width / 2.0
        btn.center = CGPoint(x: x, y: y)
        
        let t = (point.z + 2.0) / 3.0
        btn.transform = CGAffineTransform(scaleX: t, y: t)
        btn.layer.zPosition = t
        btn.alpha = t
        btn.isUserInteractionEnabled = point.z >= 0
    }
    
    // MARK: - actions
    /// 更新每个标签的位置
    private func updateSubviewsFrame(index: NSInteger, direction: SpherePoint, angle: CGFloat) {
        let point  = coordinate[index]
        let rPoint = MatrixTool.pointMakeRotation(point: point, direction: direction, angle: angle)
        coordinate[index] = rPoint
        setupSubview(point: rPoint, index: index)
    }
    
    public func startAniamtion() {
        timer = CADisplayLink(target: self, selector: #selector(autoTurnRotation))
        timer?.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
    }
    
    public func stopAniamtion() {
        timer?.invalidate()
        timer = nil
    }
    
    func inertiaStart() {
        stopAniamtion()
        inertia = CADisplayLink(target: self, selector: #selector(inertiaStep))
        inertia?.add(to: RunLoop.main, forMode: .defaultRunLoopMode)
    }
    
    func inertiaStop() {
        inertia?.invalidate()
        inertia = nil
        startAniamtion()
    }
    
    @objc func inertiaStep() {
        guard velocity > 0 else {
            inertiaStop()
            return
        }
        velocity = velocity - 70.0
        let angle = velocity / self.frame.size.width * 2.0 * CGFloat(inertia?.duration ?? 0.01)
        let count = btns?.count ?? 0
        if count > 0, let point = normalPoint {
            for i in 0..<count {
                updateSubviewsFrame(index: i, direction: point, angle: angle)
            }
        }
    }
    
    @objc private func autoTurnRotation() {
        guard let subViews = btns, let point = normalPoint else {
            return
        }
        for (i, _) in subViews.enumerated() {
            updateSubviewsFrame(index: i, direction: point, angle: 0.002)
        }
    }
    
    // MARK: - UIPanGestureRecognizer
    @objc private func handlePanGesture(gesture: UIPanGestureRecognizer) {
        if gesture.state == UIGestureRecognizer.State.began {
            last = gesture.location(in: self)
            stopAniamtion()
            inertiaStop()
            
        } else if gesture.state == UIGestureRecognizer.State.changed {
            let current = gesture.location(in: self)
            let direction = SpherePoint((last?.y ?? 0.0) - current.y, current.x - (last?.x ?? 0.0), 0)
            let distance = sqrt(direction.x * direction.x + direction.y * direction.y)
            let angle = distance / (self.frame.size.width / 2.0)
            let count = btns?.count ?? 0
            if count > 0 {
                for i in 0..<count {
                    updateSubviewsFrame(index: i, direction: direction, angle: angle)
                }
            }
            normalPoint = direction
            last = current
            
        } else if gesture.state == UIGestureRecognizer.State.ended {
            let velocityP = gesture.velocity(in: self)
            velocity = sqrt(velocityP.x * velocityP.x + velocityP.y * velocityP.y)
            inertiaStart()
        }
    }
}
