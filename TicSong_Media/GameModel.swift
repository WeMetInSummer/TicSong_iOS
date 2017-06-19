//
//  GameModel.swift
//  TicSong_Media
//
//  Created by 윤민섭 on 2017. 6. 20..
//  Copyright © 2017년 jeon. All rights reserved.
//

import Foundation
import Alamofire

class GameModel{
    
    static let shared = GameModel()
    
    private var url = ""
    private var startTime = 0.0
    var userSet = [String]()
    private let user = UserDefaults.standard
    
    func setMusic(name: String, time: Double){
        url = "https://api.soundcloud.com/tracks/"+name+"/stream?client_id=59eb0488cc28a2c558ecbf47ed19f787"
        if(time != 0){
            startTime = time/1000.0
        }else{
            startTime = time
        }
    }
    
    func getSoundData() -> NSData?{
        let fileUrl = NSURL(string: url)! as URL
        if let soundData = NSData(contentsOf: fileUrl) {
            return soundData
        } else{
            return nil
        }
    }
    
    
    func itemUpdate() {
        
        let baseURL = API.server + "TicSongServer/item.do"
        
        let parameters: Parameters = ["service":"update", "userId":userSet[1], "item1Cnt":userSet[4], "item3Cnt":userSet[5], "item4Cnt":userSet[6], "item5Cnt":userSet[7]]
        
        Alamofire.request(baseURL,method : .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (response:DataResponse<Any>) in
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8), let encodedData = utf8Text.data(using: String.Encoding.utf8){
                            let JSON = try! JSONSerialization.jsonObject(with: encodedData, options: [])
                            if let JSON = JSON as? [String: AnyObject] {
                                if let resultCode = JSON["resultCode"] as? Int {
                                    
                                    if(resultCode == 1){
                                        self.updateUd()
                                    }else{
                                        
                                    }
                                }
                            }
                        }
                    }
                    break
                    
                case .failure(_):
                    break
            }
        }
    }
    
    func myScoreUpdate(){
        
        let baseURL = API.server + "TicSongServer/myscore.do"
        
        let parameters: Parameters = ["service":"update", "userId":userSet[1], "exp":userSet[2], "userLevel":userSet[3]]
        
        
        Alamofire.request(baseURL,method : .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8), let encodedData = utf8Text.data(using: String.Encoding.utf8){
                            
                            let JSON = try! JSONSerialization.jsonObject(with: encodedData, options: [])
                            
                            if let JSON = JSON as? [String: AnyObject] {
                                if let resultCode = JSON["resultCode"] as? Int{
                                    
                                    if(resultCode == 1){
                                        
                                    }else{
                                        
                                    }
                                }
                            }
                        }
                    }
                    break
                case .failure(_):
                    break
            }
        }
    }
    
    func updateUd(){
        self.user.set(userSet, forKey: "user")
    }
}
