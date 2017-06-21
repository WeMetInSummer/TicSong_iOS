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
    
    var userInfo: (name: String,profileImage: UIImage?)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        UserModel.shared.guestMode = 0
        UserModel.shared.userSetClear()
    }
    
    @IBAction func guestLoginClicked(_ sender: UIButton) {
        
        UserModel.shared.guestMode = 1
        UserModel.shared.guestLogin()
        self.performSegue(withIdentifier: "LoginToMainSegue", sender: self)
    }
    
    @IBAction func kakaoLoginClicked(_ sender: UIButton) {
        setKakaoProf()
    }
    
    func setKakaoProf(){
        UserModel.shared.setKaKaoSession(vc: self)
        UserModel.shared.requestLogin { (completion) in
            if completion == 0 {
              self.performSegue(withIdentifier: "LoginToMainSegue", sender: self)
            }
        }
    }
    
    @IBAction func unwindToLogin(_ sender: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        userInfo = UserModel.shared.getUserInfo()
        
        if segue.identifier == "LoginToMainSegue"{
            let destination = segue.destination as! MainViewController
            if let profileImage = userInfo?.profileImage{
                destination.receivedProfImg = profileImage
            }
            destination.receivedName = (userInfo?.name)!
        }
    }
}
