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
    var item : Int = 3
    
    // 디폴트
    var userSet : [String] = []
    let user = UserDefaults.standard
    
    //MARK: 생명주기
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stageLabel.text = " STAGE \(stage+1)"
        stageLabel.textColor = UIColor.white
        stageLabel.font = UIFont(name: "EXO-REGULAR", size: 27)
        //stageLabel.font = UIFont.systemFont(ofSize: 30)
        
        answer.autocorrectionType = .no
        
        //한번더 viewDidLoad()에서 프린트 되는데 보류.... 세팅이 다시되는거 같진않음...
        print(roundList)
        
        setting(music: roundList[stage].code, time: roundList[stage].start)
        
        if let result = user.stringArray(forKey: "user"){
            userSet = result
        }
        print(userSet)
    
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
            
            print("노래 제목 : " + roundList[stage].songName)
            print("life :"+life.description)
            print("stage :"+stage.description)
            print("score :"+score.description)
        }else{
            
            print("life :"+life.description)
            print("마지막 stage :"+stage.description)
            print("최종 점수 :"+score.description)
            showToast("그만!")
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
        showToast("정답입니다!")
        
        }else if !isMatch{
             life -= 1
                if(life == 0){
                    self.answer.endEditing(true)
                    nextStageInit()
                    score += 0
                }
            showToast("틀렸습니다!")
        }
        lifeCreate()
    }
    
    // item !
    
    @IBAction func threeSecHint(_ sender: UIButton) {
        hintMode = 1
        playMusic()
        aniStar(pic: juke_shootingStar, aniDuration: 4.0)
    }
    @IBAction func singerHint(_ sender: UIButton) {
        singerAlert(artist: roundList[stage].artist)
    }
    
    @IBAction func firstCharHint(_ sender: UIButton) {
        firstCharAlert(songName: roundList[stage].songName)
    }
    
    @IBAction func inputSecHint(_ sender: UIButton) {
        inputSecAlert()
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
    
    // 아직 노래 코드 오류났을 때 제대로 해결 못함..
    func setting(music: String, time:Double){
        answer.placeholder = "정답을 입력해주세요 (한글로)"
        
        do {
            //무음에서도 들리게 해주는 부분!! 나중에 정리하면 될거 같아요 민섭님
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
            print(error)
            print("Error getting the audio file")
        }
    }
    
   // 노래 재생 시간 설정 ( musicSec가 초를 나타낸다 )
    
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
        life = 3
        stageFinishAlert(songTitle: roundList[stage-1].songName, artist: roundList[stage-1].artist)
        
        audioPlayer.currentTime = 0
        audioPlayer.play()
        //lifeCreate()
        // Alert 띄우고 별똥별 도는거 보류
        //aniStar(pic: juke_shootingStar, aniDuration: 4.0)
    }
    
    func nextSong(){
        
        audioPlayer.stop()
        
        
        //다음 노래 준비
        if(stage < roundList.count){
            stageLabel.text = " STAGE \(stage+1)"
            answer.text = ""
            setting(music: roundList[stage].code, time: roundList[stage].start)
            print("다음 노래 준비!")
            
        }else{
            //모든 스테이지 종료 시 일단은 라벨 제거함
            //Alert창 띄워서 결과보여주고 확인누르면 메인으로 돌아가게 만들까?
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
        
        print("origin: \(compare1.lowercased()) input : \(compare2.lowercased())")
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
        
//        let image = UIImage(named: "album")
//        let realiamge = UIImageView(image: image)
//        realiamge.frame = CGRect(x: 0, y: 100, width: 250, height: 250)
//        
//        alertView.view.addSubview(realiamge)
        
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            alertView.dismiss(animated: true, completion: nil)
            
            self.nextSong()
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
                    self.basicAlert(string: "꽝",message: "노래의 범위를 벗어난 꽝")
                }
            }else{
                self.basicAlert(string: "꽝",message: "숫자 외 다른 문자를 입력한 꽝")
            }
        }))
        
        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)

    }

    
  
    
    
    func resultAlert(score:Int){
        // 내가 가진 경험치에 이번판에 얻은 스코어를 더한후..
        let scoreSum = Int(userSet[2])! + score
        let myLevel = Int(userSet[3])! // 내 레벨
        let random : Int = Int(arc4random_uniform(UInt32(4)))+1
        var levelUp : Bool = false
        print("내 경험치 : \(scoreSum)")
        print("내 레벨 : \(myLevel)")
        print("내가 가지고 있는 아이템 ",userSet[4])
        
        print("내가 가지고 있는 아이템 ",userSet[5])
        
        print("내가 가지고 있는 아이템 ",userSet[6])
        
        print("내가 가지고 있는 아이템 ",userSet[7])
        
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
        //------>>>여기에<<<-----
        //userSet에 담긴 프리퍼런스 값을 그대로 서버에 삽입!
        // item5Cnt 까지 추가하면 완료... 아마 default 에 4567에 들어있을 것임..
        // 만약 랜덤값이 4면 서버에는 item5Cnt 을 추가하면 돼
        
        
        
        
        // 프리퍼런스로 내가 가진 경험치에 + score = 내 경험치
        let alertView = UIAlertController(title: "RESULT", message: "당신의 점수는 \(score)점 입니다!", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            //만약 경험치가 레벨업을 할 수 있는 경험치라면 레벨업 뷰로..
            
            
                // 임시로 랜덤아이템이 뭐가 나왔나 띄우는 것
                
                
            if levelUp{
                print("레벨업!")
                self.levelUpAlert(random)
                self.dismiss(animated: true, completion: nil)
            }else{
                //아니라면 alertView 끄기..
                alertView.dismiss(animated: true, completion: nil)
                self.dismiss(animated: true, completion: nil)
            }
            
        })
        alertView.addAction(action)
        
        alertWindow(alertView: alertView)

    }
    
    // 레벨업 할 수 있나 없나 체크!
    func isLevelUp(_ scoreSum : Int ,_ myLevel : Int) -> Bool{
        var mylv = myLevel
        print("levelup 판독기에서")
        print ("mylv \(mylv)")
        for index in 0..<expArr.count{
            if scoreSum >= expArr[index]{
                mylv = index+2
            }else{
                break
            }
        }
        
        print ("mylv2 \(mylv)")
        print("levelup 판독 끝")
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
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in print("cancel button clicked")}
        
        alertView.addAction(action)
        alertView.addAction(cancelAction)
        
        alertWindow(alertView: alertView)

    }
    
    func basicAlert(string : String,message : String){
        let alertView = UIAlertController(title: string+"!!", message: message+"입니다요", preferredStyle: .alert)

        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            alertView.dismiss(animated: true, completion: nil)
        })
        
        
        alertView.addAction(action)
        
        alertWindow(alertView: alertView)
    }
    
    // level up alert !
    func levelUpAlert(_ random: Int){
        
        let alertView = UIAlertController(title: "레벨업!!", message: "레벨업 입니다요", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            alertView.dismiss(animated: true, completion: nil)
        })
        
        // 1345
        // 1234 = random 값
//        let image = UIImage(named: "levelupItem\(random)")
//        let realiamge = UIImageView(image: image)
//        realiamge.frame = CGRect(x: 80, y: 150, width: 100, height: 100) // 위치는 나중에 생각..
//        alertView.view.addSubview(realiamge)
        alertView.addAction(action)
        alertWindow(alertView: alertView)

        // 획득 했다는 것 어떻게 알려줄까? 
        
        print("내가 가지고 있는 아이템 ",userSet[4])
        
        print("내가 가지고 있는 아이템 ",userSet[5])
        
        print("내가 가지고 있는 아이템 ",userSet[6])
        
        print("내가 가지고 있는 아이템 ",userSet[7])
        
        
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
    
    func myscoreUpdate(userId:String, exp:Int, userLevel:Int){
    
        let baseURL = "http://52.79.152.130/TicSongServer/myscore.do"
        
        let parameters: Parameters = ["service":"update", "userId":userId, "exp":exp, "userLevel":userLevel]
        
        
        Alamofire.request(baseURL,method : .post, parameters: parameters, encoding: URLEncoding.default, headers: nil)
        .responseJSON { (response:DataResponse<Any>) in
            
            switch(response.result) {
            case .success(_):
                if response.result.value != nil{
                    //print(response.result.value!)
                    
                    if let data = response.data, let utf8Text = String(data: data, encoding: .utf8), let encodedData = utf8Text.data(using: String.Encoding.utf8){
                        
                        let JSON = try! JSONSerialization.jsonObject(with: encodedData, options: [])
                        
                        if let JSON = JSON as? [String: AnyObject] {
                            if let resultCode = JSON["resultCode"] as? Int{
                                
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
    
    
    func itemUpdate(userId:String, exp:Int, userLevel:Int, item1Cnt:Int, item2Cnt:Int, item3Cnt:Int, item4Cnt:Int) {
        
        
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

}

