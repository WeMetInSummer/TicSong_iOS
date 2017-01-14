//
//  RankingTableViewController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 14..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit
import Alamofire

class RankingTableViewController: UITableViewController {
    
    var rankings = [Ranking]()
    var countRanking :Int = 30
    var userId : String = ""

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
//        
//        if let savedRankings = loadRankings() {
//            rankings += savedRankings
//            // += 대신에 = 해도 되지않을까...
//        }
   
        let user = UserDefaults.standard
        
        userId = (user.stringArray(forKey:"user")?[1])!
       
        //print(rankings[0].name)
    
    }
    override func viewDidAppear(_ animated: Bool) {
        
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
        
        //서버에서 가져온 개수 카운트
        
        return countRanking
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        print("여기....\(indexPath.row)")
        
        rankings.removeAll()
        selectRankings(userId: userId)

        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "RankingTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RankingTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let ranking = rankings[indexPath.row]
        print(ranking)
    
        cell.numberLabel.text = ranking.number
        cell.nameLabel.text = ranking.name
        cell.levelLabel.text = ranking.level
        cell.expLabel.text = ranking.exp
        
        return cell
    }
    
    
    
//     func loadRankings() -> [Ranking]? {
//        
//        //서버에서 불러다가 [Ranking] type으로 반환하면 됨.
//        
//        
//        
//        // as? [Ranking] return
//        return nil
//    }
    
    
    func selectRankings(userId:String)  {
        print("selectRanking 호출")
        let baseURL = "http://52.79.152.130/TicSongServer/myscore.do"
        print("selectRanking 호출2")

        let parameters: Parameters = ["service":"rank","userId":userId]
        print(parameters)
        print("selectRanking 호출3")

        Alamofire.request(baseURL,method : .get, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (response:DataResponse<Any>) in
                print("selectRanking 호출3-1")

                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        
                        print("selectRanking 호출4")

                        //print(response.result.value!)
                        
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8), let encodedData = utf8Text.data(using: String.Encoding.utf8){
                            
                            let JSON = try! JSONSerialization.jsonObject(with: encodedData, options: [])
                            
                            if let JSON = JSON as? [String: AnyObject] {
                                
                                if let resultCode = JSON["resultCode"] as? String{
                                    print("selectRanking 호출5")

                                    if(resultCode == "1"){
                                        
                                        var ranking: Ranking!
                                        if let result = JSON["rankerList"] as? [AnyObject]{
                                            
                                            let counts =  result.map(
                                                {(a: AnyObject) -> Int in
                                                    print("여기 호출")
                                                    let rankDict = a as! Dictionary<String, AnyObject>
                                                    
                                                    let rank = rankDict["rank"] as! Int
                                                    let name = rankDict["name"] as! String!
                                                    let exp = rankDict["exp"] as! Int
                                                    let userLevel = rankDict["userLevel"] as! Int
                                                    
                                                    
                                                    
                                                    ranking = Ranking(number: String(rank), name: name!, exp : String(exp), level : String(userLevel))
                                                    
                                                    self.rankings += [ranking]
                                                    
                                                    print(ranking)
                                                
                                                    
                                                    return a.count
                                                }
                                            )
                                            self.countRanking = counts.count
                                            
                                            print("counts: \(counts.count)")
                                            print(self.rankings[0].name)
                                            
                                            
                                        }
                                        
                                        if let myrank = JSON["myRank"] as? Int{
                                            
                                            print("myrank: \(myrank)")
                                        }
                                        
                                        
                                        
                                    }
                                }
                                
                                
                            }}
                        
                        
                        
                    }
                    break
                    
                case .failure(_):
                    print(response.result.error!)
                    
                    break
                    
                }
        }
        
        
        }
        
    
    
    
    @IBAction func toMain(_ sender: UIBarButtonItem) {
        
        self.dismiss(animated: true, completion: nil)
    }
    
    
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    
    
   



