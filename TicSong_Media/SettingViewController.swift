//
//  SettingViewController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 14..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit
import Alamofire

class SettingViewController: UIViewController,UINavigationControllerDelegate,UINavigationBarDelegate {

    @IBOutlet weak var bgmSwitch: UISwitch!
    let setting = UserDefaults.standard
    
    var userId : String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let bar:UINavigationBar! = navigationController?.navigationBar
        let barColor = UIColor(red: 20.0/255.0, green: 34.0/255.0, blue: 58.0/255.0, alpha: 1.0)
        bar.isTranslucent = false
        bar.barTintColor = barColor
        
        
        bar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        
        
        userId = (setting.stringArray(forKey: "user")?[1])!
        
        
        
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
        
        let alertView = UIAlertController(title: "회원 탈퇴", message: "정말로 탈퇴하시겠습니까?", preferredStyle: .alert)
        
        
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            
            
            alertView.dismiss(animated: true, completion: nil)
            self.deleteUser()
            
        
        
        
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in print("cancel button clicked")}
        
        alertView.addAction(action)
        alertView.addAction(cancelAction)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertView, animated: true, completion: nil)
       
    
    }
    
    
    func deleteUser(){
    
    
        //서버통신
        let baseURL = "http://52.79.152.130/TicSongServer/user.do?service=delete&userId="+userId
        
        
        
        Alamofire.request(baseURL,method : .get,encoding: URLEncoding.default, headers: nil)
            .responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        
                        
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8), let encodedData = utf8Text.data(using: String.Encoding.utf8){
                            
                            let JSON = try! JSONSerialization.jsonObject(with: encodedData, options: [])
                            
                            if let JSON = JSON as? [String: AnyObject] {
                                if let resultCode = JSON["resultCode"] as? String {
                                    
                                    
                                    if resultCode == "1"{
                                        
                                        self.setting.removeObject(forKey: "user")
                                        self.setting.removeObject(forKey: "setting")
                                        
                                        self.performSegue(withIdentifier: "unwindToLogin", sender: self)
                                        
                                    }else{
                                        
                                        self.showToast("네트워크 연결 상태를 확인해주세요.")
                                        
                                        
                                    }
                                    
                                }
                            }
                        }
                    }
                    
                    
                    break
                    
                case .failure(_):
                    print(response.result.error!)
                    
                    
                    break
                    
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
    
   
    
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
