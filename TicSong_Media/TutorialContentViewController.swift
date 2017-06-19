//
//  TutorialContentViewController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 16..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit

class TutorialContentViewController: UIViewController {
    
    @IBOutlet weak var tutorialImage: UIImageView!
    
    @IBOutlet weak var startBtn: UIButton!
    
    var pageIndex: Int = 0
    var PhotoName: String!
    
    var setting = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if(pageIndex < 4){
            startBtn.isHidden = true
        }else{
            startBtn.isHidden = false
        }
        tutorialImage.image = UIImage(named: PhotoName)
    }
    
    @IBAction func startAction(_ sender: UIButton) {

        if setting.string(forKey: "agree") == nil {
            setting.set("1", forKey: "agree")
            performSegue(withIdentifier: "tutorialToLogin", sender: self)
        }else {
            dismiss(animated: true, completion: nil)
        }
        
        
    }
}
