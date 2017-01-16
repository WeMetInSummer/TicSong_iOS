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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        if(pageIndex < 4)
        {
            startBtn.isHidden = true
        }else{
            
            startBtn.isHidden = false
        }
        
        
        tutorialImage.image = UIImage(named: PhotoName)
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func startAction(_ sender: UIButton) {
        
        dismiss(animated: true, completion: nil)
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
