//
//  Animation.swift
//  TicSong_Media
//
//  Created by 윤민섭 on 2017. 6. 20..
//  Copyright © 2017년 jeon. All rights reserved.
//

import Foundation


func aniBackgroundStar(pic : UIImageView){
    let duration = 35.0
    let delay = 0.0
    let fullRotation = CGFloat(Double.pi*2)
    let options = UIViewKeyframeAnimationOptions.calculationModeLinear
    
    UIView.animateKeyframes(withDuration: duration, delay: delay, options:  options, animations: {
        UIView.setAnimationRepeatCount(Float.infinity)
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/3, animations: {
            pic.transform = CGAffineTransform(rotationAngle: (1/3) * fullRotation)
        })
        UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
            pic.transform = CGAffineTransform(rotationAngle: (2/3) * fullRotation)
        })
        UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
            pic.transform = CGAffineTransform(rotationAngle: (3/3) * fullRotation)
        })
        
    })
    
}

//MARK: ANIMATION

func aniStar(pic : UIImageView, aniDuration : Double){
    var duration = 1.0
    duration = aniDuration
    let delay = 0.0
    let fullRotation = CGFloat(Double.pi*2)
    let options = UIViewKeyframeAnimationOptions.calculationModeLinear
    
    UIView.animateKeyframes(withDuration: duration, delay: delay, options:  options, animations: {
        //UIView.setAnimationRepeatCount(1)
        UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/3, animations: {
            pic.transform = CGAffineTransform(rotationAngle: -(1/3) * fullRotation)
        })
        UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
            pic.transform = CGAffineTransform(rotationAngle: -(2/3) * fullRotation)
        })
        UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
            pic.transform = CGAffineTransform(rotationAngle: -(3/3) * fullRotation)
        })
        
    })
}
