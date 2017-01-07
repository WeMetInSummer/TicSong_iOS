//
//  LoginController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 5..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit

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
                            print(kakao.id)
                            
                            if let value = kakao.properties["nickname"] as? String{
                                
                                self.name = "\(value)"
                            }
                            if let value = kakao.properties["profile_image"] as? String{
                                
                                self.profileIMG = UIImage(data: NSData(contentsOf: NSURL(string: value)! as URL)! as Data)!
                                
                            }
                            
                            self.performSegue(withIdentifier: "LoginToMainSegue", sender: self)
                            
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
