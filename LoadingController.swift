//
//  LoadingController.swift
//  TicSong_Media
//
//  Created by 윤민섭 on 2017. 1. 14..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit
import Alamofire
import AEXML

class LoadingController: UIViewController {

    var code :[String] = []
    var songName:[String] = []
    var artist :[String] = []
    var start :[Double] = []
    
    var url: String!
    
    var itemSort = 1
    var index = 0
    
    var data : String!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        TicSongLoadingView.shared.showProgressView(view)
        getSongXmlFromServer()
    }

    override func viewDidAppear(_ animated: Bool) {
        if !MainController.loadingPref{
            self.dismiss(animated: true, completion: nil)
        }
        else if MainController.loadingPref{
            readySongs()
            
        }
    }
    

    
   
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
        
    func readySongs(){
        self.performSegue(withIdentifier: "LoadingToGame", sender: self)

    }
    
    
    func random() -> Int {
        let random = Int(arc4random_uniform(UInt32(songName.count)))
        return random
    }
    
    func makeList() -> [(code:String,songName:String,artist:String,start:Double)]{
        var list:[(code:String,songName:String,artist:String,start:Double)] = []
        var indexList:[Int] = []
        var index = 0
        
        while indexList.count != 5 {
            index = random()
            if(!indexList.contains(index)){
                url = "https://api.soundcloud.com/tracks/"+code[index]+"/stream?client_id=59eb0488cc28a2c558ecbf47ed19f787"
                let fileURL = NSURL(string:url)
                if NSData(contentsOf:fileURL! as URL) != nil {
                    indexList.append(index)
                    list.append((code:code[index],songName:songName[index],artist:artist[index],start:start[index]))
                }else{
                    print(code[index] + " 노래제목 : " + songName[index])
                }
            }
        }
        
        //print(indexList)
        return list
    }

    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
       
        if segue.identifier == "LoadingToGame"
        {
            let destination = segue.destination as! GameController
            destination.roundList = makeList()
        }

    }
 
    
    
    func getSongXmlFromServer() {
        let url: URL = URL(string: "http://52.79.152.130/TicSongServer/songs?type=xml")!
        let doc = xmlDocumentFromURL(url: url)
        parseSongXml(doc: doc)
    }
    
    func parseSongXml(doc: AEXMLDocument) {
        
        
        if let songs = doc.root["string-array"].all {
            for song in songs {
                for child in song.children {
                    
                    data = String(describing: child.value)
                    
                    switch itemSort {
                        
                    case 1:
                        code.append(child.value!)
                        itemSort += 1
                    case 2:
                        songName.append(child.value!)
                        //print("index : \(index) | name : \(data.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines))")
                        itemSort += 1
                    case 3:
                        artist.append(child.value!)
                        itemSort += 1
                    default:
                        start.append(Double(child.value!)!)
                        itemSort = 1
                        //index += 1
                    }
                }
            }
        }
        
        //printSongList()
    }
    
    func xmlDocumentFromURL(url: URL) -> AEXMLDocument {
        var xmlDocument = AEXMLDocument()
        
        do {
            let data = try Data.init(contentsOf: url)
            xmlDocument = try AEXMLDocument(xml: data)
        } catch {
            print(error)
        }
        return xmlDocument
    }
    


}
