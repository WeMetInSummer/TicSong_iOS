//
//  PrivacyCheckViewController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 16..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit

class PrivacyCheckViewController: UIViewController {

    var setting = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
    }
    
    @IBAction func cancelBtn(_ sender: UIButton) {
        exit(0)
    }

    @IBAction func agreeBtn(_ sender: UIButton) {
        performSegue(withIdentifier: "agreeToTutorial", sender: self)
    }
}
