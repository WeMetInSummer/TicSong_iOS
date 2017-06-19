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
    
    static var guest : Int = 0
    
    var userInfo: (name: String,profileImage: UIImage?)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        LoginModel.shared.userSetClear()
    }
    
    @IBAction func guestLoginClicked(_ sender: UIButton) {
        
        LoginViewController.guest = 1
        LoginModel.shared.guestLogin()
        self.performSegue(withIdentifier: "LoginToMainSegue", sender: self)
    }
    
    @IBAction func kakaoLoginClicked(_ sender: UIButton) {
        setKakaoProf()
    }
    
    func setKakaoProf(){
        LoginModel.shared.setKaKaoSession(vc: self)
        LoginModel.shared.requestLogin { (completion) in
            if completion == 0 {
              self.performSegue(withIdentifier: "LoginToMainSegue", sender: self)
            }
        }
    }
    
    @IBAction func unwindToLogin(_ sender: UIStoryboardSegue) {
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        userInfo = LoginModel.shared.getUserInfo()
        
        if segue.identifier == "LoginToMainSegue"{
            let destination = segue.destination as! MainViewController
            if let profileImage = userInfo?.profileImage{
                destination.receivedProfImg = profileImage
            }
            destination.receivedName = (userInfo?.name)!
        }
    }
}
