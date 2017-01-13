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
    var countRanking :Int = 0

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
        
        
        
        if let savedRankings = loadRankings() {
            rankings += savedRankings
            // += 대신에 = 해도 되지않을까...
        }
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
        
        // Table view cells are reused and should be dequeued using a cell identifier.
        let cellIdentifier = "RankingTableViewCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier, for: indexPath) as! RankingTableViewCell
        
        // Fetches the appropriate meal for the data source layout.
        let ranking = rankings[indexPath.row]
        
    
        cell.numberLabel.text = ranking.number
        cell.nameLabel.text = ranking.name
        cell.levelLabel.text = ranking.level
        cell.expLabel.text = ranking.exp
        
        return cell
    }
    
    
    
     func loadRankings() -> [Ranking]? {
        
        //서버에서 불러다가 [Ranking] type으로 반환하면 됨.
        
        
        
        // as? [Ranking] return
        return nil
    }
    
    
    func selectRankings(userId:String, exp:Int, userLevel:Int, item1Cnt:Int, item2Cnt:Int, item3Cnt:Int, item4Cnt:Int)  {
        
        
        let baseURL = "http://52.79.152.130/TicSongServer/item.do"
        
        let parameters: Parameters = ["service":"update", "userId":userId, "item1Cnt":item1Cnt, "item2Cnt":item2Cnt,"item3Cnt":item3Cnt, "item4Cnt":item4Cnt]
        
        
        Alamofire.request(baseURL,method : .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (response:DataResponse<Any>) in
                
                switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        //print(response.result.value!)
                        
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8), let encodedData = utf8Text.data(using: String.Encoding.utf8){
                            
                            let JSON = try! JSONSerialization.jsonObject(with: encodedData, options: [])
                            
                            if let JSON = JSON as? [String: AnyObject] {
                                if let resultCode = JSON["resultCode"] as? Int {
                                    
                                    if(resultCode == 1){
                                        print("성공적으로 exp와 userLevel update!")
                                    }else{print("exp와 userLevel update 실패…")
                                    }
                                    
                                    
                                }
                            }}
                        //self.performSegue(withIdentifier: "LoginToMainSegue", sender: self)
                    }
                    break
                    
                case .failure(_):
                    print(response.result.error!)
                    
                    break
                    
                }
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
    
    
    
   


}
