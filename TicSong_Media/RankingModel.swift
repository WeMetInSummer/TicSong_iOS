//
//  RankingModel.swift
//  TicSong_Media
//
//  Created by 윤민섭 on 2017. 6. 20..
//  Copyright © 2017년 jeon. All rights reserved.
//

import Foundation
import Alamofire

class RankingModel {
    
    static let shared = RankingModel()
    
    private let user = UserDefaults.standard
    private var rankings = [RankingVO]()
    private var countRanking :Int = 0
    private var myRank: Int = 0
    
    func requestRankings(completion: @escaping(Int)->Void){
        let baseURL = API.server + "TicSongServer/myscore.do"
        
        var userId = (self.user.stringArray(forKey:"user")?[1])!

        let parameters: Parameters = ["service":"rank","userId":userId]
        Alamofire.request(baseURL,method : .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8), let encodedData = utf8Text.data(using: String.Encoding.utf8){
                            let JSON = try! JSONSerialization.jsonObject(with: encodedData, options: [])
                            if let JSON = JSON as? [String: AnyObject] {
                                if let resultCode = JSON["resultCode"] as? String{
                                    if(resultCode == "1"){
                                        var ranking: RankingVO!
                                        if let result = JSON["rankerList"] as? [AnyObject]{
                                            let counts =  result.map(
                                            {(a: AnyObject) -> Int in
                                                let rankDict = a as! Dictionary<String, AnyObject>
                                                let rank = rankDict["rank"] as! Int
                                                let name = rankDict["name"] as! String!
                                                let exp = rankDict["exp"] as! Int
                                                let userLevel = rankDict["userLevel"] as! Int
                                                ranking = RankingVO(number: String(rank), name: name!, exp : String(exp), level : String(userLevel))
                                                self.rankings += [ranking]
                                                
                                                return a.count
                                                }
                                            )
                                            self.countRanking = counts.count
                                            
                                        }
                                        
                                        if let myrank = JSON["myRank"] as? Int{
                                            self.myRank = myrank
                                        }
                                        
                                        completion(0)
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
    
    func clearRankings(){
        self.rankings.removeAll()
    }
    
    func getRanking() -> [RankingVO]{
        return rankings
    }
    
    func getMyRank() -> Int{
        return myRank
    }
}
