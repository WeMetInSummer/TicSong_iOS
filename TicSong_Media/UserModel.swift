//
//  UserModel.swift
//  
//
//  Created by 윤민섭 on 2017. 6. 20..
//
//

import Foundation
import Alamofire

class UserModel{
    static let shared = UserModel()
    
    var userId = ""
    
    func deleteUser(completion: @escaping(Int)->Void){
        
        let baseURL = API.server + "TicSongServer/user.do?service=delete&userId="+userId
        
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
                                        completion(1)
                                    }
                                }
                            }
                        }
                    }
                    break
                case .failure(_):
                    completion(0)
                    break
            }
        }
    }
}


