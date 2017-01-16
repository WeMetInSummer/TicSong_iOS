//
//  FakeViewController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 17..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit

class FakeViewController: UIViewController {

    var setting = UserDefaults.standard

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if setting.string(forKey: "agree") == "1"{
            performSegue(withIdentifier: "FakeToLogin", sender: self)
        }else{
            performSegue(withIdentifier: "FakeToPrivacy", sender: self)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
