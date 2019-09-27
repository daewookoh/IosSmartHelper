import UIKit
import WebKit
import JavaScriptCore
import MessageUI
import Social
import CoreLocation
import AVFoundation
import NaverThirdPartyLogin
import Alamofire
import MediaPlayer

class MainWebVC: UIViewController,WKUIDelegate, WKNavigationDelegate, WKScriptMessageHandler, XMLParserDelegate, MFMessageComposeViewControllerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, NaverThirdPartyLoginConnectionDelegate, SmaCoreBlueToolDelegate, BLConnectDelegate, ALInterstitialAdDelegate {
    
    static var getSystemVolumSliderVolumeViewSlider: UISlider? = nil
    
    let Sma = SmaBLE()
    let SmaBleSend = SmaBLE.sharedCoreBlue()
    let SmaBleMgr = BLConnect.sharedCoreBlueTool()
    let BLC = BLConnect()
    
    // 기본
    var sUrl:String = ""
    let common = Common()
    let apiHelper = APIHelper()
    var audioPlayer: AVAudioPlayer!
    
    // ios 11이하 버젼에서는 스토리보드를 이용한 WKWebView를 사용할수 없으므로 아래와 같이 수동처리
    //@IBOutlet weak var webView: WKWebView!
    var webView: WKWebView!
    var createWebView: WKWebView!
    
    // Adlib
    var adlibAd: ALInterstitialAd!
    
    //GPS
    var locationManager:CLLocationManager!
    
    // 이미지 업로드
    var picker = UIImagePickerController()
    var image: UIImage?
    
    // 리프레시
    var refreshControl = UIRefreshControl()
    
    // 네이버 로그인
    var foundCharacters = "";
    var email = ""
    var id = ""
    var gender = ""
    var name = ""

    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage
        
        UIImageWriteToSavedPhotosAlbum(pickedImage!, nil, nil, nil);
        picker.dismiss(animated: true, completion: nil)
        SmaBleSend?.setBLcomera(false)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController){
        SmaBleSend?.setBLcomera(false)
    }
  
    func createTable(){
        let filemgr = FileManager.default
        let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var databasePath = dirPaths.appendingPathComponent("record.db").path
        
        //if !filemgr.fileExists(atPath: databasePath) {
            let myDB = FMDatabase(path: databasePath as String)
            
            if myDB == nil {
                print("데이터베이스 생성오류 :\(myDB?.lastErrorMessage())")
            }
            
            if myDB!.open() {
                
                
                let sql15 = "drop table sport"
                if myDB!.executeUpdate(sql15, withArgumentsIn: nil){
                    print("ERR:\(myDB?.lastErrorMessage())")
                }
                 
                 let sql16 = "drop table heart"
                 if myDB!.executeUpdate(sql16, withArgumentsIn: nil){
                 print("ERR:\(myDB?.lastErrorMessage())")
                 }
                 
                 let sql17 = "drop table sleep"
                 if myDB!.executeUpdate(sql17, withArgumentsIn: nil){
                 print("ERR:\(myDB?.lastErrorMessage())")
                }
                 
                 let sql18 = "drop table exercise"
                 if myDB!.executeUpdate(sql18, withArgumentsIn: nil){
                 print("ERR:\(myDB?.lastErrorMessage())")
                }
 
                 let sql19 = "drop table tracker"
                 if myDB!.executeUpdate(sql19, withArgumentsIn: nil){
                 print("ERR:\(myDB?.lastErrorMessage())")
                 }
                
 
 
                let sql = "create table if not exists sport ( id INTEGER PRIMARY KEY ASC AUTOINCREMENT , s_date varchar(50), mode integer, step integer, mem_no integer)"
                if myDB!.executeStatements(sql){
                    print("ERR:\(myDB?.lastErrorMessage())")
                }
                
                let sql2 = "create table if not exists heart ( id INTEGER PRIMARY KEY ASC AUTOINCREMENT , s_date varchar(50), mode integer, heart integer, mem_no integer)"
                if myDB!.executeStatements(sql2){
                    print("ERR:\(myDB?.lastErrorMessage())")
                }
                
                let sql3 = "create table if not exists sleep ( id INTEGER PRIMARY KEY ASC AUTOINCREMENT , s_date varchar(50), mode integer, softly integer, strong integer, mem_no integer)"
                if myDB!.executeStatements(sql3){
                    print("ERR:\(myDB?.lastErrorMessage())")
                }
                
                let sql4 = "create table if not exists exercise ( id INTEGER PRIMARY KEY ASC AUTOINCREMENT , s_date varchar(50), airPressure varchar(20), cal varchar(20), distance varchar(50), altitude varchar(20), end_time varchar(20), mode varchar(50), pace varchar(20), duration varchar(20), speed varchar(50), step varchar(20), spm varchar(20), type varchar(50), mem_no integer)"
                if myDB!.executeStatements(sql4){
                    print("ERR:\(myDB?.lastErrorMessage())")
                }
                
                let sql5 = "create table if not exists tracker ( id INTEGER PRIMARY KEY ASC AUTOINCREMENT , s_date varchar(50), latitude varchar(20), longitude varchar(20), altitude integer, mem_no integer)"
                if myDB!.executeStatements(sql5){
                    print("ERR:\(myDB?.lastErrorMessage())")
                }
                
                myDB!.close()
            }
        //}
    }
    
    func readDB(type:String, sql:String) -> Bool {
        
        print(sql)
        
        var flag = false
        let filemgr = FileManager.default
        let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var databasePath = dirPaths.appendingPathComponent("record.db").path
        
        // databasePath 변수에 설정된 파일이 존재할 때 처리
        let myDB = FMDatabase(path: databasePath as String)
        
        if myDB == nil {
            print("Error: \(myDB?.lastErrorMessage())")
        }
        
        // DB 쿼리 실행 부분
        if myDB!.open() {
            
            let results:FMResultSet? = myDB!.executeQuery(sql, withArgumentsIn: nil)
            
            if (results == nil) {
                print("Error: \(myDB!.lastErrorMessage())")
            }else{
                
                // DB에서 불러온 각 열을 루프를 돌며 처리한다. (텍스트박스용 스트링에 내용 추가, 테이블뷰용 배열에 내용 추가)
                while(results?.next() == true) {
                    flag = true
                    
                    if(type=="sport")
                    {
                        let s_id = (results!.string(forColumn: "id"))! as String
                        let s_date = (results!.string(forColumn: "s_date"))! as String
                        let mode = (results!.string(forColumn: "mode"))! as String
                        let step = (results!.string(forColumn: "step"))! as String
                        let mem_no = (results!.string(forColumn: "mem_no"))! as String

                        let parameters = [
                            "action": "sendDataIOS",
                            "table_name": "sport",
                            "mem_no": mem_no,
                            "s_date":s_date,
                            "mode":mode,
                            "step":step
                            ]
                        
                        Alamofire.request(common.api_url, method: .post, parameters: parameters)
                    }
                    else if(type=="heart")
                    {
                        let s_id = (results!.string(forColumn: "id"))! as String
                        let s_date = (results!.string(forColumn: "s_date"))! as String
                        let mode = (results!.string(forColumn: "mode"))! as String
                        let heart = (results!.string(forColumn: "heart"))! as String
                        let mem_no = (results!.string(forColumn: "mem_no"))! as String

                        
                        let parameters = [
                            "action": "sendDataIOS",
                            "table_name": "heart",
                            "mem_no": mem_no,
                            "s_date":s_date,
                            "mode":mode,
                            "heart":heart
                        ]
                        
                        Alamofire.request(common.api_url, method: .post, parameters: parameters)
                    }
                    else if(type=="sleep")
                    {
                        let s_id = (results!.string(forColumn: "id"))! as String
                        let s_date = (results!.string(forColumn: "s_date"))! as String
                        let mode = (results!.string(forColumn: "mode"))! as String
                        let soft = (results!.string(forColumn: "softly"))! as String
                        let strong = (results!.string(forColumn: "strong"))! as String
                        let mem_no = (results!.string(forColumn: "mem_no"))! as String
                        
                        
                        let parameters = [
                            "action": "sendDataIOS",
                            "table_name": "sleep",
                            "mem_no": mem_no,
                            "s_date":s_date,
                            "mode":mode,
                            "soft":soft,
                            "strong":strong
                        ]
                        
                        Alamofire.request(common.api_url, method: .post, parameters: parameters)
                    }
                    else if(type=="exercise")
                    {
                        let s_id = (results!.string(forColumn: "id"))! as String
                        let s_date = (results!.string(forColumn: "s_date"))! as String
                        let airPressure = (results!.string(forColumn: "airPressure"))! as String
                        let cal = (results!.string(forColumn: "cal"))! as String
                        let distance = (results!.string(forColumn: "distance"))! as String
                        let altitude = (results!.string(forColumn: "altitude"))! as String
                        let end_time = (results!.string(forColumn: "end_time"))! as String
                        let mode = (results!.string(forColumn: "mode"))! as String
                        let pace = (results!.string(forColumn: "pace"))! as String
                        let duration = (results!.string(forColumn: "duration"))! as String
                        let speed = (results!.string(forColumn: "speed"))! as String
                        let step = (results!.string(forColumn: "step"))! as String
                        let spm = (results!.string(forColumn: "spm"))! as String
                        let type = (results!.string(forColumn: "type"))! as String
                        let mem_no = (results!.string(forColumn: "mem_no"))! as String
                        
                        
                        let parameters = [
                            "action": "sendDataIOS",
                            "table_name": "exercise",
                            "mem_no": mem_no,
                            "s_date":s_date,
                            "airPressure":airPressure,
                            "cal":cal,
                            "distance":distance,
                            "altitude":altitude,
                            "end_time":end_time,
                            "mode":mode,
                            "pace":pace,
                            "duration":duration,
                            "speed":speed,
                            "step":step,
                            "spm":spm,
                            "type":type
                        ]
                        
                        Alamofire.request(common.api_url, method: .post, parameters: parameters)
                    }
                    else if(type=="tracker")
                    {
                        let s_id = (results!.string(forColumn: "id"))! as String
                        let s_date = (results!.string(forColumn: "s_date"))! as String
                        let altitude = (results!.string(forColumn: "altitude"))! as String
                        let longitude = (results!.string(forColumn: "longitude"))! as String
                        let latitude = (results!.string(forColumn: "latitude"))! as String
                        let mem_no = (results!.string(forColumn: "mem_no"))! as String
                        
                        
                        let parameters = [
                            "action": "sendDataIOS",
                            "table_name": "tracker",
                            "mem_no": mem_no,
                            "s_date":s_date,
                            "altitude":altitude,
                            "longitude":longitude,
                            "latitude":latitude
                        ]
                        
                        Alamofire.request(common.api_url, method: .post, parameters: parameters)
                    }
                }
                
            }
            
            myDB!.close()
        } else {
            print("Error: \(myDB!.lastErrorMessage())")
        }
        
        return flag
    }
    
    func insertDB(){
        let filemgr = FileManager.default
        let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var databasePath = dirPaths.appendingPathComponent("record.db").path
        
        // databasePath 변수에 설정된 파일이 존재할 때 처리
        let myDB = FMDatabase(path: databasePath as String)
        
        if myDB == nil {
            print("Error: \(myDB?.lastErrorMessage())")
        }
        
        // DB 쿼리 실행 부분
        if myDB!.open() {
            
            let sql = "INSERT INTO sport (s_date, step, mem_no) VALUES ('2019-11-11 11:11:11','56','88');"
            let results = myDB!.executeUpdate(sql, withArgumentsIn: nil)
            
            if !results {
                print("Error: \(myDB!.lastErrorMessage())")
            }
            
            myDB!.close()
        } else {
            print("Error: \(myDB!.lastErrorMessage())")
        }
    }
    
    override func viewDidLoad() {
        print("viewDidLoad")
        super.viewDidLoad()
        setGPS()
        setWebView()
        //Sma.delegate = self
        SmaBleMgr?.bLdelegate = self
        Sma.delegate_swift = self as SmaCoreBlueToolDelegate
        BLC.delegate_swift = self as BLConnectDelegate
        
        let is_connected = common.getUD("is_connected") ?? ""
        if(is_connected=="true")
        {
            SmaBleMgr?.scanBL(1)
            DispatchQueue.main.asyncAfter(deadline: .now() + 120) {
                self.SmaBleMgr?.stopSearch()
            }
        }
        
        
        // 카메라 촬영
        picker.delegate = self
        
        createTable()
        //insertDB()
        //readDB()
        
        adlibAd = ALInterstitialAd.init(rootViewController: self)
        //adlibAd.isTestMode=true
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.reloadView(_:)), name: NSNotification.Name("ReloadView"), object: nil)
    }

    @objc func reloadView(_ notification: Notification?) {
        webView.reload()
    }

    // 앱이 꺼지지 않은 상태에서 다시 뷰가 보일때 viewWillAppear부터 시작됨
    override func viewWillAppear(_ animated: Bool) {
        print("viewWillAppear")
        setNavController()
        checkNetwork()
        
        let urlFromPush = common.getUD("urlFromPush") ?? ""
        let lastUrl = common.getUD("lastUrl") ?? ""
        
        if(!urlFromPush.isEmpty)
        {
            common.setUD("urlFromPush","")
            loadPage(url: urlFromPush)
        }
        else if(lastUrl.contains("login.php"))
        {
             webView.reload()
        }
    }
    
    func sendTimezone(){
        
        let myTimezone = common.getUD("timezone") ?? ""
        //let myTimezone = "null"
        let timezone = Calendar.current.timeZone.identifier
        
        if(!timezone.isEmpty)
        {
            if(myTimezone.isEmpty || myTimezone != timezone){
                
                common.setUD("timezone", timezone)
                
                let swiftLocale: Locale = Locale.current
                let regionCode: String! = swiftLocale.regionCode ?? "null"

                let country:String!
                if(regionCode != "null"){
                    country = Locale.current.localizedString(forRegionCode: regionCode) ?? "?"
                }else{
                    country = timezone
                }

                let data = "act=setTimezoneInfo&timezone="+timezone+"&country="+country
                let enc_data = Data(data.utf8).base64EncodedString()
                print("jsNativeToServer(enc_data)")
                webView.evaluateJavaScript("jsNativeToServer('" + enc_data + "')", completionHandler:nil)
            }
        }
    }
    

    func unbind(){
        if let p = SmaBleMgr?.peripheral {
            SmaBleMgr?.mgr.cancelPeripheralConnection(p)
        }
        common.setUD("is_connected","false")
        common.removeUD("UUID")
        SmaBleSend?.p = nil
        SmaBleSend?.relieveWatchBound()
        webView.reload()
    }

    
    @objc(insertExercise:)
    func insertExercise(_ array: NSMutableArray)
    {
        print(array)
        let mem_no = self.common.getUD("mem_no") ?? "0"
        
        if(mem_no == "0" || mem_no == "")
        {
            return;
        }
        
        var flag = false;
        var update_data_status = self.common.getUD("update_data_status") ?? "";
        self.common.setUD("update_data_status", update_data_status + "EXERCISE");
        
        for item in array {
            
            if let dict = item as? NSDictionary {
                
                if dict.value(forKey: "NODATA") != nil
                {
                    break;
                }
                    
                else if (dict.value(forKey: "STARTDATE") != nil &&
                    dict.value(forKey: "AIRPRESSURE") != nil &&
                    dict.value(forKey: "CAL") != nil &&
                    dict.value(forKey: "DISTANCE") != nil &&
                    dict.value(forKey: "ELEVATION") != nil &&
                    dict.value(forKey: "ENDDATE") != nil &&
                    dict.value(forKey: "MODE") != nil &&
                    dict.value(forKey: "PACE") != nil &&
                    dict.value(forKey: "RUNTIME") != nil &&
                    dict.value(forKey: "SPEED") != nil &&
                    dict.value(forKey: "STEP") != nil &&
                    dict.value(forKey: "STEPFREQUENCY") != nil &&
                    dict.value(forKey: "VERSION") != nil)
                {
                    flag = true;
                    let s_date = dict.value(forKey: "STARTDATE")!
                    let airPressure = dict.value(forKey: "AIRPRESSURE")!
                    let cal = dict.value(forKey: "CAL")!
                    let distance = dict.value(forKey: "DISTANCE")!
                    let altitude = dict.value(forKey: "ELEVATION")!
                    let end_time = dict.value(forKey: "ENDDATE")!
                    let mode = dict.value(forKey: "MODE")!
                    let pace = dict.value(forKey: "PACE")!
                    let duration = dict.value(forKey: "RUNTIME")!
                    let speed = dict.value(forKey: "SPEED")!
                    let step = dict.value(forKey: "STEP")!
                    let spm = dict.value(forKey: "STEPFREQUENCY")!
                    let type = dict.value(forKey: "VERSION")!
                    
                    let filemgr = FileManager.default
                    let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    var databasePath = dirPaths.appendingPathComponent("record.db").path
                    
                    // databasePath 변수에 설정된 파일이 존재할 때 처리
                    let myDB = FMDatabase(path: databasePath as String)
                    
                    if myDB == nil {
                        print("Error: \(myDB?.lastErrorMessage())")
                    }
                    
                    // DB 쿼리 실행 부분
                    if myDB!.open() {
                        
                        let sql = "INSERT INTO exercise (s_date, airPressure, cal, distance, altitude, end_time, mode, pace, duration, speed, step, spm, type, mem_no) VALUES ('\(s_date)','\(airPressure)','\(cal)','\(distance)','\(altitude)','\(end_time)','\(mode)','\(pace)','\(duration)','\(speed)','\(step)','\(spm)','\(type)','\(mem_no)');"
                        let results = myDB!.executeUpdate(sql, withArgumentsIn: nil)
                        
                        if !results {
                            print("Error: \(myDB!.lastErrorMessage())")
                        }
                        
                        myDB!.close()
                    } else {
                        print("Error: \(myDB!.lastErrorMessage())")
                    }
                    
                    let parameters = [
                        "action": "sendDataIOS",
                        "table_name": "exercise",
                        "mem_no": "\(mem_no)",
                        "s_date":"\(s_date)",
                        "airPressure":"\(airPressure)",
                        "cal":"\(cal)",
                        "distance":"\(distance)",
                        "altitude":"\(altitude)",
                        "end_time":"\(end_time)",
                        "mode":"\(mode)",
                        "pace":"\(pace)",
                        "duration":"\(duration)",
                        "speed":"\(speed)",
                        "step":"\(step)",
                        "spm":"\(spm)",
                        "type":"\(type)"
                    ] as! [String:String]
                    
                    Alamofire.request(common.api_url, method: .post, parameters: parameters)
                }
                
            }
            
        }
        
        update_data_status = self.common.getUD("update_data_status") ?? "";
        update_data_status = update_data_status.replace(target:"EXERCISE",withString: "");
        self.common.setUD("update_data_status",update_data_status);
        
        if(update_data_status.isEmpty && flag==true)
        {
            showToast(message: "신규 데이터 업데이트 중")
            let seconds = 2.5
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.webView.reload()
            }
        }
        
    }
    
    @objc(insertTracker:)
    func insertTracker(_ array: NSMutableArray)
    {
        print(array)
        let mem_no = self.common.getUD("mem_no") ?? "0"
        
        if(mem_no == "0" || mem_no == "")
        {
            return;
        }
        
        var flag = false;
        var update_data_status = self.common.getUD("update_data_status") ?? "";
        self.common.setUD("update_data_status", update_data_status + "TRACKER");
        
        let date : Date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"

        for item in array {
            
            if let dict = item as? NSDictionary {
                
                if dict.value(forKey: "NODATA") != nil
                {
                    break;
                }
                    
                else if (dict.value(forKey: "DATE") != nil &&
                    dict.value(forKey: "LATITUDE") != nil &&
                    dict.value(forKey: "LONGITUDE") != nil &&
                    dict.value(forKey: "ALTITUDE") != nil)
                {
                    flag = true;
                    let s_date = dict.value(forKey: "DATE")!
                    
                    //기기에서 데이터가 잘못넘어오는경우 대응
                    if df.string(from:date).compare(s_date as! String, options: .numeric) == .orderedAscending {
                        continue
                    }

                    let latitude = dict.value(forKey: "LATITUDE")!
                    let longitude = dict.value(forKey: "LONGITUDE")!
                    let altitude = dict.value(forKey: "ALTITUDE")!
                    
                    let filemgr = FileManager.default
                    let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    var databasePath = dirPaths.appendingPathComponent("record.db").path
                    
                    // databasePath 변수에 설정된 파일이 존재할 때 처리
                    let myDB = FMDatabase(path: databasePath as String)
                    
                    if myDB == nil {
                        print("Error: \(myDB?.lastErrorMessage())")
                    }
                    
                    // DB 쿼리 실행 부분
                    if myDB!.open() {
                        
                        let sql = "INSERT INTO tracker (s_date, latitude, longitude, altitude, mem_no) VALUES ('\(s_date)','\(latitude)','\(longitude)','\(altitude)','\(mem_no)');"
                        let results = myDB!.executeUpdate(sql, withArgumentsIn: nil)
                        
                        if !results {
                            print("Error: \(myDB!.lastErrorMessage())")
                        }
                        
                        myDB!.close()
                    } else {
                        print("Error: \(myDB!.lastErrorMessage())")
                    }
                    
                    let parameters = [
                        "action": "sendDataIOS",
                        "table_name": "tracker",
                        "mem_no": "\(mem_no)",
                        "s_date":"\(s_date)",
                        "altitude":"\(altitude)",
                        "longitude":"\(longitude)",
                        "latitude":"\(latitude)"
                    ] as! [String:String]
                    
                    Alamofire.request(common.api_url, method: .post, parameters: parameters)
                }
                
            }
            
        }
        
        update_data_status = self.common.getUD("update_data_status") ?? "";
        update_data_status = update_data_status.replace(target:"TRACKER",withString: "");
        self.common.setUD("update_data_status",update_data_status);
        
        if(update_data_status.isEmpty && flag==true)
        {
            showToast(message: "신규 데이터 업데이트 중")
            let seconds = 2.5
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.webView.reload()
            }
        }
        
    }

    
    @objc(insertSport:)
    func insertSport(_ array: NSMutableArray)
    {
        print(array)
        let mem_no = self.common.getUD("mem_no") ?? "0"
        
        if(mem_no == "0" || mem_no == "")
        {
            return;
        }
        
        var flag = false;
        var update_data_status = self.common.getUD("update_data_status") ?? "";
        self.common.setUD("update_data_status", update_data_status + "SPORT");
        
        for item in array {
                
            if let dict = item as? NSDictionary {
                
                if dict.value(forKey: "NODATA") != nil
                {
                    break;
                }
                
                else if (dict.value(forKey: "DATE") != nil &&
                dict.value(forKey: "MODE") != nil &&
                dict.value(forKey: "STEP") != nil)
                {
                    flag = true
                    let s_date = dict.value(forKey: "DATE")!
                    let mode = dict.value(forKey: "MODE")!
                    let step = dict.value(forKey: "STEP")!
                    
                    let filemgr = FileManager.default
                    let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    var databasePath = dirPaths.appendingPathComponent("record.db").path
                    
                    // databasePath 변수에 설정된 파일이 존재할 때 처리
                    let myDB = FMDatabase(path: databasePath as String)
                    
                    if myDB == nil {
                        print("Error: \(myDB?.lastErrorMessage())")
                    }
                    
                    // DB 쿼리 실행 부분
                    if myDB!.open() {
                        
                        let sql = "INSERT INTO sport (s_date, mode, step, mem_no) VALUES ('\(s_date)','\(mode)','\(step)','\(mem_no)');"
                        let results = myDB!.executeUpdate(sql, withArgumentsIn: nil)

                        if !results {
                            print("Error: \(myDB!.lastErrorMessage())")
                        }
                        
                        myDB!.close()
                    } else {
                        print("Error: \(myDB!.lastErrorMessage())")
                    }
                    
                    
                    let parameters = [
                        "action": "sendDataIOS",
                        "table_name": "sport",
                        "mem_no": "\(mem_no)",
                        "s_date":"\(s_date)",
                        "mode":"\(mode)",
                        "step":"\(step)"
                    ] as! [String : String]

                    Alamofire.request(self.common.api_url, method: .post, parameters: parameters)
                    
                }

            }
            
        }
        
        update_data_status = self.common.getUD("update_data_status") ?? "";
        update_data_status = update_data_status.replace(target:"SPORT",withString: "");
        self.common.setUD("update_data_status",update_data_status);
        
        if(update_data_status.isEmpty && flag==true)
        {
            showToast(message: "신규 데이터 업데이트 중")
            let seconds = 2.5
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.webView.reload()
            }
        }

    }

    
    @objc(insertHeart:)
    func insertHeart(_ array: NSMutableArray)
    {
        print(array)
        let mem_no = self.common.getUD("mem_no") ?? "0"
        
        if(mem_no == "0" || mem_no == "")
        {
            return;
        }
        
        var flag = false;
        var update_data_status = self.common.getUD("update_data_status") ?? "";
        self.common.setUD("update_data_status", update_data_status + "HEART");
        
        for item in array {
            
            if let dict = item as? NSDictionary {
                
                if dict.value(forKey: "NODATA") != nil
                {
                    break;
                }
                    
                else if (dict.value(forKey: "DATE") != nil &&
                    dict.value(forKey: "HRMODE") != nil &&
                    dict.value(forKey: "HEART") != nil)
                {
                    flag = true
                    let s_date = dict.value(forKey: "DATE")!
                    let mode = dict.value(forKey: "HRMODE")!
                    let heart = dict.value(forKey: "HEART")!
                    
                    let filemgr = FileManager.default
                    let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    var databasePath = dirPaths.appendingPathComponent("record.db").path
                    
                    // databasePath 변수에 설정된 파일이 존재할 때 처리
                    let myDB = FMDatabase(path: databasePath as String)
                    
                    if myDB == nil {
                        print("Error: \(myDB?.lastErrorMessage())")
                    }
                    
                    // DB 쿼리 실행 부분
                    if myDB!.open() {
                        
                        let sql = "INSERT INTO heart (s_date, mode, heart, mem_no) VALUES ('\(s_date)','\(mode)','\(heart)','\(mem_no)');"
                        let results = myDB!.executeUpdate(sql, withArgumentsIn: nil)
                        
                        if !results {
                            print("Error: \(myDB!.lastErrorMessage())")
                        }
                        
                        myDB!.close()
                    } else {
                        print("Error: \(myDB!.lastErrorMessage())")
                    }
                    
                    let parameters = [
                        "action": "sendDataIOS",
                        "table_name": "heart",
                        "mem_no": "\(mem_no)",
                        "s_date":"\(s_date)",
                        "mode":"\(mode)",
                        "heart":"\(heart)"
                    ] as! [String:String]
                    
                    Alamofire.request(common.api_url, method: .post, parameters: parameters)
                }
                
            }
            
        }
        
        update_data_status = self.common.getUD("update_data_status") ?? "";
        update_data_status = update_data_status.replace(target:"HEART",withString: "");
        self.common.setUD("update_data_status",update_data_status);
        
        if(update_data_status.isEmpty && flag==true)
        {
            showToast(message: "신규 데이터 업데이트 중")
            let seconds = 2.5
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.webView.reload()
            }
        }
        
    }
    
    @objc(insertSleep:)
    func insertSleep(_ array: NSMutableArray)
    {
        print(array)
        let mem_no = self.common.getUD("mem_no") ?? "0"
        
        if(mem_no == "0" || mem_no == "")
        {
            return;
        }
        
        var flag = false;
        var update_data_status = self.common.getUD("update_data_status") ?? "";
        self.common.setUD("update_data_status", update_data_status + "SLEEP");
        
        for item in array {
            
            if let dict = item as? NSDictionary {
                
                if dict.value(forKey: "NODATA") != nil
                {
                    break;
                }
                    
                else if (dict.value(forKey: "DATE") != nil &&
                    dict.value(forKey: "MODE") != nil &&
                    dict.value(forKey: "SOFTLY") != nil &&
                    dict.value(forKey: "STRONG") != nil)
                {
                    flag = true
                    let s_date = dict.value(forKey: "DATE")!
                    let mode = dict.value(forKey: "MODE")!
                    let softly = dict.value(forKey: "SOFTLY")!
                    let strong = dict.value(forKey: "STRONG")!
                    
                    let filemgr = FileManager.default
                    let dirPaths = filemgr.urls(for: .documentDirectory, in: .userDomainMask)[0]
                    var databasePath = dirPaths.appendingPathComponent("record.db").path
                    
                    // databasePath 변수에 설정된 파일이 존재할 때 처리
                    let myDB = FMDatabase(path: databasePath as String)
                    
                    if myDB == nil {
                        print("Error: \(myDB?.lastErrorMessage())")
                    }
                    
                    // DB 쿼리 실행 부분
                    if myDB!.open() {
                        
                        let sql = "INSERT INTO sleep (s_date, mode, softly, strong, mem_no) VALUES ('\(s_date)','\(mode)','\(softly)','\(strong)','\(mem_no)');"
                        let results = myDB!.executeUpdate(sql, withArgumentsIn: nil)
                        
                        if !results {
                            print("Error: \(myDB!.lastErrorMessage())")
                        }
                        
                        myDB!.close()
                    } else {
                        print("Error: \(myDB!.lastErrorMessage())")
                    }
                    
                    let parameters = [
                        "action": "sendDataIOS",
                        "table_name": "sleep",
                        "mem_no": "\(mem_no)",
                        "s_date":"\(s_date)",
                        "mode":"\(mode)",
                        "soft":"\(softly)",
                        "strong":"\(strong)"
                    ] as! [String:String]
                    
                    Alamofire.request(common.api_url, method: .post, parameters: parameters)
                }
                
            }
            
        }
        
        update_data_status = self.common.getUD("update_data_status") ?? "";
        update_data_status = update_data_status.replace(target:"SLEEP",withString: "");
        self.common.setUD("update_data_status",update_data_status);
        
        if(update_data_status.isEmpty && flag==true)
        {
            showToast(message: "신규 데이터 업데이트 중")
            let seconds = 2.5
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                self.webView.reload()
            }
        }
        
    }

    
    func getDateStr() -> String
    {
        let date : Date = Date()
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"
        
        return df.string(from:date)
    }
    
    func getDateFromStr(dateStr : String) -> Date
    {
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"
        
        return df.date(from: dateStr)!
    }
    
    func getLastDataDate() -> Date
    {
        let ymdhis = common.getUD("last_data_date") ?? "20190701000000"
        
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"
        
        return df.date(from:ymdhis)!
    }
    
    func getLastWeatherDate() -> Date
    {
        let ymdhis = common.getUD("last_weather_date") ?? "20190701000000"
        
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"
        
        return df.date(from:ymdhis)!
    }
    
    func getLastAgpsDate() -> Date
    {
        let ymdhis = common.getUD("last_agps_date") ?? "20190701000000"
        
        let df = DateFormatter()
        df.dateFormat = "yyyyMMddHHmmss"
        
        return df.date(from:ymdhis)!
    }
    
    
    func setAgps()
    {
        let last_agps_date = getLastAgpsDate()
        let cur_date = Date()
        
        // 최종 업데이트후 6시간이 지난 경우만 업데이트
        if(cur_date.timeIntervalSince(last_agps_date) > 60*360)
        {
            common.setUD("last_agps_date", getDateStr())
            
            print("agps_update")
            
            SmaBleSend?.updateEPOFileForAGPS()
        }
        else
        {
            print("agps_update_gap : \(cur_date.timeIntervalSince(last_agps_date)) seconds")
            return;
        }

    }
    
    func setWeather()
    {
        let mem_no = self.common.getUD("mem_no") ?? "0"
        
        if(mem_no == "0" || mem_no == "")
        {
            return;
        }
        
        let last_weather_date = getLastWeatherDate()
        let cur_date = Date()
        
        // 최종 업데이트후 1시간이 지난 경우만 업데이트
        if(cur_date.timeIntervalSince(last_weather_date) > 60*60)
        {
            common.setUD("last_weather_date", getDateStr())
            
            print("weather_update")
            
            getGPS()
            
            let seconds = 4.0
            DispatchQueue.main.asyncAfter(deadline: .now() + seconds) {
                
                let parameters = [
                    "action": "getWeatherFromServer",
                    "mem_no": mem_no
                    ] as! [String : String]
                
                
                Alamofire.request(self.common.api_url, method: .post, parameters: parameters)
                    .responseJSON { response in
                        //print(response)
                        
                        //to get JSON return value
                        if let result = response.result.value {
                            let JSON = result as! NSDictionary
                            
                            if (JSON.value(forKey: "resultcode") != nil && JSON.value(forKey: "response") != nil)
                            {
                                let resulcode = JSON.value(forKey: "resultcode") as! String
                                let DATA = JSON.value(forKey: "response") as! NSDictionary
                                
                                if(resulcode == "00")
                                {
                                    
                                    //setLiveWeather
                                    let weather = SMAWeatherInfo()
                                    
                                    let humidity = Int32(DATA["humidity"] as! String)
                                    
                                    weather.date = Date()
                                    weather.humidity = Int32(DATA["humidity"] as! String) ?? 0
                                    weather.nowTmp = Int32(DATA["temperature"] as! String) ?? 0
                                    weather.precipitation = Int32(DATA["precipitation"] as! String) ?? 0
                                    weather.visibility = Int32(DATA["visibility"] as! String) ?? 0
                                    weather.weatherIcon = Int32(DATA["weatherCode"] as! String) ?? 0
                                    weather.windSpeed = Int32(DATA["windSpeed"] as! String) ?? 0
                                    
                                    self.SmaBleSend?.setLiveWeather(weather)
                                    
                                    //setWeatherForecast
                                    var weatherArr : NSMutableArray = []
                                    
                                    let w1 = SMAWeatherInfo()
                                    w1.minTmp = Int32(DATA["min1"] as! String) ?? 0
                                    w1.maxTmp = Int32(DATA["max1"] as! String) ?? 0
                                    w1.weatherIcon = Int32(DATA["weatherCode1"] as! String) ?? 0
                                    w1.ultraviolet = Int32(DATA["ultraviolet"] as! String) ?? 0
                                    weatherArr.add(w1)
                                    
                                    let w2 = SMAWeatherInfo()
                                    w2.minTmp = Int32(DATA["min2"] as! String) ?? 0
                                    w2.maxTmp = Int32(DATA["max2"] as! String) ?? 0
                                    w2.weatherIcon = Int32(DATA["weatherCode2"] as! String) ?? 0
                                    weatherArr.add(w2)
                                    
                                    let w3 = SMAWeatherInfo()
                                    w3.minTmp = Int32(DATA["min3"] as! String) ?? 0
                                    w3.maxTmp = Int32(DATA["max3"] as! String) ?? 0
                                    w3.weatherIcon = Int32(DATA["weatherCode3"] as! String) ?? 0
                                    weatherArr.add(w3)
                                    
                                    self.SmaBleSend?.setWeatherForecast(weatherArr as! [SMAWeatherInfo])
                                }
                            }
                            
                        }
                        
                }
            }
        }
        else
        {
            print("weather_update_gap : \(cur_date.timeIntervalSince(last_weather_date)) seconds")
            return;
        }
        
        
    }
    
    @objc(setGoal:)
    func setGoal(_ goal: NSString)
    {
        //let batt1: String? = battery as String
        //let batt = batt1 ?? "0"
        print(goal)
        if let goal:String? = goal as String {
            let mem_no = self.common.getUD("mem_no") ?? "0"
            
            let parameters = [
                "action": "getGoalFromApp",
                "goal": goal,
                "mem_no": mem_no
                ] as! [String : String]
            
            Alamofire.request(common.api_url, method: .post, parameters: parameters)
        }
    }
    
    
    @objc(setSit:)
    func setSit(_ sit: SmaSeatInfo)
    {
        
        let mem_no = self.common.getUD("mem_no") ?? "0"
        
        let parameters = [
            "action": "getSitFromApp",
            "enabled": sit.isOpen!,
            "interval": sit.seatValue!,
            "mem_no": mem_no
            ] as! [String : String]
        print(parameters)
        Alamofire.request(common.api_url, method: .post, parameters: parameters)
    }
    
    @objc(setAlarm:)
    func setAlarm(_ alarm: NSMutableArray)
    {
        print("SETALARM")
        let mem_no = self.common.getUD("mem_no") ?? "0"
        
        let number = alarm.count - 1
        
        let parameters = [
            "action": "getAlarmCountFromApp",
            "alarm_count": "\(alarm.count)",
            "mem_no": mem_no
            ] as! [String : String]
        print(parameters)
        Alamofire.request(common.api_url, method: .post, parameters: parameters)
        
        for i in 0 ... number {
        
            let info = alarm[i] as? SmaAlarmInfo
        
            let parameters = [
                "action": "getAlarmsFromApp",
                "no": "\(i+1)",
                "time": info!.hour + ":" + info!.minute,
                "enabled": info!.isOpen,
                "repeat": info!.dayFlags,
                "mem_no": mem_no
                ] as! [String : String]
            print(parameters)
            Alamofire.request(common.api_url, method: .post, parameters: parameters)
 
        }

    }
    
    @objc(battery:)
    func battery(_ battery: NSString)
    {
        //let batt1: String? = battery as String
        //let batt = batt1 ?? "0"
        print(battery)
        if let batt:String? = battery as String {
            doJavascript("battery('"+batt!+"')")
        }
    }
    
    @objc(findPhone:)
    func findPhone(_ flag: NSString)
    {
        
        if let flag:String? = flag as String {
            
            if(flag == "1")
            {
                playAudioFile(sound: "ring")
            }
            else
            {
                stopAudioFile(sound: "ring")
            }
        }
    }
    
    @objc(getDeviceNameAndAddress:)
    func getDeviceNameAndAddress(_ mac:NSString)
    {
        let mem_no = self.common.getUD("mem_no") ?? "0"
        
        let parameters = [
            "action": "getDeviceNameAndAddress",
            "device_name": SmaBleMgr?.peripheral.name,
            "device_address": mac,
            "mem_no": mem_no
            ] as! [String : String]
        
        //print("asdf%@",parameters)
        Alamofire.request(common.api_url, method: .post, parameters: parameters)
        
    }
    
    @objc(disconnected)
    func disconnected()
    {
        showToast(message : "기기 연결 끊김")
        doJavascript("reload()")
    }
    
    @objc(connectCancel)
    func connectCancel()
    {
        showToast(message : "기기 연결 취소")
        unbind()
    }
    
    @objc(connectSuccess)
    func connectSuccess()
    {
        common.setUD("last_weather_date", "20190701000000")
        common.setUD("last_agps_date", "20190701000000")
        common.setUD("last_latitude", "0")
        common.setUD("last_longitude", "0")
        webView.reload()
    }
    
    @objc(closePhoto)
    func closePhoto()
    {
        picker.dismiss(animated: true, completion: nil)
    }
    
    @objc(takePhoto)
    func takePhoto()
    {
        picker.takePicture()
    }

    @objc(connected)
    func connected()
    {
        showToast(message : "기기 연결 성공");
        doJavascript("reload()")
    }
 
    func setGPS() {
        locationManager = CLLocationManager()
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization() //권한 요청
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.startUpdatingLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        //위치가 업데이트될때마다
        if let coor = manager.location?.coordinate{
            if(!String(coor.latitude).isEmpty && !String(coor.longitude).isEmpty)
            {
                common.setUD("latitude", String(coor.latitude))
                common.setUD("longitude", String(coor.longitude))
                locationManager.stopUpdatingLocation()
                //print("latitude" + String(coor.latitude) + "/ longitude" + String(coor.longitude))
            }
        }
    }
    
    func getGPS() {
        
        let last_lat = common.getUD("last_latitude") ?? "0"
        let last_lon = common.getUD("last_longitude") ?? "0"
        let lat = common.getUD("latitude") ?? "0"
        let lon = common.getUD("longitude") ?? "0"
        let mem_no = self.common.getUD("mem_no") ?? "0"
        
        if(Int(mem_no)!>0)
        {
            let lat_gap: Float = Float(last_lat)! - Float(lat)!
            let lon_gap: Float = Float(last_lon)! - Float(lon)!
            let gps_gap: Float = fabsf(lat_gap) + fabsf(lon_gap)
            
            print("lat_gap : " , lat_gap)
            print("lon_gap : " , lon_gap)
            print("gps_gap : " , gps_gap)
            
            if(gps_gap>0.1)
            {
            
                let parameters = [
                    "action": "getGpsFromApp",
                    "lon": lon,
                    "lat": lat,
                    "mem_no": mem_no
                    ] as! [String : String]
                
                Alamofire.request(common.api_url, method: .post, parameters: parameters)
                
                common.setUD("last_longitude", String(lon ?? "0"))
                common.setUD("last_latitude", String(lat ?? "0"))
            }
        }
        
    }
    
    func playAudioFile(sound:String) {
        
        let soundURL = Bundle.main.url(forResource: sound, withExtension: "mp3")
        do {
            
            // 무음상태에서 소리나게 설정
            do {
                try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
                try AVAudioSession.sharedInstance().setActive(true)
            } catch {
                print(error)
            }
            
            audioPlayer = try AVAudioPlayer(contentsOf: soundURL!)
            audioPlayer.numberOfLoops = (-1)
            audioPlayer.volume = 1.0
            audioPlayer.prepareToPlay()
            
        } catch  {
            print(error)
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            
            // Code you want to be delayed
            self.getSystemVolumSlider()?.value = 1.0
            self.audioPlayer.play()
        }
        
        
 
    }

    
    func getSystemVolumSlider() -> UISlider? {
        if MainWebVC.getSystemVolumSliderVolumeViewSlider == nil {
            let volumeView = MPVolumeView(frame: CGRect(x: 10, y: 50, width: 200, height: 4))
            
            for newView in volumeView.subviews {
                if (newView.self.description == "MPVolumeSlider") {
                    MainWebVC.getSystemVolumSliderVolumeViewSlider = newView as? UISlider
                    break
                }
            }
        }
        return MainWebVC.getSystemVolumSliderVolumeViewSlider
    }
    
    
    func stopAudioFile(sound:String) {
        audioPlayer.stop()
    }
    
    func setWebView() {
        print("setWebView")
        
        //App Delegate 에서 DidBecomeActive감지
        //NotificationCenter.default.addObserver(self, selector: #selector(self.reloadWebView(_:)), name: NSNotification.Name("ReloadView"), object: nil)
        
        UserDefaults.standard.register(defaults: ["UserAgent": UIWebView().stringByEvaluatingJavaScript(from: "navigator.userAgent")! + common.user_agent])
        
        // ios 11이하 버젼에서는 스토리보드를 이용한 WKWebView를 사용할수 없으므로 아래와 같이 수동처리
        let contentController = WKUserContentController()
        contentController.add(self, name: common.js_name)
        contentController.add(self, name: common.bootpay_js_name)
        
        let config = WKWebViewConfiguration()
        config.userContentController = contentController
        
        
        webView = WKWebView(frame: .zero, configuration: config)
        /*
        let safeArea = self.view.safeAreaLayoutGuide
        webView.leadingAnchor.constraint(equalTo: safeArea.leadingAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: safeArea.bottomAnchor).isActive = true
        */
        webView.uiDelegate = self as WKUIDelegate
        webView.navigationDelegate = self as WKNavigationDelegate
        
        
        var url = URL(string: common.default_url)
        if(!sUrl.isEmpty){
            url = URL(string: sUrl)
        }
        
        let request = URLRequest(url: url!)
        
        webView.load(request)
        
        view = webView
        
        setupRefreshControl()

    }
    
    @objc func reloadWebView(_ notification: Notification?) {
        print("reloadWebView")
        
        refreshControl.beginRefreshing()
        webView.reload()

    }
    
    @objc
    private func refreshWebView(sender: UIRefreshControl) {
        print("refreshWebView")
        webView.reload()
        sender.endRefreshing()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func setNavController(){
        //상단바 숨기기
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        //페이지변환시 fade효과
        /*
        let transition: CATransition = CATransition()
        transition.duration = 0.4
        transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
        transition.type = CATransitionType.fade
        */
        //self.navigationController!.view.layer.add(transition, forKey: nil)
    }
    
    func sendDeviceInfo(){
        
        var device_id = common.getUD("device_id")
        var device_token = common.getUD("device_token")
        var device_model = common.getUD("device_model")
        var app_version = common.getUD("app_version")
        var latitude = common.getUD("latitude")
        var longitude = common.getUD("longitude")
        
        if(device_id == nil){
            device_id = UIDevice.current.identifierForVendor!.uuidString
            device_model = UIDevice.current.modelName
            app_version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
                as? String
        }
        
        
        if (device_id == nil) {device_id=""}
        if (device_token == nil) {device_token=""}
        if (device_model == nil) {device_model=""}
        if (app_version == nil) {app_version=""}
        if (latitude == nil) {latitude=""}
        if (longitude == nil) {longitude=""}
        
        let new_app_version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
            as! String
        let old_app_version = app_version ?? ""
        
        if(new_app_version != old_app_version)
        {
            app_version=new_app_version
        }
        
        common.setUD("device_id", device_id!)
        common.setUD("device_token", device_token!)
        common.setUD("device_model", device_model!)
        common.setUD("app_version", app_version!)
        
        let data = "act=setAppDeviceInfo&device_type=iOS" +
            "&device_id="+device_id!+"&device_token="+device_token!+"&device_model="+device_model!+"&app_version="+app_version!+"&latitude="+latitude!+"&longitude="+longitude!
        let enc_data = Data(data.utf8).base64EncodedString()
        print("jsNativeToServer(enc_data)")
        webView.evaluateJavaScript("jsNativeToServer('" + enc_data + "')", completionHandler:nil)
        
    }
    
    private func setupRefreshControl() {
        //let refreshControl = UIRefreshControl()
        //refreshControl.backgroundColor = common.uicolorFromHex(0x8912f6)
        //refreshControl.tintColor = UIColor.white
        refreshControl.addTarget(self, action: #selector(refreshWebView(sender:)), for: UIControl.Event.valueChanged)
        webView.scrollView.addSubview(refreshControl)
    }
    
    func loadPage(url:String) {
        print("loadPage")
        let url = URL(string: url.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)!)
        let request = URLRequest(url: url!)
        webView.load(request)
    }
    
    func checkNetwork(){
        if(CheckNetwork.isConnected()==false)
        {
            self.moveToErrorView()
        }
    }
    
    func moveToErrorView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let next = storyboard.instantiateViewController(withIdentifier: "ErrorVC")as! ErrorVC
        self.navigationController?.pushViewController(next, animated: false)
        self.dismiss(animated: false, completion: nil)
    }
 
    func moveToScanView(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let next = storyboard.instantiateViewController(withIdentifier: "ViewController")
        self.navigationController?.pushViewController(next, animated: false)
        self.dismiss(animated: false, completion: nil)
    }
    
    // 네이버 로그인 시작
    // 로그인전
    // 로그인 토큰이 없는 경우, 로그인 화면을 오픈한다.
    func oauth20ConnectionDidOpenInAppBrowser(forOAuth request: URLRequest!) {
        // Open Naver SignIn View Controller
        let naverSignInViewController = NLoginThirdPartyOAuth20InAppBrowserViewController(request: request)!
        present(naverSignInViewController, animated: true, completion: nil)
    }
    
    // 로그인후
    func oauth20ConnectionDidFinishRequestACTokenWithRefreshToken() {
        getNaverDataFromURL()
    }
    
    func oauth20ConnectionDidFinishRequestACTokenWithAuthCode() {
        getNaverDataFromURL()
    }
    
    func oauth20ConnectionDidFinishDeleteToken() {
        // Do Nothing
    }
    
    func oauth20Connection(_ oauthConnection: NaverThirdPartyLoginConnection!, didFailWithError error: Error!) {
        // Do Nothing
    }
    
    func getNaverDataFromURL() {
        
        // Naver SignIn Success
        
        let loginConn = NaverThirdPartyLoginConnection.getSharedInstance()
        let tokenType = loginConn?.tokenType
        let accessToken = loginConn?.accessToken
        
        // Get User Profile
        if let url = URL(string: "https://apis.naver.com/nidlogin/nid/getUserProfile.xml") {
            if tokenType != nil && accessToken != nil {
                let authorization = "\(tokenType!) \(accessToken!)"
                var request = URLRequest(url: url)
                
                request.setValue(authorization, forHTTPHeaderField: "Authorization")
                let dataTask = URLSession.shared.dataTask(with: request) {(data, response, error) in
                    if let str = String(data: data!, encoding: .utf8) {
                        
                        var parser = XMLParser()
                        parser = XMLParser(data: data!)
                        parser.delegate = self
                        parser.parse()
                        
                        print("\n"+self.id+"\n"+self.gender+"\n"+self.name+"\n"+self.email+"\n")
                        
                        print(str)
                        
                        let url = self.common.sns_callback_url +
                            "?login_type=naver" +
                            "&success_yn=Y" +
                            "&id=" + self.id +
                            "&gender=" + self.gender +
                            "&name=" + self.name +
                            "&email=" + self.email
                        self.loadPage(url: url)
                        
                        // Naver Sign Out
                        //loginConn?.resetToken()
                    }
                }
                dataTask.resume()
            }
        }
        
    }
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "id" { foundCharacters = "" }
        else if elementName == "gender" { foundCharacters = "" }
        else if elementName == "name" { foundCharacters = "" }
        else if elementName == "email" { foundCharacters = "" }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        foundCharacters += string
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "id" { id = foundCharacters }
        else if elementName == "gender" { gender = foundCharacters }
        else if elementName == "name" { name = foundCharacters }
        else if elementName == "email" { email = foundCharacters }
    }
    // 네이버 로그인 끝
    
    // 문자발송
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
}

//BOOTPAY 시작
extension MainWebVC  {
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {

        refreshControl.endRefreshing()
        
        if let cur_url = webView.url?.absoluteString{
            
            common.setUD("lastUrl", cur_url)
            /*
            if(cur_url.hasSuffix("step.php"))
            {
                sendStepInfo()
            }
            else if(cur_url.hasSuffix("challenge.php"))
            {
                frontAd = GADInterstitial(adUnitID: common.admob_front_ad)
                frontAd.delegate = self
                let request = GADRequest()
                request.testDevices = [kGADSimulatorID, "f4debf541bf25e9a44ac6794249bde14" ]
                frontAd.load(request)
            }
            else if(cur_url.hasSuffix("index2.php"))
            {   
                frontAd = GADInterstitial(adUnitID: common.admob_front_ad)
                frontAd.delegate = self
                let request = GADRequest()
                request.testDevices = [kGADSimulatorID, "f4debf541bf25e9a44ac6794249bde14" ]
                frontAd.load(request)
            }
            */
        }
        
        
        sendDeviceInfo()
        registerAppId()
        setDevice()
        startTrace()
        registerAppIdDemo()
    }
    
    func registerAppId() {
        doJavascript("BootPay.setApplicationId('\(common.bootpay_id)');")
    }
    
    func registerAppIdDemo() {
        doJavascript("window.setApplicationId('\(common.bootpay_id)');")
    }
    
    internal func setDevice() {
        doJavascript("window.BootPay.setDevice('IOS');")
    }
    
    internal func startTrace() {
        doJavascript("BootPay.startTrace();")
    }
    
    func isMatch(_ urlString: String, _ pattern: String) -> Bool {
        let regex = try! NSRegularExpression(pattern: pattern, options: [])
        let result = regex.matches(in: urlString, options: [], range: NSRange(location: 0, length: urlString.count))
        return result.count > 0
    }
    
    func isItunesURL(_ urlString: String) -> Bool {
        return isMatch(urlString, "\\/\\/itunes\\.apple\\.com\\/")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let url = navigationAction.request.url {
            print(url)
            
            if(isItunesURL(url.absoluteString)) {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                decisionHandler(.cancel)
            } else if url.scheme != "http" && url.scheme != "https" {
                
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
                decisionHandler(.cancel)
            } else {
                decisionHandler(.allow)
            }
        } else {
            decisionHandler(.allow)
        }
        
        /*
         //KCP
         guard let url = navigationAction.request.url else {
         decisionHandler(.cancel)
         return
         }
         
         print(url)
         
         if url.absoluteString.range(of: "//itunes.apple.com/") != nil {
         UIApplication.shared.open(url)
         decisionHandler(.cancel)
         return
         
         } else if !url.absoluteString.hasPrefix("http://") && !url.absoluteString.hasPrefix("https://") {
         if UIApplication.shared.canOpenURL(url) {
         UIApplication.shared.open(url)
         decisionHandler(.cancel)
         return
         }
         }
         
         switch navigationAction.navigationType {
         case .linkActivated:
         if navigationAction.targetFrame == nil || !navigationAction.targetFrame!.isMainFrame {
         UIApplication.shared.open(navigationAction.request.url!, options: [:]) // target='_blank' 처리
         //webView.load(URLRequest(url: url))
         decisionHandler(.cancel)
         return
         }
         case .backForward:
         break
         case .formResubmitted:
         break
         case .formSubmitted:
         break
         case .other:
         break
         case .reload:
         break
         }
         
         decisionHandler(.allow)
         */
    }

    
    //func sendDB(sport_date: String, heart_date: String, sleep_date: String, exercise_date: String, tracker_date: String) -> Bool
    func sendDB() -> Void
    {
        //var flag = false;
        let mem_no = self.common.getUD("mem_no") ?? "0"
        
        if(mem_no == "0" || mem_no == "")
        {
            return;
        }
        
        let update_data_status = self.common.getUD("update_data_status") ?? ""
        let last_data_date = getLastDataDate();
        
        let cur_date = Date()
        
        // 최종 업데이트후 1시간이 지난 경우만 업데이트
        if(!update_data_status.isEmpty && cur_date.timeIntervalSince(last_data_date) < 10)
        {
            showToast(message : "데이터 업데이트 진행중")
            return;
        }
        else if(cur_date.timeIntervalSince(last_data_date) < 10)
        {
            return;
        }
        else
        {
            self.common.setUD("update_data_status","UPDATE")
            self.common.setUD("last_data_date", getDateStr())
            
            SmaBleSend?.requestCuffSportData()
            SmaBleSend?.requestCuffHRData()
            SmaBleSend?.requestCuffSleepData()
            SmaBleSend?.requestSportDataV2()
            SmaBleSend?.requestGpsData()
            
            var update_data_status = self.common.getUD("update_data_status") ?? "";
            update_data_status = update_data_status.replace(target:"UPDATE",withString: "");
            self.common.setUD("update_data_status",update_data_status);
            return;
        }
        
        /*
        var sql1 = "SELECT * FROM sport WHERE mem_no='\(mem_no)'"
        if(sport_date != "null") {
            sql1 = "SELECT * FROM sport WHERE s_date>'\(sport_date)' AND mem_no='\(mem_no)'"
        }
        
        let r1 = readDB(type:"sport",sql:sql1)
        if(r1==true)
        {
            flag = true
        }
        
        var sql2 = "SELECT * FROM heart WHERE mem_no='\(mem_no)'"
        if(heart_date != "null") {
            sql2 = "SELECT * FROM heart WHERE s_date>'\(heart_date)' AND mem_no='\(mem_no)'"
        }
        
        let r2 = readDB(type:"heart",sql:sql2)
        if(r2==true)
        {
            flag = true
        }
        
        var sql3 = "SELECT * FROM sleep WHERE mem_no='\(mem_no)'"
        if(sleep_date != "null") {
            sql3 = "SELECT * FROM sleep WHERE s_date>'\(sleep_date)' AND mem_no='\(mem_no)'"
        }
        
        let r3 = readDB(type:"sleep",sql:sql3)
        if(r3==true)
        {
            flag = true
        }
        
        var sql4 = "SELECT * FROM exercise WHERE mem_no='\(mem_no)'"
        if(exercise_date != "null") {
            sql4 = "SELECT * FROM exercise WHERE s_date>'\(exercise_date)' AND mem_no='\(mem_no)'"
        }
        
        let r4 = readDB(type:"exercise",sql:sql4)
        if(r4==true)
        {
            flag = true
        }
        
        var sql5 = "SELECT * FROM tracker WHERE mem_no='\(mem_no)'"
        if(tracker_date != "null") {
            sql5 = "SELECT * FROM tracker WHERE s_date>'\(tracker_date)' AND mem_no='\(mem_no)'"
        }
        
        let r5 = readDB(type:"tracker",sql:sql5)
        if(r5==true)
        {
            flag = true
        }
        */
        return
    }
    
    func appInstalled()
    {
    
    }
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        let p = SmaBleSend?.p
        //let con_app = common.getUD("is_connected") as? String
        //let con_device = SmaBleSend?.serialNum as? Int
        //showToast(message: "\(p)")
        var con = "true";
        if(p == nil)
        {
            con = "false";
        }
        
        if(message.name==common.js_name){
            if let message = message.body as? String {
                
                print(message)

                if message.starts(with: "DATA_DETAIL") {
                    let m = message.components(separatedBy: "__")
                    
                    if(m[1] == "LOGIN")
                    {
                        common.setUD("mem_no", m[2])
                    }
                    else if(m[1] == "CHECK_APP_INSTALLED")
                    {
                        let app_name = convertDate(d:m[2])
                        
                        if(UIApplication.shared.canOpenURL(URL(string: app_name + "://")!)==true){
                            doJavascript("appInstalled('" + app_name + "')")
                        }else{
                            doJavascript("appNotInstalled('" + app_name + "')")
                        }
                    }
                    else if(m[1] == "SETUP")
                    {
                        if(con != "true") {return}
                        
                        let lost_yn = convertDate(d:m[2])
                        let gesture_yn = convertDate(d:m[3])
                        let phone_yn = convertDate(d:m[4])
                        let message_yn = convertDate(d:m[5])
                        
                        if(lost_yn == "Y") {
                            SmaBleSend?.setDefendLose(true)
                            UserDefaults.standard.set(1, forKey: "DefendLose")
                        } else {
                            SmaBleSend?.setDefendLose(false)
                            UserDefaults.standard.set(0, forKey: "DefendLose")
                        }
                        
                        if(gesture_yn == "Y") {
                            SmaBleSend?.setLiftBright(true)
                        } else {
                            SmaBleSend?.setLiftBright(false)
                        }
                        
                        if(phone_yn == "Y"){
                            SmaBleSend?.setphonespark(true);
                            UserDefaults.standard.set(1, forKey: "PHONE")
                        }else {
                            SmaBleSend?.setphonespark(false);
                            UserDefaults.standard.set(0, forKey: "PHONE")
                        }
                        
                        if(message_yn == "Y"){
                            SmaBleSend?.setSmspark(true);
                            UserDefaults.standard.set(1, forKey: "SMS")
                        }else {
                            SmaBleSend?.setSmspark(false);
                            UserDefaults.standard.set(1, forKey: "SMS")
                        }
                        
                    }
                    else if(m[1] == "CHECK_UPDATE")
                    {
                        if(con != "true") {return}
                        
                        sendDB()
                        /*
                        let sport_date = convertDate(d:m[2])
                        let heart_date = convertDate(d:m[4])
                        let sleep_date = convertDate(d:m[6])
                        let exercise_date = convertDate(d:m[8])
                        let tracker_date = convertDate(d:m[9])
                        
                        sendDB(sport_date: sport_date, heart_date: heart_date, sleep_date: sleep_date, exercise_date: exercise_date, tracker_date: tracker_date)
                        */
                        /*
                        let update_success = sendDB(sport_date: sport_date, heart_date: heart_date, sleep_date: sleep_date, exercise_date: exercise_date, tracker_date: tracker_date)
                        
                        if(update_success==true)
                        {
                            showToast(message : "신규 데이터 업데이트")
                            doJavascript("show_loading(4000)")
                        }
                        */
                    }
                    else if(m[1] == "GESTURE")
                    {
                        if(con != "true") {showToast(message : "기기연결이 안되어 있습니다"); self.disconnected(); return}
                        
                        let info = SMARightScreenInfo()
                        
                        info.beginTime = m[2]
                        info.endTime = m[3]
                        info.isOpen = m[4]
 
                        SmaBleSend?.setBrightInfo(info)
                        
                    }
                    else if(m[1] == "USER")
                    {
                        if(con != "true") {showToast(message : "기기연결이 안되어 있습니다"); self.disconnected(); return}
                        
                        let gender = Int32(m[2]) ?? 1
                        let age = Int32(m[3]) ?? 20
                        let height = Float(m[4]) ?? 170
                        let weight = Float(m[5]) ?? 60
                        SmaBleSend?.setUserMnerberInfoWithHeight(height, weight: weight, sex: gender, age: age)
                        
                        let goal = Int32(m[6]) ?? 8000
                        SmaBleSend?.setStepNumber(goal)
                    }
                    else if(m[1] == "SIT")
                    {
                        if(con != "true") {showToast(message : "기기연결이 안되어 있습니다"); self.disconnected(); return}
                        
                        let info = SmaSeatInfo()
                        
                        info.beginTime0 = m[2]
                        info.endTime0 = m[3]
                        info.isOpen0 = m[4]
                        /*
                         18：00（today）~~08：00（tomorrow）if endTime1<=beginTime1
                         */
                        info.beginTime1 = m[5]
                        info.endTime1 = m[6]
                        info.isOpen1 = m[7]
                        info.repeatWeek = convertRepeat(r:m[8]) // "1111111"的十进制  One week average detection
                        
                        if(m[4]=="1" || m[7]=="1")
                        {
                            info.isOpen = "1"
                        }
                        else
                        {
                            info.isOpen = "0"
                        }
                        
                        info.stepValue = "30"
                        info.seatValue = m[9]
                        
                        SmaBleSend?.seatLongTimeInfoV2(info)
                    }
                    else if(m[1] == "HEART")
                    {
                        if(con != "true") {showToast(message : "기기연결이 안되어 있습니다"); self.disconnected(); return}
                        
                        let info = SmaHRHisInfo()
                        
                        info.beginhour0 = m[2]
                        info.endhour0 = m[3]
                        info.isopen0 = m[4]
                        info.isopen = m[4]
                        info.tagname = m[5]
                        info.dayFlags = "127"
                        info.isopen1 = "0"
                        
                        SmaBleSend?.setHRWithHR(info)
                        
                    }
                    else if(m[1] == "ALARM")
                    {
                        if(con != "true") {showToast(message : "기기연결이 안되어 있습니다"); self.disconnected(); return}
                        
                        var alarmArr : NSMutableArray = []
                        let alarm_count = Int(m[42]) ?? 0
                        
                        let alarm1 = SmaAlarmInfo()
                        alarm1.aid = "0"
                        alarm1.hour = m[2]
                        alarm1.minute = m[3]
                        alarm1.dayFlags = convertRepeat(r: m[4])
                        
                        if(m[5]=="null")
                        {
                            alarm1.tagname = " "
                        }
                        else
                        {
                            alarm1.tagname = m[5]
                        }
                        
                        alarm1.isOpen = m[6]
                        
                        if(alarm_count>0)
                        {
                            alarmArr.add(alarm1)
                        }
                        
                        let alarm2 = SmaAlarmInfo()
                        alarm2.aid = "1"
                        alarm2.hour = m[7]
                        alarm2.minute = m[8]
                        alarm2.dayFlags = convertRepeat(r:m[9])
                        
                        if(m[10]=="null")
                        {
                            alarm2.tagname = " "
                        }
                        else
                        {
                            alarm2.tagname = m[10]
                        }
                        
                        alarm2.isOpen = m[11]
                        
                        if(alarm_count>1)
                        {
                            alarmArr.add(alarm2)
                        }
                        
                        let alarm3 = SmaAlarmInfo()
                        alarm3.aid = "2"
                        alarm3.hour = m[12]
                        alarm3.minute = m[13]
                        alarm3.dayFlags = convertRepeat(r:m[14])
                        
                        if(m[15]=="null")
                        {
                            alarm3.tagname = " "
                        }
                        else
                        {
                            alarm3.tagname = m[15]
                        }
                        
                        alarm3.isOpen = m[16]
                        
                        if(alarm_count>2)
                        {
                            alarmArr.add(alarm3)
                        }
                        
                        let alarm4 = SmaAlarmInfo()
                        alarm4.aid = "3"
                        alarm4.hour = m[17]
                        alarm4.minute = m[18]
                        alarm4.dayFlags = convertRepeat(r:m[19])
                        
                        if(m[20]=="null")
                        {
                            alarm4.tagname = " "
                        }
                        else
                        {
                            alarm4.tagname = m[20]
                        }
                        
                        alarm4.isOpen = m[21]
                        
                        if(alarm_count>3)
                        {
                            alarmArr.add(alarm4)
                        }
                        
                        let alarm5 = SmaAlarmInfo()
                        alarm5.aid = "4"
                        alarm5.hour = m[22]
                        alarm5.minute = m[23]
                        alarm5.dayFlags = convertRepeat(r:m[24])
                        
                        if(m[25]=="null")
                        {
                            alarm5.tagname = " "
                        }
                        else
                        {
                            alarm5.tagname = m[25]
                        }
                        
                        alarm5.isOpen = m[26]
                        
                        if(alarm_count>4)
                        {
                            alarmArr.add(alarm5)
                        }
                        
                        let alarm6 = SmaAlarmInfo()
                        alarm6.aid = "5"
                        alarm6.hour = m[27]
                        alarm6.minute = m[28]
                        alarm6.dayFlags = convertRepeat(r:m[29])
                        
                        if(m[30]=="null")
                        {
                            alarm6.tagname = " "
                        }
                        else
                        {
                            alarm6.tagname = m[30]
                        }
                        
                        alarm6.isOpen = m[31]
                        
                        if(alarm_count>5)
                        {
                            alarmArr.add(alarm6)
                        }
                        
                        let alarm7 = SmaAlarmInfo()
                        alarm7.aid = "6"
                        alarm7.hour = m[32]
                        alarm7.minute = m[33]
                        alarm7.dayFlags = convertRepeat(r:m[34])
                        
                        if(m[35]=="null")
                        {
                            alarm7.tagname = " "
                        }
                        else
                        {
                            alarm7.tagname = m[35]
                        }
                        
                        alarm7.isOpen = m[36]
                        
                        if(alarm_count>6)
                        {
                            alarmArr.add(alarm7)
                        }
                        
                        let alarm8 = SmaAlarmInfo()
                        alarm8.aid = "7"
                        alarm8.hour = m[37]
                        alarm8.minute = m[38]
                        alarm8.dayFlags = convertRepeat(r:m[39])
                        
                        if(m[40]=="null")
                        {
                            alarm8.tagname = " "
                        }
                        else
                        {
                            alarm8.tagname = m[40]
                        }
                        
                        alarm8.isOpen = m[41]
                        
                        if(alarm_count>7)
                        {
                            alarmArr.add(alarm8)
                        }
                        
                        //    [alarmArr removeAllObjects];//delete all alarms
                        //    [alarmArr removeObjectAtIndex:1];//delete the second alarm
                        //    [alarmArr removeLastObject];delete the last alarm
                        
                        if(alarm_count>0)
                        {
                            SmaBleSend?.setClockInfoV2(alarmArr)
                        }
                    }
                    
                }
                else if message == "CHECK_TIMEZONE" {
                    sendTimezone()
                }
                else if message == "SCAN" {
                    unbind()
                    moveToScanView()
                }
                else if(message == "CHECK_UPDATE")
                {
                    if(con != "true") {return}
                    
                    sendDB()
                }
                else if message == "APP_SETTING" {
                    UIApplication.shared.openURL(NSURL(string: UIApplicationOpenSettingsURLString)! as URL)
                }
                else if message == "GET_GPS" {
                    getGPS()
                }
                else if message == "AGPS_AUTO_UPDATE" {
                    setAgps()
                }
                else if message == "AGPS" {
                    SmaBleSend?.updateEPOFileForAGPS()
                    
                    /*
                    [AFNetRequestManager DownloadFileWithURL:@"http://wepodownload.mediatek.com/EPO_GR_3_1.DAT" Success:^(id responseObject) {
                        
                        NSLog(@"response==%@",responseObject);
                        if (responseObject) {
                        [self updataEPOFileWithPath:responseObject];
                        }
                        } fail:^(NSError *error) {
                        NSLog(@"error==%@",error);
                        }];
                    */
                    /*
                    AFNetRequestManager.downloadFile(withURL: "http://wepodownload.mediatek.com/EPO_GR_3_1.DAT", success: { responseObject in
                        
                        if let responseObject = responseObject {
                            print("response==\(responseObject)")
                        }
                        if responseObject != nil {
                            self.SmaBleSend?.updataEPOFile(withPath: responseObject as! URL)
                            self.showToast(message: "AGPS 업데이트 진행중")
                        }
                    }, fail: { error in
                        if let error = error {
                            print("error==\(error)")
                            self.showToast(message: "AGPS 업데이트 실패")
                        }
                    })
                    */
                }
                else if message == "GET_GOAL" {
                    SmaBleSend?.getGoal()
                }
                else if message == "GET_SIT" {
                    SmaBleSend?.getLongTime()
                }
                else if message == "GET_ALARM" {
                    SmaBleSend?.getCuffCalarmClockList()
                }
                else if message == "LOGOUT" {
                    common.setUD("mem_no","0")
                }
                else if message == "BATTERY" {
                    if(con != "true") {showToast(message : "기기연결이 안되어 있습니다"); self.disconnected(); return}
                    SmaBleSend?.getElectric()
                }
                else if message == "PHONE_ON" {
                    if(con != "true") {showToast(message : "기기연결이 안되어 있습니다"); self.disconnected(); return}
                    SmaBleSend?.setphonespark(true);
                    UserDefaults.standard.set(1, forKey: "PHONE")
                }
                else if message == "PHONE_OFF" {
                    if(con != "true") {showToast(message : "기기연결이 안되어 있습니다"); self.disconnected(); return}
                    SmaBleSend?.setphonespark(false);
                    UserDefaults.standard.set(0, forKey: "PHONE")
                }
                else if message == "MESSAGE_ON" {
                    if(con != "true") {showToast(message : "기기연결이 안되어 있습니다"); self.disconnected(); return}
                    SmaBleSend?.setSmspark(true);
                    UserDefaults.standard.set(1, forKey: "SMS")
                }
                else if message == "MESSAGE_OFF" {
                    if(con != "true") {showToast(message : "기기연결이 안되어 있습니다"); self.disconnected(); return}
                    SmaBleSend?.setSmspark(false);
                    UserDefaults.standard.set(0, forKey: "SMS")
                }
                else if message == "LOST_ON" {
                    if(con != "true") {showToast(message : "기기연결이 안되어 있습니다"); self.disconnected(); return}
                    SmaBleSend?.setDefendLose(true);
                    UserDefaults.standard.set(1, forKey: "DefendLose")
                    //[SmaUserDefaults setInteger:swit.on forKey:@"DefendLose"];
                }
                else if message == "LOST_OFF" {
                    if(con != "true") {showToast(message : "기기연결이 안되어 있습니다"); self.disconnected(); return}
                    SmaBleSend?.setDefendLose(false);
                    UserDefaults.standard.set(0, forKey: "DefendLose")
                }
                else if message == "FIND_DEVICE" {
                    if(con != "true") {showToast(message : "기기연결이 안되어 있습니다"); self.disconnected(); return}
                    SmaBleSend?.requestFindDevice(withBuzzing: 1)
                }
                else if message == "CAMERA" {
                    if(con != "true") {showToast(message : "기기연결이 안되어 있습니다"); self.disconnected(); return}
                    
                    picker.sourceType = .camera
                    
                    present(picker, animated: false, completion: nil)
                    
                    SmaBleSend?.setBLcomera(true)
                    
                }
                else if message == "UNBIND" {
                    unbind()
                }
                else if message == "CHECK_CONNECTION" {
                    if(con == "true")
                    {
                        webView.evaluateJavaScript("isConnected('true')", completionHandler:nil)
                    }
                    else
                    {
                        webView.evaluateJavaScript("isConnected('false')", completionHandler:nil)
                    }
                }
                else if message == "SET_TIME" {
                    SmaBleSend?.setPhoneSystemState(2)
                    SmaBleSend?.setTimeZone()
                    SmaBleSend?.setSystemTime()
                }
                else if message == "SET_WEATHER" {
                    if(con != "true") {showToast(message : "기기연결이 안되어 있습니다"); self.disconnected(); return}
                    
                    setWeather()
                }
                else if message == "RESET_TIMEZONE" {
                    common.setUD("timezone", "")
                    sendTimezone()
                }
                else if message == "TEST_RING" {
                    playAudioFile(sound: "dingdong")
                }
                else if message == "SHOW_ADLIB_FRONT_AD" {
                    common.setUD("ADLIB_TYPE", "FRONT")
                    adlibAd.request(withKey: common.adlib_id, adDelegate: self)
                }
                else if message == "SHOW_ADLIB_REWARD_AD" {
                    common.setUD("ADLIB_TYPE", "REWARD")
                    adlibAd.request(withKey: common.adlib_id, adDelegate: self)
                }
                else if message == "NAVER" {
                    print("NAVERLOGIN")
                    let naverConnection = NaverThirdPartyLoginConnection.getSharedInstance()
                    naverConnection?.delegate = self
                    naverConnection?.requestThirdPartyLogin()
                }
                else if message == "KAKAO" {
                    print("KAKAOLOGIN")
                    let session: KOSession = KOSession.shared();
                    if session.isOpen() {
                        session.close()
                    }
                    session.presentingViewController = self
                    session.open(completionHandler: { (error) -> Void in
                        if error != nil{
                            print(error?.localizedDescription as Any)
                        }else if session.isOpen() == true{
                            
                            KOSessionTask.userMeTask(completion: { (error, me) in
                                if let error = error as NSError? {
                                    self.alert(title: "kakaologin_error", msg: error.description)
                                } else if let me = me as KOUserMe? {
                                    print("id: \(String(describing: me.id))")
                                    
                                    self.name = (me.properties!["nickname"])!
                                    if(me.account?.email == nil)
                                    {
                                        self.email = "null"
                                    }else{
                                        self.email = (me.account?.email)!
                                    }
                                    self.id = me.id!
                                    
                                    let url = self.common.sns_callback_url +
                                        "?login_type=kakao" +
                                        "&success_yn=Y" +
                                        "&id=" + self.id +
                                        "&email=" + self.email +
                                        "&name=" + self.name
                                    
                                    print(url)
                                    
                                    self.loadPage(url: url)
                                    
                                } else {
                                    print("has no id")
                                }
                            })
                        }else{
                            print("isNotOpen")
                        }
                    })
                }else {
                    /*
                    let data = Data(message.utf8)
                    let json = try! JSONSerialization.jsonObject(with: data, options: []) as! [String : Any]
                    
                    let share_type = json["share_type"] as? String
                    
                    let link_url = json["link_url"] as? String
                    let title = json["title"] as? String
                    let img_url = json["img_url"] as? String
                    let content = json["content"] as? String
                    
                    if(share_type == "MMS")
                    {
                        if (MFMessageComposeViewController.canSendText()) {
                            let controller = MFMessageComposeViewController()
                            controller.body = title! + "\n\n" + content! + "\n\n" +  link_url!
                            controller.recipients = [""]
                            controller.messageComposeDelegate = self
                            self.present(controller, animated: true, completion: nil)
                        }
                    }
                    else if(share_type == "KAKAO")
                    {
                        var stringDictionary: Dictionary = [String: String]()
                        stringDictionary["${title}"] = title
                        stringDictionary["${content}"] = content
                        
                        KLKTalkLinkCenter.shared().sendCustom(withTemplateId: common.kakao_template_id, templateArgs: stringDictionary as! [String : String], success: nil, failure: nil)
                    }
                    else if(share_type == "KAKAOSTORY")
                    {
                        if !SnsLinkHelper.canOpenStoryLink() {
                            SnsLinkHelper.openiTunes("itms://itunes.apple.com/app/id486244601")
                            return
                        }
                        let bundle = Bundle.main
                        var postMessage: String!
                        if let bundleId = bundle.bundleIdentifier, let appVersion: String = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String,
                            let appName: String = bundle.object(forInfoDictionaryKey: "CFBundleName") as? String {
                            postMessage = SnsLinkHelper.makeStoryLink(title! + " " + link_url!, appBundleId: bundleId, appVersion: appVersion, appName: appName, scrapInfo: nil)
                        }
                        if let urlString = postMessage {
                            _ = SnsLinkHelper.openSNSLink(urlString)
                        }
                    }
                    else if share_type == "LINE" {
                        if !SnsLinkHelper.canOpenLINE() {
                            SnsLinkHelper.openiTunes("itms://itunes.apple.com/app/id443904275")
                            return
                        }
                        let postMessage = SnsLinkHelper.makeLINELink(title! + " " + link_url!)
                        if let urlString = postMessage {
                            _ = SnsLinkHelper.openSNSLink(urlString)
                        }
                        
                    }
                    else if share_type == "BAND" {
                        if !SnsLinkHelper.canOpenBAND() {
                            SnsLinkHelper.openiTunes("itms://itunes.apple.com/app/id542613198")
                            return
                        }
                        let postMessage = SnsLinkHelper.makeBANDLink(title! + " " + link_url!, link_url!)
                        if let urlString = postMessage {
                            _ = SnsLinkHelper.openSNSLink(urlString)
                        }
                    }
                    else if share_type == "FACEBOOK" {

                         // import Social 을 이용할경우
                         let facebookShare = SLComposeViewController(forServiceType: SLServiceTypeFacebook)
                         if let facebookShare = facebookShare{
                         facebookShare.setInitialText(title!) // 작동안함
                         //facebookShare.add(UIImage(named: "iOSDevCenters.jpg")!)
                         facebookShare.add(URL(string: link_url!))
                         self.present(facebookShare, animated: true, completion: nil)
                         }
                        
                    }
 */
                }
            }
        }else if(message.name==common.bootpay_js_name){
            if let message = message.body as? String {
                
                print(message)
            }
            
            guard let body = message.body as? [String: Any] else {
                
                if message.body as? String == "close" {
                    onClose()
                }
                return
            }
            guard let action = body["action"] as? String else {
                return
            }
            
            
            print(action)
            
            
            // 해당 함수 호출
            if action == "BootpayCancel" {
                onCancel(data: body)
            } else if action == "BootpayError" {
                onError(data: body)
            } else if action == "BootpayBankReady" {
                onReady(data: body)
            } else if action == "BootpayConfirm" {
                onConfirm(data: body)
            } else if action == "BootpayDone" {
                onDone(data: body)
            }
        }
    }

    
    func convertDate(d:String) -> String{
        let c = d.replace(target:":",withString: "")
        let b = c.replace(target:" ",withString:"")
        let a = b.replace(target:"-",withString:"")
        
        return a
    }
    
    func convertRepeat(r:String) -> String{
        
        var a : String = ""
        
        let d : Int = Int(r) ?? 0
        
        let b = String(d, radix:2).pad(with: "0",toLength: 7)
        
        
            a.append(b[6])
            a.append(b[5])
            a.append(b[4])
            a.append(b[3])
            a.append(b[2])
            a.append(b[1])
            a.append(b[0])
        
            //print(a.asBinary()!)
        
        return String(a.asBinary()!)
    }
    
    func webView(_ webView: WKWebView, didReceive challenge: URLAuthenticationChallenge, completionHandler: @escaping (URLSession.AuthChallengeDisposition, URLCredential?) -> Swift.Void) {
        if(challenge.protectionSpace.authenticationMethod == NSURLAuthenticationMethodServerTrust) {
            let cred = URLCredential(trust: challenge.protectionSpace.serverTrust!)
            completionHandler(.useCredential, cred)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    //Adlib
    func alInterstitialAd(_ interstitialAd: ALInterstitialAd!, didClickedAdAt platform: ALMEDIATION_PLATFORM) {
        print("alInterstitialAd-didClickedAdAt")
        if(common.getUD("ADLIB_TYPE")=="REWARD")
        {
            print("rewardComplete")
            doJavascript("rewardComplete()")
        }
    }
    
    func alInterstitialAd(_ interstitialAd: ALInterstitialAd!, didReceivedAdAt platform: ALMEDIATION_PLATFORM) {
        print("alInterstitialAd-didReceivedAdAt")
    }
    
    func alInterstitialAd(_ interstitialAd: ALInterstitialAd!, didFailedAdAt platform: ALMEDIATION_PLATFORM) {
        print("alInterstitialAd-didFailedAdAt")
    }
    
    func alInterstitialAdDidFailedAd(_ interstitialAd: ALInterstitialAd!) {
        print("alInterstitialAdDidFailedAd")

    }
    //Adlib 끝
    
}

// 웹뷰 alert 팝업처리
extension MainWebVC {
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        
        if navigationAction.targetFrame == nil {
            if let url = navigationAction.request.url {
                if #available(iOS 10, *) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                } else {
                    UIApplication.shared.openURL(url)
                }
            }
            
            return nil
        }
        
        //뷰를 생성하는 경우
        let frame = UIScreen.main.bounds
        
        //파라미터로 받은 configuration
        createWebView = WKWebView(frame: frame, configuration: configuration)
        
        //오토레이아웃 처리
        createWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        createWebView.navigationDelegate = self
        createWebView.uiDelegate = self
        
        
        view.addSubview(createWebView!)
        
        return createWebView!
    }

    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping () -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler()
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (Bool) -> Void) {
        let alertController = UIAlertController(title: "", message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            completionHandler(true)
        }))
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(false)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo,
                 completionHandler: @escaping (String?) -> Void) {
        let alertController = UIAlertController(title: "", message: prompt, preferredStyle: .alert)
        alertController.addTextField { (textField) in
            textField.text = defaultText
        }
        alertController.addAction(UIAlertAction(title: "확인", style: .default, handler: { (action) in
            if let text = alertController.textFields?.first?.text {
                completionHandler(text)
            } else {
                completionHandler(defaultText)
            }
        }))
        
        alertController.addAction(UIAlertAction(title: "취소", style: .default, handler: { (action) in
            completionHandler(nil)
        }))
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    public func webViewWebContentProcessDidTerminate(_ webView: WKWebView) {
        // 중복적으로 리로드가 일어나지 않도록 처리 필요.
        webView.reload()
    }
    
    func webViewDidClose(_ webView: WKWebView) {
        if webView == createWebView {
            createWebView?.removeFromSuperview()
            createWebView = nil
        }
    }
    
    func alert(title : String?, msg : String,
               style: UIAlertController.Style = .alert,
               dontRemindKey : String? = nil) {
        if dontRemindKey != nil,
            UserDefaults.standard.bool(forKey: dontRemindKey!) == true {
            return
        }
        
        let ac = UIAlertController.init(title: title,
                                        message: msg, preferredStyle: style)
        ac.addAction(UIAlertAction.init(title: "OK",
                                        style: .default, handler: nil))
        
        if dontRemindKey != nil {
            ac.addAction(UIAlertAction.init(title: "Don't Remind",
                                            style: .default, handler: { (aa) in
                                                UserDefaults.standard.set(true, forKey: dontRemindKey!)
                                                UserDefaults.standard.synchronize()
            }))
        }
        DispatchQueue.main.async {
            self.present(ac, animated: true, completion: nil)
        }
    }
    
}
// 웹뷰 팝업처리 끝

//MARK: Bootpay Callback Protocol
extension MainWebVC {
    // 에러가 났을때 호출되는 부분
    func onError(data: [String: Any]) {
        print(data)
        
        let json = dicToJsonString(data)
        alert(title: "bootpay_error", msg: json)
    }
    
    // 가상계좌 입금 계좌번호가 발급되면 호출되는 함수입니다.
    func onReady(data: [String: Any]) {
        print("ready")
        print(data)
    }
    
    // 결제가 진행되기 바로 직전 호출되는 함수로, 주로 재고처리 등의 로직이 수행
    func onConfirm(data: [String: Any]) {
        print(data)

        let json = dicToJsonString(data).replacingOccurrences(of: "\"", with: "'")
        //print(json)
        //doJavascript("BootPay.transactionConfirm( \(json) );"); // 결제 승인
        
        // 중간에 결제창을 닫고 싶을 경우
        // doJavascript("BootPay.removePaymentWindow();");
    }
    
    // 결제 취소시 호출
    func onCancel(data: [String: Any]) {
        print(data)
        webView.reload()
    }
    
    // 결제완료시 호출
    func onDone(data: [String: Any]) {
        print(data)
        let receipt_id = data["receipt_id"] as! String
        sUrl = common.default_url + "/pay/bootpay_check.php?receipt_id=" + receipt_id
        loadPage(url: sUrl)
    }
    
    //결제창이 닫힐때 실행되는 부분
    func onClose() {
        print("close")
    }
    
    internal func doJavascript(_ script: String) {
        webView.evaluateJavaScript(script, completionHandler: nil)
    }
    
    fileprivate func dicToJsonString(_ data: [String: Any]) -> String {
        do {
            let jsonData = try JSONSerialization.data(withJSONObject: data, options: [])
            let jsonStr = String(data: jsonData, encoding: .utf8)
            if let jsonStr = jsonStr {
                return jsonStr
            }
            return ""
        } catch {
            print(error.localizedDescription)
            return ""
        }
    }
    
}
//BOOTPAY 끝


extension String {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
    func pad(with character: String, toLength length: Int) -> String {
        let padCount = length - self.count
        guard padCount > 0 else { return self }
        
        return String(repeating: character, count: padCount) + self
    }
    func replace(target: String, withString: String) -> String { return self.replacingOccurrences(of: target, with: withString, options: NSString.CompareOptions.literal, range: nil) }
    func asBinary() -> Int? {
        var result: Int = 0
        
        for digit in self {
            switch(digit) {
            case "0": result = result * 2
            case "1": result = result * 2 + 1
            default: return nil
            }
        }
        return result
    }
}
extension Substring {
    subscript (i: Int) -> Character {
        return self[index(startIndex, offsetBy: i)]
    }
    subscript (bounds: CountableRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ..< end]
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[start ... end]
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return self[start ... end]
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ... end]
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return self[startIndex ..< end]
    }
}
