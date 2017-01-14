//
//  TicSongLoadingView.swift
//  TicSong_Media
//
//  Created by 윤민섭 on 2017. 1. 14..
//  Copyright © 2017년 jeon. All rights reserved.
//

//
//  IJProgressView.swift
//  IJProgressView
//
//  Created by Isuru Nanayakkara on 1/14/15.
//  Copyright (c) 2015 Appex. All rights reserved.
//
import UIKit

open class TicSongLoadingView {
    
    var containerView = UIView()
    var progressView = UIView()
    var label = UILabel()
    
    var activityIndicator = UIActivityIndicatorView()
    
    open class var shared: TicSongLoadingView {
        struct Static {
            static let instance: TicSongLoadingView = TicSongLoadingView()
        }
        return Static.instance
    }
    
    open func showProgressView(_ view: UIView) {
        containerView.frame = view.frame
        containerView.center = view.center
        containerView.backgroundColor = UIColor(hex: 0xffffff, alpha: 0.1)
        
        
//        let blurVisualEffect = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        blurVisualEffect.alpha = 0.4
//        blurVisualEffect.frame = containerView.frame
//        containerView.addSubview(blurVisualEffect)
        
        
        
        progressView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        progressView.center = CGPoint(x: view.bounds.width / 2, y: view.bounds.height / 2)
 //       progressView.backgroundColor = UIColor(hex: 0x0000000, alpha: 0.9)
        
        progressView.clipsToBounds = true
        progressView.layer.cornerRadius = 10
//        
        label.text = "게임 준비중 입니다"
        label.textColor = UIColor(hex: 0xffffff, alpha: 1.0)
        label.center = CGPoint(x: progressView.bounds.width/2, y: progressView.bounds.height / 7)
//        label.sizeToFit()
//
        activityIndicator.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        activityIndicator.color = UIColor(hex: 0xaaaaaa, alpha: 0.7)
        activityIndicator.activityIndicatorViewStyle = .gray
        activityIndicator.center = CGPoint(x: progressView.bounds.width / 2, y: progressView.bounds.height / 2)
        
        
//        progressView.addSubview(label)
        progressView.addSubview(activityIndicator)
        containerView.addSubview(progressView)
        view.addSubview(containerView)
        
        activityIndicator.startAnimating()
    }
    
    open func hideProgressView() {
        activityIndicator.stopAnimating()
        containerView.removeFromSuperview()
    }
}

extension UIColor {
    
    convenience init(hex: UInt32, alpha: CGFloat) {
        let red = CGFloat((hex & 0xFF0000) >> 16)/256.0
        let green = CGFloat((hex & 0xFF00) >> 8)/256.0
        let blue = CGFloat(hex & 0xFF)/256.0
        
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
}
