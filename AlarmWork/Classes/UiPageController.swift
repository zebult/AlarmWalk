//
//  UiPageController.swift
//  AlarmWork
//
//  Created by 鈴木才智 on 2015/01/25.
//  Copyright (c) 2015年 SaichiSuzuki. All rights reserved.
//

import UIKit

class UiPageController: UIViewController, UIScrollViewDelegate{
    
    var pageControl: UIPageControl!
    var scrollView: UIScrollView!
    var footLabel: UILabel!
    
    let pageSize = 4
    var winSize = CGRect()
    var footCount = 2
    
    var walkTestTimer: NSTimer!
    
    var myUserDafault:NSUserDefaults = NSUserDefaults()
    
    let volumeChange = SystemVolumeController()
    
    var titleBtn = UIButton()
    
    var myUserDefault = NSUserDefaults()
    
    //背景画像
    var backgroundImageView: UIImageView!
    // 画像を設定する.
    let bgInputImage = CIImage(image: UIImage(named: "scrollBackground.png"))
    
    var jButton: UIButton!
    var eButton: UIButton!
    var titleLabel: UILabel!
    
    //バナー広告準備
    var bannerView: GADBannerView = GADBannerView()
    
    func adsButtonAction(sender: UIButton){
        let url = NSURL(string: "https://itunes.apple.com/us/app/ultrazebra/id853473067?l=ja&ls=1&mt=8")
        UIApplication.sharedApplication().openURL(url!)
    }
    
    /**日本語ボタン**/
    func japaneseAction(sender: UIButton){
        self.myUserDafault.setInteger(1, forKey: "LANGUAGE")
        self.myUserDafault.synchronize()
        titleHidden()
    }
    func japaneseActionOut(sender: UIButton){
        jButton.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    }
    func japaneseActionDown(sender: UIButton){
        jButton.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
    }
    /**英語ボタン**/
    func englishAction(sender: UIButton){
        self.myUserDafault.setInteger(0, forKey: "LANGUAGE")
        self.myUserDafault.synchronize()
        titleHidden()
    }
    func englishActionOut(sender: UIButton){
        eButton.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.0)
    }
    func englishActionDown(sender: UIButton){
        eButton.backgroundColor = UIColor(red: 0.0, green: 0.0, blue: 0.0, alpha: 0.2)
    }
    
    func titleHidden(){
        titleLabel.removeFromSuperview()
        jButton.removeFromSuperview()
        eButton.removeFromSuperview()
        titleBtn.removeFromSuperview()
        self.view.addSubview(scrollView)
        self.view.addSubview(pageControl)
        objectCreate()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        removeFromParentViewController() //とりあえずなんか解放できるかも
        
        winSize = self.view.bounds //画面サイズ取得
        
        
        titleSetting()
        
        self.view.backgroundColor = UIColor.grayColor()
        
        // ScrollViewを取得する.
        scrollView = UIScrollView(frame: self.view.frame)
        
        // ページ数を定義する.
        
        // 縦方向と、横方向のインディケータを非表示にする.
        scrollView.showsHorizontalScrollIndicator = false;
        scrollView.showsVerticalScrollIndicator = false
        // ページングを許可する.
        scrollView.pagingEnabled = true
        // ScrollViewのデリゲートを設定する.
        scrollView.delegate = self
        // スクロールの画面サイズを指定する.
        scrollView.contentSize = CGSizeMake(CGFloat(pageSize) * winSize.width, 0)
        // ScrollViewをViewに追加する.
        
        // PageControlを作成する.
        pageControl = UIPageControl(frame: CGRectMake(0, self.view.frame.maxY - 100, winSize.width, 50))
        pageControl.backgroundColor = UIColor(red: 0.1, green: 0.2, blue: 0.3, alpha: 1.0)
        // PageControlするページ数を設定する.
        pageControl.numberOfPages = pageSize
        
        // 現在ページを設定する.
        pageControl.currentPage = 0
        pageControl.userInteractionEnabled = false
        
        
        if(myUserDefault.boolForKey("RegularUser_Ads")){
            adbannerOpen() //バナー広告表示
        }
        self.myUserDafault.setBool(true, forKey: "RegularUser_Ads")
        self.myUserDafault.setInteger(4, forKey: "TUTORIALLIFE")
        self.myUserDafault.synchronize()
    }
    func walkTestUpdate(){
        if(myUserDafault.integerForKey("TUTORIALLIFE") == 4 || myUserDafault.integerForKey("TUTORIALLIFE") == 5){
            myUserDafault.setInteger(2, forKey: "TUTORIALLIFE")
            myUserDafault.synchronize()
        }
        if(footCount != myUserDafault.integerForKey("TUTORIALLIFE")){
            
            footCount = myUserDafault.integerForKey("TUTORIALLIFE")
            if(footCount>0){
                //ラベル更新
                footLabel.text = "\(footCount)"
            }
            else{
                footLabel.text = "ok"
            }
            if(footCount == 0){
                AVAudioPlayerUtil.playTestFinish()
            }
        }
    }
    
    func objectCreate(){
        
        let howtoImage1_1:UIImage = UIImage(named:"howto1_1.png")!
        let howtoImage1_2:UIImage = UIImage(named:"howto1_2.png")!
        
        let lm = LangManager()
        
        setPageObjectCreate()
        
        // ページ数分ボタンを生成する.
        for var i = 0; i < pageSize; i++ {
            
            //タイトルボタン作成
            titleBtn = UIButton(frame: CGRectMake(10, 15, 50, 30))
            titleBtn.setTitle("Skip", forState: .Normal)
            titleBtn.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
            titleBtn.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
            titleBtn.addTarget(self, action: "moveTitle", forControlEvents:.TouchUpInside)
            self.view.addSubview(titleBtn)
            
            //            //ナビゲーションバー作成
            //            let barLabel:UILabel = UILabel(frame: CGRectMake(CGFloat(i) * winSize.width, 0, winSize.width, 50))
            //            barLabel.backgroundColor = UIColor.lightGrayColor()
            //            barLabel.layer.opacity = 0.8
            //            self.view.addSubview(barLabel)
            
            // ページごとに異なるタイトルを生成する.
            let myLabel:UILabel = UILabel(frame: CGRectMake(CGFloat(i) * winSize.width, 50, winSize.width, 50))
            myLabel.backgroundColor = UIColor.blackColor()
            myLabel.textColor = UIColor.whiteColor()
            myLabel.textAlignment = NSTextAlignment.Center
            myLabel.layer.masksToBounds = true
            myLabel.numberOfLines = 0;
            myLabel.text = "Page\(i)"
            myLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
            myLabel.font = UIFont.systemFontOfSize(14) //標準
            myLabel.layer.opacity = 0.8
            
            //ページの補足説明
            let soundLabel:UILabel = UILabel(frame: CGRectMake(CGFloat(i) * winSize.width, winSize.height - 130, winSize.width, 30))
            soundLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
            soundLabel.textColor = UIColor.blackColor()
            soundLabel.textAlignment = NSTextAlignment.Center
            soundLabel.numberOfLines = 0;
            soundLabel.text = lm.getString(4)
            soundLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
            soundLabel.font = UIFont.systemFontOfSize(12)
            soundLabel.hidden = false
            soundLabel.layer.opacity = 0.8
            //メイン画像
            var iphoneView:UIImageView = UIImageView(image:howtoImage1_1)
            iphoneView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            iphoneView.frame = CGRectMake(CGFloat(i) * winSize.width + winSize.width/2 - 100, 150, 199, 305)
            //サブ画像
            var iphoneSubView:UIImageView = UIImageView(image:howtoImage1_2)
            iphoneSubView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
            iphoneSubView.frame = CGRectMake(CGFloat(i) * winSize.width + winSize.width/2 - 100, 150, 199, 305)
            iphoneSubView.hidden = true
            
            switch i{
            case 0: myLabel.text = lm.getString(0)
            iphoneView.layer.position = CGPoint(x: winSize.width/2 - 55, y: winSize.height/2 + 25)
            iphoneSubView.frame = CGRectMake(CGFloat(i) * winSize.width + winSize.width/2 - 100, 150, 150, 225)
            iphoneSubView.layer.position = CGPoint(x: winSize.width/2 + 75, y: winSize.height/2 + 25)
            iphoneSubView.hidden = false
                break
            case 1: myLabel.text = lm.getString(1)
            iphoneView.image = UIImage(named: "pocket1.png")
            iphoneSubView.image = UIImage(named: "pocket2.png")
            iphoneView.frame = CGRectMake(CGFloat(i) * winSize.width + winSize.width/2 - 150, winSize.height/2 - 90, 150, 250)
            soundLabel.text = lm.getString(5)
            iphoneSubView.frame = CGRectMake(CGFloat(i) * winSize.width + winSize.width/2 + 5, winSize.height/2 - 90, 100, 250)
            iphoneSubView.hidden = false
                break
            case 2: myLabel.text = lm.getString(2)
            //            iphoneView.image = UIImage(named: "footPaint.png")
            //            iphoneView.frame = CGRectMake(CGFloat(i) * winSize.width + winSize.width/2 - 100, winSize.height/2 - 50, 75, 75)
            iphoneView.hidden = true
            soundLabel.text = lm.getString(6)
                break
            case 3: myLabel.text = lm.getString(3)
            iphoneView.hidden = true
            soundLabel.hidden = true
                break
                //            case 4: myLabel.text = page5TopText
                //            //            iphoneView.frame = CGRectMake(CGFloat(i) * winSize.width + winSize.width/2, winSize.height/2, 300, 132)
                //            //            iphoneView.image = UIImage(named: "howtoBookOpen.png")
                //            iphoneView.hidden = true
                //            soundLabel.hidden = true
                //                break
            default:
                break
            }
            iphoneView.layer.zPosition = -1
            iphoneSubView.layer.zPosition = -1
            scrollView.addSubview(iphoneView)
            scrollView.addSubview(iphoneSubView)
            scrollView.addSubview(myLabel)
            scrollView.addSubview(soundLabel)
        }
    }
    
    /**
    *指定したページにオブジェクトを配置する
    */
    func setPageObjectCreate(){
        
        let lm = LangManager()
        
        //0ページ目に設置
        let myLabel:UILabel = UILabel(frame: CGRectMake(-winSize.width, 50, winSize.width, 50))
        myLabel.backgroundColor = UIColor.blackColor()
        myLabel.layer.opacity = 0.8
        let soundLabel:UILabel = UILabel(frame: CGRectMake(-winSize.width, winSize.height - 130, winSize.width, 30))
        soundLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.8)
        soundLabel.layer.opacity = 0.8
        //隠し広告
        let zebraAdsImage = CIImage(image: UIImage(named: "zebraAds.png"))
        let zebraAdsButton = UIButton(frame: CGRectMake(0, 0, 320 * 0.8, 180 * 0.8))
        zebraAdsButton.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        //        zebraAdsButton.frame = CGRectMake(-winSize.width, winSize.height - 130, winSize.width/2, winSize.width/9)
        zebraAdsButton.layer.position = CGPoint(x: -150, y:winSize.height/2)
        zebraAdsButton.setImage(UIImage(CIImage: zebraAdsImage), forState: .Normal)
        zebraAdsButton.addTarget(self, action: "adsButtonAction:", forControlEvents:.TouchDown)
        //        //隠れゼブラ
        //        let zebraImage:UIImage = UIImage(named:"simaumal03.png")!
        //        var zebraView:UIImageView = UIImageView(image:zebraImage)
        //        zebraView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        //        zebraView.frame = CGRectMake(-winSize.width/2, winSize.height - 166, 25, 25) //173浮いてる
        
        //2ページの補足説明
        let pocketLabel:UILabel = UILabel(frame: CGRectMake(winSize.width, 100, winSize.width, 50))
        pocketLabel.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.3)
        pocketLabel.textColor = UIColor.blackColor()
        pocketLabel.textAlignment = NSTextAlignment.Center
        pocketLabel.numberOfLines = 0
        pocketLabel.text = lm.getString(7)
        pocketLabel.font = UIFont.systemFontOfSize(UIFont.smallSystemFontSize())
        pocketLabel.font = UIFont.systemFontOfSize(12)
        //3ページの補足説明
        footLabel = UILabel(frame: CGRectMake((winSize.width * 2) + winSize.width/2 - 70, winSize.height/2 - 80, 130, 130))
        footLabel.textColor = UIColor.whiteColor()
        footLabel.layer.borderWidth = 3
        footLabel.layer.borderColor = UIColor.whiteColor().CGColor
        footLabel.layer.cornerRadius = 50
        footLabel.textAlignment = NSTextAlignment.Center
        footLabel.text = "\(footCount)"
        footLabel.font = UIFont(name: "ChalkboardSE-Bold", size: 60)
        //        //4ページの説明画像
        //        let iphoneImage:UIImage = UIImage(named:"screenPlay.png")!
        //        var iphoneView:UIImageView = UIImageView(image:iphoneImage)
        //        iphoneView.layer.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        //        iphoneView.frame = CGRectMake(winSize.width * 3 + winSize.width/2 - 150, winSize.height/2 - 100, 300, 200)
        
        scrollView.addSubview(zebraAdsButton)
        //        scrollView.addSubview(zebraView)
        scrollView.addSubview(pocketLabel)
        scrollView.addSubview(myLabel)
        scrollView.addSubview(soundLabel)
        scrollView.addSubview(footLabel)
        //        scrollView.addSubview(iphoneView)
    }
    
    
    func scrollViewDidEndDecelerating(scrollView: UIScrollView) {
        // スクロール数が1ページ分になった時.
        if fmod(scrollView.contentOffset.x, scrollView.frame.maxX) == 0 {
            // ページの場所を切り替える.
            pageControl.currentPage = Int(scrollView.contentOffset.x / scrollView.frame.maxX)
            //            println(pageControl.currentPage)
            timerManager() //タイマー管理処理
            switch pageControl.currentPage{
            case 3:
                footLabel.text = "2"
                moveTitle()
                break
            case 2:
                footCount = 2
                myUserDafault.setInteger(footCount, forKey: "TUTORIALLIFE")
                myUserDafault.synchronize()
                footLabel.text = "\(footCount)"
                break
            default:
                myUserDafault.setInteger(4, forKey: "TUTORIALLIFE")
                myUserDafault.synchronize()
                footLabel.text = "2"
                break
            }
            if(pageControl.currentPage==4){
                
            }
            else if(pageControl.currentPage==2) {
                
            }
            
            
        }
    }
    func timerManager(){
        //歩いても反応しないように
        if(pageControl.currentPage != 2){
            self.myUserDafault.setInteger(4, forKey: "TUTORIALLIFE")
            self.myUserDafault.synchronize()
            if(walkTestTimer != nil && walkTestTimer.valid == true){
                walkTestTimer.invalidate()
                walkTestTimer = nil
            }
        }
            //歩いたら反応するように
        else {
            self.myUserDafault.setInteger(2, forKey: "TUTORIALLIFE")
            self.myUserDafault.synchronize()
            if(walkTestTimer == nil){ //ないので生成します
                walkTestTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "walkTestUpdate", userInfo: nil, repeats: true)
            }
            if(walkTestTimer.valid == false){ //あるっぽいけど動いてないっぽいので生成します
                walkTestTimer = NSTimer.scheduledTimerWithTimeInterval(2, target: self, selector: "walkTestUpdate", userInfo: nil, repeats: true)
            }
            if(myUserDafault.boolForKey("bgm")){
                volumeChange.systemVolumeChange(0.8)
            }
        }
    }
    func moveTitle(){
        if(myUserDafault.boolForKey("bgm") == true){
            myUserDafault.setInteger(5, forKey: "TUTORIALLIFE")
            myUserDafault.synchronize()
        }
        else{
            myUserDafault.setInteger(4, forKey: "TUTORIALLIFE")
            myUserDafault.synchronize()
        }
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    func adbannerOpen(){
        bannerView = GADBannerView(frame: CGRect(x: 0, y: 0, width: 320, height: 50))
        bannerView.adUnitID = "ca-app-pub-1645837363749700/1318708476" // ユニットID
        bannerView.rootViewController = self
        bannerView.layer.position = CGPoint(x: winSize.width/2, y: winSize.height - 25)
        self.view.addSubview(bannerView)
        
//        var request = GADRequest()
//        request.testDevices = ["9e51e86223f362580ae947fffea1b3e8"]
//        bannerView.loadRequest(request) //テスト用
        
        bannerView.loadRequest(GADRequest()) //本番用
    }
    
    func titleSetting(){
        let lm = LangManager()
        //ナビゲーションバー作成
        let barLabel:UILabel = UILabel(frame: CGRectMake(0, 0, winSize.width, 50))
        barLabel.backgroundColor = UIColor.lightGrayColor()
        barLabel.layer.opacity = 0.8
        self.view.addSubview(barLabel)
        //タイトルボタン作成
        titleBtn = UIButton(frame: CGRectMake(10, 15, 50, 30))
        titleBtn.setTitle("Skip", forState: .Normal)
        titleBtn.setTitleColor(UIColor.darkGrayColor(), forState: .Normal)
        titleBtn.setTitleColor(UIColor.grayColor(), forState: .Highlighted)
        titleBtn.addTarget(self, action: "moveTitle", forControlEvents:.TouchUpInside)
        self.view.addSubview(titleBtn)
        
        
        titleLabel = UILabel(frame: CGRectMake(0, 50, winSize.width, winSize.height/6))
        titleLabel.backgroundColor = UIColor.blackColor()
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.layer.masksToBounds = true
        titleLabel.numberOfLines = 0;
        titleLabel.font = UIFont.systemFontOfSize(20)
        titleLabel.text = lm.getString(8)
        titleLabel.layer.opacity = 0.8
        self.view.addSubview(titleLabel)
        
        jButton = UIButton(frame: CGRectMake(0, 0, 100, 50))
        jButton.layer.position = CGPoint(x: winSize.width/2 - 75, y: winSize.height/2 + 150);
        jButton.setTitle("日本語", forState: .Normal)
        jButton.layer.cornerRadius = 3
        jButton.layer.borderWidth = 1
        jButton.layer.borderColor = UIColor(white: 1.0, alpha: 1.0).CGColor
        jButton.addTarget(self, action: "japaneseAction:", forControlEvents:.TouchUpInside)
        jButton.addTarget(self, action: "japaneseActionOut:", forControlEvents:.TouchUpOutside)
        jButton.addTarget(self, action: "japaneseActionDown:", forControlEvents:.TouchDown)
        self.view.addSubview(jButton)
        
        eButton = UIButton(frame: CGRectMake(0, 0, 100, 50))
        eButton.layer.position = CGPoint(x: winSize.width/2 + 75, y: winSize.height/2 + 150);
        eButton.setTitle("English", forState: .Normal)
        eButton.layer.cornerRadius = 3 //角丸
        eButton.layer.borderWidth = 1 //枠線の太さ
        eButton.layer.borderColor = UIColor(white: 1.0, alpha: 1.0).CGColor
        eButton.addTarget(self, action: "englishAction:", forControlEvents:.TouchUpInside)
        eButton.addTarget(self, action: "englishActionOut:", forControlEvents:.TouchUpOutside)
        eButton.addTarget(self, action: "englishActionDown:", forControlEvents:.TouchDown)
        self.view.addSubview(eButton)
        
        // UIImageViewを作成する.
        backgroundImageView = UIImageView(frame: CGRectMake(0, 0, winSize.width, winSize.height))
        backgroundImageView.image = UIImage(CIImage: bgInputImage)
        backgroundImageView.layer.opacity = 0.4
        backgroundImageView.layer.zPosition = -2
        view.addSubview(backgroundImageView)
        
        //次シーンで使うもの
        self.myUserDafault.setInteger(4, forKey: "TUTORIALLIFE")
        self.myUserDafault.synchronize()
        
        self.view.backgroundColor = UIColor.grayColor()
    }
    
    override func viewDidDisappear(animated:Bool)
    {
        super.viewDidDisappear(animated)
        if walkTestTimer != nil && walkTestTimer.valid == true {
            walkTestTimer.invalidate()
            walkTestTimer = nil
        }
    }
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
}

