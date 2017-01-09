//
//  MainController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 3..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit
import AEXML

class MainController: UIViewController {
    
    // MARK: 멤버 필드
    
    @IBOutlet var mainView: UIView!
    
    @IBOutlet weak var startGameBtn: UIButton!
    @IBOutlet weak var juke_shootingStar: UIImageView!
    @IBOutlet weak var main_backgroundStar: UIImageView!
    
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    
    var pulseEffect : LFTPulseAnimation!
    
    
    var receivedName : String = ""
    var receivedProfImg : UIImage = UIImage(named : "album")!
    //var receviedUserSet : [String] = []
    
    var url: String!
   
//    var arraySong : [String] = ["270052873","287320848","18560800","285714919","17179509","200018532","73847634","196942610","261595798","266565177"]
//    var arrayTitle : [String] = ["야생화","숨","사랑한후에","꿈","눈의꽃","해줄수없는일","안녕사랑아","동경","화신","나를넘는다"]
//    
    var itemSort = 1
    var index = 0
    
    var data : String!
    
    var code :[String] = []
    var songName:[String] = []
    var artist :[String] = []
    var start :[Double] = []
    
    // MARK: - 생명주기
  
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //UIFont.systemFont(ofSize: 20)
        
        nickNameLabel.textColor = UIColor.white
        nickNameLabel.font = UIFont.systemFont(ofSize: 20)
        levelLabel.font = UIFont(name: "EXO-REGULAR", size: 16)
        
        
        
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        
        aniPulse(90)
        aniPulse(125)
        aniPulse(160)
        aniPulse(170)
        
        
        
        
        
        //print(receviedUserSet)
        
        // Do any additional setup after loading the view.
        
        
        getSongXmlFromServer()
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        aniBackgroundStar(pic: main_backgroundStar)
        
        
        
        nickNameLabel.text = receivedName
        profileImage.image = receivedProfImg
        
        
        let user = UserDefaults.standard
        
        if let result = user.stringArray(forKey: "user")
        {
            levelLabel.text = "LV.\(result[3])"
        }
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    @IBAction func startGameBtn(_ sender: UIButton) {
        print("노래를 준비중..")
        self.performSegue(withIdentifier: "MainToSegue", sender: self)
        print("노래를 보냈음..")
    }
    
    // MARK: - Method
    
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
        
        
        
        
        if segue.identifier == "MainToSegue"
        {
            
            let destination = segue.destination as! GameController
            destination.roundList = makeList()
        }
        
    }
    
    
    // MARK: - Animation
    // 가운데 별 회전 애니메이션
    
    func aniBackgroundStar(pic : UIImageView){
        let duration = 35.0
        let delay = 0.0
        let fullRotation = CGFloat(M_PI*2)
        let options = UIViewKeyframeAnimationOptions.calculationModeLinear
        
        UIView.animateKeyframes(withDuration: duration, delay: delay, options:  options, animations: {
            UIView.setAnimationRepeatCount(Float.infinity)
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/3, animations: {
                pic.transform = CGAffineTransform(rotationAngle: (1/3) * fullRotation)
            })
            UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
                pic.transform = CGAffineTransform(rotationAngle: (2/3) * fullRotation)
            })
            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
                pic.transform = CGAffineTransform(rotationAngle: (3/3) * fullRotation)
            })
            
        })
        
    }
    
    // 물 퍼지는 듯한 애니메이션
    
    func aniPulse(_ radius :Float){
        pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:CGFloat(radius), position:mainView.center)
        view.layer.insertSublayer(self.pulseEffect, below: juke_shootingStar.layer)
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
    
    
    func printSongList() {
        
        for cc in code {
            print("code : \(cc)")
        }
        for ss in songName {
            print("name : \(ss)")
        }
        for aa in artist {
            print("artist : \(aa)")
        }
        for tt in start {
            print("time : \(tt)")
        }
    }
    
    
    
    
}
