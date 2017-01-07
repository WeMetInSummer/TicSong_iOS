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
    
    
    
    var audioPlayer:AVAudioPlayer = AVAudioPlayer()
    
    var url : String!
    var timer = Timer() // 노래 시간 설정시 사용
    var musicSec = 0
    var startTime : Double!
    var roundList:[(title:String,song:String,start:Int)] = []
    
    var hintMode: Int = 0 // 0 : 일반 재생 1 : 힌트 재생
    
    var score : Int = 0
    var life : Int = 3
    var stage : Int = 0
    var item : Int = 3
    
    
    
    //MARK: 생명주기
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        stageLabel.text = "STAGE \(stage+1)"
        stageLabel.textColor = UIColor.white
        stageLabel.font = UIFont.systemFont(ofSize: 30)
        
        //한번더 viewDidLoad()에서 프린트 되는데 보류.... 세팅이 다시되는거 같진않음...
        print(roundList)
        
        setting(music: roundList[stage].song)
    
        
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
            aniStar(pic: juke_shootingStar, aniDuration: 1.0)
            
            print("노래 제목 : " + roundList[stage].title)
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
        
        
       if answer.text == roundList[stage].title {
        
            nextStageInit()
            answer.text = ""
        
            self.answer.endEditing(true)
            showToast("정답입니다!")
        
        
        if(life == 3){score += 100}
        else if(life == 2){score += 60}
        else if(life == 1){score += 30}
        else{score += 0}
        
        
        }else if answer.text != roundList[stage].title{
            showToast("틀렸습니다!")
             life -= 1
        if(life == 0){
            nextStageInit()
            score += 0
        }
        }
        lifeCreate()
    }
    
    @IBAction func Hint(_ sender: UIButton) {
        hintMode = 1
        playMusic()
        aniStar(pic: juke_shootingStar, aniDuration: 3.0)
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
    
    func setting(music: String){
        do {
            //무음에서도 들리게 해주는 부분!! 나중에 정리하면 될거 같아요 민섭님
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
            
            setSong(name: music, time: 100)
            let fileURL = NSURL(string:url)
            let soundData = NSData(contentsOf:fileURL! as URL)
            self.audioPlayer = try AVAudioPlayer(data: soundData! as Data)
            audioPlayer.prepareToPlay()
            audioPlayer.volume = 1.0
            audioPlayer.delegate = self
            audioPlayer.currentTime = startTime
        } catch {
            print(error)
            print("Error getting the audio file")
        }
    }
    
   // 노래 재생 시간 설정 ( musicSec가 초를 나타낸다 )
    
    func counter() {
        musicSec += 1
        if musicSec > 0 && hintMode == 0{
            audioPlayer.stop() // 지정한 시간이 지나면 스톱
            timer.invalidate()   // 타이머를 다시 0초로
        }
        else if musicSec > 2 && hintMode == 1{
            audioPlayer.stop() // 지정한 시간이 지나면 스톱
            timer.invalidate()   // 타이머를 다시 0초로
        }
        
    }
    
    // 노래제목을 설정 하는 함수
    
    func setSong(name: String,time: Double){
        url = "https://api.soundcloud.com/tracks/"+name+"/stream?client_id=59eb0488cc28a2c558ecbf47ed19f787"
        startTime = time
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
        stage += 1
        life = 3
        stageFinishAlert(songTitle: roundList[stage-1].title)
        
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
            
            stageLabel.text = "STAGE \(stage+1)"
            answer.text = ""
            setting(music: roundList[stage].song)
            print("다음 노래 준비!")
            
        }else{
            //모든 스테이지 종료 시 일단은 라벨 제거함
            //Alert창 띄워서 결과보여주고 확인누르면 메인으로 돌아가게 만들까?
            stageLabel.isHidden = true
            resultAlert(score: score)
            
        }
        lifeCreate()
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
    
    func stageFinishAlert(songTitle:String){
        
        let alertView = UIAlertController(title: songTitle, message: "소울트리~", preferredStyle: .alert)
        
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
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertView, animated: true, completion: nil)
        

    }
    
  
    
    
    func resultAlert(score:Int){
        
        let alertView = UIAlertController(title: "RESULT", message: "당신의 점수는 \(score)점 입니다!", preferredStyle: .alert)
        
//        let image = UIImage(named: "album")
//        let realiamge = UIImageView(image: image)
//        realiamge.frame = CGRect(x: 0, y: 100, width: 250, height: 250)
//        
//        alertView.view.addSubview(realiamge)
        
        
        let action = UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (UIAlertAction) in
            alertView.dismiss(animated: true, completion: nil)
            self.dismiss(animated: true, completion: nil)
        })
        alertView.addAction(action)
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertView, animated: true, completion: nil)
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
        
        let alertWindow = UIWindow(frame: UIScreen.main.bounds)
        alertWindow.rootViewController = UIViewController()
        alertWindow.windowLevel = UIWindowLevelAlert + 1
        alertWindow.makeKeyAndVisible()
        alertWindow.rootViewController?.present(alertView, animated: true, completion: nil)
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

    
    
    
  

}

