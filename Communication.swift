//
//  Communication.swift
//  HomePower
//
//  Created by triumph_sha on 2018/7/31.
//  Copyright © 2018年 triumph_sha. All rights reserved.
//

import Foundation

// comm type
enum EnumCommType{
    case SERIALTYPE
    case TCPCLIENTTYPE
    case TCPSERVERTYPE
    
}
// comm status
enum EnumCommStatus {
    case IDLE
    case WORKING
    case WRONG
}
//
enum EnumCommTaskStatus
{
    case request_send
    case wait_respone
    case task_finish
}

protocol INotify {
    func notify(msg:Data)
}

protocol ICommTask:INotify  {
    var device_id:Int{get set}
    var comm_desc:[String:String]{get set}
    //func getdeviceid() -> Int
    func request() -> [UInt8]
    func getstatus() -> EnumCommTaskStatus
}

// channel handle
protocol ICommChannel {
    
    // comm channel process
    func CommChannelHandle(param:NSObject)
    // attack task
    func attach_task(trans:CCommTransaction) -> Bool
    // attach task
    func attach_task(id:Int,newtask:ICommTask) -> Bool
    
    // detach task
    func detach_task(id:Int) -> Void
}

/// comm class
class CCommDevice: NSObject {
    var Name:String
    var Describle:[String:Any]
    var Status:EnumCommStatus = .WRONG
    
    init(_ name:String,_ desc:[String:Any])
    {
        //super.init()
        Name = name
        Describle = desc
    }
    
    func init_device() -> Int {
        // do nothing
        return 0
    }
    
    func sent(_ buff:Data,_ length:Int) -> Int {
        // do nothing
        
        return 0
    }
    
    func recv(_ buff:Data,_ length:Int) -> Int {
        // do nothing
        
        return 0
    }
    
}

// commserial class
class CCommSerial: CCommDevice {
    override func init_device() -> Int {
        // do nothing
        return 0
    }
    
    override func sent(_ buff:Data,_ length:Int) -> Int {
        // do nothing
        return 0
    }
    
    override func recv(_ buff:Data,_ length:Int) -> Int {
        // do nothing
        return 0
    }
}

// tcp client config
struct StrTCPClient {
    var HostIP:String
    var HostPort:Int
    init(_ IP:String,_ Port:Int) {
        HostIP = IP
        HostPort = Port
    }
}

// commtcpclient class
class CTCPClientDevice: CCommDevice,GCDAsyncSocketDelegate {
    var DescTCPClient:StrTCPClient
    var ClientSocket:GCDAsyncSocket!
    var RecvBuffer:[UInt8]
    var DataHandle:INotify?
    
    // init
//    convenience init(_ name:String,_ desc:StrTCPClient) {
//        DescTCPClient = desc//StrTCPClient("192.168.1.1",9000)
//        ClientSocket = GCDAsyncSocket()
//        RecvBuffer = [UInt8]()
//
//        //super.init(name, [])
//        //self.init(name, )
//    }
    
    override init(_ name:String,_ desc:[String:Any]) {
        DescTCPClient = StrTCPClient(desc["hostip"] as! String,desc["port"] as! Int)
        ClientSocket = GCDAsyncSocket()
        RecvBuffer = [UInt8]()
        
        super.init(name, desc)
    }
    
    // init device
    override func init_device() -> Int {
        // do nothing
        if(parse(self.Describle)){
            ClientSocket = GCDAsyncSocket(delegate: self, delegateQueue: DispatchQueue.global())
            self.Status = .IDLE
            
            return 0
        }
        
        return -1
    }
    
    // transform host and post connect
    func connect() -> Void {
        if self.Status == .WRONG || self.Status == .WORKING
        {
            return
        }
        
        do {
            try ClientSocket.connect(toHost: self.DescTCPClient.HostIP, onPort: UInt16(self.DescTCPClient.HostPort), withTimeout: 3)
            
        } catch {
            print("try connect error: \(error)")
            return
        }
        
        //self.Status = .WORKING
    }
    
    // sent context
    override func sent(_ buff:Data,_ length:Int) -> Int {
        // do nothing
        if self.Status == .WORKING {
            ClientSocket.write(buff, withTimeout: -1, tag: 0)
            return length
        }
        
        return 0
    }
    
    // recv data
    override func recv(_ buff:Data,_ length:Int) -> Int {
        // do nothing
        return 0
    }
    
    
    // did connect
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        
        print("connected success!")
        
        self.Status = .WORKING
    }
    
    // dis connect
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        
        print(err.debugDescription)
        
        // set different status by err description
        self.Status = .IDLE
    }
    
    // recv data
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        //
        self.RecvBuffer.append(contentsOf: [UInt8](data))
        //
        DataHandle!.notify(msg: Data(self.RecvBuffer))
    }
    
    // parse init param
    func parse(_ desc:[String:Any]) -> Bool {
        
        //let temp = desc as! [String:Any]
        DescTCPClient.HostIP = desc["hostip"] as! String
        DescTCPClient.HostPort = desc["hostport"] as! Int
        
        return true
    }
}

// factory class
class CCommDeviceFactory: NSObject {
    func CreateCommDevice(_ type:EnumCommType)->CCommDevice?{
        // do nothing
        switch type {
        case .SERIALTYPE:
            return CCommSerial("RS232", ["COMNUM":"COM1","SPEED":19200,"Stopbits":1,"Databits":8,"Parity":1])
        case .TCPCLIENTTYPE:
            return CTCPClientDevice("TCPClient", ["HostIP":"192.168.1.102","HostPort":8000])
        default:
            return nil
        }
    }
}

class CTCPClientChannel: ICommChannel {
    //var DescChannel:StrTCPClient
    var TCPClientForMeterArr:[Int:CTCPClientDevice]
    
    // registed task into dic,
    var task_dic = [Int:CCommTransaction]()
    
    
    init() {
        //DescChannel = desc
        TCPClientForMeterArr = [Int:CTCPClientDevice]()
    }
    
    // communication strategy
    func CommChannelHandle(param: NSObject) {
        // channel device manage
        // 1、connect manage
        
        //
        for elm in task_dic {
            //if elm.value.getstatus() == EnumCommTaskStatus.request_send{
                let client_dev = TCPClientForMeterArr[elm.value.response_id]
                client_dev?.DataHandle = elm.value
            if (client_dev?.sent(Data(bytes: elm.value.request_context!), 1))! > 0
                {
                    task_dic.removeValue(forKey: elm.key)
            }
            //}
        }
    }
    
    func attach_task(trans:CCommTransaction) -> Bool
    {
        if (task_dic.keys.contains(trans.id)) {
            return false
        }
        
        // Is want add device?
        if(!TCPClientForMeterArr.keys.contains(trans.response_id))
        {
            // init tcp client device
            let tcp_client_config = CWifiMeter.get_meter_tcp_client_config(meterid: trans.response_id)
            TCPClientForMeterArr[trans.response_id] = CTCPClientDevice("", tcp_client_config)
        }
        
        // add tcp client device
        task_dic[trans.id] = trans
        
        return true
    }
    
    //
    func attach_task(id:Int,newtask:ICommTask) -> Bool {
//        if (task_dic.keys.contains(id)) {
//            return false
//        }
//
//        // Is want add device?
//        if(!TCPClientForMeterArr.keys.contains(newtask.device_id))
//        {
//            // init tcp client device
//            let tcp_client_config = CWifiMeter.get_meter_tcp_client_config(meterid: newtask.device_id)
//            TCPClientForMeterArr[newtask.device_id] = CTCPClientDevice("", tcp_client_config)
//        }
//
//        // add tcp client device
//        task_dic[id] = newtask
        
        return true
    }
    
    func detach_task(id:Int) -> Void {
        task_dic.removeValue(forKey: id)
    }
}

