//
//  ResultViewControllerLvUp.swift
//  TicSong_Media
//
//  Created by 윤민섭 on 2017. 1. 15..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit

class ResultViewControllerLvUp: UIViewController {

    var randomIndex : Int = 0
    var myLevel : String = ""
    var myScore : String = ""
    
    @IBOutlet weak var newItemImage: UIImageView!
    @IBOutlet weak var myScoreLabel: UILabel!
    @IBOutlet weak var myLevelLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let image = UIImage(named: "levelupItem\(randomIndex)")
        newItemImage.image = image
        myScoreLabel.text = myScore
        myLevelLabel.text = "Lv. " + myLevel
    }
    
    @IBAction func dismissResult(_ sender: UIButton) {
        self.performSegue(withIdentifier: "unwindToMain", sender: self)
    }
   
}
