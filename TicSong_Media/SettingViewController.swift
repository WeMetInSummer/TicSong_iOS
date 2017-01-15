//
//  SettingViewController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 14..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit

class SettingViewController: UIViewController,UINavigationControllerDelegate,UINavigationBarDelegate {

    @IBOutlet weak var bgmSwitch: UISwitch!
    let setting = UserDefaults.standard
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bar:UINavigationBar! = navigationController?.navigationBar
        let barColor = UIColor(red: 20.0/255.0, green: 34.0/255.0, blue: 58.0/255.0, alpha: 1.0)
        bar.isTranslucent = false
        bar.barTintColor = barColor
        
        
        bar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        
        let switchState = setting.string(forKey: "setting")
        if switchState == "1" || switchState == nil {
            bgmSwitch.setOn(true, animated:true)
        }else{
            bgmSwitch.setOn(false, animated:true)
        }
        // Do any additional setup after loading the view.
    }
    override func viewDidAppear(_ animated: Bool) {
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func bgmSetting(_ sender: UISwitch) {
        
        if bgmSwitch.isOn {
            print("bgmSwitch 킴")
            setting.set("1", forKey: "setting")
        }else{
            print("bgmSwitch 끔")
            setting.set("2", forKey: "setting")
        }
        
    }
    
    @IBAction func toMain(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)

    }
    
    
    @IBAction func deleteUserBtn(_ sender: UIButton) {
        print("a")
    }
    
    @IBAction func tutorialBtn(_ sender: UIButton) {
        print("keep")

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
