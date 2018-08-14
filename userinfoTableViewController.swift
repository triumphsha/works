//
//  userinfoTableViewController.swift
//  HomePower
//
//  Created by triumph_sha on 2018/2/28.
//  Copyright © 2018年 triumph_sha. All rights reserved.
//

import UIKit
import Foundation
import Dispatch
//import SwiftSocket
// socket 状态
enum SocketStatus
{
    case idle
    case connected
    case disconnected
}
/*
// 数据处理代理
protocol DataHandleDelegate {
    // 组织
    func encode(input:[Byte]) -> Int32
    func encode(input:Data) -> Int32
    func encode(input:[String:Any]) -> Int32
    // 解析
    func decode(input:[Byte],output:[Byte]) -> Int32
    func decode(input:[String:Any],output:[Byte]) -> Int32
}

// 告警代理
protocol AlarmDelegate {
    func alert(msg:String,after:()->(Void))
}*/
 
/*
// HPW 通道管理
class HPWSocketClient: NSObject {
    var socket:TCPClient?
    var host:String = "192.168.1.113"
    var port:Int32 = 9000
    var status:SocketStatus = .idle
    var datahandle:DataHandleDelegate?
    var alarmhandle:AlarmDelegate?
    // 初始化
    override init() {
        socket = TCPClient(address: host, port: port)
        status = .disconnected
    }
    
    init(host:String,port:Int32) {
        self.host = host
        self.port = port
        socket = TCPClient(address: host, port: port)
        status = .disconnected
    }
    
    init(host:String,port:Int32,alarm:AlarmDelegate) {
        self.host = host
        self.port = port
        alarmhandle = alarm
        socket = TCPClient(address: host, port: port)
        status = .disconnected
    }

    // 🔗服务器
    func connect() -> Void  {
        // 异步接受信息
        DispatchQueue.global(qos: .background).async {
            //用于读取并解析服务端发来的消息
            func readmsg()->[String:Any]?{
                //read 4 byte int as type
                if let buff=self.socket!.read(256){
                    if buff.count > 0
                    {
                        let msgd = Data(bytes:buff,count:buff.count)
                        if let msgi = try? JSONSerialization.jsonObject(with: msgd,
                                                                        options: .mutableContainers) {
                            return msgi as? [String:Any]
                        }
                    }
                }
                
                Thread.sleep(forTimeInterval: 1)
                return nil
            }
            // 连接服务器
            let result = self.socket!.connect(timeout: 5)
            
            switch result{
            case .success:
                self.status = .connected
                self.alarmhandle?.alert(msg: "connect succ", after: {})
                //不断接收服务器发来的消息
                while true{
                    if let msg=readmsg(){
                        // 此处处理数据信息
                        _ = self.datahandle?.decode(input:msg,output:[])
                    }else{
                        // 计时处理异常
                    }
                }
            default:
                self.status = .disconnected
                self.alarmhandle?.alert(msg: "connect fail", after: {})
            }
        }
    }
    
    // 发送数据
    func send(msgtosend:[String:String]){
        let msgdata=try? JSONSerialization.data(withJSONObject: msgtosend,
                                                options: .prettyPrinted)
    let len = datahandle?.encode(input:msgdata!)
       if len != nil
       {
        
            if len!>0{
                let result = self.socket!.send(data:msgdata!)
                if result.isSuccess {
                    print("send data len \(String(describing: len))")
                }
        }
        }
    }
}*/

// 客户端 Socket
// var gclientsocket:HPWSocketClient?

class userinfoTableViewController: UITableViewController,GCDAsyncSocketDelegate {
    var infoIndex:Int = 0
    var infoTitle:String = ""
    //var socketClient:TCPClient?
    var clientSocket:GCDAsyncSocket!
    var initSocket:Bool = false
    
    let host = "192.168.10.102"
    let port = 9000
    
    // = HPWSocketClient()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
      
        self.navigationItem.title = infoTitle
        let rightBarBtn = UIBarButtonItem(title: "提交", style: .plain, target: self,
                                         action: #selector(submitEdit))
        self.navigationItem.rightBarButtonItem = rightBarBtn
        /*if gclientsocket == nil{
            gclientsocket = HPWSocketClient(host:host,port:Int32(port),alarm:self)
        }
        //初始化客户端，并连接服务器
        if gclientsocket?.status != .connected{
            gclientsocket?.connect()
        }*/
    }
    
   
    func alert(msg:String,after:()->(Void)){
        let alertController = UIAlertController(title: "",
                                                message: msg,
                                                preferredStyle: .alert)
        self.present(alertController, animated: true, completion: nil)
        
        //1.5秒后自动消失
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) {
            alertController.dismiss(animated: false, completion: nil)
        }
    }
 
    //发送消息
    func sendMessage(msgtosend:[String:String]){
        let msgdata=try? JSONSerialization.data(withJSONObject: msgtosend,
                                                options: .prettyPrinted)
        var len:Int32=Int32(msgdata!.count)
        let data = Data(bytes: &len, count: 4)
        //_ = self.socketClient!.send(data: data)
        //_ = self.socketClient!.send(data:msgdata!)
    }
    
    //处理服务器返回的消息
    func processMessage(msg:[String:Any]){
        let cmd:String=msg["cmd"] as! String
        switch(cmd){
        case "msg":
            print((msg["from"] as! String) + ": " + (msg["content"] as! String) + "\n")
        default:
            print(msg)
        }
    }
    //
    func toJSONString(dict:NSDictionary!)->NSString{
        let data = try?JSONSerialization.data(withJSONObject: dict, options: JSONSerialization.WritingOptions.prettyPrinted) //dataWithJSONObject(dict, options: JSONSerialization.WritingOptions.PrettyPrinted, error: nil)
        let strJson=NSString(data:data!,encoding: String.Encoding.utf8.rawValue)//.utf8
        return strJson!
    }
    
    // 提交按钮事件处理
    @objc func submitEdit()
    {
        //gclientsocket?.send(msgtosend: maindata[infoIndex])
        if host != "" { // 如果IP地址不为空则开始连接Socket
            clientSocket = GCDAsyncSocket()
            clientSocket.delegate = self
            clientSocket.delegateQueue = DispatchQueue.global()
            do {
                try clientSocket.connect(toHost:host, onPort: UInt16(port))
            } catch {
                print("try connect error: \(error)")
                //conBtn.backgroundColor = UIColor.red
            }
        } else {
            //msgView.insertText("IP地址不能为空！\n")
        }
    }
    
    
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) -> Void {
        alert(msg:"connect success",after:{})
        print("connect success")
        //sendBtn.isEnabled = true // 连接成功后发送按钮设为可用
        clientSocket.readData(withTimeout: -1, tag: 0)
    }
    
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) -> Void {
        
        alert(msg:"disconnect socket",after:{})
        print("connect error: \(err)")
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) -> Void {
        // 1、获取客户端发来的数据，把 NSData 转 NSString
        //let readClientDataString: NSString? = NSString(data: data as Data, encoding: String.Encoding.utf8.rawValue)
        //let msgd = Data(data,)
        let msgi = try? JSONSerialization.jsonObject(with: data,options: .mutableContainers)
        
        print("---Data Recv---")
        print(msgi.debugDescription)
        
        // 2、主界面UI显示数据
        DispatchQueue.main.async {
            //let showStr: NSMutableString = NSMutableString()
            //showStr.append(self.msgView.text)
            //showStr.append(readClientDataString! as String)
            //showStr.append("\r\n")
            //self.msgView.text = showStr as String
        }
        
        // 3、处理请求，返回数据给客户端OK
        let serviceStr: NSMutableString = NSMutableString()
        serviceStr.append("OK")
        serviceStr.append("\r\n")
        clientSocket.write(serviceStr.data(using: String.Encoding.utf8.rawValue)!, withTimeout: -1, tag: 0)
        
        // 4、每次读完数据后，都要调用一次监听数据的方法
        clientSocket.readData(withTimeout: -1, tag: 0)
    }
    
    // 发送消息按钮事件
    @IBAction func sendBtnClick(_ sender: AnyObject) {
        // 如果消息不为空则发送
        let serviceStr: NSMutableString = NSMutableString()
        //serviceStr.append(self.msgInput.text!)
        serviceStr.append("\r\n")
        clientSocket.write(serviceStr.data(using: String.Encoding.utf8.rawValue)!, withTimeout: -1, tag: 0)
    }

    override func viewWillAppear(_ animated: Bool) {
        self.tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    private func sendRequest(string: String, using client: TCPClient) -> String? {
        switch client.send(string: string) {
        case .success:
            return readResponse(from: client)
        case .failure(let error):
            print(String(describing: error))
            return nil
        }
    }
    
    private func readResponse(from client: TCPClient) -> String? {
        guard let response = client.read(1024*10) else { return nil }
        
        return String(bytes: response, encoding: .utf8)
    }
    */
    private func appendToTextField(string: String) {
        print(string)
        //textView.text = textView.text.appending("\n\(string)")
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return maindata[infoIndex].count
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //let cell = tableView.dequeueReusableCell(withIdentifier: "reuseIdentifier", for: indexPath)

        let id = String(describing:userinfoTableViewCell.self)
        let cell = tableView.dequeueReusableCell(withIdentifier: id,for:indexPath) as! userinfoTableViewCell
        // Configure the cell...
        let dicshow = maindata[infoIndex]
        cell.nameLabel.text = keyArray[infoIndex][indexPath.row]//Array(dicshow.keys)[indexPath.row]
        cell.contextLabel.text = dicshow[keyArray[infoIndex][indexPath.row]] as! String
        //cell.contextView.addLayoutGuide(UILayoutGuide.)
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        performSegue(withIdentifier: "userinfoSetting", sender:self)
    }
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        let row = tableView.indexPathForSelectedRow!.row
        let destination = segue.destination as! usersettingTableViewController
        
        let dicshow = maindata[infoIndex]
        let data = dicshow[keyArray[infoIndex][row]]
        destination.settingValue = data as! String
        destination.destRow = row
        destination.infoIndex = infoIndex
        // Pass the selected object to the new view controller.
    }
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

}
