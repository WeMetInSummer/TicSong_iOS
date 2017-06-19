//
//  LoginModel.swift
//  TicSong_Media
//
//  Created by 윤민섭 on 2017. 6. 20..
//  Copyright © 2017년 jeon. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

class LoginModel {
    
    static let shared = LoginModel()
    
    private var profileIMG: UIImage?
    private var name: String = "GUEST"
    private var userSet = [String]()
    private let user = UserDefaults.standard
    private var bgmSetting : String? = "1"
    var guestMode = 0
    
    private var session :KOSession = KOSession.shared()
    
    func requestLogin(completion: @escaping(Int)->Void){
        
        
        if session.isOpen() {
            session.close()
        }
        
        session.open(completionHandler: { (error) -> Void in
            if error != nil{
                
            }else if self.session.isOpen() == true{
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
                            let baseURL = "http://13.124.46.227/TicSongServer/login.do"
                            
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
                                                        
                                                        self.user.set(self.userSet, forKey: "user")
                                                    }
                                                }
                                            }
                                            let setting = UserDefaults.standard
                                            
                                            if setting.string(forKey: "setting") == nil{
                                                let set = UserDefaults.standard
                                                set.set(self.bgmSetting, forKey: "setting")
                                            }
                                            completion(0)
                                        }
                                        break
                                        
                                    case .failure(_):
                                        completion(1)
                                        break
                                        
                                    }
                            }
                        })
                    }else{
                        
                    }
                })
            }else{
                
            }
        })
    }
    
    func setKaKaoSession(vc: UIViewController){
        session.presentingViewController = vc
    }
    
    func userSetClear(){
        self.userSet.removeAll()
    }
    
    func guestLogin(){
        let setting = UserDefaults.standard
        
        if setting.string(forKey: "setting") == nil{
            let set = UserDefaults.standard
            set.set(self.bgmSetting, forKey: "setting")
        }
    }
    
    func getUserInfo()->(String,UIImage?){
        if let pimage = profileIMG {
            return (name,pimage)
        } else{
            return (name,nil)
        }
    }
    
}
