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
        print(myScore,"내점수")
        myScoreLabel.text = myScore
        myLevelLabel.text = "레벨 : " + myLevel
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func dismissResult(_ sender: UIButton) {
       
        self.performSegue(withIdentifier: "unwindToMain", sender: self)
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
