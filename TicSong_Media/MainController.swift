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
    
    // 경험치 관련
    
    @IBOutlet weak var expText: UILabel!
    @IBOutlet weak var expBar: UIImageView!
    let barSize : Int = 20  // bar 의 개수
    
    // 아이템 관련
    
    @IBOutlet weak var item1Label: UILabel!
    @IBOutlet weak var item2Label: UILabel!
    @IBOutlet weak var item3Label: UILabel!
    @IBOutlet weak var item4Label: UILabel!
    
    
    static let expArray : [Int] =
        [100,600,1200,1900,2700,3600,4600,5700,6900,8200,9700,11400,13300,15400,17700,20200,22900,25800,28900,32200,35800,39700,43900,48400,53200,58300,63700,69400,75400,81700,88450,95650,103300,111400,119950,128950,138400,148300,158650,169450,180650,192250,204250,216650,229450,242650,256250,270250,284650,299450,315000,331300,348350,366150,384700,404000,424050,444850,466400,
         488700,511850,535850,560700,586400,612950,640350,668600,697700,727650,758450,790250,823050,
         856850,891650,927450,964250,1002050,1040850,1080650,1121450,1163750,1207550,1252850,1299650,
         1347950,1398250,1450550,1504850,1561150,1621150,1686150,1761150,1861150,2011150,2261150,2661150,3261150,4261150,7000000,10000000]
    
    
    // 애니메이션
    var pulseEffect : LFTPulseAnimation!
    
    // 카카오톡 프로필 및 이름
    var receivedName : String = ""
    var receivedProfImg : UIImage = UIImage(named : "default")!
    //var receviedUserSet : [String] = []
    
    // 사운드 클라우드 유알엘
    var url: String!
   
//    var arraySong : [String] = ["270052873","287320848","18560800","285714919","17179509","200018532","73847634","196942610","261595798","266565177"]
//    var arrayTitle : [String] = ["야생화","숨","사랑한후에","꿈","눈의꽃","해줄수없는일","안녕사랑아","동경","화신","나를넘는다"]
//    
    
    // 멤버 변수
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
        
        
        getSongXmlFromServer()
        
        
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        aniBackgroundStar(pic: main_backgroundStar)
        
        
        
        nickNameLabel.text = receivedName
        profileImage.image = receivedProfImg
        
        
        let user = UserDefaults.standard
        
        if let result = user.stringArray(forKey: "user")
        {
            let myLevel = Int(result[3])!
            let myExp = Int(result[2])!
            var countBar = 0
            var oneBarExpSize = 0
            print("내 경험치 : \(myExp)")
            
            levelLabel.text = "LV.\(myLevel)"
            let forLevelUpExp = MainController.expArray[myLevel-1]
            print("레벨 업을 위한 경험치 \(forLevelUpExp)")
            
            // 원래 레벨업 까지 필요한 경험치 (다음레벨 - 내 레벨) exp를 레벨업 바 (19개 던가...) 개수로 나누면 레벨업 바 한칸
            // ( 원래 레벨업까지 필요한 경험치 - 내가 레벨업까지 남은 경험치 = 내가 채운 경험치 ) / 레벨업 바 한칸 경험치 = 레벨업 바 개수
            
            // exp bar 개수 : 20개
            if myLevel == 1{
               oneBarExpSize = forLevelUpExp / barSize
               countBar = myExp / oneBarExpSize
                expText.text = "(\(myExp)/100)"
            }else{
            
                oneBarExpSize = ( forLevelUpExp - MainController.expArray[myLevel-2] ) / barSize // oneBarExpSize 는 내가 레벨업에 필요한 경험치 bar의한칸의 경험치
                countBar = ( myExp - MainController.expArray[myLevel-2] ) / oneBarExpSize
                expText.text = "(\(myExp-MainController.expArray[myLevel-2])/\(forLevelUpExp-MainController.expArray[myLevel-2]))"
                
            }
            
            expBar.image = UIImage(named: "bar\(countBar)")
            
            
            item1Label.text = result[4]
            item2Label.text = result[5]
            item3Label.text = result[6]
            item4Label.text = result[7]
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
