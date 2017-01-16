//
//  AboutUsViewController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 16..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit

class AboutUsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func closeBtn(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
    }
}
