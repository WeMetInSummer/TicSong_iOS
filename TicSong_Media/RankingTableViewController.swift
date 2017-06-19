//
//  RankingTableViewController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 14..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit
import Alamofire

class RankingTableViewController: UITableViewController  {
    @IBOutlet weak var myRankLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
     
    }
    override func viewDidAppear(_ animated: Bool) {
        
        RankingModel.shared.clearRankings()
        RankingModel.shared.requestRankings { (completion) in
            if completion == 0 {
                self.tableView.reloadData()
            }
        }
    }
    
    func setup(){
        let barColor = UIColor(red: 20.0/255.0, green: 34.0/255.0, blue: 58.0/255.0, alpha: 1.0)
        if let bar = navigationController?.navigationBar{
            bar.isTranslucent = false
            bar.barTintColor = barColor
            bar.titleTextAttributes = [NSForegroundColorAttributeName:UIColor.white]
        }
        myRankLabel.backgroundColor = barColor
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return RankingModel.shared.getRanking().count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "RankingTableViewCell", for: indexPath) as! RankingCell
        
        let ranking = RankingModel.shared.getRanking()[indexPath.row]
        
        cell.numberLabel.text = ranking.number
        cell.nameLabel.text = ranking.name
        cell.levelLabel.text = "Lv. \(ranking.level)"
        cell.expLabel.text = "Exp : \(ranking.exp)"
        
        myRankLabel.text = "🏆내 순위 : \(RankingModel.shared.getMyRank())등🏆"
        return cell
    }
    
    
    @IBAction func toMain(_ sender: UIBarButtonItem) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}








