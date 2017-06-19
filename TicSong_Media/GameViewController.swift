//
//  GameController.swift
//  TicSong_Media
//
//  Created by 윤민섭X전한경on 2017. 1. 2..
//  Copyright © 2017년 yoon. All rights reserved.
//




import UIKit
import AVFoundation
import Alamofire
import ActionButton

class GameViewController: UIViewController , AVAudioPlayerDelegate {
    
    
    // MARK: 멤버 필드
    
    @IBOutlet weak var stageLabel: UILabel!
    
    @IBOutlet weak var answer: UITextField!
    
    @IBOutlet weak var juke_shootingStar: UIImageView!
    
    @IBOutlet weak var main_backgroundStar: UIImageView!
    
    @IBOutlet weak var escapeBtn: UIButton!
    
    @IBOutlet weak var lifeOne: UIImageView!
    
    @IBOutlet weak var lifeTwo: UIImageView!
    
    @IBOutlet weak var lifeThree: UIImageView!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    var randomItemIndex : Int = 0 // result view 를 위한 변수
    var gameScore : Int = 0  // result view 를 위한 변수
    
    var actionButton: ActionButton!
    
    let expArr : [Int] = expArray
    
    var audioPlayer:AVAudioPlayer = AVAudioPlayer()
    
    var url : String!
    var timer = Timer() // 노래 시간 설정시 사용
    var musicSec = 0
    var startTime : Double!
    var roundList:[(code:String,songName:String,artist:String,start:Double)] = []
    
    var hintMode: Int = 0 // 0 : 일반 재생 1 : 힌트 재생
    
    var score : Int = 0
    var life : Int = 3
    var stage : Int = 0
    
    var itemReuseCheck : Int = 0
    var items : [ActionButtonItem] = []
    var image : UIImage? = nil
    
    var user = UserDefaults.standard
    
    final let COUNT_ITEM : String = "0"
    
    //MARK: 생명주기
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    override func viewDidAppear(_ animated: Bool) {

        aniBackgroundStar(pic: main_backgroundStar)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    
    func setup(){
        let randomForFloatBtn : Int = Int(arc4random_uniform(UInt32(7)))+1
        image = UIImage(named:"FloatBtn\(randomForFloatBtn)")
        
        stageLabel.text = " STAGE \(stage+1)"
        answer.autocorrectionType = .no
        
        musicSetting(music: roundList[stage].code, time: roundList[stage].start)
        
        if let result = user.stringArray(forKey: "user"){
            GameModel.shared.userSet = result
        }
        
        if LoginModel.shared.guestMode == 0{
            makeFloatBtn()
        }
    }
   
    // 플로팅 버튼에 대한 액션을 만든다.
    
    func makeAction(_ items : [ActionButtonItem]){
        actionButton = nil
        actionButton = ActionButton(attachedToView: view, items: items)
        actionButton.action = { button in button.toggleMenu() }
        actionButton.setTitle("Item", forState: UIControlState())
        actionButton.setImage(image, forState: UIControlState())
        actionButton.backgroundColor = UIColor(red: 242.0/255.0, green: 238.0/255.0, blue: 186.0/255.0, alpha:1.0)
    }
    
    // 플로팅 버튼을 리셋팅
    
    func resetActionBtn(_ action : ActionButtonItem){
        actionButton.close()
        let index = items.index(of: action)
        items.remove(at: index!)
        makeAction(items)
    }
    
    func makeFloatBtn(){
        //액션 버튼 초기화
        actionButton = nil
        //아이템 초기화
        items.removeAll()
        let hint_singerName = UIImage(named:"levelupItem1")
        let hint_firstChar = UIImage(named:"levelupItem2")
        let hint_threeSec = UIImage(named:"levelupItem3")
        let hint_selectStart = UIImage(named:"levelupItem4")
       
        let singerName = ActionButtonItem(title: itemCounting(GameModel.shared.userSet[4]), image: hint_singerName)
        singerName.action = { item in
            if (GameModel.shared.userSet[4] != self.COUNT_ITEM){
                self.singerAlert(artist: self.roundList[self.stage].artist)
                self.resetActionBtn(singerName)
                GameModel.shared.userSet[4] = String(Int(GameModel.shared.userSet[4])!-1)
                // Item Update API
                GameModel.shared.itemUpdate()
            }else{
                
            }
        }
        
        
        let firstChar = ActionButtonItem(title: itemCounting(GameModel.shared.userSet[5]), image: hint_firstChar)
        firstChar.action = { item in
            if (GameModel.shared.userSet[5] != self.COUNT_ITEM){
                self.firstCharAlert(songName: self.roundList[self.stage].songName)
                self.resetActionBtn(firstChar)
                GameModel.shared.userSet[5] = String(Int(GameModel.shared.userSet[5])!-1)
                // Item Update API
                GameModel.shared.itemUpdate()
            }else{
            }
        }
        
        
        let threeSec = ActionButtonItem(title: itemCounting(GameModel.shared.userSet[6]), image: hint_threeSec)
        threeSec.action = { item in
            if (GameModel.shared.userSet[6] != self.COUNT_ITEM){
                self.hintMode = 1
                self.playMusic()
                aniStar(pic: self.juke_shootingStar, aniDuration: 4.0)
                self.resetActionBtn(threeSec)
                GameModel.shared.userSet[6] = String(Int(GameModel.shared.userSet[6])!-1)
                
                // Item Update API
                GameModel.shared.itemUpdate()
            }else{
                
            }
        }
        
        let selectStart = ActionButtonItem(title: itemCounting(GameModel.shared.userSet[7]), image: hint_selectStart)
        selectStart.action = { item in
             if (GameModel.shared.userSet[7] != self.COUNT_ITEM){
                self.inputSecAlert()
                self.resetActionBtn(selectStart)
                GameModel.shared.userSet[7] = String(Int(GameModel.shared.userSet[7])!-1)
                
                // Item Update API
                GameModel.shared.itemUpdate()
             }else{
             }
        }
        items.append(selectStart)
        items.append(threeSec)
        items.append(firstChar)
        items.append(singerName)
        
        makeAction(items)
    }
    
    func itemCounting(_ item : String) -> String{

        if Int(item)! > 9 {
            return item
        }else{
            return " " + item + " "
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        answer.endEditing(true)
        self.bottomConstraint.constant = 0
    }
    
    func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(show: true, notification: notification)
    }
    
    func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(show: false, notification: notification)
        
    }
    
    func adjustingHeight(show:Bool, notification:NSNotification) {
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let changeInHeight = (keyboardFrame.height) * (show ? 1 : -1)
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.bottomConstraint.constant += changeInHeight
        })
    }
    
    @IBAction func Play(_ sender: UIButton) {
        hintMode = 0
        if(stage < roundList.count){
            playMusic()
            aniStar(pic: juke_shootingStar, aniDuration: 2.0)
        }
    }
    
    @IBAction func Check(_ sender: UIButton) {
        
       let isMatch = compareCharacter(origin: roundList[stage].songName, input: answer.text!)
       if isMatch {
        
        if(life == 3){score += 100}
        else if(life == 2){score += 60}
        else if(life == 1){score += 30}
        else{score += 0}
        
        nextStageInit(checkMsg: "정답입니다👍")
        answer.text = ""
        
        }else if !isMatch{
             life -= 1
                if(life == 0){
                    nextStageInit(checkMsg:"아쉽군요🤔")
                    score += 0
                }else{
                    showToast("틀렸습니다🙅🏻")
                }
        }
        lifeCreate()
    }
    
    // 패스 버튼
    
    @IBAction func Pass(_ sender: UIButton) {
        nextStageInit(checkMsg:"패스 사용")
        self.answer.endEditing(true)
        score += 0
    }
    
   
    @IBAction func Escape(_ sender: UIButton) {
        escapeAlert(score: score)
    }
    
    func musicSetting(music: String, time:Double){
        answer.placeholder = "정답을 입력해주세요.(원곡제목)"
        GameModel.shared.setMusic(name: music, time: time)
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            if let data = GameModel.shared.getSoundData(){
                self.audioPlayer = try AVAudioPlayer(data: data as Data)
                audioPlayer.prepareToPlay()
                audioPlayer.volume = 1.0
                audioPlayer.delegate = self
                audioPlayer.currentTime = startTime
            }
        } catch {
            
        }
    }
    
    
    func counter() {
        musicSec += 1
        if musicSec > 1 && hintMode == 0{
            audioPlayer.stop() // 지정한 시간이 지나면 스톱
            timer.invalidate()   // 타이머를 다시 0초로
        }
        else if musicSec > 3 && hintMode == 1{
            audioPlayer.stop() // 지정한 시간이 지나면 스톱
            timer.invalidate()   // 타이머를 다시 0초로
        }
        
    }
    
    func playMusic(){
        timer.invalidate()
        audioPlayer.currentTime = startTime
        musicSec = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameViewController.counter), userInfo: nil, repeats:true)
        audioPlayer.play()
    }
    
    func nextStageInit(checkMsg:String){
        self.bottomConstraint.constant = 0
        if stage < 4 {
            self.loadProgress()
        }
        self.answer.text=""
        timer.invalidate()
        stage += 1
        stageFinishAlert(checkMsg:checkMsg,songTitle: roundList[stage-1].songName, artist: roundList[stage-1].artist)
        life = 3
        audioPlayer.currentTime = 0
        audioPlayer.play()

    }
    
    func nextSong(){
        audioPlayer.stop()
        if(stage < roundList.count){
            stageLabel.text = " STAGE \(stage+1)"
            answer.text = ""
            musicSetting(music: roundList[stage].code, time: roundList[stage].start)
            if LoginModel.shared.guestMode == 0{
                makeFloatBtn()
            }
            dismiss(animated: true, completion: nil)
            answer.endEditing(true)
        }else{
            stageLabel.isHidden = true
            resultAlert(score: score)
        }
        lifeCreate()
    }
    
    
    //정답 체크해주는 함수
    func compareCharacter(origin:String, input:String) -> Bool {
        var compare1 : String = ""
        var compare2 : String = ""
        
        
        for origin in origin.characters {
            if(origin.description != " " && origin.description != "," && origin.description != "-" && origin.description != "!" && origin.description != "&" && origin.description != "'"){
                compare1 += origin.description
            }
        }
        
        for input in input.characters {
            if(input.description != " " && input.description != "," && input.description != "-" && input.description != "!" && input.description != "&" && input.description != "'"){
                compare2 += input.description
            }
        }
        return  compare1.lowercased()==compare2.lowercased()
    }
    
    
    //MARK: Life Reloading
    
    func lifeCreate(){
        if(life == 3){lifeThree.isHidden = false
                     lifeTwo.isHidden = false
                    lifeOne.isHidden = false}
        else if(life == 2){lifeThree.isHidden = true}
        else if(life == 1){lifeTwo.isHidden = true}
        else{lifeOne.isHidden = true}
        
    }
    
    
    // MARK: Alert
    
    func showToast(_ msg:String) {
        let toast = UIAlertController()
        toast.message = msg;
        
        self.present(toast, animated: true, completion: nil)
        let duration = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: duration) {
            toast.dismiss(animated: true, completion: nil)
        }
    }
    
    func stageFinishAlert(checkMsg:String,songTitle:String,artist:String){
    
        let alertView = UIAlertController(title: checkMsg, message: "\(artist) - \(songTitle)", preferredStyle: .alert)
    
        let action = UIAlertAction(title: "네", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.nextSong()
            alertView.dismiss(animated: true, completion: nil)
        })
        alertView.addAction(action)
        
        alertWindow(alertView: alertView)
    }

    //가수 힌트 alert!
    
    func singerAlert (artist : String){
        
        let alertView = UIAlertController(title: "가수 힌트", message: "해당 노래의 가수는 : " + artist, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            alertView.dismiss(animated: true, completion: nil)
        })
        alertView.addAction(action)
        alertWindow(alertView: alertView)

    }
    
    
    // 첫글자 힌트 alert!
    
    func firstCharAlert(songName: String){
        let alertView = UIAlertController(title: "첫글자 힌트", message: "해당 노래의 첫글자는 : " + songName.substring(to: songName.index(after: songName.startIndex)), preferredStyle: .alert)
        
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            alertView.dismiss(animated: true, completion: nil)
        })
        alertView.addAction(action)
        
        alertWindow(alertView: alertView)

    }
    
    // 원하는 구간 힌트 alert!
    
    func inputSecAlert(){
        //1. Create the alert controller.
        let alert = UIAlertController(title: "시작구간 선택힌트", message: "원하는 시작구간(초) 을 입력해주세요!", preferredStyle: .alert)
        
        //2. Add the text field. You can configure it however you need.
        alert.addTextField { (textField) in
            textField.placeholder = "0~180 사이 숫자만 입력해주세요."
        }
        
        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            let textField = alert?.textFields![0] // Force unwrapping because we know it exists.
            if Double((textField?.text)!) != nil {
                if Double((textField?.text)!)! < 180 {
                self.answer.endEditing(true)
                self.audioPlayer.currentTime = Double((textField?.text)!)!
                self.timer.invalidate()
                self.musicSec = 0
                self.hintMode = 1
                aniStar(pic: self.juke_shootingStar, aniDuration: 3.5)
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameViewController.counter), userInfo: nil,repeats:true)
                self.audioPlayer.play()
                }else{
                    basicAlert(string: "꽝",message: "노래의 범위를 벗어났습니다")
                }
            }else{
                basicAlert(string: "꽝",message: "숫자 외 다른 문자를 입력하셨습니다")
            }
        }))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }

    
  
    
    
    func resultAlert(score:Int){
        
        if LoginModel.shared.guestMode == 0 {
            let scoreSum = Int(GameModel.shared.userSet[2])! + score
            let myLevel = Int(GameModel.shared.userSet[3])!
            let random : Int = Int(arc4random_uniform(UInt32(4)))+1
            randomItemIndex = random
            gameScore = score
        
            var levelUp : Bool = false
        
            GameModel.shared.userSet[2] = "\(scoreSum)"
        
            if isLevelUp(scoreSum,myLevel){
                levelUp = true
                GameModel.shared.userSet[random+3] = String(Int(GameModel.shared.userSet[random+3])! + 1)
         
            }
            
            GameModel.shared.myScoreUpdate()
            GameModel.shared.itemUpdate()
        
        
            if levelUp {
                self.performSegue(withIdentifier: "GameToResultLvUp", sender: self)
            }else{
                self.performSegue(withIdentifier: "GameToResult", sender: self)
            }
        }else{
            gameScore = score
            self.performSegue(withIdentifier: "GameToResult", sender: self)
        }
        
    }
    
    func isLevelUp(_ scoreSum : Int ,_ myLevel : Int) -> Bool{
        var mylv = myLevel
        for index in 0..<expArr.count{
            if scoreSum >= expArr[index]{
                mylv = index+2
            }else{
                break
            }
        }
        
        if mylv != myLevel{       
            GameModel.shared.userSet[3] = "\(mylv)"
            return true
        }else{
            return false
        }
        
    }
    
    func escapeAlert(score:Int){
        
        let alertView = UIAlertController(title: "나가기", message: "현재 당신의 점수는 \(score)점 입니다.\n 정말 나가시겠습니까?", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            alertView.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        })
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertView.addAction(action)
        alertView.addAction(cancelAction)
        
        alertWindow(alertView: alertView)

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GameToResultLvUp"{
            let des = segue.destination as! ResultViewControllerLvUp
            des.randomIndex = randomItemIndex
            des.myLevel = GameModel.shared.userSet[3]
            des.myScore = String(gameScore)
        }
        else if segue.identifier == "GameToResult"{
            let des = segue.destination as! ResultViewController
            if LoginModel.shared.guestMode == 0{
            des.myLevel = GameModel.shared.userSet[3]
            }else{
            des.myLevel = "0"
            }
            des.myScore = String(gameScore)
        }
    }
    
    func loadProgress(){
        let alert = UIAlertController(title: nil, message: "  다음 곡을 준비중입니다🎤", preferredStyle: .alert)
        
        alert.view.tintColor = UIColor.black
        let loadingIndicator: UIActivityIndicatorView = UIActivityIndicatorView(frame: CGRect(x:10, y:5, width:50, height:50)) as UIActivityIndicatorView
        loadingIndicator.hidesWhenStopped = true
        loadingIndicator.activityIndicatorViewStyle = UIActivityIndicatorViewStyle.gray
        loadingIndicator.startAnimating();
        
        alert.view.addSubview(loadingIndicator)
        present(alert, animated: true, completion: nil)
    }
    
}

