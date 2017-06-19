//
//  ResultViewController.swift
//  TicSong_Media
//
//  Created by 윤민섭 on 2017. 1. 15..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {

    var myLevel : String = ""
    var myScore : String = ""
    
    @IBOutlet weak var myScoreLabel: UILabel!
    @IBOutlet weak var myLevelLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
   
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        myScoreLabel.text = myScore
        myLevelLabel.text = "Lv. " + myLevel
    }

    @IBAction func dismissResult(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToMain", sender: self)
    }

}
