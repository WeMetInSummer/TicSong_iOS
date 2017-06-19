//
//  Ranking.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 14..
//  Copyright © 2017년 jeon. All rights reserved.
//

import Foundation


class RankingVO {
    
    //MARK: Properties
    var number : String
    var name: String
    var exp : String
    var level : String
    
    //MARK: Initialization
    
    init?(number: String, name: String, exp : String, level : String) {
        
        // Initialize stored properties.
        self.number = number
        self.name = name
        self.exp = exp
        self.level = level
        
        if(number.isEmpty || name.isEmpty || exp.isEmpty || level.isEmpty){
            return nil
        }
    }
}
