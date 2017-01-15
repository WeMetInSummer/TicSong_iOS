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
        print(myScore,"내점수")
        let image = UIImage(named: "levelupItem\(randomIndex)")
        newItemImage.image = image
        myScoreLabel.text = myScore
        myLevelLabel.text = "레벨 : " + myLevel
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
