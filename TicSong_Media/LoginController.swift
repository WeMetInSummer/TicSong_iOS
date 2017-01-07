//
//  LoginController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 5..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit
import Alamofire

class LoginController: UIViewController {
    
    

    
    var profileIMG:UIImage = UIImage(named: "album")!
    var name:String = "default"
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        
        
        if segue.identifier == "LoginToMainSegue"
        {
            
            
            
            let destination = segue.destination as! MainController
            
            destination.receivedProfImg = profileIMG
            destination.receivedName = name
          
        }
        
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
                print(error?.localizedDescription as Any) // any 원래 없어야함
            }else if session.isOpen() == true{
                KOSessionTask.meTask(completionHandler: { (profile , error) -> Void in
                    if profile != nil{
                        DispatchQueue.main.async(execute: { () -> Void in
                            let kakao : KOUser = profile as! KOUser
                            //고유 ID값
                            //print(kakao.id)
                            
                            if let value = kakao.properties["nickname"] as? String{
                                
                                self.name = "\(value)"
                            }
                            if let value = kakao.properties["profile_image"] as? String{
                                
                                self.profileIMG = UIImage(data: NSData(contentsOf: NSURL(string: value)! as URL)! as Data)!
                                
                            }
                       //서버통신
                            

                            let baseURL = "http://52.79.152.130/TicSongServer/login.do"
                            
                            let parameters: Parameters = ["userId":kakao.id!,"name":self.name,"platform":"1"]
                            
                        
                            
                            Alamofire.request(baseURL,method : .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
                                .responseJSON { (response:DataResponse<Any>) in
                                
                                switch(response.result) {
                                case .success(_):
                                    if response.result.value != nil{
                                        print(response.result.value!)
                                        
                                        self.performSegue(withIdentifier: "LoginToMainSegue", sender: self)
                                    }
                                    break
                                    
                                case .failure(_):
                                    print(response.result.error!)
                                    
                                    //대섭이형이 ㅈ같이 코드짜서 카톡이나 페이스북이 널값만 안넘기면 쉽게 가입 및 로그인가능 
                                    //error시 alert창 띄우기...할일이 있나 싶음..
                                    
                                    //exp,item1,2,3,4,userid,userlevel
                                    
                                    break
                                    
                                }
                            }
                            
                            
                            
                            
                            
                        })
                    }else{
                        
                        print(error!)}
                })
            }else{
                print("isNotOpen")
            }
        })
    
        
        }

   

}
