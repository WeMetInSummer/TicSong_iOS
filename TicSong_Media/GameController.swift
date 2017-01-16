//
//  GameController.swift
//  TicSong_Media
//
//  Created by 윤민섭X전한경on 2017. 1. 2..
//  Copyright © 2017년 yoon. All rights reserved.
//


/* 2017.01.03
 1. 노래 리스트업 10곡 선정 V
 2. 점수 기능 (3번의 목숨이 있으며 1번에 맞추면 100점 2번에 맞추면 60점 3번에 맞추면 30점) V
 3. 아이템 (1. 3초 재생 2. 타이틀 앞 글자 제공 3. 목숨 늘려주기) - 보류
 4. 노래 맞추면 노래 재생 (stop 도 생김) + widget visible /invisible 가능 하게
 5. 라운드 개념 넣기(5곡이 한 라운드로 가정하고 라운드 중간에 종료시 점수는 무효 / 모든 점수를 합산해서 ResultController로 전송) - 보류
 6. ResultController 로 넘어갈 수 있게 prepareSegue 준비 - 다이얼로그 가능성 제기
 7. ResultController에서 unwindSegue로 값 받아서 서버로 전송하기 - 보류
 8. MainController에서 서버에서 불러온 현재의 exp와 level , item 현황 등 을 제공한다. - 보류
 9. 소셜로그인 카카오톡 추가 - 보류
 10. 랭킹 테이블뷰 생성하고 서버에서 불러와서 뿌리기 - 보류
 */

import UIKit
import AVFoundation
import Alamofire
import ActionButton

class GameController: UIViewController , AVAudioPlayerDelegate {
    
    
    // MARK: 멤버 필드

    
    @IBOutlet weak var stageLabel: UILabel!
    
    @IBOutlet weak var answer: UITextField!
    
    @IBOutlet weak var juke_shootingStar: UIImageView!
    
    @IBOutlet weak var main_backgroundStar: UIImageView!
    
    @IBOutlet weak var escapeBtn: UIButton!
    
    @IBOutlet weak var lifeOne: UIImageView!
    
    @IBOutlet weak var lifeTwo: UIImageView!
    
    @IBOutlet weak var lifeThree: UIImageView!
    
    var randomItemIndex : Int = 0 // result view 를 위한 변수
    var gameScore : Int = 0  // result view 를 위한 변수
    
    var actionButton: ActionButton!
    
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    
    let expArr : [Int] = MainController.expArray
    
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
    let image = UIImage(named:"earthFloatBtn")
    
    // 디폴트
    var userSet : [String] = []
    let user = UserDefaults.standard
    
    final let COUNT_ITEM : String = "0"
    
    //MARK: 생명주기
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stageLabel.text = " STAGE \(stage+1)"
        answer.autocorrectionType = .no
        setting(music: roundList[stage].code, time: roundList[stage].start)
        
        if let result = user.stringArray(forKey: "user"){
            userSet = result
        }
        makeFloatBtn()
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
       
        let singerName = ActionButtonItem(title: itemCounting(userSet[4]), image: hint_singerName)
        singerName.action = { item in
            if (self.userSet[4] != self.COUNT_ITEM){
                self.singerAlert(artist: self.roundList[self.stage].artist)
                self.resetActionBtn(singerName)
                self.userSet[4] = String(Int(self.userSet[4])!-1)
                // Item Update API
                self.itemUpdate()
                self.user.set(self.userSet, forKey: "user")
            }else{
            }
        }
        
        
        let firstChar = ActionButtonItem(title: itemCounting(userSet[5]), image: hint_firstChar)
        firstChar.action = { item in
            if (self.userSet[5] != self.COUNT_ITEM){
                self.firstCharAlert(songName: self.roundList[self.stage].songName)
                self.resetActionBtn(firstChar)
                self.userSet[5] = String(Int(self.userSet[5])!-1)
                // Item Update API
                self.itemUpdate()
                self.user.set(self.userSet, forKey: "user")
            }else{
            }
        }
        
        
        let threeSec = ActionButtonItem(title: itemCounting(userSet[6]), image: hint_threeSec)
        threeSec.action = { item in
            if (self.userSet[6] != self.COUNT_ITEM){
                self.hintMode = 1
                self.playMusic()
                self.aniStar(pic: self.juke_shootingStar, aniDuration: 4.0)
                self.resetActionBtn(threeSec)
                self.userSet[6] = String(Int(self.userSet[6])!-1)
                
                // Item Update API
                self.itemUpdate()
                self.user.set(self.userSet, forKey: "user")
            }else{
            }
        }
        
        let selectStart = ActionButtonItem(title: itemCounting(userSet[7]), image: hint_selectStart)
        selectStart.action = { item in
             if (self.userSet[7] != self.COUNT_ITEM){
                self.inputSecAlert()
                self.resetActionBtn(selectStart)
                self.userSet[7] = String(Int(self.userSet[7])!-1)
                
                // Item Update API
                self.itemUpdate()
                self.user.set(self.userSet, forKey: "user")
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
    
    override func viewDidAppear(_ animated: Bool) {
        // 배경화면 돌아가게 한다.
        aniBackgroundStar(pic: main_backgroundStar)

        // 키패드에게 알림을 줘서 키보드가 보여질 때 사라질 때의 함수를 실행시킨다
        NotificationCenter.default.addObserver(self, selector: #selector(GameController.keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(GameController.keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    // 다른 화면 누르면 키패드 사라지기
    
    override func touchesBegan(_ touches: Set<UITouch>, with: UIEvent?) {
        answer.endEditing(true) // textBox는 textFiled 오브젝트 outlet 연동할때의 이름.
        self.bottomConstraint.constant = 0
    }
    
    // 키보드가 보여지면..
    func keyboardWillShow(notification:NSNotification) {
        adjustingHeight(show: true, notification: notification)
        
    }
    
    // 키보드가 사라지면..
    func keyboardWillHide(notification:NSNotification) {
        adjustingHeight(show: false, notification: notification)
        
    }
    
    // 높이를 조정한다 ..
    func adjustingHeight(show:Bool, notification:NSNotification) {
        var userInfo = notification.userInfo!
        let keyboardFrame:CGRect = (userInfo[UIKeyboardFrameBeginUserInfoKey] as! NSValue).cgRectValue
        let animationDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        let changeInHeight = (keyboardFrame.height) * (show ? 1 : -1)
        UIView.animate(withDuration: animationDuration, animations: { () -> Void in
            self.bottomConstraint.constant += changeInHeight
            
        })
        
    }
    
  
   //MARK: 각종 버튼

    @IBAction func Play(_ sender: UIButton) {
        hintMode = 0
        if(stage < roundList.count){
            playMusic()
            aniStar(pic: juke_shootingStar, aniDuration: 2.0)
        }else{
            
        }
        
    }
    
 
   
    
    @IBAction func Check(_ sender: UIButton) {
        
       let isMatch = compareCharacter(origin: roundList[stage].songName, input: answer.text!)
       if isMatch {
        
        if(life == 3){score += 100}
        else if(life == 2){score += 60}
        else if(life == 1){score += 30}
        else{score += 0}
        
        nextStageInit()
        answer.text = ""
        self.answer.endEditing(true)
        
        }else if !isMatch{
             life -= 1
            showToast("틀렸습니다!")
                if(life == 0){
                    self.answer.endEditing(true)
                    nextStageInit()
                    score += 0
                }
        }
        lifeCreate()
    }
    
    // 패스 버튼
    
    @IBAction func Pass(_ sender: UIButton) {
        nextStageInit()
        score += 0
    }
    
   
    @IBAction func Escape(_ sender: UIButton) {
        escapeAlert(score: score)
    }
   //MARK: 노래 재생 설정
    
    func setting(music: String, time:Double){
        answer.placeholder = "정답을 입력해주세요 (원곡제목)"
        
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            setSong(name: music, time: time)
            let fileURL = NSURL(string:url)
            if let soundData = NSData(contentsOf:fileURL! as URL) {
                self.audioPlayer = try AVAudioPlayer(data: soundData as Data)
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
    
    // 노래제목을 설정 하는 함수
    
    func setSong(name: String,time: Double){
        url = "https://api.soundcloud.com/tracks/"+name+"/stream?client_id=59eb0488cc28a2c558ecbf47ed19f787"
        if(time != 0){
        startTime = time/1000.0
        }else{
            startTime = time
        }
    }
    
    // 노래 재생 하는 함수
    
    func playMusic(){
        timer.invalidate()
        audioPlayer.currentTime = startTime
        musicSec = 0
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameController.counter), userInfo: nil, repeats:true)
        audioPlayer.play()
    }
    
    func nextStageInit(){
        self.answer.text=""
        timer.invalidate()
        stage += 1
        stageFinishAlert(songTitle: roundList[stage-1].songName, artist: roundList[stage-1].artist)
        life = 3
        audioPlayer.currentTime = 0
        audioPlayer.play()

    }
    
    func nextSong(){
        
        audioPlayer.stop()
        
        if(stage < roundList.count){
            stageLabel.text = " STAGE \(stage+1)"
            answer.text = ""
            setting(music: roundList[stage].code, time: roundList[stage].start)
            makeFloatBtn()

        }else{
            stageLabel.isHidden = true
            resultAlert(score: score)
        }
        lifeCreate()
    }
    
    
    //정답 체크해주는 함수
    func compareCharacter(origin:String, input:String) -> Bool
    {
        var compare1 : String = ""
        var compare2 : String = ""
        
        //, - ! 문자 예외처리 포함!
        
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
    
    
    // MARK: 여러가지 Alert
    
    func showToast(_ msg:String) {
        let toast = UIAlertController()
        toast.message = msg;
        
        self.present(toast, animated: true, completion: nil)
        let duration = DispatchTime.now() + Double(Int64(2 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)
        
        DispatchQueue.main.asyncAfter(deadline: duration) {
            toast.dismiss(animated: true, completion: nil)
        }
    }
    
    func stageFinishAlert(songTitle:String,artist:String){
    
        let alertView = UIAlertController(title: songTitle, message: artist, preferredStyle: .alert)
    
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            self.nextSong()
            alertView.dismiss(animated: true, completion: nil)
        })
        alertView.addAction(action)
        
        alertWindow(alertView: alertView)
    }

    //가수 힌트 alert!
    
    func singerAlert (artist : String){
        
        let alertView = UIAlertController(title: "가수힌트", message: "해당 노래의 가수는 : " + artist, preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            alertView.dismiss(animated: true, completion: nil)
        })
        alertView.addAction(action)
        alertWindow(alertView: alertView)

    }
    
    
    // 첫글자 힌트 alert!
    
    func firstCharAlert(songName: String){
        let alertView = UIAlertController(title: "첫글자힌트", message: "해당 노래의 첫글자는 : " + songName.substring(to: songName.index(after: songName.startIndex)), preferredStyle: .alert)
        
        
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
            // 사용자가 한글 입력은 안되고 노래 전체구간 사이를 입력했을 경우만 들려준다.
            if Double((textField?.text)!) != nil {
                if Double((textField?.text)!)! < 180 {
                self.answer.endEditing(true)
                self.audioPlayer.currentTime = Double((textField?.text)!)!
                self.timer.invalidate()
                self.musicSec = 0
                self.hintMode = 1
                self.aniStar(pic: self.juke_shootingStar, aniDuration: 3.5)
                self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(GameController.counter), userInfo: nil,repeats:true)
                self.audioPlayer.play()
                }else{
                    self.basicAlert(string: "꽝",message: "노래의 범위를 벗어났")
                }
            }else{
                self.basicAlert(string: "꽝",message: "숫자 외 다른 문자를 입력하셨")
            }
        }))
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }

    
  
    
    
    func resultAlert(score:Int){
        
        let scoreSum = Int(userSet[2])! + score
        let myLevel = Int(userSet[3])! // 내 레벨
        let random : Int = Int(arc4random_uniform(UInt32(4)))+1
        randomItemIndex = random // segue 로 넘기기 위한 변수
        gameScore = score // segue 로 넘기기 위한 변수
        
        var levelUp : Bool = false
        
        //총 경험치를 userSet의 두번째 인덱스에 넣어주고
        self.userSet[2] = "\(scoreSum)"
        
        //레벨업한 경우에만 아이템을 하나 더 준다.
        if isLevelUp(scoreSum,myLevel){
            levelUp = true
            self.userSet[random+3] = String(Int(self.userSet[random+3])! + 1)
         
        }
        //레벨업을 하거나 하지않거나 해서 나온 결과들을 프리퍼런스에 저장시키고
        self.user.set(self.userSet, forKey: "user")

        //그값들을 동일하게 서버에 저장시킨다.
        // Update MyScore, Item 
        myscoreUpdate()
        itemUpdate()
        
        
        if levelUp {
            self.performSegue(withIdentifier: "GameToResultLvUp", sender: self)
 
        } else{
            self.performSegue(withIdentifier: "GameToResult", sender: self)
        }
        
        
    }
    
    // 레벨업 할 수 있나 없나 체크!
    func isLevelUp(_ scoreSum : Int ,_ myLevel : Int) -> Bool{
        var mylv = myLevel
        for index in 0..<expArr.count{
            if scoreSum >= expArr[index]{
                mylv = index+2
            }else{
                break
            }
        }
        
        if mylv != myLevel{       //내 레벨이 바뀌었으면
            self.userSet[3] = "\(mylv)"
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
    
    func basicAlert(string : String,message : String){
        let alertView = UIAlertController(title: string+"!", message: message+"습니다.", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            alertView.dismiss(animated: true, completion: nil)
        })
        
        alertView.addAction(action)
        
        alertWindow(alertView: alertView)
    }
    
      
    //MARK: ANIMATION
    
    func aniStar(pic : UIImageView, aniDuration : Double){
        var duration = 1.0
        duration = aniDuration
        let delay = 0.0
        let fullRotation = CGFloat(M_PI*2)
        let options = UIViewKeyframeAnimationOptions.calculationModeLinear
        
        UIView.animateKeyframes(withDuration: duration, delay: delay, options:  options, animations: {
            //UIView.setAnimationRepeatCount(1)
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 1/3, animations: {
                pic.transform = CGAffineTransform(rotationAngle: -(1/3) * fullRotation)
            })
            UIView.addKeyframe(withRelativeStartTime: 1/3, relativeDuration: 1/3, animations: {
                pic.transform = CGAffineTransform(rotationAngle: -(2/3) * fullRotation)
            })
            UIView.addKeyframe(withRelativeStartTime: 2/3, relativeDuration: 1/3, animations: {
                pic.transform = CGAffineTransform(rotationAngle: -(3/3) * fullRotation)
            })
            
        })
        
    }
    
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
    
    // alertWindow 중복 제거
    
    func alertWindow(alertView: UIAlertController){
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertView, animated: true, completion: nil)
    }

    
    
    //MARK: SERVER 통신 함수
    
    // Update MyScore API
    func myscoreUpdate(){
    
        let baseURL = "http://52.79.152.130/TicSongServer/myscore.do"
        
        let parameters: Parameters = ["service":"update", "userId":userSet[1], "exp":userSet[2], "userLevel":userSet[3]]
        
        
        Alamofire.request(baseURL,method : .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
        .responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8), let encodedData = utf8Text.data(using: String.Encoding.utf8){
                        
                        let JSON = try! JSONSerialization.jsonObject(with: encodedData, options: [])
                        
                        if let JSON = JSON as? [String: AnyObject] {
                            if let resultCode = JSON["resultCode"] as? Int{
                                
                                if(resultCode == 1){
                               
                                }else{

                                }
                            }
                        }
                    }
                }
                break
            case .failure(_):
                break
                
            }
        }
    }
    
    // Update Item API
    func itemUpdate() {
        
        
        let baseURL = "http://52.79.152.130/TicSongServer/item.do"
        
        let parameters: Parameters = ["service":"update", "userId":userSet[1], "item1Cnt":userSet[4], "item3Cnt":userSet[5], "item4Cnt":userSet[6], "item5Cnt":userSet[7],]
        
        
        Alamofire.request(baseURL,method : .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
            .responseJSON { (response:DataResponse<Any>) in
                
            switch(response.result) {
                case .success(_):
                    if response.result.value != nil{
                        
                        if let data = response.data, let utf8Text = String(data: data, encoding: .utf8), let encodedData = utf8Text.data(using: String.Encoding.utf8){
                            
                            let JSON = try! JSONSerialization.jsonObject(with: encodedData, options: [])
                            
                            if let JSON = JSON as? [String: AnyObject] {
                                if let resultCode = JSON["resultCode"] as? Int {
                                    
                                    if(resultCode == 1){
                                        
                                    }else{
                                    
                                    }
                                }
                            }
                        }
                    }
                    break
                    
                case .failure(_):
                    break
            }
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "GameToResultLvUp"{
            let des = segue.destination as! ResultViewControllerLvUp
            des.randomIndex = randomItemIndex
            des.myLevel = self.userSet[3]
            des.myScore = String(gameScore)
        }
        else if segue.identifier == "GameToResult"{
            let des = segue.destination as! ResultViewController
            des.myLevel = self.userSet[3]
            des.myScore = String(gameScore)
        }
    }
    
    
}

