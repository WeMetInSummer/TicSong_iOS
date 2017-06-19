//
//  Alert.swift
//  TicSong_Media
//
//  Created by 윤민섭 on 2017. 6. 20..
//  Copyright © 2017년 jeon. All rights reserved.
//

import Foundation

func basicAlert(string : String,message : String){
    let alertView = UIAlertController(title: string, message: message, preferredStyle: .alert)
    
    let action = UIAlertAction(title: "확인", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
        alertView.dismiss(animated: true, completion: nil)
    })
    
    alertView.addAction(action)
    
    alertWindow(alertView: alertView)
}


func alertWindow(alertView: UIAlertController){
    let alertWindow = UIWindow(frame: UIScreen.main.bounds)
    alertWindow.rootViewController = UIViewController()
    alertWindow.windowLevel = UIWindowLevelAlert + 1
    alertWindow.makeKeyAndVisible()
    alertWindow.rootViewController?.present(alertView, animated: true, completion: nil)
}
