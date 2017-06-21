//
//  SettingViewController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 14..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit
import Alamofire

class SettingViewController: UIViewController {

    @IBOutlet weak var bgmSwitch: UISwitch!
    @IBOutlet weak var deleteUserButton: UIButton!
    
    let ud = UserDefaults.standard
    
    var userId : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        
    }
    
    func setup(){
        if let bar = navigationController?.navigationBar{
            let barColor = UIColor(red: 20.0/255.0, green: 34.0/255.0, blue: 58.0/255.0, alpha: 1.0)
            bar.isTranslucent = false
            bar.barTintColor = barColor
            bar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        }
        
        if UserModel.shared.guestMode == 0{
            userId = (ud.stringArray(forKey: "user")?[1])!
        }else{
            deleteUserButton.isHidden = true
        }
        
        let switchState = ud.string(forKey: "setting")
        
        if switchState == "1" || switchState == nil {
            bgmSwitch.setOn(true, animated:true)
        }else{
            bgmSwitch.setOn(false, animated:true)
        }

    }
    
    @IBAction func bgmSetting(_ sender: UISwitch) {
        
        if bgmSwitch.isOn {
            ud.set("1", forKey: "setting")
        }else{
            ud.set("2", forKey: "setting")
        }
    }
    
    @IBAction func toMain(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    

    @IBAction func deleteUserBtn(_ sender: UIButton) {
        
        let alertView = UIAlertController(title: "회원 탈퇴", message: "정말로 탈퇴하시겠습니까?", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            alertView.dismiss(animated: true, completion: nil)
            self.deleteUser()
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertView.addAction(action)
        alertView.addAction(cancelAction)
        self.present(alertView, animated: false, completion: nil)
    }
    
    func deleteUser(){
        UserModel.shared.deleteUser { (completion) in
            if completion == 1{
                self.ud.removeObject(forKey: "user")
                self.ud.removeObject(forKey: "setting")
                self.performSegue(withIdentifier: "unwindToLogin", sender: self)
            } else {
                self.showToast("네트워크 연결 상태를 확인해주세요.")
            }
        }
    }
   
    func showToast(_ msg:String) {
        let toast = UIAlertController()
        toast.message = msg;
        
        self.present(toast, animated: true, completion: nil)
        let duration = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: duration) {
            toast.dismiss(animated: true, completion: nil)
        }
    }
}
