//
//  EditViewController.swift
//  AlarmWork
//
//  Created by 鈴木才智 on 2015/01/10.
//  Copyright (c) 2015年 SaichiSuzuki. All rights reserved.
//

import UIKit
import AVFoundation
import MediaPlayer
import AudioToolbox
import CoreLocation
import CoreMotion
import GoogleMobileAds

class EditViewController: UIViewController, UIPickerViewDelegate, CLLocationManagerDelegate {
    
    //ユーザ設定
    var walkStep:Double = 0.1 //小幅の人は0.1//普通の人0.3 //大幅の人は0.8º //ランニングの場合は1.5
    var walkPoint = 5
    var roomwalk = 1 //室内(スリッパ)なら0.75//いや,全て0.8にしよう(accelyの1)
    
    //実験用
    var experimentFlag = false //データ収集
    var cwFlag = false //時間falseで表示
    
    var logStr = ""
    var logRemain = false
    
    
    /*パラメータ*/
    ////////////
    var elbowroomValue = 2 //ゆとり仕様
    //移動距離最初(ライフ)
    var lifePoints = 3
    //ジャイロ反応値アウト
    var gyroReaction = 4.5
    //バイブ感覚
    var vibInterval:Double = 3
    //暗号数
    var cryptographyNum = 20 //デフォルトは20
    //通知回数
    var postTime = 120
    //通知間隔時間
    var postInterval = 15
    //使用カラー
    var colorCode = "ffffff" //青系 4169E1
    
    /*研究*/
    ////////////
    var myAccelYCounter = 100
    var myAccelY2Counter = 100
    var myAccelZCounter = 100
    var myJyroXCounter = 100
    var myJyroYCounter = 100
    var myJyroZCounter = 100
    var accelYf1 = false
    var accelYf2 = false
    var accelYf3 = false
    var accelZf1 = false
    var accelZf2 = false
    var accelZf3 = false
    var jyroXf1 = false
    var jyroXf2 = false
    var jyroXf3 = false
    var jyroZf1 = false
    var jyroZf2 = false
    var jyroZf3 = false
    
    /*加速度センサー*/
    ///////////////
    var myMotionManager: CMMotionManager!//加速度センサー
    var longitude: CLLocationDegrees!//緯度
    var latitude: CLLocationDegrees!//経度
    //    var accelX:Double = 0
    var accelY:Double = 0
    var accelZ:Double = 0
    
    /*ジャイロセンサー*/
    //////////
    var currentMaxRotX: Double = 0.0
    var currentMaxRotY: Double = 0.0
    var currentMaxRotZ: Double = 0.0
    var gyroAuthorization = false
    var pastJyroX = 0
    var pastJyroZ = 0
    
    /*ピッカー*/
    //////////
    var myDatePicker: UIDatePicker!//ピッカー用意
    //現在時刻
    var now = NSDate()
    var formatter = NSDateFormatter()
    //設定時刻
    var mySelectedDate:NSString = ""
    var myDateFormatter = NSDateFormatter()
    var planTime = NSDate()
    //設定時間(秒)
    var planSec = 0
    //設定時間と現在時刻の差
    var timeDifference = 0
    //ピッカーいじったか
    var pickerUsedFlag = false
    
    
    
    /*フラグ準備*/
    ////////////
    //音楽なってるか
    var bgFlag = false
    var onOffFlag = false
    var musicSelectFlag = false;
    //    var switchPushOverFlag = false
    
    /*タイマー*/
    //////////
    //ラベル更新タイマー
    //    var labelTimer : NSTimer!
    var pushSetTimer : NSTimer!
    //バイブレーション開始タイマー
    var vibTimer : NSTimer!
    var alarmTimer : NSTimer!
    var playBoyTimer : NSTimer!
    //広告タイマー
    var interstitialTimer : NSTimer!
    //マナーモード解除警告
    var mannerCautionTimer : NSTimer!
    
    /*その他*/
    //ユーザーデフォルト
    var myUserDafault:NSUserDefaults = NSUserDefaults()
    //音楽を司る変数
    var musicPlayer:MPMusicPlayerController = MPMusicPlayerController.applicationMusicPlayer()
    //画面サイズ取得
    var winSize:CGRect!
    //現在時刻取得
    var calendar = NSCalendar.currentCalendar()
    var comps:NSDateComponents!
    
    let volumeChange = SystemVolumeController()
    
    let session: AVAudioSession = AVAudioSession.sharedInstance()
    //    let mc = MusicController() //音楽コントローラ
    
    /*オブジェクト*/
    ///////
    var pointLabel:UILabel!//ポイントラベル
    //設定時刻ラベル
    var setTimeLabel: UILabel!//時間表示テキストフィールド
    //ギブアップボタン
    var giveUpBtn: UIButton!
    //音楽選択ボタン
    var musicSelectBtn: UIButton!
    //音楽選択ウィンドウ
    var musicSelectView: UIView!
    //区切りラベル
    var horizonLabel1: UILabel!
    var horizonLabel2: UILabel!
    var horizonLabel3: UILabel!
    var horizonLabel4: UILabel!
    var horizonLabel5: UILabel!
    //音楽鳴らすボタン
    var musicHearButton1: UIButton!
    var musicHearButton2: UIButton!
    var musicHearButton3: UIButton!
    var musicHearButton4: UIButton!
    var musicHearButton5: UIButton!
    var musicHearButton6: UIButton!
    //音楽選択ボタン
    var musicSelectButton1: UIButton!
    var musicSelectButton2: UIButton!
    var musicSelectButton3: UIButton!
    var musicSelectButton4: UIButton!
    var musicSelectButton5: UIButton!
    var musicSelectButton6: UIButton!
    //ステップバー
    var lifeStepper: UIStepper!
    //音量アイコン
    let musicStopCIImage = CIImage(image: UIImage(named: "soundIconZero.png"))
    var musicStopUIImage:UIImageView!
    let musicPlayCIImage = CIImage(image: UIImage(named: "soundIconOne.png"))
    var musicPlayUIImage:UIImageView!
    //距離アイコン
    //    let walkCIImage = CIImage(image: UIImage(named: "soundIconZero.png"))
    //    var walkUIImage:UIImageView!
    //    let runCIImage = CIImage(image: UIImage(named: "soundIconOne.png"))
    //    var runUIImage:UIImageView!
    //足跡アイコン
    let footCIImage = CIImage(image: UIImage(named: "footPaint.png"))
    var footUIImage:UIImageView!
    //チュートリアルアイコン
    //    let howtoCIImage = CIImage(image: UIImage(named: "infooff.png"))
    //チュートリアルオープン状態
    let howtoOpenCIImage = CIImage(image: UIImage(named: "infoon.png"))
    //アラームアイコン
    let alarmOnCIImage = CIImage(image: UIImage(named: "bellon.png"))
    let alarmOffCIImage = CIImage(image: UIImage(named: "belloff.png"))
    var alarmUIImage:UIImageView!
    
    //チュートリアルボタン
    var tutorialBtn: UIButton!
    //歩幅調整スライダー
    //    var stepSlider:UISlider!
    //背景画像
    var backgroundImageView: UIImageView!
    //背景に仕様する画像
    // 画像を設定する.
    let bgInputImage = CIImage(image: UIImage(named: "bg.png"))
    //アラームオンオフスイッチ
    var alarmSwitch: UISwitch = UISwitch()
    //マナーモード推奨バー
    var mannerModeLabel: UILabel = UILabel()
    //マナーモード推奨ボタン
    //    var mannerModeButton: UIButton = UIButton()
    
    //エフェクトビュー(隠すやつ)
    var effectView : UIVisualEffectView!
    //インタースティシャル広告準備
    var interstitial: GADInterstitial = GADInterstitial()
    
    //ステップバー変更
    func stepperOneChanged(stepper: UIStepper){
        myUserDafault.setInteger(Int(stepper.value), forKey: "LIFEFINAL")
        myUserDafault.setInteger(Int(stepper.value), forKey: "LIFE")
        myUserDafault.synchronize()
        lifePoints = myUserDafault.integerForKey("LIFE")
        self.pointLabel.text = "\(self.lifePoints)"
    }
    //ステップスライダー動かす
    //    func onChangeValueStepSlider(sender : UISlider){
    //        walkStep = Double(sender.value)
    //        myUserDafault.setDouble(walkStep, forKey: "STEPFINAL")
    //        myUserDafault.synchronize()
    //        println(walkStep)
    //    }
    //オンオフスイッチ
    func onClickMySwicth(sender: UISwitch){
        
        NotificationUtil.pushDelete()
        let lm = LangManager()
        if sender.on == true {
            onOffFlag = true
            self.mannerModeLabel.text = lm.getString(11)
            alarmUIImage.image = UIImage(CIImage: alarmOnCIImage)
            setTimeLabel.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            myUserDafault.setBool(true, forKey: "HAJIMEIPPO_STILL")
            myUserDafault.synchronize()
            
            UIView.animateWithDuration(1.0, animations: {() -> Void in
                self.mannerModeLabel.center = CGPoint(x: self.winSize.width/2,y: self.winSize.height/2 + 40);
                }, completion: {(Bool) -> Void in
                    self.mannerModeLabel.text = lm.getString(11);
            })
            if(self.mannerCautionTimer != nil){
                self.mannerCautionTimer.invalidate()
                self.mannerCautionTimer = nil
            }
            self.mannerCautionTimer = NSTimer.scheduledTimerWithTimeInterval(3.0, target: self, selector: "mannerLabelReturn", userInfo: nil, repeats: true)
        } else {
            //            switchPushOverFlag = false
            postTime = 0
            onOffFlag = false
            alarmUIImage.image = UIImage(CIImage: alarmOffCIImage)
            setTimeLabel.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
            UIView.animateWithDuration(1.0, animations: {() -> Void in
                self.mannerModeLabel.center = CGPoint(x: -150,y: self.winSize.height/2 + 40)
                }, completion: {(Bool) -> Void in
                    self.mannerModeLabel.text = lm.getString(11)
            })
        }
        myUserDafault.setBool(onOffFlag, forKey: "ONOFF")
        myUserDafault.synchronize()
        
        let qualityOfServiceClass = DISPATCH_QUEUE_PRIORITY_DEFAULT
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            // Backgroundで行いたい重い処理はここ
            if sender.on == true {
                self.settingAlarmTime()
            }
            dispatch_async(dispatch_get_main_queue(), {
                // 処理が終わった後UIスレッドでやりたいことはここ
            })
        })
        
    }
    //音楽選択ボタン
    func musicSelectAction(sender: UIButton){
        print("musicselect")
        if(musicSelectFlag == true){ //出てるから隠す
            musicSelectFlag = false
            UIView.animateWithDuration(0.5, animations: {() -> Void in
                self.musicSelectView.center = CGPoint(x: self.winSize.width*3/4,y: self.winSize.height*5/8)
                }, completion: {(Bool) -> Void in
                    //self.mannerModeLabel.text = lm.getString(11)
            })
        }else{ //隠れてるから出す
            musicSelectFlag = true
            UIView.animateWithDuration(0.5, animations: {() -> Void in
                self.musicSelectView.center = CGPoint(x: self.winSize.width*5/4,y: self.winSize.height*5/8)
                }, completion: {(Bool) -> Void in
                    //self.mannerModeLabel.text = lm.getString(11)
            })
        }
         //winSize.width*3/4, y:winSize.height/2
        

    }
    //ギブアップボタン
    func giveUpBtnAction(sender: UIButton){
        let lm = LangManager()
        //textの表示はalertのみ。ActionSheetだとtextfiledを表示させようとすると
        //落ちます。
        var strCrypho = ""
        var strAnswer = ""
        //        var stopBeforeMessage = "%を除く英数字を入力すると止まります"
        //        var stopAfterMessage = "見損なったよ"
        //        if(myUserDafault.integerForKey("LANGUAGE") == 1){
        //            stopBeforeMessage = "You stop when you enter the characters except '%'"
        //            stopAfterMessage = "ouch!"
        //        }
        //暗号生成
        for(var i=0;i<cryptographyNum;i++){
            var rand = Int(arc4random()%36)
            if(rand>9){
                //英語に変換
                var word = englishWordsConverter(rand)
                strCrypho = strCrypho + "\(word)" + "%"
                strAnswer = strAnswer + "\(word)"
            }
            else{
                strCrypho = strCrypho + "\(rand)" + "%"
                strAnswer = strAnswer + "\(rand)"
            }
            println("fof\(i)回目")
        }
        let alert:UIAlertController = UIAlertController(title:strCrypho,
            message: lm.getString(9),
            preferredStyle: UIAlertControllerStyle.Alert)
        
        
        
        let cancelAction:UIAlertAction = UIAlertAction(title: "Cancel",
            style: UIAlertActionStyle.Cancel,
            handler:{
                (action:UIAlertAction!) -> Void in
        })
        let defaultAction:UIAlertAction = UIAlertAction(title: "OK",
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                let textFields:Array<UITextField>? =  alert.textFields as! Array<UITextField>?
                if textFields != nil {
                    for textField:UITextField in textFields! {
                        //各textにアクセス
                        if(strAnswer==textField.text){
                            self.musicStop()
                            self.openAlert("You are looser to yourself", messageStr: lm.getString(10),okStr:"No thank you")
                            if(self.vibTimer != nil){
                                self.vibTimer.invalidate() //バイブ終了
                            }
                        }
                    }
                }
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        
        //textfiledの追加 実行した分textfiledを追加される。
        alert.addTextFieldWithConfigurationHandler({(text:UITextField!) -> Void in
            text.placeholder = "Never Give Up"
        })
        presentViewController(alert, animated: true, completion: nil)
    }
    //チュートリアルボタンアクション
    func tutorialBtnActionIn(sender: UIButton){
        if(experimentFlag == true){
            logRemain = true
            print("@")
            print(logStr)
        }
        sceneChange()
    }
    //    //チュートリアル外で離した時
    //    func tutorialBtnActionOut(sender: UIButton){
    //        //        tutorialBtn.backgroundColor = UIColor.hexStr("000000", alpha: 0.3)
    //        tutorialBtn.setImage(UIImage(CIImage: howtoCIImage), forState: .Normal)
    //    }
    //    //チュートリアル押した瞬間
    //    func tutorialBtnActionDown(sender: UIButton){
    //        //        tutorialBtn.backgroundColor = UIColor.hexStr("000000", alpha: 0.3)
    //        tutorialBtn.setImage(UIImage(CIImage: howtoOpenCIImage), forState: .Normal)
    //    }
    override func viewDidLoad() {
        super.viewDidLoad()
        removeFromParentViewController() //とりあえずなんか解放できるかも
        //インタースティシャル広告準備
        admobInterstitialReady()
        //        println(myUserDafault.integerForKey("TUTORIALLIFE"))
        /*リセット！音楽鳴らしたり止めたり(テスト用)*/
        //        self.myUserDafault.setBool(true, forKey: "HAJIMEIPPO_STILL")
        //        self.myUserDafault.synchronize()
        //        bgFlag = true
        //        myUserDafault.setBool(bgFlag, forKey: "bgm")
        //        myUserDafault.synchronize()
        //        musicStop()
        //        NotificationUtil.pushDelete()
        //        myUserDafault.synchronize()
        //初期音楽設定
//        myUserDafault.setObject("You_wanna_fightC", forKey: "MUSIC_NAME")
        var rnd = arc4random() % 6;
        var bgName = ""
        switch rnd{
        case 0:
            bgName = "bravo"
            break
        case 1:
            bgName = "cafe"
            break
        case 2:
            bgName = "normal"
            break
        case 3:
            bgName = "village"
            break
        case 4:
            bgName = "wafu"
            break
        case 5:
            bgName = "You_wanna_fightC"
            break
        default:
            break
        }
        println(rnd)
        println(bgName)
        println("~~")
        myUserDafault.setObject(bgName, forKey: "MUSIC_NAME")
        myUserDafault.synchronize()
        ///////////////////////////////
        firstContactCheck()
        winSize = self.view.bounds //画面サイズ取得
        self.view.backgroundColor = UIColor.lightGrayColor() //背景色
        pushAuthorization() //プッシュ通知許可
        bgFlag = myUserDafault.boolForKey("bgm")
        alarmUpdate() //1秒おきのアップデート1回最初に呼ぶ
        //        if(myUserDafault.integerForKey("TUTORIALLIFE") != 4){
        objectMake() //オブジェクト生成関数を実行してもよければ実行
        objectMove() //オブジェクト移動
        //        }
        timerStart() //タイマースタート
        myCoreMotion() //加速度センサー起動
        gyroInit() //ジャイロセンサー起動
        //alertComeCheck() //アラートからきたかチェック
        self.bgColorChange() //背景色いい感じにする
        if(bgFlag == true){
            AVAudioPlayerUtil.play();//再生
            NotificationUtil.pushDelete()
            //バイブも鳴らす
            vibTimer = NSTimer.scheduledTimerWithTimeInterval(vibInterval, target: self, selector: "vibUpdate", userInfo: nil, repeats: true)
            self.myUserDafault.setInteger(5, forKey: "TUTORIALLIFE") //5は通常稼働
            self.myUserDafault.synchronize()
            //一歩目限定イベント
            if(self.myUserDafault.boolForKey("HAJIMEIPPO_STILL") == true){
                AVAudioPlayerUtil.playMusicVolumeSetting(1.0)
            }
            else{
                AVAudioPlayerUtil.playMusicVolumeSetting(0.1)
            }
        }
        else{
            noMusicInit()
        }
        //現在時刻保存
        comps = calendar.components(NSCalendarUnit.YearCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.DayCalendarUnit|NSCalendarUnit.HourCalendarUnit|NSCalendarUnit.MinuteCalendarUnit|NSCalendarUnit.SecondCalendarUnit,
            fromDate: now)
        myUserDafault.setInteger(comps.hour, forKey: "ONCEHOUR")
        myUserDafault.setInteger(comps.minute, forKey: "ONCEMINUTE")
        myUserDafault.synchronize()
        
        //割り込み用生成
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioSessionInterrupted:", name: "AVAudioSessionInterruptionNotification", object: nil)
        //イヤホン用？
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "audioSessionRouteChange:", name: "AVAudioSessionRouteChangeNotification", object: nil)
        //音量変更時
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "getInstanceVolumeButtonNotification:", name: "AVSystemController_SystemVolumeDidChangeNotification", object: nil)
        var n = Int(arc4random()%20)
        if(n == 0){
            interstitialTimer = NSTimer.scheduledTimerWithTimeInterval(5, target: self, selector: "ads", userInfo: nil, repeats: true)
        }
        
    }
    //タイマースタート
    func timerStart(){
        //メインUpdate
        alarmTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "alarmUpdate", userInfo: nil, repeats: true)
    }
    
    ////////////////////////////////////////////////
    
    ////~~~~UPDATE~~~~///////////////////////////////
    
    ////////////////////////////////////////////////
    
    //メインUpdate(現在時刻取得、GPSスレッド起動、)
    func alarmUpdate(){
        //1秒毎に現在時刻取得
        now = NSDate()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeStyle = .MediumStyle
        //現在時刻を過去時刻に保存
        calendar = NSCalendar.currentCalendar()
        comps = calendar.components(NSCalendarUnit.YearCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.DayCalendarUnit|NSCalendarUnit.HourCalendarUnit|NSCalendarUnit.MinuteCalendarUnit|NSCalendarUnit.SecondCalendarUnit,
            fromDate: now)
        var nowSecond = secondConverter(comps.hour, minute: comps.minute, second: comps.second)
        var setingTime = myUserDafault.integerForKey("PLANSECOND")
        //本来なるはずの時刻
        var timerPlanTime = myUserDafault.integerForKey("pastTime") + myUserDafault.integerForKey("differenceTime")
        if(timerPlanTime>=86400){
            timerPlanTime - 86400
        }
        //アラームセットして画面つけていてセットタイムになった場合
        if((nowSecond>=timerPlanTime || nowSecond==setingTime) && bgFlag==false && onOffFlag==true){
            println("アラーム開始")
            musicStart()
        }
        if(bgFlag == true && comps.second == 0){
            setTime(comps.hour, m: comps.minute) //時間ラベル更新
        }
        inclinateGyroContinue() //加速度、ジャイロチェック
    }
    //アラートから来たかチェック
    func alertComeCheck(){
        now = NSDate()
        formatter.dateFormat = "HH:mm:ss"
        formatter.timeStyle = .MediumStyle
        //現在時刻を過去時刻に保存
        calendar = NSCalendar.currentCalendar()
        comps = calendar.components(NSCalendarUnit.YearCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.DayCalendarUnit|NSCalendarUnit.HourCalendarUnit|NSCalendarUnit.MinuteCalendarUnit|NSCalendarUnit.SecondCalendarUnit,
            fromDate: now)
        var nowSecond = secondConverter(comps.hour, minute: comps.minute, second: comps.second)
        var pastTime = myUserDafault.integerForKey("pastTime")
        var differenceTime = myUserDafault.integerForKey("differenceTime")
        var timerPlanTime = pastTime + differenceTime
        if(timerPlanTime>=86400){
            timerPlanTime - 86400
        }
        println("設定時間:\(timerPlanTime)秒")
        println("現在時刻:\(nowSecond)秒")
        onOffFlag = myUserDafault.boolForKey("ONOFF")
        println("ONOFFflag:\(onOffFlag)")
        //アラートからきた場合
        if(timerPlanTime<=nowSecond && bgFlag==false && onOffFlag==true){
            println("アラートからきましたね")
            musicStart()
        }
    }
    
    ////////////////////////////////////////////////
    
    ////~~~~CoreMotion~~~~///////////////////////////////
    
    ////////////////////////////////////////////////
    
    func myCoreMotion(){
        // MotionManagerを生成.
        myMotionManager = CMMotionManager()
        // 更新周期を設定.
        myMotionManager.accelerometerUpdateInterval = 0.3
        // 加速度の取得を開始.
        myMotionManager.startAccelerometerUpdatesToQueue(NSOperationQueue.mainQueue(), withHandler: {(accelerometerData:CMAccelerometerData!, error:NSError!) -> Void in
            //現在加速度取得しテキスト表示
            //            self.accelX = accelerometerData.acceleration.x
            self.accelY = accelerometerData.acceleration.y
            self.accelZ = accelerometerData.acceleration.z
            //実験ならログを残す
            if(self.logRemain == false && self.experimentFlag == true){
                print("\(accelerometerData.acceleration.x):")
                print("\(accelerometerData.acceleration.y):")
                print("\(accelerometerData.acceleration.z)X")
            }
            /*新機能Accel研究*/
            //accelY研究
            if(self.accelYf3 == true && self.accelY>=1 && self.accelY<=4){
                self.myAccelYCounter = self.elbowroomValue
            }
            if(self.accelYf2 == true && self.accelY<=1 && self.accelY>=(-2)){
                self.accelYf3 = true
            }
            if(self.accelY>=1 || self.accelY<=(-2)){
                self.accelYf3 = false
            }
            if(self.accelYf1 == true && self.accelY>=1 && self.accelY<=4){
                self.accelYf2 = true
            }
            if(self.accelY<=1 || self.accelY>=4){
                self.accelYf2 = false
            }
            if(self.accelY<=1 && self.accelY>=(-2)){
                self.accelYf1 = true
            }
            else {
                self.accelYf1 = false
            }
            //accelY2研究
            if(self.accelY>=1.4 || self.accelY<=0.8){ //NGゾーンに入っていなかったら
                self.myAccelY2Counter = 100
            }
            else{
                self.myAccelY2Counter -= 1 //90以下になったらダメだね
            }
            //accelZ研究
            if(self.accelZf3 == true && self.accelZ>=(-0.1) && self.accelZ<=3){
                self.myAccelZCounter = 2
            }
            if(self.accelZf2 == true && self.accelZ<=(-0.1) && self.accelZ>=(-3)){
                self.accelZf3 = true
            }
            if(self.accelZ>=(-0.1) || self.accelZ<=(-3)){
                self.accelZf3 = false
            }
            if(self.accelZf1 == true && self.accelZ>=(-0.1) && self.accelZ<=3){
                self.accelZf2 = true
            }
            if(self.accelZ<=(-0.1) || self.accelZ>=3){
                self.accelZf2 = false
            }
            if(self.accelZ<=(-0.1) && self.accelZ>=(-3)){
                self.accelZf1 = true
            }
            else {
                self.accelZf1 = false
            }
            
            //TUTORIALLIFE
            //2以下:testwalk中 4:鳴ってほしくない 5:タイトルで鳴ってる
            //全検証突破した為OK牧場 //TUTORIALLIFE本来は3、実験は100
            if(self.myAccelZCounter != 100 && self.myAccelYCounter != 100 && self.myJyroXCounter != 100 && self.myJyroYCounter != 100 && self.myUserDafault.integerForKey("TUTORIALLIFE") != 4){
                self.sensorInit()
                //アラームシーンの場合
                if(self.myUserDafault.integerForKey("TUTORIALLIFE") == 5){
                    self.lifePoints = self.myUserDafault.integerForKey("LIFE")
                    self.lifePoints -= 1 //ライフを減らす
                    self.myUserDafault.setInteger(self.lifePoints, forKey: "LIFE")
                    self.myUserDafault.synchronize()
                    
                    //効果音再生
                    AVAudioPlayerUtil.playSE();//再生
                    //ライフポイントが尽きたら
                    if(self.lifePoints<1 && self.bgFlag==true){
                        let lm = LangManager()
                        self.musicStop()
                        if(self.vibTimer != nil){
                            self.vibTimer.invalidate() //バイブ終了
                        }
                        AVAudioPlayerUtil.playFinish();//終了音再生
                        //                        var stopMessage = "おきましたか？"
                        //                        if(self.myUserDafault.integerForKey("LANGUAGE") == 1){
                        //                            stopMessage = "Let's happy life"
                        //                        }
                        self.openAlert("GoodMorning", messageStr: lm.getString(12), okStr: "OK") //アラート表示
                        self.myUserDafault.setInteger(4, forKey: "TUTORIALLIFE")
                        self.myUserDafault.synchronize()
                    }
                    self.pointLabel.text = "\(self.lifePoints)"
                    self.bgColorChange() //背景色いい感じにする
                    //一歩目限定イベント
                    if(self.myUserDafault.boolForKey("HAJIMEIPPO_STILL") == true){
                        self.ippome()
                    }
                    
                }
                    //チュートリアルシーンの場合
                else if(self.myUserDafault.integerForKey("TUTORIALLIFE") <= 2){
                    //tutorialのライフ減らす
                    var tLife = self.myUserDafault.integerForKey("TUTORIALLIFE")
                    tLife -= 1
                    self.myUserDafault.setInteger(tLife, forKey: "TUTORIALLIFE")
                    self.myUserDafault.synchronize()
                    //効果音再生
                    AVAudioPlayerUtil.playSE();//再生
                }
            }
            /*-------------*/
            
            
        })
        
        
    }
    //一歩目限定イベント
    func ippome(){
        self.myUserDafault.setBool(false, forKey: "HAJIMEIPPO_STILL")
        self.myUserDafault.synchronize()
        volumeChange.systemVolumeChange(0.5) //システム音変更
        AVAudioPlayerUtil.playMusicVolumeSetting(0.1)
    }
    
    ////////////////////////////////////////////////
    
    ////~~~~ジャイロセンサー~~~~///////////////////////////////
    
    ////////////////////////////////////////////////
    
    func gyroInit(){
        if myMotionManager.gyroAvailable {
            myMotionManager.deviceMotionUpdateInterval = 0.3;
            myMotionManager.startDeviceMotionUpdates()
            myMotionManager.gyroUpdateInterval = 0.2
            myMotionManager.startGyroUpdatesToQueue(NSOperationQueue.currentQueue()) {
                [weak self] (gyroData: CMGyroData!, error: NSError!) in
                
                self?.outputRotationData(gyroData.rotationRate)
                if error != nil {
                    println("\(error)")
                }
            }
        } else {
            // alert message
            var alert = UIAlertController(title: "No gyro", message: "Get a Gyro", preferredStyle: UIAlertControllerStyle.Alert)
            alert.addAction(UIAlertAction(title: "Click", style: UIAlertActionStyle.Default, handler: nil))
            self.presentViewController(alert, animated: true, completion: nil)
        }
    }
    
    func outputRotationData(rotation:CMRotationRate)
    {
        if fabs(rotation.x) > fabs(currentMaxRotX)
        {
            currentMaxRotX = rotation.x
        }
        if fabs(rotation.y) > fabs(currentMaxRotY)
        {
            currentMaxRotY = rotation.y
        }
        if fabs(rotation.z) > fabs(currentMaxRotZ)
        {
            currentMaxRotZ = rotation.z
        }
        self.logStr = self.logStr + "\(rotation.x):"
        self.logStr = self.logStr + "\(rotation.y):"
        self.logStr = self.logStr + "\(rotation.z)X"
        
        
        /*新機能jyro研究*/
        //jyroX研究
        if(self.jyroXf3 == true && rotation.x>=self.walkStep && rotation.x<=4.5){
            self.myJyroXCounter = self.elbowroomValue
        }
        if(self.jyroXf2 == true && rotation.x<=(-self.walkStep) && rotation.x>=(-4.5)){
            self.jyroXf3 = true
        }
        if(rotation.x>=self.walkStep || rotation.x<=(-4.5)){
            self.jyroXf3 = false
        }
        if(self.jyroXf1 == true && rotation.x>=self.walkStep && rotation.x<=4.5){
            self.jyroXf2 = true
        }
        if(rotation.x<=(-self.walkStep) || rotation.x>=4.5){
            self.jyroXf2 = false
        }
        if(rotation.x<=(-self.walkStep) && rotation.x>=(-4.5)){
            self.jyroXf1 = true
        }
        else {
            self.jyroXf1 = false
        }
        //jyroY研究
        if(rotation.y >= 2 || rotation.y <= (-2)){ //2より外ならおっけー
            self.myJyroYCounter = self.elbowroomValue
        }
        //jyroZ研究
        var shift = 1.0
        if(self.jyroZf3 == true && rotation.z<(rotation.x - shift) && rotation.z<(rotation.y - shift)){
            self.myJyroZCounter = self.elbowroomValue
        }
        if(self.jyroZf2 == true && rotation.z>(rotation.x + shift) && rotation.z>(rotation.y + shift)){
            self.jyroZf3 = true
        }
        if(rotation.z<rotation.x || rotation.z<rotation.y){
            self.jyroZf3 = false
        }
        if(self.jyroZf1 == true && rotation.z<(rotation.x - shift) && rotation.z<(rotation.y - shift)){
            self.jyroZf2 = true
        }
        if(rotation.z>rotation.x || rotation.z>rotation.y){
            self.jyroZf2 = false
        }
        if(rotation.z>(rotation.x + shift) || rotation.z>(rotation.y + shift)){
            self.jyroZf1 = true
        }
        else {
            self.jyroZf1 = false
        }
        //jyroZ研究2 //歩いてる感じをその場で再現を防止
        if(rotation.z >= 2.5 || rotation.z <= (-2.5)){
            self.myJyroZCounter = 2
        }
        
        //NGな行為な為初期化する
        //gyroY振りすぎ || ←強く降るの防止 || 上着ポケット入れる際の防止 || ←同じ || accecY2入り続けたら || 俺いい感上下防止策 || ポケット落とししたな
        if(rotation.y < (-gyroReaction) || rotation.y > gyroReaction || self.accelY < 0 || self.myAccelY2Counter < 94 || (self.accelY >= 1.5 && myJyroYCounter == 100) && self.myJyroZCounter != 100){
            
            //            if(experimentFlag == false){
            //                if(rotation.y < (-gyroReaction) || rotation.y > gyroReaction){
            //                    println("gyroY振りすぎ")
            //                }
            //                //            if(self.accelX<(-0.4)){
            //                //                println("上着のポケットに入れる動き")
            //                //            }
            //                if(self.accelY < 0){
            //                    println("ポケット入れたな")
            //                }
            //                //            if(self.myAccelY2Counter < 94){
            //                //                println("ケツ叩きしたな\(self.myAccelY2Counter)")
            //                //            }
            //                if(self.accelY >= 1.5 && myJyroYCounter == 100){
            //                    println("いい感じ上下防止")
            //                }
            //                if(self.myJyroZCounter != 100){
            //                    println("ポケット落とししたな\(self.myJyroZCounter)")
            //                }
            //            }
            
            sensorInit()
        }
        /*-------------*/
        
        var attitude = CMAttitude()
        var motion = CMDeviceMotion()
    }
    //研究パラメータ初期化
    func sensorInit(){
        self.myAccelYCounter = 100
        self.myAccelZCounter = 100
        self.myJyroXCounter = 100
        self.myJyroYCounter = 100
        self.accelYf1 = false
        self.accelYf2 = false
        self.accelYf3 = false
        self.accelZf1 = false
        self.accelZf2 = false
        self.accelZf3 = false
        self.jyroXf1 = false
        self.jyroXf2 = false
        self.jyroXf3 = false
        self.jyroZf1 = false
        self.jyroZf2 = false
        self.jyroZf3 = false
    }
    
    ////////////////////////////////////////////////
    
    ////~~~~DatePicker~~~~///////////////////////////////
    
    ////////////////////////////////////////////////
    
    
    //DatePickerが選ばれた際に呼ばれる.
    func onDidChangeDate(sender: UIDatePicker){
        //ピッカー時刻取得
        myDateFormatter = NSDateFormatter()
        myDateFormatter.dateFormat = "HH:mm"
        myDateFormatter.timeStyle = .MediumStyle
        mySelectedDate = myDateFormatter.stringFromDate(sender.date)
        //スイッチフラグ取得
        //        onOffFlag = myUserDafault.boolForKey("ONOFF")
        pickerUsedFlag = true
        //オンならアラームセット
        if(onOffFlag==true){
            settingAlarmTime()
        }
        else{
            planTime = myDateFormatter.dateFromString(mySelectedDate as String)!
            comps = calendar.components(NSCalendarUnit.YearCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.DayCalendarUnit|NSCalendarUnit.HourCalendarUnit|NSCalendarUnit.MinuteCalendarUnit|NSCalendarUnit.SecondCalendarUnit,
                fromDate: planTime)
            setTime(comps.hour, m: comps.minute) //時間ラベル更新
        }
    }
    func settingAlarmTime(){
        
        now = NSDate() // 現在の時刻を取得する。
        
        planTime = myDateFormatter.dateFromString(mySelectedDate as String)!
        
        //現在時刻を秒で取得
        comps = calendar.components(NSCalendarUnit.YearCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.DayCalendarUnit|NSCalendarUnit.HourCalendarUnit|NSCalendarUnit.MinuteCalendarUnit|NSCalendarUnit.SecondCalendarUnit,
            fromDate: now)
        var nowSecond = secondConverter(comps.hour, minute: comps.minute, second: comps.second)
        println("nowは \(comps.hour):\(comps.minute):\(comps.second)")
        println("nowを秒にすると\(nowSecond)");
        comps = calendar.components(NSCalendarUnit.YearCalendarUnit|NSCalendarUnit.MonthCalendarUnit|NSCalendarUnit.DayCalendarUnit|NSCalendarUnit.HourCalendarUnit|NSCalendarUnit.MinuteCalendarUnit|NSCalendarUnit.SecondCalendarUnit,
            fromDate: planTime)
        //ピッカー使われてない場合
        if(pickerUsedFlag==false){
            comps.hour = myUserDafault.integerForKey("ONCEHOUR")
            comps.minute = myUserDafault.integerForKey("ONCEMINUTE")
        }
        setTime(comps.hour, m: comps.minute) //時間ラベル更新
        
        //設定時刻を秒で取得
        var planTimeSecond = secondConverter(comps.hour, minute: comps.minute, second: 0)
        if(nowSecond>=planTimeSecond){
            planTimeSecond += 86400
        }
        timeDifference = planTimeSecond - nowSecond
        if(timeDifference<0){
            timeDifference = Int(numberConversion(Double(timeDifference)))
            timeDifference = 86400 - timeDifference
        }
        if(timeDifference==0){
            timeDifference = 0
        }
        println("planは \(comps.hour):\(comps.minute):00")
        println("planを秒にすると\(planTimeSecond)");
        println("時差は\(timeDifference)");
        myUserDafault.setInteger(nowSecond, forKey: "pastTime")
        myUserDafault.setInteger(timeDifference, forKey: "differenceTime")
        myUserDafault.setInteger(planTimeSecond, forKey: "PLANSECOND")
        myUserDafault.synchronize()
        timeSave() //設定時刻の保存
        postAlarm() //プッシュ通知設定する
        volumeChange.systemVolumeChange(1.0) //システム音変更
    }
    //通知仕込み処理
    func pushSixteen() {
        if(postTime == 60){
            postTime = 0
        }
        //        println(timeDifference)
        let lm = LangManager()
        while(postTime < 61) {
            //            print(postTime)
            var secondPost = Double(timeDifference)
            let myNotification: UILocalNotification = UILocalNotification()
            myNotification.alertBody = lm.getString(14)
            let musicNameStr:String = NSUserDefaults.standardUserDefaults().stringForKey("MUSIC_NAME")!
            myNotification.soundName = musicNameStr + ".caf"
            myNotification.timeZone = NSTimeZone.defaultTimeZone()
            myNotification.fireDate = NSDate(timeIntervalSinceNow: secondPost+(Double(postTime*postInterval)))
            UIApplication.sharedApplication().scheduleLocalNotification(myNotification)
            postTime += 1
        }
    }
    //giveupアラート仕込み処理
    func giveUpAlartCreate(){
        while(cryptographyNum > 0){
            cryptographyNum -= 0
            
        }
    }
    //プッシュ通知設定行う
    func postAlarm(){
        postTime = 60
        let qualityOfServiceClass = DISPATCH_QUEUE_PRIORITY_DEFAULT
        let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
        dispatch_async(backgroundQueue, {
            // Backgroundで行いたい重い処理はここ
            self.pushSixteen()
            dispatch_async(dispatch_get_main_queue(), {
                // 処理が終わった後UIスレッドでやりたいことはここ
            })
        })
    }
    
    func inclinateGyroContinue(){
        
        //加速度Yオッケーサインでたら1秒おっけー
        if(myAccelYCounter <= elbowroomValue){
            myAccelYCounter -= 1
        }
        if(myAccelYCounter < 1){
            myAccelYCounter = 100
        }
        //加速度Zオッケーサインでたら1秒おっけー
        if(myAccelZCounter <= elbowroomValue){
            myAccelZCounter -= 1
        }
        if(myAccelZCounter < 1){
            myAccelZCounter = 100
        }
        //ジャイロXオッケーサインでたら1秒おっけー
        if(myJyroXCounter <= elbowroomValue){
            myJyroXCounter -= 1
        }
        if(myJyroXCounter < 1){
            myJyroXCounter = 100
        }
        //ジャイロYNGサインでたら2秒おっけー
        if(myJyroYCounter <= elbowroomValue){
            myJyroYCounter -= 1
        }
        if(myJyroYCounter < 1){
            myJyroYCounter = 100
        }
        //ジャイロZオッケーサインでたら1秒NG
        if(myJyroZCounter <= 2){
            myJyroZCounter -= 1
        }
        if(myJyroZCounter < 1){
            myJyroZCounter = 100
        }
        
        
        
    }
    ////////////////////////////////////////////////
    ////~~~~オブジェクト生成~~~~///////////////////////////////
    ////////////////////////////////////////////////
    func objectMake(){
        let lm = LangManager()
        
        // DatePickerを生成する.
        myDatePicker = UIDatePicker()
        myDatePicker.datePickerMode = UIDatePickerMode.Time;//ここを変えればタイマーカウント等も作成できます。
        // datePickerを設定（デフォルトでは位置は画面上部）する.
        myDatePicker.frame = CGRectMake(0, 0, winSize.width,winSize.height/2)
        myDatePicker.timeZone = NSTimeZone.localTimeZone()
        myDatePicker.backgroundColor = UIColor.grayColor()
        myDatePicker.layer.cornerRadius = 2.0
        myDatePicker.layer.shadowOpacity = 0.5
        myDatePicker.layer.opacity = 0.6
        myDatePicker.layer.position = CGPoint(x: winSize.width/2,y: winSize.height/2 - 130); //108
        
        
        // 値が変わった際のイベントを登録する.
        myDatePicker.addTarget(self, action: "onDidChangeDate:", forControlEvents: .ValueChanged)
        //スイッチ準備
        alarmSwitch.layer.position = CGPoint(x: 30, y: winSize.height/2 - 2)
        alarmSwitch.onTintColor = UIColor.hexStr("#6286c0", alpha: 1)
        onOffFlag = myUserDafault.boolForKey("ONOFF")
        alarmSwitch.on = onOffFlag
        // SwitchのOn/Off切り替わりの際に、呼ばれるイベントを設定する.
        alarmSwitch.addTarget(self, action: "onClickMySwicth:", forControlEvents: UIControlEvents.ValueChanged)
        // 設定時間ラベル作成
        var hou = myUserDafault.integerForKey("SET_HOUR")
        var min = myUserDafault.integerForKey("SET_MINUTE")
        setTimeLabel = UILabel(frame: CGRectMake(0,0,winSize.width,winSize.height))
        setTimeLabel.layer.position = CGPoint(x: winSize.width/2,y: winSize.height/2 + 100);
        setTimeLabel.textAlignment = NSTextAlignment.Center
        //        setTimeLabel.font = UIFont.boldSystemFontOfSize(60)
        //        setTimeLabel.font = UIFont.systemFontOfSize(70)
        setTimeLabel.font = UIFont(name: "HelveticaNeue-UltraLight", size: 80)
        setTimeLabel.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        setTime(comps.hour, m: comps.minute) //時間ラベル更新
        if(onOffFlag == true && bgFlag == false){
            setTime(hou, m: min) //時間ラベル更新
        }
        
        //残り歩数ラベル生成
        pointLabel = UILabel(frame: CGRect(x: 0, y: 0, width: winSize.width, height: 30))
        pointLabel.textAlignment = NSTextAlignment.Center
        //        pointLabel.font = UIFont.boldSystemFontOfSize(20)
        pointLabel.font = UIFont.systemFontOfSize(20)
        //        pointLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 20)
        pointLabel.layer.position = CGPoint(x: winSize.width/2 + 80, y:winSize.height/2)
        pointLabel.layer.zPosition = 2
        pointLabel.textColor = UIColor.hexStr(colorCode, alpha: 1)
        lifePoints = myUserDafault.integerForKey("LIFE")
        pointLabel.text = "\(lifePoints)"
        
        //ギブアップボタン作成
        giveUpBtn = UIButton(frame: CGRectMake(160, 30, 100, 50))
        giveUpBtn.setTitle("give up!!", forState: .Normal)
        giveUpBtn.addTarget(self, action: "giveUpBtnAction:", forControlEvents:.TouchUpInside)
        giveUpBtn.layer.borderWidth = 1
        giveUpBtn.layer.borderColor = UIColor(white: 1.0, alpha: 1.0).CGColor
        giveUpBtn.layer.cornerRadius = 3
        giveUpBtn.layer.position = CGPoint(x: winSize.width/2,y: 150);
        giveUpBtn.layer.zPosition = -1
        //        giveUpBtn.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
        
        //音楽選択ボタン作成
        musicSelectBtn = UIButton(frame: CGRectMake(0, 0, 40, 40))
        musicSelectBtn.setTitle("♪", forState: .Normal)
        musicSelectBtn.addTarget(self, action: "musicSelectAction:", forControlEvents:.TouchUpInside)
//        musicSelectBtn.layer.borderWidth = 1
//        musicSelectBtn.layer.borderColor = UIColor(white: 1.0, alpha: 1.0).CGColor
//        musicSelectBtn.layer.cornerRadius = 3
        musicSelectBtn.layer.position = CGPoint(x: winSize.width - 20,y: winSize.height/2 + 50);
        musicSelectBtn.layer.zPosition = 2
        musicSelectBtn.backgroundColor = UIColor(red: 0.0, green: 1.0, blue: 0.5, alpha: 0.3)
        
        musicSelectView = UIView(frame: CGRectMake(0,0,winSize.width/2,winSize.height*3/4))
//        musicSelectView.layer.masksToBounds = true
        musicSelectView.backgroundColor = UIColor.hexStr("34495e", alpha: 0.7)
        musicSelectView.layer.zPosition = 3
        //flameLabel.layer.cornerRadius = 5
//        musicSelectWindow.layer.opacity = 0.8
        musicSelectView.layer.position = CGPoint(x: self.winSize.width*5/4,y: self.winSize.height*5/8)

        /**ウィンドウに乗せる関係*/
        horizonLabel1 = UILabel(frame: CGRectMake(0, 0, winSize.width/2 - 5, 3))
        horizonLabel1.backgroundColor = UIColor.hexStr("000000", alpha: 0.9)
        horizonLabel1.layer.zPosition = 3
        horizonLabel1.layer.position = CGPoint(x: self.winSize.width/4,y: self.winSize.height*2/8)
        horizonLabel2 = UILabel(frame: CGRectMake(0, 0, winSize.width/2 - 5, 2))
        horizonLabel2.backgroundColor = UIColor.hexStr("000000", alpha: 0.9)
        horizonLabel2.layer.zPosition = 3
        horizonLabel2.layer.position = CGPoint(x: self.winSize.width/4,y: self.winSize.height*3/8)
        horizonLabel3 = UILabel(frame: CGRectMake(0, 0, winSize.width/2 - 5, 1))
        horizonLabel3.backgroundColor = UIColor.hexStr("000000", alpha: 0.9)
        horizonLabel3.layer.zPosition = 3
        horizonLabel3.layer.position = CGPoint(x: self.winSize.width/4,y: self.winSize.height*4/8)
        horizonLabel4 = UILabel(frame: CGRectMake(0, 0, winSize.width/2 - 5, 3))
        horizonLabel4.backgroundColor = UIColor.hexStr("000000", alpha: 0.9)
        horizonLabel4.layer.zPosition = 3
        horizonLabel4.layer.position = CGPoint(x: self.winSize.width/4,y: self.winSize.height*5/8)
        horizonLabel5 = UILabel(frame: CGRectMake(0, 0, winSize.width/2 - 5, 3))
        horizonLabel5.backgroundColor = UIColor.hexStr("000000", alpha: 0.9)
        horizonLabel5.layer.zPosition = 3
        horizonLabel5.layer.position = CGPoint(x: self.winSize.width*5/4,y: self.winSize.height*6/8)
        
        
        // Stepperの作成する
        lifeStepper = UIStepper()
        //lifeStepper.backgroundColor = UIColor.whiteColor()
        lifeStepper.addTarget(self, action: "stepperOneChanged:", forControlEvents: UIControlEvents.ValueChanged)
        lifeStepper.layer.cornerRadius = 1
        //        lifeStepper.setcolor = UIColor.hexStr(colorCode, alpha: 1)
        lifeStepper.tintColor = UIColor.hexStr(colorCode, alpha: 1)
        lifeStepper.layer.position = CGPoint(x: winSize.width/2 - 5,y: winSize.height/2 - 2);
        // 最小値, 最大値, 規定値の設定をする.
        lifeStepper.minimumValue = 3
        lifeStepper.maximumValue = 15
        lifeStepper.value = Double(myUserDafault.integerForKey("LIFEFINAL"))
        // ボタンを押した際に動く値の.を設定する.
        lifeStepper.stepValue = 1
        
        //枠組み作成
        //枠の見た目作成する.
        var flameLabel = UILabel(frame: CGRectMake(0,0,winSize.width,40))
        flameLabel.layer.masksToBounds = true
        flameLabel.backgroundColor = UIColor.hexStr("34495e", alpha: 1)
        //flameLabel.layer.cornerRadius = 5
        flameLabel.layer.opacity = 0.8
        flameLabel.layer.position = CGPoint(x: winSize.width/2, y:winSize.height/2 - 2)
        
        //        //マナーモード推奨ボタン
        //        mannerModeButton = UIButton(frame: CGRectMake(0, 0, 10, 10))
        //        tutorialBtn.layer.position = CGPoint(x: winSize.width/2 - 100, y:winSize.height/2 + 40)
        //        tutorialBtn.setImage(UIImage(CIImage: howtoOpenCIImage), forState: .Normal)
        //        //        tutorialBtn.layer.borderWidth = 0.7
        //        //        tutorialBtn.layer.borderColor = UIColor(white: 1.0, alpha: 1.0).CGColor
        //        //        tutorialBtn.layer.cornerRadius = 3.0
        //        tutorialBtn.addTarget(self, action: "tutorialBtnActionIn:", forControlEvents:.TouchUpInside)
        
        //音量アイコン
        musicStopUIImage = UIImageView(frame: CGRectMake(0, 0, 35, 35))
        musicStopUIImage.image = UIImage(CIImage: musicStopCIImage)
        musicStopUIImage.layer.position = CGPoint(x: 25, y: winSize.height - 20)
        musicPlayUIImage = UIImageView(frame: CGRectMake(0, 0, 35, 35))
        musicPlayUIImage.image = UIImage(CIImage: musicPlayCIImage)
        musicPlayUIImage.layer.position = CGPoint(x: winSize.width - 25, y: winSize.height - 20)
        
        //歩きアイコン
        //        walkUIImage = UIImageView(frame: CGRectMake(0, 0, 25, 25))
        //        walkUIImage.image = UIImage(CIImage: walkCIImage)
        //        walkUIImage.layer.position = CGPoint(x: 25, y: winSize.height - 50)
        //        runUIImage = UIImageView(frame: CGRectMake(0, 0, 25, 25))
        //        runUIImage.image = UIImage(CIImage: runCIImage)
        //        runUIImage.layer.position = CGPoint(x: winSize.width - 25, y: winSize.height - 50)
        
        //足跡アイコン
        footUIImage = UIImageView(frame: CGRectMake(0, 0, 25, 25))
        footUIImage.image = UIImage(CIImage: footCIImage)
        footUIImage.layer.position = CGPoint(x: winSize.width/2 + 58, y: winSize.height/2 - 2)
        footUIImage.layer.zPosition = 2
        
        //アラームアイコン
        alarmUIImage = UIImageView(frame: CGRectMake(0, 0, 30, 30))
        alarmUIImage.image = UIImage(CIImage: alarmOffCIImage)
        alarmUIImage.layer.position = CGPoint(x: 70, y: winSize.height/2 - 2)
        alarmUIImage.layer.zPosition = 2
        
        //チュートリアルボタン作成
        tutorialBtn = UIButton(frame: CGRectMake(0, 0, 30, 30))
        tutorialBtn.layer.position = CGPoint(x: winSize.width - 30, y:winSize.height/2 - 2)
        tutorialBtn.layer.zPosition = 2
        tutorialBtn.setImage(UIImage(CIImage: howtoOpenCIImage), forState: .Normal)
        //        tutorialBtn.layer.borderWidth = 0.7
        //        tutorialBtn.layer.borderColor = UIColor(white: 1.0, alpha: 1.0).CGColor
        //        tutorialBtn.layer.cornerRadius = 3.0
        tutorialBtn.addTarget(self, action: "tutorialBtnActionIn:", forControlEvents:.TouchUpInside)
        //        tutorialBtn.addTarget(self, action: "tutorialBtnActionOut:", forControlEvents:.TouchUpOutside)
        //        tutorialBtn.addTarget(self, action: "tutorialBtnActionDown:", forControlEvents:.TouchDown)
        //        tutorialBtn.backgroundColor = UIColor.hexStr("ffffff", alpha: 0.3)
        
        // UIImageViewを作成する.
        backgroundImageView = UIImageView(frame: CGRectMake(0, 0, winSize.width, winSize.height))
        backgroundImageView.image = UIImage(CIImage: bgInputImage)
        backgroundImageView.layer.opacity = 0.8
        
        //マナーモード推奨ラベル
        mannerModeLabel = UILabel(frame: CGRectMake(0,0,winSize.width*2/3,30))
        mannerModeLabel.backgroundColor = UIColor.hexStr("CC0000", alpha: 1)
        mannerModeLabel.text = lm.getString(11)
        mannerModeLabel.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        mannerModeLabel.textAlignment = .Center
        mannerModeLabel.font = UIFont.systemFontOfSize(12)
        mannerModeLabel.layer.cornerRadius = 2
        mannerModeLabel.layer.opacity = 0.6
        mannerModeLabel.layer.position = CGPoint(x: -150, y:winSize.height/2 + 40)
        
        //        //歩幅調整スライダー
        //        stepSlider = UISlider(frame: CGRectMake(0, 0, winSize.width-100, 40))
        //        stepSlider.layer.position = CGPoint(x: winSize.width/2, y:winSize.height - 50)
        //        stepSlider.tintColor = UIColor.whiteColor()
        //        stepSlider.minimumValue = 0.0;//最小値設定
        //        stepSlider.maximumValue = 1.5;//最大値設定
        //        walkStep = myUserDafault.doubleForKey("STEPFINAL")
        //        stepSlider.value = Float(walkStep)
        //        stepSlider.addTarget(self, action: "onChangeValueStepSlider:", forControlEvents: UIControlEvents.ValueChanged)
        //        self.view.backgroundColor = UIColor(red: 0, green: CGFloat(stepSlider.value), blue: 0, alpha: 1)
        
        //Blurエフェクト生成
        var effect : UIBlurEffect!
        effect = UIBlurEffect(style: UIBlurEffectStyle.Light)
        
        //音量スライダー生成
        var wrapperView = MPVolumeView(frame: CGRectMake(0, 0, winSize.width-100, 50))
        wrapperView.layer.position = CGPoint(x: winSize.width/2, y:winSize.height - 5)
        //        wrapperView.addTarget(self, action: "onChangeValueStepSlider:", forControlEvents: UIControlEvents.ValueChanged)
        wrapperView.tintColor = UIColor.whiteColor()
        
        // Viewに追加する.
        self.view.addSubview(backgroundImageView) //背景
        self.addVirtualEffectView(effect)
        self.view.addSubview(myDatePicker)
        self.view.addSubview(musicStopUIImage)
        self.view.addSubview(musicPlayUIImage)
        //        self.view.addSubview(walkUIImage)
        //        self.view.addSubview(runUIImage)
        self.view.addSubview(flameLabel)
        self.view.addSubview(lifeStepper)
        self.view.addSubview(giveUpBtn)
        self.view.addSubview(tutorialBtn)
        self.view.addSubview(musicSelectBtn)
        
        self.view.addSubview(musicSelectView)
        self.musicSelectView.addSubview(horizonLabel1)
        self.musicSelectView.addSubview(horizonLabel2)
        self.musicSelectView.addSubview(horizonLabel3)
        self.musicSelectView.addSubview(horizonLabel4)
        self.musicSelectView.addSubview(horizonLabel5)
        
        self.view.addSubview(pointLabel)
        self.view.addSubview(footUIImage)
        self.view.addSubview(alarmUIImage)
        self.view.addSubview(alarmSwitch)
        //        self.view.addSubview(stepSlider)
        self.view.addSubview(setTimeLabel)
        self.view.addSubview(wrapperView)
        self.view.addSubview(mannerModeLabel)
        
        
        //objectMove()//オブジェクトポジション
    }
    
    func objectMove(){
        //音楽鳴ってれば
        if(bgFlag==true){
            myDatePicker.layer.zPosition = -1 //ピッカーさよなら
            myDatePicker.layer.position = CGPoint(x: winSize.width * 2,y: winSize.height * 2);
            giveUpBtn.layer.zPosition = 3 //ギブアップボタン浮上
            giveUpBtn.layer.hidden = false
            effectView.layer.zPosition = 1 //Blur浮上
            alarmUIImage.layer.zPosition = -1 //アラームアイコンさよなら
            
            //押せるようにする
            giveUpBtn.enabled = true
            //押せないようにする
            alarmSwitch.enabled = false
            lifeStepper.enabled = false
            myDatePicker.enabled = false
            
        }
            //音楽鳴ってなければ
        else{
            myDatePicker.layer.zPosition = 1 //ピッカー浮上
            myDatePicker.layer.position = CGPoint(x: winSize.width/2,y: winSize.height/2 - 130);
            giveUpBtn.layer.zPosition = -1 //ギブアップボタンさよなら
            giveUpBtn.layer.hidden = true
            effectView.layer.zPosition = -1 //Blurさよなら
            alarmUIImage.layer.zPosition = 2 //アラームアイコン浮上
            
            //押せるようにする
            alarmSwitch.enabled = true
            lifeStepper.enabled = true
            myDatePicker.enabled = true
            //押せないようにする
            giveUpBtn.enabled = false
        }
        
        //アラームオンなら
        if(onOffFlag == true){
            alarmUIImage.image = UIImage(CIImage: alarmOnCIImage)
            setTimeLabel.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        }
        else {
            alarmUIImage.image = UIImage(CIImage: alarmOffCIImage)
            setTimeLabel.textColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.2)
        }
        bgColorChange()
    }
    
    //背景色いい感じにする
    func bgColorChange(){
        
        // カラーエフェクトを指定してCIFilterをインスタンス化する.
        let myColorFilter = CIFilter(name: "CIColorCrossPolynomial")
        
        // イメージを設定する.
        myColorFilter.setValue(bgInputImage, forKey: kCIInputImageKey)
        
        // RGBの変換値を作成する.
        var r: [CGFloat]!
        var g: [CGFloat]!
        var b: [CGFloat]!
        if(lifePoints>2){
            r = [0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
            g = [0.0, 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
            b = [0.2, CGFloat(lifePoints/50), 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        }
            //        else if(lifePoints>2){
            //            r = [0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
            //            g = [0.2, CGFloat(lifePoints/30), 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
            //            b = [0.0, 0.2, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
            //        }
        else {
            r = [0.0, 0.5, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
            g = [0.0, 0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
            b = [0.1, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0, 0.0]
        }
        
        // 値の調整をする.
        myColorFilter.setValue(CIVector(values: r, count: 10), forKey: "inputRedCoefficients")
        myColorFilter.setValue(CIVector(values: g, count: 10), forKey: "inputGreenCoefficients")
        myColorFilter.setValue(CIVector(values: b, count: 10), forKey: "inputBlueCoefficients")
        
        // フィルターで処理した画像をアウトプットする.
        let myOutputImage : CIImage = myColorFilter.outputImage
        
        // 再びUIView処理済み画像を設定する.
        backgroundImageView.image = UIImage(CIImage: myOutputImage)
        
        // 再描画をおこなう.
        backgroundImageView.setNeedsDisplay()
    }
    
    
    //Blurエフェクト表示
    func addVirtualEffectView(effect : UIBlurEffect!){
        // Blurエフェクトを適用するEffectViewを作成.
        effectView = UIVisualEffectView(effect: effect)
        effectView.frame = CGRectMake(0, 0, winSize.width, winSize.height/2 + 25)
        //        effectView.layer.position = CGPointMake(0,0)
        //        effectView.layer.masksToBounds = true
        effectView.backgroundColor = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 0.2)
        effectView.layer.cornerRadius = 3.0
        effectView.layer.zPosition = -1
        self.view.addSubview(effectView)
    }
    
    //時間セットラベル変更
    func setTime(h:Int, m:Int){
        setTimeLabel.text = "\(h):\(m)"
        if(m<10){
            setTimeLabel.text = "\(h):0\(m)"
        }
    }
    func pushAuthorization(){
        // 通知の許可をもらう.
        UIApplication.sharedApplication().registerUserNotificationSettings(
            UIUserNotificationSettings(
                forTypes:UIUserNotificationType.Sound | UIUserNotificationType.Alert,
                categories: nil)
        )
    }
    
    ////////////////////////////////////////////////
    ////~~~~TURU~~~~///////////////////////////////
    ////////////////////////////////////////////////
    //負なら正へ変換
    func numberConversion(value:Double) -> Double{
        if(value < 0){
            return value * (-1)
        }
        return value
    }
    //x時x分x秒を秒に変換
    func secondConverter(hour:Int, minute:Int, second:Int) -> Int{
        return (hour*3600) + (minute*60) + second
    }
    func timeSave(){
        myUserDafault.setInteger(comps.hour, forKey: "SET_HOUR")
        myUserDafault.setInteger(comps.minute, forKey: "SET_MINUTE")
        myUserDafault.synchronize()
    }
    //数字を英語に変換
    func englishWordsConverter(wordNum:Int) ->String{
        var word = ""
        switch wordNum{
        case 10:
            word = "a"
            break
        case 11:
            word = "b"
            break
        case 12:
            word = "c"
            break
        case 13:
            word = "d"
            break
        case 14:
            word = "e"
            break
        case 15:
            word = "f"
            break
        case 16:
            word = "g"
            break
        case 17:
            word = "h"
            break
        case 18:
            word = "i"
            break
        case 19:
            word = "j"
            break
        case 20:
            word = "k"
            break
        case 21:
            word = "l"
            break
        case 22:
            word = "m"
            break
        case 23:
            word = "n"
            break
        case 24:
            word = "o"
            break
        case 25:
            word = "p"
            break
        case 26:
            word = "q"
            break
        case 27:
            word = "r"
            break
        case 28:
            word = "s"
            break
        case 29:
            word = "t"
            break
        case 30:
            word = "u"
            break
        case 31:
            word = "v"
            break
        case 32:
            word = "w"
            break
        case 33:
            word = "x"
            break
        case 34:
            word = "y"
            break
        case 35:
            word = "z"
            break
        default:
            word = "x"
            break
        }
        
        return word
    }
    
    //アラート出力
    func openAlert(titleStr:String, messageStr:String, okStr:String){
        NotificationUtil.pushDelete()
        let alert:UIAlertController = UIAlertController(title:titleStr,
            message: messageStr,
            preferredStyle: UIAlertControllerStyle.Alert)
        let defaultAction:UIAlertAction = UIAlertAction(title: okStr,
            style: UIAlertActionStyle.Default,
            handler:{
                (action:UIAlertAction!) -> Void in
                let textFields:Array<UITextField>? =  alert.textFields as! Array<UITextField>?
                self.interstitial.presentFromRootViewController(self) //インタースティシャル広告表示
        })
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    func firstContactCheck(){
        let fc = FirstClass()
        if(fc.playBoyCheck() == false){
            playBoyTimer = NSTimer.scheduledTimerWithTimeInterval(0.1, target: self, selector: "sceneChange", userInfo: nil, repeats: false)
        }
    }
    func sceneChange(){
        myUserDafault.setBool(bgFlag, forKey: "bgm")
        myUserDafault.synchronize()
        let mySecondViewController: UIViewController = UiPageController()
        mySecondViewController.modalTransitionStyle = UIModalTransitionStyle.CrossDissolve
        presentViewController(mySecondViewController, animated: true, completion: nil)
    }
    ////////////////////////////////////////////////
    ////~~~~MUSIC~~~~///////////////////////////////
    ////////////////////////////////////////////////
    
    func musicStart(){
        bgFlag = true
        myUserDafault.setBool(bgFlag, forKey: "bgm")
        myUserDafault.synchronize()
        AVAudioPlayerUtil.play();//再生
        //バイブも鳴らす
        vibTimer = NSTimer.scheduledTimerWithTimeInterval(vibInterval, target: self, selector: "vibUpdate", userInfo: nil, repeats: true)
        objectMove()
        self.myUserDafault.setInteger(5, forKey: "TUTORIALLIFE")
        self.myUserDafault.synchronize()
    }
    func musicStop(){
        if(self.bgFlag==true){
            self.bgFlag = false
            self.onOffFlag = false
            myUserDafault.setBool(self.bgFlag, forKey: "bgm")
            myUserDafault.synchronize()
            myUserDafault.setBool(self.onOffFlag, forKey: "ONOFF")
            myUserDafault.synchronize()
            self.alarmSwitch.on = self.onOffFlag
            //Blurエフェクト削除
            //            if effectView != nil {
            //                effectView.removeFromSuperview()
            //            }
            AVAudioPlayerUtil.playMusicVolumeSetting(1.0)
            AVAudioPlayerUtil.stop()
            objectMove() //オブジェクト移動
            noMusicInit()
        }
    }
    //音楽が止まった時の初期化処理
    func noMusicInit(){
        self.myUserDafault.setInteger(4, forKey: "TUTORIALLIFE") //4はストップ
        self.myUserDafault.synchronize()
        self.lifePoints = self.myUserDafault.integerForKey("LIFEFINAL")
        self.myUserDafault.setInteger(self.lifePoints, forKey: "LIFE")
        self.myUserDafault.synchronize()
        self.myUserDafault.setBool(false, forKey: "HAJIMEIPPO_STILL") //1歩目か初期化
        self.myUserDafault.synchronize()
        
        pointLabel.text = "\(lifePoints)"
        objectMove() //オブジェクト移動
    }
    func vibUpdate(){
        print("vib")
        if(bgFlag == true){
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        }
    }
    //割り込み対策
    func audioSessionInterrupted(notification: NSNotification) {
        if let userInfos = notification.userInfo {
            if let type: AnyObject = userInfos["AVAudioSessionInterruptionTypeKey"] {
                if type is NSNumber {
                    if type.unsignedLongValue == AVAudioSessionInterruptionType.Began.rawValue{
                        println("割り込みきた")
                        if (bgFlag == true && AVAudioPlayerUtil.audioPlayer[0].playing) {
                            //AVAudioPlayerUtil.stop()
                        }
                    }
                    if type.unsignedLongValue == AVAudioSessionInterruptionType.Ended.rawValue{
                        print("割り込み終わっ・")
                        if (bgFlag == true  && AVAudioPlayerUtil.audioPlayer[0].playing == false) {
                            // 現在再生していないなら再生
                            print("・・・")
                            AVAudioPlayerUtil.play() //再生
                        }
                        println("た")
                    }
                }
            }
        }
    }
    //イヤホン挿したり？
    func audioSessionRouteChange(notification: NSNotification) {
        //        if let userInfos = notification.userInfo {
        //            if let type: AnyObject = userInfos["AVAudioSessionRouteChangeReasonKey"] {
        //                if type is NSNumber {
        //                    if type.unsignedLongValue == AVAudioSessionRouteChangeReason.NewDeviceAvailable.rawValue{
        //                        println("NewDeviceAvailable")
        //                    }
        //                    if type.unsignedLongValue == AVAudioSessionRouteChangeReason.Override.rawValue{
        //                        println("Override")
        //                    }
        //                }
        //            }
        //        }
        for port in session.currentRoute.outputs as! [AVAudioSessionPortDescription] {
            //            println(port.portName)
            //            println(port.portType)
            //            println(port.UID)
            if port.portType == AVAudioSessionPortBuiltInSpeaker {
                //内臓スピーカが選ばれている時の処理
                println("スピーカ")
            }else if port.portType == AVAudioSessionPortHeadphones {
                //ヘッドホンが選ばれている時の処理
                //                println("ヘッドホン")
                session.setCategory(AVAudioSessionCategoryPlayAndRecord, error: nil)
                session.setActive(true, error: nil)
                session.overrideOutputAudioPort(AVAudioSessionPortOverride.Speaker, error: nil)
            }
            for channel in port.channels as! [AVAudioSessionChannelDescription] {
                //左右チャンネルなどの情報が欲しいとき、以下を検討
                //println(channel.channelName)
                //println(channel.channelNumber)
                //println(channel.owningPortUID)
                //println(channel.channelName)
            }
        }
    }
    
    func getInstanceVolumeButtonNotification(notification: NSNotification) {
        //        var aSession = AVAudioSession()
        //        var volume = aSession.outputVolume
        //        println("音量改變：\(volume)")
        volumeChange.systemVolumeChange(0.3) //システム音変更 //本来は0.3
    }
    
    //admobインタースティシャル準備
    func admobInterstitialReady(){
        //本番用
        interstitial.adUnitID = "ca-app-pub-1645837363749700/5447856877"
        interstitial.loadRequest(GADRequest())
        
        //テスト用
        //        var request = GADRequest()
        //        request.testDevices = ["9e51e86223f362580ae947fffea1b3e8"]
        //        interstitial.loadRequest(request)
    }
    
    
    func audioPlayerDidFinishPlaying(player: AVAudioPlayer!, successfully flag: Bool) {
        player.stop()
        // 再生終了を通知
        let noti = NSNotification(name: "stop", object: self)
        NSNotificationCenter.defaultCenter().postNotification(noti)
        println("ストップしました")
    }
    
    func mannerLabelReturn(){
        let lm = LangManager()
        if(mannerCautionTimer != nil){
            mannerCautionTimer.invalidate()
            mannerCautionTimer = nil
            UIView.animateWithDuration(1.0, animations: {() -> Void in
                self.mannerModeLabel.center = CGPoint(x: -150,y: self.winSize.height/2 + 40)
                }, completion: {(Bool) -> Void in
                    self.mannerModeLabel.text = lm.getString(11)
            })
        }
        
    }
    func ads(){
        self.interstitial.presentFromRootViewController(self) //インタースティシャル広告表示
        interstitialTimer.invalidate()
        interstitialTimer = nil
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

struct NotificationUtil {
    static func pushDelete(){
        //全てのローカル通知を削除する。（過去のローカル通知を削除する）
        UIApplication.sharedApplication().cancelAllLocalNotifications()
    }
}
