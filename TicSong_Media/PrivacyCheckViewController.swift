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
    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func cancelBtn(_ sender: UIButton) {
        exit(0)
    }

    @IBAction func agreeBtn(_ sender: UIButton) {
        performSegue(withIdentifier: "agreeToTutorial", sender: self)
    }
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
