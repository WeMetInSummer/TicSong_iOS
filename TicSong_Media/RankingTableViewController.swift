//
//  RankingTableViewController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 14..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit
import Alamofire


// hex code로 변환
extension UIColor {
    convenience init(hex: Int) {
        let r = hex / 0x10000
        let g = (hex - r*0x10000) / 0x100
        let b = hex - r*0x10000 - g*0x100
        self.init(red: CGFloat(r)/255, green: CGFloat(g)/255, blue: CGFloat(b)/255, alpha: 1)
    }
}

class RankingTableViewController: UITableViewController,UINavigationBarDelegate, UINavigationControllerDelegate {
    
    var rankings = [Ranking]()
    var countRanking :Int = 0
    var userId : String = ""
    var myRank : Int = 0
    
    
    @IBOutlet weak var myRankLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let bar:UINavigationBar! = navigationController?.navigationBar
        let barColor = UIColor(red: 20.0/255.0, green: 34.0/255.0, blue: 58.0/255.0, alpha: 1.0)
        bar.isTranslucent = false
        bar.barTintColor = barColor
        myRankLabel.backgroundColor = barColor
        bar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        let user = UserDefaults.standard
        userId = (user.stringArray(forKey:"user")?[1])!
    }
    override func viewDidAppear(_ animated: Bool) {
        rankings.removeAll()
        selectRankings(userId: userId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        
        return rankings.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "RankingTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RankingTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        if !rankings.isEmpty {
            let ranking = rankings[indexPath.row]
            cell.numberLabel.text = ranking.number
            cell.nameLabel.text = ranking.name
            cell.levelLabel.text = "Lv. \(ranking.level)"
            cell.expLabel.text = "Exp : \(ranking.exp)"
        }
        myRankLabel.text = "🏆내 순위 : \(myRank)등🏆"
        return cell
    }
    func selectRankings(userId:String)  {
        let baseURL = "http://13.124.46.227/TicSongServer/myscore.do"
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
                                        var ranking: Ranking!
                                        if let result = JSON["rankerList"] as? [AnyObject]{
                                            let counts =  result.map(
                                                {(a: AnyObject) -> Int in
                                                    let rankDict = a as! Dictionary<String, AnyObject>
                                                    let rank = rankDict["rank"] as! Int
                                                    let name = rankDict["name"] as! String!
                                                    let exp = rankDict["exp"] as! Int
                                                    let userLevel = rankDict["userLevel"] as! Int
                                                    ranking = Ranking(number: String(rank), name: name!, exp : String(exp), level : String(userLevel))
                                                    self.rankings += [ranking]
                                           
                                                    return a.count
                                                }
                                            )
                                        self.countRanking = counts.count
                                            
                                        self.tableView.reloadData()
                                    }
                                        
                                if let myrank = JSON["myRank"] as? Int{
                                            
                                self.myRank = myrank
                            }
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
    
    @IBAction func toMain(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
}








