//
//  MainController.swift
//  TicSong_Media
//
//  Created by 전한경 on 2017. 1. 3..
//  Copyright © 2017년 jeon. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController ,AVAudioPlayerDelegate{
    
    // MARK: 멤버 필드
    @IBOutlet var mainView: UIView!
    @IBOutlet weak var startGameBtn: UIButton!
    @IBOutlet weak var juke_shootingStar: UIImageView!
    @IBOutlet weak var main_backgroundStar: UIImageView!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var levelLabel: UILabel!
    @IBOutlet weak var rankingLabel: UIButton!
    // 경험치 관련
    @IBOutlet weak var expText: UILabel!
    @IBOutlet weak var expBar: UIImageView!
    let barSize : Int = 20
    
    // 아이템 레이블
    @IBOutlet weak var item1Label: UILabel!
    @IBOutlet weak var item2Label: UILabel!
    @IBOutlet weak var item3Label: UILabel!
    @IBOutlet weak var item4Label: UILabel!
    
    
    // 배경음
    var bgMusic: AVAudioPlayer!
    let setting = UserDefaults.standard
    var bgmState : Bool = false
    
    
    // 애니메이션
    var pulseEffect : LFTPulseAnimation!
    
    
    // 카카오톡 프로필 및 이름
    var receivedName : String = ""
    var receivedProfImg : UIImage = UIImage(named : "default")!
    
    // 백그라운드 큐
    let backgroundQueue = DispatchQueue(label: "com.app.queue",
                                        qos: .background,
                                        target: nil)
    
    // user defaults
    let ud = UserDefaults.standard
    
    // MARK: - 생명주기
  
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        aniBackgroundStar(pic: main_backgroundStar)
       
        if ud.string(forKey: "setting") == "1" {
            playBgm()
        }else{
            if bgmState == true{
                bgMusic.stop()
            }
        }
        
        levelLogic()
    }
    
    func setup(){
        if UserModel.shared.guestMode == 1{
            rankingLabel.isHidden = true
        }
        profileImage.layer.borderWidth = 1
        profileImage.layer.masksToBounds = false
        profileImage.layer.borderColor = UIColor.black.cgColor
        profileImage.layer.cornerRadius = profileImage.frame.height/2
        profileImage.clipsToBounds = true
        
        
        aniPulse(90)
        aniPulse(125)
        aniPulse(160)
        aniPulse(170)
        
        nickNameLabel.text = receivedName
        profileImage.image = receivedProfImg
        
        if UserModel.shared.guestMode  == 1 {
            basicAlert(string:"🍄WARNING🍄", message:"Guest Login에서는 \n일부 기능이 제한되오니\n 다른 Login Platform 선택하여 \n플레이하시는 것을 추천합니다.")
        }
    }
    
    func levelLogic(){
        if UserModel.shared.guestMode == 0 {
            if let result = ud.stringArray(forKey: "user") {
                let myLevel = Int(result[3])!
                let myExp = Int(result[2])!
                var countBar = 0
                var oneBarExpSize = 0
                
                levelLabel.text = "LV.\(myLevel)"
                let forLevelUpExp = expArray[myLevel-1]
                
                
                if myLevel == 1{
                    oneBarExpSize = forLevelUpExp / barSize
                    countBar = myExp / oneBarExpSize
                    expText.text = "(\(myExp)/100)"
                }else{
                    
                    oneBarExpSize = ( forLevelUpExp - expArray[myLevel-2] ) / barSize
                    countBar = ( myExp - expArray[myLevel-2] ) / oneBarExpSize
                    expText.text = "(\(myExp-expArray[myLevel-2])/\(forLevelUpExp-expArray[myLevel-2]))"
                }
                
                expBar.image = UIImage(named: "bar\(countBar)")
                
                let itemLabelArray: [UILabel] = [self.item1Label,self.item2Label,self.item3Label,self.item4Label]
                
                for item in 0..<4 {
                    if Int(result[item+4])! > 99{
                        itemLabelArray[item].text = ".."
                    }else{
                        itemLabelArray[item].text = result[item+4]
                    }
                }
            }
        } else {
            levelLabel.text = "LV.\(0)"
            expText.text = "(0)"
            expBar.image = UIImage(named: "bar\(0)")
            let itemLabelArray: [UILabel] = [self.item1Label,self.item2Label,self.item3Label,self.item4Label]
            
            for item in 0..<4 {
                itemLabelArray[item].text = "0"
            }
        }
    }
    
    // 물 퍼지는 듯한 애니메이션
    func aniPulse(_ radius :Float){
        pulseEffect = LFTPulseAnimation(repeatCount: Float.infinity, radius:CGFloat(radius), position:mainView.center)
        view.layer.insertSublayer(self.pulseEffect, below: juke_shootingStar.layer)
    }
    
    // 배경음악
    func playBgm(){
        bgmState = true
        let path = Bundle.main.path(forResource: "jellyfish", ofType:"mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            bgMusic = try AVAudioPlayer(contentsOf: url)
            bgMusic.prepareToPlay()
            bgMusic.volume = 1.0
            bgMusic.delegate = self
            bgMusic.play()
        } catch { }
    }
    
    
    // MARK : 게임 set 과 준비
    
    @IBAction func startGameBtn(_ sender: UIButton) {
        loadProgress()
        if setting.string(forKey: "setting") == "1" {
            self.bgMusic.stop()
        }
        backgroundQueue.async {
            MainModel.shared.getSongXmlFromServer()
            self.readySongs()
        }
    }
    
    func readySongs(){
        self.performSegue(withIdentifier: "MainToGameSegue", sender: self)
    }

    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "MainToGameSegue"
        {
            let destination = segue.destination as! GameViewController
            destination.roundList = MainModel.shared.makeList()
            dismiss(animated: false, completion: nil)
        }
    }
    
    
    func loadProgress(){
        let alert = UIAlertController(title: nil, message: " 노래를 준비중입니다...🎶", preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:10, y:5, width:50, height:50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func unwindToMain(_ sender: UIStoryboardSegue) {

    }

   }
