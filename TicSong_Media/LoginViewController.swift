//
//  LoginController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 5..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit
import Alamofire

class LoginViewController: UIViewController {
    
    // 카톡 프로필 이미지
    var profileIMG:UIImage = UIImage(named: "default")!
    var name:String = "GUEST"
    var userSet:[String] = []
    var bgmSetting : String? = "1"
    static var guest : Int = 0
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        userSet.removeAll()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "LoginToMainSegue"{
            let destination = segue.destination as! MainViewController
            destination.receivedProfImg = profileIMG
            destination.receivedName = name
        }
    }
    
    @IBAction func guestLoginClicked(_ sender: UIButton) {
        
        LoginViewController.guest = 1
        
        let setting = UserDefaults.standard
        
        if setting.string(forKey: "setting") == nil{
            let set = UserDefaults.standard
            set.set(self.bgmSetting, forKey: "setting")
        }
        self.performSegue(withIdentifier: "LoginToMainSegue", sender: self)
    }

    @IBAction func kakaoLoginClicked(_ sender: UIButton) {
        setKakaoProf()
    }
    
    func setKakaoProf(){
        
        let session :KOSession = KOSession.shared()
    
            if session.isOpen() {
                session.close()
            }
            session.presentingViewController = self
        
            session.open(completionHandler: { (error) -> Void in
            if error != nil{

            }else if session.isOpen() == true{
                KOSessionTask.meTask(completionHandler: { (profile , error) -> Void in
                    if profile != nil{
                        DispatchQueue.main.async(execute: { () -> Void in
                            let kakao : KOUser = profile as! KOUser
                            
                            if(kakao.properties != nil){
                                
                                if let value = kakao.properties["nickname"] as? String{
                                    self.name = "\(value)"
                                }
                                
                                if kakao.properties["profile_image"] as? String != ""{
                                if let value = kakao.properties["profile_image"] as? String{
                                    self.profileIMG = UIImage(data: NSData(contentsOf: NSURL(string: value)! as URL)! as Data)!
                            }
                            
                        }
                            
                    }
                        
                            //서버통신
                            let baseURL = "http://52.79.152.130/TicSongServer/login.do"
            
                            let parameters: Parameters = ["userId":kakao.id!,"name":self.name,"platform":"1"]
                            
                            Alamofire.request(baseURL,method : .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                                .responseJSON { (response:DataResponse<Any>) in
                                
                                switch(response.result) {
                                case .success(_):
                                    if response.result.value != nil{
                                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8), let encodedData = utf8Text.data(using: String.Encoding.utf8){
                                            
                                            let JSON = try! JSONSerialization.jsonObject(with: encodedData, options: [])
                                        
                                        if let JSON = JSON as? [String: AnyObject] {
                                            if let exp = JSON["exp"] as? Int, let name = JSON["name"] as? String, let item1Cnt = JSON["item1Cnt"] as? Int, let item2Cnt = JSON["item3Cnt"] as? Int, let item3Cnt = JSON["item4Cnt"] as? Int, let item4Cnt = JSON["item5Cnt"] as? Int, let userLevel = JSON["userLevel"] as? Int {
                                                self.userSet.append("\(name)")
                                                self.userSet.append("\(kakao.id!)")
                                                self.userSet.append("\(exp)")
                                                self.userSet.append("\(userLevel)")
                                                self.userSet.append("\(item1Cnt)")
                                                self.userSet.append("\(item2Cnt)")
                                                self.userSet.append("\(item3Cnt)")
                                                self.userSet.append("\(item4Cnt)")
                                                
                                                let user = UserDefaults.standard
                                                
                                                user.set(self.userSet, forKey: "user")
                                                
                                            }
                                        }
                                    }
                                        
                                            let setting = UserDefaults.standard
                                        
                                            if setting.string(forKey: "setting") == nil{
                                                    let set = UserDefaults.standard
                                                    set.set(self.bgmSetting, forKey: "setting")
                                            }
                                            self.performSegue(withIdentifier: "LoginToMainSegue", sender: self)
                                }
                                    break
                                    
                                case .failure(_):
                                    break
                                    
                                }
                            }
                        })
                    }else{ }
                })
            }else{ }
        })
    }

    @IBAction func unwindToLogin(_ sender: UIStoryboardSegue) {
        
    }
   

}
