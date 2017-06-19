//
//  PrivacyViewController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 16..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit

class PrivacyViewController: UIViewController,UINavigationControllerDelegate,UINavigationBarDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bar:UINavigationBar! = navigationController?.navigationBar
        let barColor = UIColor(red: 20.0/255.0, green: 34.0/255.0, blue: 58.0/255.0, alpha: 1.0)
        bar.isTranslucent = false
        bar.barTintColor = barColor
        bar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
    }

    @IBAction func closeBtn(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
   

}
