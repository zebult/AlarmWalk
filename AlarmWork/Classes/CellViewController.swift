//
//  cellViewController.swift
//  AlarmWork
//
//  Created by saichi on 2015/08/11.
//  Copyright (c) 2015年 SaichiSuzuki. All rights reserved.
//

import UIKit

class CellViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // Tableで使用する配列を設定する
    private var myItems: [String] = ["You_wanna_fight","Electron","Yukai","Labo","Random"]
    private var myTableView: UITableView!
    
    private let lm:LangManager = LangManager()
    
    //試聴中かどうかフラグ
    private var audienceFlag = false
    //試聴用ボタン
    private var audienceButton: UIButton!
    //音楽なってるかチェックタイマー
    private var isMusicCheckTimer: NSTimer!
    //再生ボタン
    private var cellHeight:CGFloat = 0
    //課金ボタン
    private var purchaseBtn: UIButton!
    //値段
    var priceStr = ""


    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        let ud = NSUserDefaults.standardUserDefaults()
        if(ud.boolForKey("PURCHASE_MUSIC") == false){ //課金してなかったら
            createPurchaseBtn()
        }
        getPrice()
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        createCell()
        isMusicCheckTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "isMusicCheck", userInfo: nil, repeats: true)
        //通信できれば価格取得する
        if IJReachability.isConnectedToNetwork() {
            getPrice()
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewDidDisappear(animated)
        var appDelegate:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.navCon?.setNavigationBarHidden(false, animated: false)
        appDelegate.navCon?.navigationBar.tintColor = UIColor.darkGrayColor() //戻る文字色変更
        for (index,n) in enumerate(lm.getMusicName()){
            myItems[index] = n
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /**ナビゲーションバーの高さ取得*/
    func navigationBarHeight(callFrom: UIViewController) -> CGFloat? {
        return callFrom.navigationController?.navigationBar.frame.size.height
    }
    
    /**課金ボタン作成*/
    func createPurchaseBtn(){
        purchaseBtn = UIButton(frame: CGRectMake(0, 0, view.bounds.width, cellHeight*4))
        purchaseBtn.layer.anchorPoint = CGPoint(x: 0,y: 0)
        purchaseBtn.layer.position = CGPoint(x: 0,y:cellHeight)
        purchaseBtn.setTitle("Unlock", forState: .Normal)
        purchaseBtn.layer.backgroundColor = UIColor.hexStr("dd2234", alpha: 0.3).CGColor
        purchaseBtn.addTarget(self, action: "unLock:", forControlEvents:.TouchUpInside)
        self.myTableView.addSubview(purchaseBtn)
    }
    
    /**課金誘導*/
    func unLock(sender: UIButton){
        reachabilityCheck()
    }
    func unLockAlart(){
        let alert:UIAlertController = UIAlertController(title:lm.getString(15),
            message: priceStr,
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
                let pc = PurchaseController(v: self)
                pc.purchase()
        })
        alert.addAction(cancelAction)
        alert.addAction(defaultAction)
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func getPrice(){
        let productIdentifiers = ["SELECT_MUSIC"]
        //プロダクト情報取得
        SORProductManager.productsWithProductIdentifiers(productIdentifiers,
            completion: { (products, error) -> Void in
                for product in products {
                    //価格を抽出
                    let priceString = SORProductManager.priceStringFromProduct(product)
                    /*
                    価格情報を使って表示を更新したり。
                    */
                    self.priceStr = priceString
                }
        })
    }
    
    func reachabilityCheck () {
        if IJReachability.isConnectedToNetwork() {
            unLockAlart()
        } else {
            let alert = UIAlertView()
            alert.title = lm.getString(16)
            alert.message = lm.getString(17)
            alert.addButtonWithTitle("OK")
            alert.show()
        }
    }
    
    /**セル作成*/
    func createCell(){
        // Status Barの高さを取得する.
        let barHeight: CGFloat = UIApplication.sharedApplication().statusBarFrame.size.height
        // Viewの高さと幅を取得する.
        let displayWidth: CGFloat = self.view.frame.width
        let displayHeight: CGFloat = self.view.frame.height
        myTableView = UITableView(frame: CGRect(x: 0, y: 0, width: displayWidth, height: displayHeight))
        myTableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: "MyCell")
        myTableView.dataSource = self
        myTableView.delegate = self
        myTableView.backgroundColor = UIColor.hexStr("34495e", alpha: 1.0)
        // Viewに追加する.
        self.view.addSubview(myTableView)
    }
    
    // テーブルビューセルの高さ設定
//    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
//        if indexPath.section == 0 {
//            let widthOfScreen = UIScreen.mainScreen().bounds.width
//            return widthOfScreen / 8
//        } else {
//            return -1
//        }
//    }
    
    
    /*
    Cellが選択された際に呼び出されるデリゲートメソッド.
    */
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        //        for (var i=0; i<tableView.numberOfSections(); ++i){
        //            for (var j=0; j<tableView.numberOfRowsInSection(i); ++j){
        //                var c = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i))
        //                c!.backgroundColor = UIColor.hexStr("34495e", alpha: 0.7)
        //            }
        //        }
        allCellAction(tableView,type: "color")
        musicSave(indexPath.row)
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setInteger(indexPath.row, forKey: "INDEX_PATH")
        ud.synchronize()
        
        if(ud.boolForKey("ONOFF") == true){
            let qualityOfServiceClass = DISPATCH_QUEUE_PRIORITY_DEFAULT
            let backgroundQueue = dispatch_get_global_queue(qualityOfServiceClass, 0)
            dispatch_async(backgroundQueue, {
                // Backgroundで行いたい重い処理はここ
                dispatch_async(dispatch_get_main_queue(), {
                    // 処理が終わった後UIスレッドでやりたいことはここ
                    var app:AppDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                    app.mainView?.pushNotification()
                })
            })
        }
    }
    
    /**全てのセルに対する処理*/
    func allCellAction(tableView: UITableView,type:String){
        for (var i=0; i<tableView.numberOfSections(); ++i){
            for (var j=0; j<tableView.numberOfRowsInSection(i); ++j){
                var c = tableView.cellForRowAtIndexPath(NSIndexPath(forRow: j, inSection: i))
                switch type{
                case "color":
                    colorInit(c!)
                    break
                case "button":
                    buttonInit(c!.accessoryView as! UIButton)
                    break
                default:
                    break
                }
            }
        }
    }
    
    func colorInit(cell: UITableViewCell){
        cell.backgroundColor = UIColor.hexStr("34495e", alpha: 0.7)
    }
    func buttonInit(sender: UIButton){
        if(audienceFlag == true){
            AVAudioPlayerUtil.stopTest();//再生
        }
        sender.setTitle("♪", forState: .Normal)
    }
    
    /**Cellの選択がはずれたときに呼び出される*/
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        // 選択されたセルを取得
        var cell: UITableViewCell = tableView.cellForRowAtIndexPath(indexPath)!
        //        cell.accessoryType = UITableViewCellAccessoryType.None
        cell.backgroundColor = UIColor.hexStr("34495e", alpha: 0.7)
    }
    /*
    Cellの総数を返すデータソースメソッド.
    (実装必須)
    */
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return myItems.count
    }
    
    /*
    Cellに値を設定するデータソースメソッド.
    (実装必須)
    */
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        
        // 再利用するCellを取得する.
        let cell = tableView.dequeueReusableCellWithIdentifier("MyCell", forIndexPath: indexPath) as! UITableViewCell
        cellHeight = cell.bounds.height
        // Cellに値を設定する.
        cell.textLabel!.text = "\(myItems[indexPath.row])"
        cell.backgroundColor = UIColor.hexStr("34495e", alpha: 0.7)
        
        // Cell内のラベルの色変更
        cell.textLabel?.textColor = UIColor.whiteColor()
        
        //試聴ボタン追加
        audienceButton = UIButton(frame: CGRectMake(0, 0, 50, 45))
        //        audienceButton.layer.backgroundColor = UIColor.redColor().CGColor!
        audienceButton.setTitle("♪", forState: .Normal)
        //        audienceButton.setImage(UIImage(CIImage: playBackCIImage), forState: .Normal)
        audienceButton.addTarget(self, action: "musicAudition:", forControlEvents:.TouchUpInside)
        audienceButton.tag = indexPath.row
        cell.accessoryView = audienceButton
        
        // 選択された時の背景色
        var cellSelectedBgView = UIView()
        cellSelectedBgView.backgroundColor = UIColor.hexStr("3499e9e", alpha: 0.7)
        cell.selectedBackgroundView = cellSelectedBgView
        
        let ud = NSUserDefaults.standardUserDefaults()
        var ip = ud.integerForKey("INDEX_PATH")
        if(indexPath.row == ip){
            cell.backgroundColor = UIColor.hexStr("3499e9e", alpha: 1.0)
        }
        
        //        tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath)
        return cell
    }
    
    /**音楽なっていればタイトルへ遷移*/
    func isMusicCheck(){
        let ud = NSUserDefaults.standardUserDefaults()
        if(ud.boolForKey("bgm") == true){
            if isMusicCheckTimer.valid == true {
                isMusicCheckTimer.invalidate()
            }
            let evc = EditViewController()
            self.navigationController?.pushViewController(evc, animated: false)
        }
    }
    
    func musicAudition(sender: UIButton){
        let ud = NSUserDefaults.standardUserDefaults()
        var temp = ud.stringForKey("MUSIC_NAME")
        musicSave(sender.tag)
        /**今の所アラーム中にやってはいけない設定*/
        /**マナー中ならならないようにしたい*/
        if(sender.titleLabel?.text == "♪" && audienceFlag == true){
            allCellAction(myTableView,type: "button")
        }
        if(sender.titleLabel?.text == "♪"){
            audienceFlag = true
            AVAudioPlayerUtil.testPlay();//再生
            sender.setTitle("||", forState: .Normal)
        }
        else{
            audienceFlag = false
            AVAudioPlayerUtil.stopTest();//停止
            sender.setTitle("♪", forState: .Normal)
        }
        ud.setObject(temp, forKey: "MUSIC_NAME")
        ud.synchronize()
    }
    
    //音楽選択ボタン
    //    func musicSelectAction(cellNum:Int){
    //        musicSave(cellNum)
    //    }
    func musicSave(num:Int){
        var bgName = selectBGM(num)
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setObject(bgName, forKey: "MUSIC_NAME")
        ud.synchronize()
    }
    func selectBGM(num:Int) -> String{
        let ud = NSUserDefaults.standardUserDefaults()
        ud.setBool(false, forKey: "IS_RAND")
        ud.synchronize()
        var bgName = ""
        switch num{
        case 0:
            bgName = "You_wanna_fightC"
            break
        case 1:
            bgName = "Electron"
            break
        case 2:
            bgName = "Yukai"
            break
        case 3:
            bgName = "Labo"
            break
        default:
            let rm = RandMusic()
            bgName = rm.getRandMusic()
            ud.setBool(true, forKey: "IS_RAND")
            ud.synchronize()
            break
        }
        return bgName
    }
    
    //////////////////////////////////////
    /////////// getter,setter ////////////
    //////////////////////////////////////
    
    internal func getPurchaseBtn() -> UIButton{
        return purchaseBtn
    }
    
}

