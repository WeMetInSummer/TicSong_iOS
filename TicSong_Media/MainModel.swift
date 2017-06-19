//
//  MainModel.swift
//  TicSong_Media
//
//  Created by 윤민섭 on 2017. 6. 20..
//  Copyright © 2017년 jeon. All rights reserved.
//

import Foundation
import AEXML

class MainModel{
    
    static let shared = MainModel()
    
    private var data : String!
    private var code :[String] = []
    private var songName:[String] = []
    private var artist :[String] = []
    private var start :[Double] = []
    private var itemSort = 1

    
    // MARK: - 서버 준비!
    
    func getSongXmlFromServer() {
        let url: URL = URL(string: API.server + "TicSongServer/songs?type=xml")!
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
                        itemSort += 1
                    case 3:
                        artist.append(child.value!)
                        itemSort += 1
                    default:
                        start.append(Double(child.value!)!)
                        itemSort = 1
                    }
                }
            }
        }
        
    }
    
    func xmlDocumentFromURL(url: URL) -> AEXMLDocument {
        var xmlDocument = AEXMLDocument()
        
        do {
            let data = try Data.init(contentsOf: url)
            xmlDocument = try AEXMLDocument(xml: data)
        } catch {
            
        }
        return xmlDocument
    }
    
    func getCode() -> [String]{
        return code
    }
    
    func getSongName() -> [String]{
        return songName
    }
    
    func getArtist() -> [String]{
        return artist
    }
    
    func getStartPoint() -> [Double] {
        return start
    }

}
