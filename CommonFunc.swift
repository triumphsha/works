//
//  CommonFunc.swift
//  HomePower
//
//  Created by triumph_sha on 2018/4/25.
//  Copyright © 2018年 triumph_sha. All rights reserved.
//

import Foundation
import CoreData
import UIKit


// 数据处理代理
protocol DataHandleDelegate {
    // 组织
    func encode(input:[UInt8]) -> Int32
    func encode(input:Data) -> Int32
    func encode(input:[String:Any]) -> Int32
    // 解析
    //func decode(input:Data,output:[UInt8]) -> Int32
    func decode(input:[String:Any]?,output:[UInt8]) -> Void
}

// 告警代理
protocol NotifyHandleDelegate {
    func alert(msg:String,after:()->(Void))
    func refresh()
}

// socket 状态
enum SocketStatus
{
    case idle
    case connectting
    case connected
    //case datareaded
    case disconnected
}

// time flag
enum TimePrecessFlag {
    case none
    case minuteFlag
    case hourFlag
    case dayFlag
    case monthFlag
}

class CMeterDocParse: DataHandleDelegate {
    let mdataHandle:DataHandleDelegate?
    let mnotifyHandle:NotifyHandleDelegate?
    
    init(dataHandle: DataHandleDelegate, notifyHandle: NotifyHandleDelegate) {
        mdataHandle = dataHandle
        mnotifyHandle = notifyHandle
    }
    
    
    func encode(input: [UInt8]) -> Int32 {
        return 0
    }
    
    func encode(input: Data) -> Int32 {
        return 0
    }
    
    func encode(input: [String : Any]) -> Int32 {
        return 0
    }
    
    func decode(input: [String : Any]?, output: [UInt8]) {
        // data info matching
//        let meterDoc = MeterDoc(serial: input!["serial"] as! String, ip: input!["hostIP"] as! String, port: 9000)
//
//        for i in 0..<gArrayMeter.count
//        {
//            if gArrayMeter[i].mDoc.mserial == meterDoc.mserial
//            {
//                if gArrayMeter[i].mDoc.mserverIP != meterDoc.mserverIP
//                {
//                    gArrayMeter[i].mDoc.mserverIP = meterDoc.mserverIP
//                    // update config file
//                    // triumph.sha mark
//                    return
//                }
//                else
//                {
//                    return
//                }
//            }
//        }
        
        // not matching,add new wifimeter
        let newmeter = CWifiMeter(meter_id: 1, meter_serial: "NO2018080001")
        gArrayMeter.append(newmeter)
        
        // update config file
        // triumph.sha mark
    }
    
    
}

class CDataParse: DataHandleDelegate {
    var eventRefresh = [NotifyHandleDelegate]()
    
    func encode(input: [UInt8]) -> Int32 {
        return 0
    }
    
    func encode(input: Data) -> Int32 {
        return 0
    }
    
    func encode(input: [String : Any]) -> Int32 {
        return 0
    }
    
    // insert view controller
    func insertEventFresh(freshEvent:NotifyHandleDelegate) -> Void {
        eventRefresh.append(freshEvent)
    }
    
    // data parse
    func decode(input: [String : Any]?, output: [UInt8]) {
        
        if input == nil{
            return
        }
        
        let dataType = input!["DataType"] as! String
        var energyContext:CCoreDataItem
        var dataOperate:CCoreDataOperate
        
        switch dataType {
        case "NormalEnergy":
            
            //        item.setValue(values["serial"], forKey: "code")
            //
            //        let insertDatetime = Int(values["datetime"]!)
            //        item.setValue(insertDatetime, forKey: "date")
            //
            //        for i in 0..<subvalues!.count
            //        {
            //            item.setValue(Int(subvalues![i]), forKey: "value" + ((i>=9) ? "\(i+1)":"0\(i+1)"))
            //        }
            //        let subvalues = values[tableName]?.split(separator: ",")
            //        let insertDatetime = Int(values["datetime"]!)
            //        let intervaltime = Int(values["intervaltime"]!)
            //
            //        for i in 0..<subvalues!.count
            //        {
            //            let item = NSManagedObject(entity: entity!, insertInto: managedObectContext)
            //
            //            //insertDatetime = insertDatetime! + intervaltime!*i*60
            //            //item.setValue(Int(subvalues![i]), forKey: "value" + ((i>=9) ? "\(i+1)":"0\(i+1)"))
            //            item.setValue(values["serial"], forKey: "code")
            //            item.setValue(insertDatetime! + intervaltime!*i*60, forKey: "date")
            //            item.setValue(Int(subvalues![i]), forKey: "value01")
            //            appDelegate.saveContext()
            //        }
            
            let subGaugeValues = (input!["Gauge"] as! String).split(separator: ",")
            let subActivePowerValues = (input!["ActivePower"] as! String).split(separator: ",")
            let subReactivePowerValues = (input!["ReactivePower"] as! String).split(separator: ",")
            let subVoltageValues = (input!["Voltage"] as! String).split(separator: ",")
            let subCurrentValues = (input!["Current"] as! String).split(separator: ",")
            let subFreqValues = (input!["Freq"] as! String).split(separator: ",")
            
            let serial = input!["serial"] as! String
            let startDatetime = input!["datetime"] as! Int
            let intervaltime = input!["intervaltime"] as! Int
            
            for i in 0..<subGaugeValues.count
            {
                energyContext = NormalEnergyData("NormalEnergy", serial, startDatetime + intervaltime*i*60, Int(subGaugeValues[i])!, Int(subActivePowerValues[i])!, Int(subReactivePowerValues[i])!,Int(subVoltageValues[i])!, Int(subCurrentValues[i])!,Int(subFreqValues[i])!)
                
                dataOperate = NormalEnergyOperate(energyContext)
                dataOperate.insertData()
            }
        default:
            return
        }
        
        // update show cache and reflash UI
        let insertDatetime = Int(input!["datetime"]! as! String)
        if (insertDatetime!%86400)%3600 == 0
        {
            let pointCurrent:Int = (insertDatetime!%86400)/3600
            let values = input as! [String:String]
            
            var subvalues = values["Voltage"]?.split(separator: ",")
            var daylist = gCurveData["Voltage"] as! [Int]
            daylist[pointCurrent] = Int(subvalues![0])!
            gCurveData["Voltage"] = daylist
            
            subvalues = values["ActivePower"]?.split(separator: ",")
            daylist = gCurveData["ActivePower"] as! [Int]
            daylist[pointCurrent] = Int(subvalues![0])!
            gCurveData["ActivePower"] = daylist
            
            subvalues = values["Gauge"]?.split(separator: ",")
            daylist = gCurveData["Gauge"] as! [Int]
            daylist[pointCurrent] = Int(subvalues![0])!
            gCurveData["Gauge"] = daylist
            
            for elm in eventRefresh
            {
                elm.refresh()
            }
        }
    }
}


class CCommonFunc: NSObject {
    // get ip address
    static func getIPAddresses()->String?
    {
        var addresses = [String]()
        
        var ifaddr : UnsafeMutablePointer<ifaddrs>? = nil
        if getifaddrs(&ifaddr) == 0 {
            var ptr = ifaddr
            while (ptr != nil) {
                let flags = Int32(ptr!.pointee.ifa_flags)
                var addr = ptr!.pointee.ifa_addr.pointee
                if (flags & (IFF_UP|IFF_RUNNING|IFF_LOOPBACK)) == (IFF_UP|IFF_RUNNING) {
                    if addr.sa_family == UInt8(AF_INET) || addr.sa_family == UInt8(AF_INET6) {
                        var hostname = [CChar](repeating: 0, count: Int(NI_MAXHOST))
                        if (getnameinfo(&addr, socklen_t(addr.sa_len), &hostname, socklen_t(hostname.count),nil, socklen_t(0), NI_NUMERICHOST) == 0) {
                            if let address = String(validatingUTF8:hostname) {
                                addresses.append(address)
                            }
                        }
                    }
                }
                ptr = ptr!.pointee.ifa_next
            }
            freeifaddrs(ifaddr)
        }
        
        return addresses.first
    }
    
    static func getSendStr(type:String) -> String
    {
        var  result = String("{\"command\":{\"name\":\"setparam\",")
        
        if type == "无线设置"{
            let dataConfig = gConfigData[1]["Childrens"] as! [[String:Any]]
            for elm in dataConfig
            {
                result = result + (elm["name"] as! String) + ":" + (elm["value"] as! String) + ","
            }
            result.remove(at: result.endIndex)
            result = result + "}}"
        }
        else if type == ""{
            let dataConfig = gConfigData[2]["Childrens"] as! [[String:Any]]
            let subdataConfig = dataConfig[0]["Childrens"] as! [[String:Any]]
            for i in 0..<subdataConfig.count
            {
                if i==0{
                    result = result + (subdataConfig[i]["name"] as! String) + ":" + ((subdataConfig[i]["value"] as! Bool) ? "true":"false") + ","
                }
                else{
                    result = result + (subdataConfig[i]["name"] as! String) + ":" + (subdataConfig[i]["value"] as! String) + ","
                }
            }
            result = result + (dataConfig[1]["name"] as! String) + ":" + (dataConfig[1]["value"] as! String) + "}}"
//            result.remove(at: result.endIndex)
//            result = result + "}}"
        }
        
        return result
    }
    
    // get address bytes
    static func getAddressBytes(address:String?,family:String)->[UInt8]? {
        guard let addr = address else { return nil }
        
        let af:Int32
        let len:Int
        switch family {
        case "ipv4":
            af = AF_INET
            len = 4
        case "ipv6":
            af = AF_INET6
            len = 16
        default:
            return nil
        }
        var bytes = [UInt8](repeating: 0, count: len)
        let result = inet_pton(af, addr, &bytes)
        return ( result == 1 ) ? bytes : nil
    }
    
    // get config value
    static func getConfigValuesByKey(parent:String,sub:String)->Any
    {
        let subData:[String:Any] = gConfigData[3]
        //let getdata:[][parent]
        return subData[parent] as Any
    }
    // save config value
    static func saveConfigValuesByKey(parent:String,sub:String,value:Any)->Void
    {
        gConfigData[3][parent] = value
        
        //构建文件路径
        //let filePath:String = NSHomeDirectory() + "/Documents/imagetovideo.json"
        //let filePath = Bundle.main.path(forResource: "confige", ofType: "json")
        
        //
        let homeDirectory = NSHomeDirectory()
        let filePath = homeDirectory + "/Documents/config.json"
        saveJsonFileData(filePath,"","")
    }
    
    //static func
    
    // update global config data info,and return element position.  change to recursion programming
    static func updateGConfig(_ update:[String:Any],_ value:Any) -> Int
    {
        let parentKey = update["parent"] as! String
        let updateKey = update["name"] as! String
        let result = update["index"] as! Int
        
        // recursion programming
        updateTreeStructure(&gConfigData,parentKey,true,updateKey,value)
        
        let homeDirectory = NSHomeDirectory()
        let filePath = homeDirectory + "/Documents/config.json"
        saveJsonFileData(filePath,"","")
        
        /*var currindex = update["parent"] as! Int
        var level = [Int]()
        //let temp = currindex / 100
        level.append(update["index"] as! Int)
        let result = level[0]
        //level.append(result)
        if currindex / 100 > 0{
            level.append(currindex%100)
            currindex = currindex / 100
            level.append(currindex)
        }
        else
        {
        level.append(currindex%100)
        }
        
        if level.count == 3{
            var elmParent = gConfigData[level[2]]
            var Childrens = elmParent["Childrens"] as! [[String:Any]]
            var elmChildrens = Childrens[level[1]]
            var ChildChildrens = elmChildrens ["Childrens"] as! [[String:Any]]
            var elmChildChildrens = ChildChildrens[level[0]]
            elmChildChildrens["value"] = value as! String
            
            ChildChildrens[level[0]] = elmChildChildrens
            elmChildrens ["Childrens"] = ChildChildrens
            Childrens[level[1]] = elmChildrens
            elmParent["Childrens"] = Childrens
            gConfigData[level[2]] = elmParent
        }
        else if level.count == 2{
            var elmParent = gConfigData[level[1]]
            var Childrens = elmParent["Childrens"] as! [[String:Any]]
            var elmChildrens = Childrens[level[0]]
            elmChildrens["value"] = value as! String
            
            Childrens[level[0]] = elmChildrens
            elmParent["Childrens"] = Childrens
            gConfigData[level[1]] = elmParent
        }*/
        return result
        
    }
    
    // get element of tree structure
    static func getTreeStructure(_ sourceData:[[String:Any]],_ searchKey:String,_ valueKey:String) -> Any?
    {
        for i in 0..<sourceData.count
        {
            var elm = sourceData[i]
            if elm["name"] as! String == searchKey{
                let Childrens = elm[valueKey]
                return Childrens
            }
            else{
                if elm["HasChildren"] as! Bool
                {
                    let Childrens = elm["Childrens"] as! [[String:Any]]
                    if let result = getTreeStructure(Childrens,searchKey,valueKey)
                    {
                        return result
                    }
                }
            }
        }
        
        return nil
    }
    
    
    // use recursion programming way resolve traverse and update tree structure information.
    static func updateTreeStructure(_ sourceData:inout [[String:Any]],_ parentKey:String,_ isParent:Bool,_ Key:String,_ value:Any)//-> Int
    {
        for i in 0..<sourceData.count
        {
            var elm = sourceData[i]
            if isParent
            {
                if elm["name"] as! String == parentKey{
                    var Childrens = elm["Childrens"] as! [[String:Any]]
                    updateTreeStructure(&Childrens,parentKey,false,Key,value)
                    elm["Childrens"] = Childrens
                    sourceData[i] = elm
                }
                else{
                    if elm["HasChildren"] as! Bool
                    {
                        var Childrens = elm["Childrens"] as! [[String:Any]]
                        updateTreeStructure(&Childrens,parentKey,true,Key,value)
                        elm["Childrens"] = Childrens
                        sourceData[i] = elm
                    }
                }
            }
            else{
                if elm["name"] as! String == Key{
                    elm["value"] = value //as! String
                    //return elm["index"] as! Int
                    sourceData[i] = elm
                    return
                }
            }
        }
    }
    
    static func saveJsonFileData(_ path:String,_ name:String,_ type:String)
    {
        do {
            //将json保存到本地
            let jsonData = try JSONSerialization.data(withJSONObject: gConfigData, options: .prettyPrinted)
            
            // here "jsonData" is the dictionary encoded in JSON data
            let data = jsonData as NSData
            //let toUrl = homeDirectory + "/Documents/moved/hangge.txt"
            //let fileHandle = FileHandle(forUpdatingAtPath: path)
            //fileHandle?.write(jsonData)
            data.write(toFile: path, atomically: true)
        } catch {
            print(error.localizedDescription)
        }
    }
    
    static func connectServer(socket:CTCPClient)->Bool
    {
        for _ in 0...3
        {
            if socket.msocketStatus == .connected
            {
                return true
            }
            
            socket.connect(host: getConfigValuesByKey(parent: "hostIP", sub: "") as! String, port: 9000)
            Thread.sleep(forTimeInterval: 5)
        }
        
        return false
    }
    
    // search data service
    static func searchDataService(socket:CTCPClient)->Bool
    {
        var host:String="192.168.1.10"
        let port:Int=9000
        
        let netgate = CCommonFunc.getIPAddresses()
        var netgatebytes:[UInt8]? = CCommonFunc.getAddressBytes(address: netgate, family: "ipv4")
        netgatebytes![3] = netgatebytes![3] - netgatebytes![3]%100
        let initvalue = netgatebytes![3]
        var i=initvalue
        
        //let hostSave:String = getConfigValuesByKey(parent:"hostIP",sub:"") as! String
//        var retryTimes = 0
        var commtimes = 0
        //host = hostSave
        
        while true
        {
            // find terminal and connect to terminal
            if socket.msocketStatus != .connected
            {
                if commtimes == 1 {
                    commtimes = 0
                }
                // first test save host
//                if retryTimes < 3
//                {
//                    socket.connect(host:host,port:port)
//                    retryTimes = retryTimes + 1
//                }
//                else
//                {
                    if i==255
                    {
                        i=initvalue   //
                        return true
                    }
                    host = String(netgatebytes![0])+"."+String(netgatebytes![1])+"."+String(netgatebytes![2])+"."+String(i)
                    
                    //
                    socket.connect(host:host,port:port)
                    i += 1
                //}
                print("connect to :\r\n",host,port)
                Thread.sleep(forTimeInterval: 5)
            }
            else
            {
                // send command that get wifi meter info.
                if commtimes == 0
                {
                    let strSend = "{\"command\":\"get_doc\"}"
                    _ = socket.send(content: strSend.data(using: String.Encoding.utf8)!, len: 0)
                    commtimes = 1
                    Thread.sleep(forTimeInterval: 3)
                }
                else
                {
                    //commtimes = 0
                    //socket.close()
                }
            }
        }
    }
    
    // get start stamp
    static func getStartStamp(serial:String)->Int
    {
        var element:NSManagedObject?
        var startStamp:Int = 0
        var now:NSDate
        var timeInterval:TimeInterval
        var nowStamp:Int = 0
        let lockDataOperte = NSLock()
        
        lockDataOperte.lock()
        DispatchQueue.main.async {
            // get timestamp from coredata to confirm need data points
//            if let querydata = CCoreDataOperate.queryData(text: "Voltage", conditions: ["code":serial,"sortkey":"date"])
//            {
//                /*for i in 0..<querydata.count
//                 {
//                 element = querydata[i] //as! SPowerInfo
//                 print("table datetime: \r\n",element?.value(forKey: "date") as! Int)
//                 }*/
//                element = querydata.first
//            }
            lockDataOperte.unlock()
        }
        // additional/extra/quick 8 hour
        lockDataOperte.lock()
        if element == nil
        {
            now = NSDate()//timeInterval: 28800, since: NSDate() as Date)
            timeInterval = now.timeIntervalSince1970
            nowStamp = Int(timeInterval) + 28800            //- Int(timeInterval)%60 + 28800
            startStamp = nowStamp - 3600    // replenish sixty points and confirm 10 multiple
        }
        else
        {
            startStamp = element?.value(forKey: "date") as! Int + 3600
        }
        
        if startStamp%3600>0{
            startStamp = startStamp - (startStamp%3600)
        }
        print("time stamp \r\n",startStamp,nowStamp)
        lockDataOperte.unlock()
        
        return startStamp
    }
    
    // get deviece serial
    static func getDevieceSerial() -> String
    {
        let sublist = gConfigData[1]["Childrens"] as! [[String:Any]]
        
        return sublist[0]["value"] as! String
    }
    
    // time process flag
    static func timeProcessFlag()->TimePrecessFlag
    {
        //
        // static let lastSaveTime =
        let now = NSDate()
        
        if(now.getDay() == 1 && now.getHour() == 0 && now.getMinute() == 0)
        {
            return .monthFlag
        }
        
        if(now.getHour() == 0 && now.getMinute() == 0)
        {
            return .dayFlag
        }
        
        if(now.getMinute() == 0)
        {
            return .hourFlag
        }
        
        if(now.getSecond() == 0)
        {
            return .minuteFlag
        }
        
        return .none
    }
    
    // get terminal data
    static func getTerminalData(startstamp:inout Int,socket:CTCPClient)->Void
    {
        let now = NSDate()
        let timeInterval:TimeInterval = now.timeIntervalSince1970
        let nowStamp = Int(timeInterval) - Int(timeInterval)%60 + 28800 // additional/extra
        let points:Int = 10
        
        // self.lockDataOperte?.lock()
        dataLoop:while startstamp < nowStamp
        {
            if startstamp == 0
            {
                break dataLoop
            }
            else
            {
                // not enough 10 minutes
                if (startstamp + 600) > nowStamp
                {
                    break dataLoop
                }
                if socket.msocketStatus != .connected
                {
                    break dataLoop
                }
                
                let strSend = "{\"command\":{\"name\":\"get_data\",\"timestamp\":\(startstamp),\"points\":\(points)}}"
                
                _ = socket.send(content: strSend.data(using: String.Encoding.utf8)!, len: 0)
                
                startstamp = startstamp + points*60
                Thread.sleep(forTimeInterval: 3)
            }
        }
    }
    
    // fill show data:day month year
    static func fillShowData(timeDate:NSDate,typeData:String,loadSources:[[String:Any]])->[Any]
    {
        var tmpData = [Any]()
        
        //loadSources
        var sourceJson = [String:Any]()
        for source in loadSources {
            switch(source["source"] as! String)
            {
//            case "GaugeStatistics":
//                sourceJson["day"] = gArrayMeter[0].getDayData(NSDate(), .gaugestatisticsType, false)
//            case "Gauge":
//                sourceJson["day"] = gArrayMeter[0].getDayData(NSDate(), .gaugeType, false)
//                gCurveData["Gauge"] = sourceJson["day"]
//            case "ActivePower":
//                sourceJson["day"] = gArrayMeter[0].getDayData(NSDate(), .activepowerType, false)
//                gCurveData["ActivePower"] = sourceJson["day"]
//            case "Voltage":
//                sourceJson["day"] = gArrayMeter[0].getDayData(NSDate(), .voltageType, false)
//                gCurveData["Voltage"] = sourceJson["day"]
            default:
                break
            }
            tmpData.append(sourceJson)
        }
        
        return tmpData
//            do {
//                var sourceJson = [String:Any]()
//                var daydata = [Any]()
//
//                if source["source"] as! String == "GaugeStatistics"
//                {
//                    // day data
//                    var datalist = CCoreDataOperate.entitleGet(name: "Gauge",predicate: predicate,sortdesc: sortdec)
//                    var valleyPower:Int = 0
//                    var smoothPower:Int = 0
//                    var sharpPower:Int = 0
//                    var peakPower:Int = 0
//
//                    for i in 0..<datalist.count
//                    {
//                        if i < 48  // 7 clock valley power
//                        {
//                            valleyPower += datalist[i].value(forKey: "value01") as! Int
//                            valleyPower += datalist[i].value(forKey: "value02") as! Int
//                            valleyPower += datalist[i].value(forKey: "value03") as! Int
//                            valleyPower += datalist[i].value(forKey: "value04") as! Int
//                            valleyPower += datalist[i].value(forKey: "value05") as! Int
//                            valleyPower += datalist[i].value(forKey: "value06") as! Int
//                            valleyPower += datalist[i].value(forKey: "value07") as! Int
//                            valleyPower += datalist[i].value(forKey: "value08") as! Int
//                            valleyPower += datalist[i].value(forKey: "value09") as! Int
//                            valleyPower += datalist[i].value(forKey: "value10") as! Int
//                        }
//                        else if i < 132
//                        {
//                            peakPower += datalist[i].value(forKey: "value01") as! Int
//                            peakPower += datalist[i].value(forKey: "value02") as! Int
//                            peakPower += datalist[i].value(forKey: "value03") as! Int
//                            peakPower += datalist[i].value(forKey: "value04") as! Int
//                            peakPower += datalist[i].value(forKey: "value05") as! Int
//                            peakPower += datalist[i].value(forKey: "value06") as! Int
//                            peakPower += datalist[i].value(forKey: "value07") as! Int
//                            peakPower += datalist[i].value(forKey: "value08") as! Int
//                            peakPower += datalist[i].value(forKey: "value09") as! Int
//                            peakPower += datalist[i].value(forKey: "value10") as! Int
//                        }
//                        else if i < 144
//                        {
//                            valleyPower += datalist[i].value(forKey: "value01") as! Int
//                            valleyPower += datalist[i].value(forKey: "value02") as! Int
//                            valleyPower += datalist[i].value(forKey: "value03") as! Int
//                            valleyPower += datalist[i].value(forKey: "value04") as! Int
//                            valleyPower += datalist[i].value(forKey: "value05") as! Int
//                            valleyPower += datalist[i].value(forKey: "value06") as! Int
//                            valleyPower += datalist[i].value(forKey: "value07") as! Int
//                            valleyPower += datalist[i].value(forKey: "value08") as! Int
//                            valleyPower += datalist[i].value(forKey: "value09") as! Int
//                            valleyPower += datalist[i].value(forKey: "value10") as! Int
//                        }
//                    }
//
//                    daydata.append(["name":"尖时电量","y":sharpPower])
//                    daydata.append(["name":"峰时电量",
//                                    "y":peakPower])
//                    daydata.append(["name":"平时电量",
//                                    "y":smoothPower])
//                    daydata.append(["name":"谷时电量",
//                                    "y":valleyPower,
//                                    "sliced":true,
//                                    "selected":true])
//
//                    sourceJson["day"] = daydata
//
//                    // month data
//                    daydata.removeAll()
//                    predicate = NSPredicate(format: "%K = %@ and %K >= %@", argumentArray: ["code",CCommonFunc.getDevieceSerial(),"date","\(monthZeroStamp)"])
//                    datalist = CCoreDataOperate.entitleGet(name: "GaugeDay",predicate: predicate,sortdesc: sortdec)
//                    for _ in 0..<datalist.count
//                    {
//                        valleyPower += datalist[i].value(forKey: "value01") as! Int
//                        smoothPower += datalist[i].value(forKey: "value02") as! Int
//                        peakPower += datalist[i].value(forKey: "value03") as! Int
//                        sharpPower += datalist[i].value(forKey: "value04") as! Int
//                    }
//                    daydata.append(["name":"尖时电量","y":sharpPower])
//                    daydata.append(["name":"峰时电量",
//                                    "y":peakPower])
//                    daydata.append(["name":"平时电量",
//                                    "y":smoothPower])
//                    daydata.append(["name":"谷时电量",
//                                    "y":valleyPower,
//                                    "sliced":true,
//                                    "selected":true])
//
//                    sourceJson["month"] = daydata
//
//                    // year data
//                    //daydata.removeAll()
//
//                }
//                else
//                {
//                    let datalist = CCoreDataOperate.entitleGet(name: source["source"] as! String,predicate: predicate,sortdesc: sortdec)
//                    /*if let sourceName = source["source"] as? String,
//                     let sourcePath = Bundle.main.path(forResource: sourceName, ofType: "json"),
//                     let sourceData = try? Data(contentsOf: URL(fileURLWithPath: sourcePath)),
//                     let sourceJson = try JSONSerialization.jsonObject(with: sourceData) as? [String: Any]*/
//                    // first blank fill zero
//                    if let firstStamp = datalist.first
//                    {
//                        print("first record:\r\n",firstStamp.value(forKey: "date") as! Int)
//                        let blankCount = (firstStamp.value(forKey: "date") as! Int - nowZeroStamp) / 3600
//                        for _ in 0..<blankCount
//                        {
//                            daydata.append(0)
//                        }
//                    }
//
//                    // middle fill value
//                    i=0
//                    for item in datalist
//                    {
//                        // firstStamp.value(forKey: "date") as! Int
//                        if i%6 == 0
//                        {
//                            daydata.append(item.value(forKey: "value01") as! Int)
//                        }
//                        //print("data time stamp info:\r\n",item.value(forKey: "date") as! Int)
//                        i += 1
//                    }
//
//                    // tail fill zero
//                    for _ in daydata.count..<25
//                    {
//                        daydata.append(0)
//                    }
//
//                    sourceJson["day"] = daydata
//                    print("daydata \(String(describing: source["source"]))\r\n",daydata)
//
//                    //switch(source["source"] as! String == "GaugeStatistics")
//                }
//
//                tmpData.append(sourceJson)
//                gCurveData[source["source"] as! String] = sourceJson
//
//            } /*catch {
//                print("Error deserializing JSON: \(error)")
//            }*/
//        }
    }
    
    // day data statistics handle,after repair data
    static func dayDataStatistics()
    {
        // GaugeDay  86400
        let nowDate = NSDate()
        let nowZero = nowDate.getDateZero()  //
        var nowZeroStamp = Int(nowZero.timeIntervalSince1970) - 86400  // previous
        
        var valleyPower:Int = 0
        var smoothPower:Int = 0
        var sharpPower:Int = 0
        var peakPower:Int = 0
        var allPower:Int = 0
        var insertValue = [String:String]()
        var predicate = NSPredicate()
        var datalist = [NSManagedObject]()
        
        // energe statistics loop handle
        while(true)
        {
            predicate = NSPredicate(format: "%K = %@ and %K = %@", argumentArray: ["code",CCommonFunc.getDevieceSerial(),"date","\(nowZeroStamp)"])
            
            //let sortdec = NSSortDescriptor(key: "date", ascending: true)
            //datalist = CCoreDataOperate.entitleGet(name: "GaugeDay",predicate: predicate,sortdesc: nil)
            
            // if exist data,func return
            if datalist.count > 0
            {
                return
            }
            
            // get from database
            predicate = NSPredicate(format: "%K = %@ and %K >= %@ and %K < %@", argumentArray: ["code",CCommonFunc.getDevieceSerial(),"date","\(nowZeroStamp)","date","\(nowZeroStamp+86400)"])
            let sortdec = NSSortDescriptor(key: "date", ascending: true)
            //datalist = CCoreDataOperate.entitleGet(name: "Gauge",predicate: predicate,sortdesc: sortdec)
            
            // if not exist data,func return
            if datalist.count == 0
            {
                return
                }
            
            for i in 0..<datalist.count
            {
                if i < 48  // 7 clock valley power
                {
                    valleyPower += datalist[i].value(forKey: "value01") as! Int
                    valleyPower += datalist[i].value(forKey: "value02") as! Int
                    valleyPower += datalist[i].value(forKey: "value03") as! Int
                    valleyPower += datalist[i].value(forKey: "value04") as! Int
                    valleyPower += datalist[i].value(forKey: "value05") as! Int
                    valleyPower += datalist[i].value(forKey: "value06") as! Int
                    valleyPower += datalist[i].value(forKey: "value07") as! Int
                    valleyPower += datalist[i].value(forKey: "value08") as! Int
                    valleyPower += datalist[i].value(forKey: "value09") as! Int
                    valleyPower += datalist[i].value(forKey: "value10") as! Int
                }
                else if i < 132
                {
                    peakPower += datalist[i].value(forKey: "value01") as! Int
                    peakPower += datalist[i].value(forKey: "value02") as! Int
                    peakPower += datalist[i].value(forKey: "value03") as! Int
                    peakPower += datalist[i].value(forKey: "value04") as! Int
                    peakPower += datalist[i].value(forKey: "value05") as! Int
                    peakPower += datalist[i].value(forKey: "value06") as! Int
                    peakPower += datalist[i].value(forKey: "value07") as! Int
                    peakPower += datalist[i].value(forKey: "value08") as! Int
                    peakPower += datalist[i].value(forKey: "value09") as! Int
                    peakPower += datalist[i].value(forKey: "value10") as! Int
                }
                else if i < 144
                {
                    valleyPower += datalist[i].value(forKey: "value01") as! Int
                    valleyPower += datalist[i].value(forKey: "value02") as! Int
                    valleyPower += datalist[i].value(forKey: "value03") as! Int
                    valleyPower += datalist[i].value(forKey: "value04") as! Int
                    valleyPower += datalist[i].value(forKey: "value05") as! Int
                    valleyPower += datalist[i].value(forKey: "value06") as! Int
                    valleyPower += datalist[i].value(forKey: "value07") as! Int
                    valleyPower += datalist[i].value(forKey: "value08") as! Int
                    valleyPower += datalist[i].value(forKey: "value09") as! Int
                    valleyPower += datalist[i].value(forKey: "value10") as! Int
                }
            }
            
            allPower = valleyPower+smoothPower+peakPower+sharpPower
            insertValue["serial"] = "\(String(describing: gConfigData[1]["序列号"]))"
            insertValue["datetime"] = String(nowZeroStamp)
            insertValue["GaugeDay"] = "\(valleyPower),\(smoothPower),\(peakPower),\(sharpPower),\(allPower)"
            
            //CCoreDataOperate.insertData(text: "GaugeDay", values: insertValue)
            
            // max power of day
            predicate = NSPredicate(format: "%K = %@ and %K = %@", argumentArray: ["code",CCommonFunc.getDevieceSerial(),"date","\(nowZeroStamp)"])
            
            //let sortdec = NSSortDescriptor(key: "date", ascending: true)
            //datalist = CCoreDataOperate.entitleGet(name: "PowerMonth",predicate: predicate,sortdesc: nil)
            
            // if exist data,func return
            if datalist.count > 0
            {
                return
            }
            
            //
            predicate = NSPredicate(format: "%K = %@ and %K >= %@ and %K < %@", argumentArray: ["code",CCommonFunc.getDevieceSerial(),"date","\(nowZeroStamp)","date","\(nowZeroStamp+86400)"])
            //datalist = CCoreDataOperate.entitleGet(name: "ActivePower",predicate: predicate,sortdesc: sortdec)
            var dayMaxPower:Int = 0
            for element in datalist
            {
                for i in 1...9
                {
                    if element.value(forKey: "value0"+"\(i)") as! Int > dayMaxPower
                    {
                        dayMaxPower = element.value(forKey: "value0"+"\(i)") as! Int
                    }
                }
                if element.value(forKey: "value10") as! Int > dayMaxPower
                {
                    dayMaxPower = element.value(forKey: "value10") as! Int
                }
            }
            
            insertValue["serial"] = "\(String(describing: gConfigData[1]["序列号"]))"
            insertValue["datetime"] = String(nowZeroStamp)
            insertValue["PowerMonth"] = "\(dayMaxPower),0"//,\(peakPower),\(sharpPower),\(allPower)"
            
            //CCoreDataOperate.insertData(text: "PowerMonth", values: insertValue)
            
            // voltage is right percent
            predicate = NSPredicate(format: "%K = %@ and %K = %@", argumentArray: ["code",CCommonFunc.getDevieceSerial(),"date","\(nowZeroStamp)"])
            
            //let sortdec = NSSortDescriptor(key: "date", ascending: true)
            //datalist = CCoreDataOperate.entitleGet(name: "VoltageMonth",predicate: predicate,sortdesc: nil)
            
            // if exist data,func return
            if datalist.count > 0
            {
                return
            }
            
            //
            predicate = NSPredicate(format: "%K = %@ and %K >= %@ and %K < %@", argumentArray: ["code",CCommonFunc.getDevieceSerial(),"date","\(nowZeroStamp)","date","\(nowZeroStamp+86400)"])
            //datalist = CCoreDataOperate.entitleGet(name: "Voltage",predicate: predicate,sortdesc: sortdec)
            var dayVoltagePercent:Int = 0
            for element in datalist
            {
                for i in 1...9
                {
                    if (element.value(forKey: "value0"+"\(i)") as! Int > 2090) && ((element.value(forKey: "value0"+"\(i)") as! Int) < 2310)
                    {
                        dayVoltagePercent = dayVoltagePercent+1//element.value(forKey: "value0"+"\(i)") as! Int
                    }
                }
                
                if (element.value(forKey: "value10") as! Int > 2090) && ((element.value(forKey: "value10") as! Int) < 2310)
                {
                    dayVoltagePercent = dayVoltagePercent+1
                }
            }
            
            let voltagePercent = dayVoltagePercent * 1000 / 1440
            
            insertValue["serial"] = "\(String(describing: gConfigData[1]["序列号"]))"
            insertValue["datetime"] = String(nowZeroStamp)
            insertValue["VoltageMonth"] = "\(voltagePercent)"
            
            //CCoreDataOperate.insertData()
            
            nowZeroStamp = nowZeroStamp - 86400
        }
    }
    
    static func monthDataStatistics()
    {
        
    }
}
///
struct SPowerInfo {
    var code:String
    var date:Int
    var values:[Int]
}

// coredata operations
// include:entitleGet/insertData/queryData
class CCoreDataOperate: NSObject {
    //let tableName:String
    let energyData:CCoreDataItem
    
    init(_ data:CCoreDataItem) {
        
        energyData = data
        //tableName = energyData.name
        super.init()
    }
    
    // 获取实例信息
    private func entitleGet(name:String) -> [NSManagedObject] {
        return entitleGet(name:energyData.name,predicate:nil,sortdesc:nil)
    }
    
    func entitleGet(name:String,predicate:NSPredicate?,sortdesc:NSSortDescriptor?)-> [NSManagedObject]
    {
        objc_sync_enter(UIApplication.shared.delegate as! AppDelegate)
        // 步骤一：获取总代理和托管对象总管
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObectContext = appDelegate.persistentContainer.viewContext
        
        // 步骤二：建立一个获取的请求
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
        
        if predicate != nil
        {
            //fetchRequest.
            fetchRequest.predicate = predicate
        }
        
        if sortdesc != nil
        {
            fetchRequest.sortDescriptors = [NSSortDescriptor]()
            fetchRequest.sortDescriptors?.append(sortdesc!)
        }
        
        // 步骤三：执行请求
        do {
            let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
            objc_sync_exit(UIApplication.shared.delegate as! AppDelegate)
            if let results = fetchedResults {
                return results
            }
            
        } catch  {
            objc_sync_exit(UIApplication.shared.delegate as! AppDelegate)
            fatalError("获取失败")
        }
        
        return []
    }
    
    // query data operation
    func queryData(queryDescribe:String,queryValue:[Any],sortKey:String,sortAscending:Bool)->[NSManagedObject]?
    {
        var dataLists = [NSManagedObject]()
        
        dataLists = entitleGet(name:energyData.name,predicate:NSPredicate(format:queryDescribe, argumentArray: queryValue),sortdesc:NSSortDescriptor(key: sortKey, ascending: sortAscending))
        
        //执行查询操作
        return dataLists
    }
    
    func saveTableItemData(_ delegate:AppDelegate,_ context:NSManagedObjectContext,_ entity:NSEntityDescription) {
        
    }
    
    // save data
    final func insertData() {  //values:[String:String]
        DispatchQueue.main.async {
        //objc_sync_enter(UIApplication.shared.delegate as! AppDelegate)  system syn
        // 步骤一：获取总代理和托管对象总管
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let managedObectContext = appDelegate.persistentContainer.viewContext
        
        // 步骤二：建立一个entity
        let entity = NSEntityDescription.entity(forEntityName: self.energyData.name, in: managedObectContext)
            
        // 步骤三：保存数值到实体
        self.saveTableItemData(appDelegate,managedObectContext,entity!)
            
//        let item = NSManagedObject(entity: entity!, insertInto: managedObectContext)
//
//        let subvalues = values[text]?.split(separator: ",")
//
//        // 步骤三：保存文本框中的值到实体
//        item.setValue(values["serial"], forKey: "code")
//
//        let insertDatetime = Int(values["datetime"]!)
//        item.setValue(insertDatetime, forKey: "date")
//
//        for i in 0..<subvalues!.count
//        {
//            item.setValue(Int(subvalues![i]), forKey: "value" + ((i>=9) ? "\(i+1)":"0\(i+1)"))
//        }
//        let subvalues = values[tableName]?.split(separator: ",")
//        let insertDatetime = Int(values["datetime"]!)
//        let intervaltime = Int(values["intervaltime"]!)
//
//        for i in 0..<subvalues!.count
//        {
//            let item = NSManagedObject(entity: entity!, insertInto: managedObectContext)
//
//            //insertDatetime = insertDatetime! + intervaltime!*i*60
//            //item.setValue(Int(subvalues![i]), forKey: "value" + ((i>=9) ? "\(i+1)":"0\(i+1)"))
//            item.setValue(values["serial"], forKey: "code")
//            item.setValue(insertDatetime! + intervaltime!*i*60, forKey: "date")
//            item.setValue(Int(subvalues![i]), forKey: "value01")
//            appDelegate.saveContext()
//        }
            
        
        //appDelegate.saveContext()
            
        //let insertDatetime = Int(input!["datetime"] as! String)
        

        // 步骤五：保存到数组中，更新UI
        // getentitle.append(item)
        // let getitem = getentitle[getentitle.count-1]
        // print(item.value(forKey: "value02") ?? 0)
        // getentitle.
            
        //objc_sync_exit(UIApplication.shared.delegate as! AppDelegate)
        }
    }
    
    static func deleteData(name:String,predicate:NSPredicate?) -> Void {
        DispatchQueue.main.async {

            // 步骤一：获取总代理和托管对象总管
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedObectContext = appDelegate.persistentContainer.viewContext
            
            // 步骤二：建立一个获取的请求
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
            
            
            if predicate != nil
            {
                fetchRequest.predicate = predicate
            }
            
            // 步骤三：执行请求
            do {
                if let fetchedResults = try managedObectContext.fetch(fetchRequest) as? [NSManagedObject]
                {
                    for obj in fetchedResults
                    {
                        managedObectContext.delete(obj)
                    }
                }
            } catch  {
                fatalError("获取失败")
            }
            
            appDelegate.saveContext()
        }
    }
}

// client socket class
class CTCPClient: NSObject,GCDAsyncSocketDelegate {
    var mhost:String?
    var mport:Int=9000
    var mclientSocket:GCDAsyncSocket!
    var mDataHandle:DataHandleDelegate?
    var mAlarmHandle:NotifyHandleDelegate?
    var msocketStatus:SocketStatus = .idle
    //var mflagHandle:Bool = false
    
    // init by host and port
    init(host:String,port:Int,dataHandle:DataHandleDelegate,notifyHandle:NotifyHandleDelegate?) {
        super.init()
        mhost = host
        mport = port
        mDataHandle = dataHandle
        mAlarmHandle = notifyHandle
        mclientSocket = GCDAsyncSocket()
    }
    
    convenience init(dataHandle:DataHandleDelegate,notifyHandle:NotifyHandleDelegate?) {
        self.init(host: "192.168.1.101", port: 9000, dataHandle: dataHandle, notifyHandle: notifyHandle)
    }
    
    // connect to host
    func connect() -> Void {
        if self.mhost == nil
        {
            return
        }
        
        //mclientSocket.disconnect()
        
        mclientSocket.delegate = self
        mclientSocket.delegateQueue = DispatchQueue.global()
        do {
            try mclientSocket.connect(toHost: self.mhost!, onPort: UInt16(self.mport), withTimeout: 3)//mclientSocket.connect(toHost:mhost!, onPort: UInt16(mport))
            
        } catch {
            print("try connect error: \(error)")
            return
        }
        
        msocketStatus = .connectting
    }
    // transform host and post connect
    func connect(host:String,port:Int) -> Void {
        mhost=host
        mport=port
        self.connect()
    }
    
    //
    func close()
    {
        mclientSocket.disconnect()
    }
    
    func send(content:Data,len:Int) -> Bool {
        if msocketStatus != .connected
        {
            return false
        }
        
        mclientSocket.write(content, withTimeout: -1, tag: 0)
        //mflagHandle = true
        return true
    }
    
    // connected to host handle
    func socket(_ sock: GCDAsyncSocket, didConnectToHost host: String, port: UInt16) {
        //self.mAlarmHandle?.alert(msg:"connect success",after:{})
        print("connect success")
        msocketStatus = .connected
        mclientSocket.readData(withTimeout: -1, tag: 0)
    }
    
    // connect is break
    func socketDidDisconnect(_ sock: GCDAsyncSocket, withError err: Error?) {
        //self.mAlarmHandle?.alert(msg:"disconnect socket",after:{})
        print("connect error: \(String(describing: err))")
        
        msocketStatus = .disconnected
    }
    
    func socket(_ sock: GCDAsyncSocket, didRead data: Data, withTag tag: Int) {
        // 1、获取客户端发来的数据，把 NSData 转 NSString
        let msgi = try? JSONSerialization.jsonObject(with: data,options: .mutableContainers) as! [String:Any]
        
        print("---Data Recv---")
        print(msgi.debugDescription)
        
        // 2、主界面UI显示数据 or datahandledeletgate
        self.mDataHandle?.decode(input: msgi, output: [])
        
        // mflagHandle = false
        // msocketStatus = .datareaded
        // 3、处理请求，返回数据给客户端OK
        /*let serviceStr: NSMutableString = NSMutableString()
        if !send(content: serviceStr.data(using: String.Encoding.utf8.rawValue)!, len: 0)
        {
            print("data send fail...")
        }*/
        // 4、每次读完数据后，都要调用一次监听数据的方法
        mclientSocket.readData(withTimeout: -1, tag: 0)
    }
    
    /*
     unsigned char * getdefaultgateway(in_addr_t * addr)
     {
     unsigned char * octet=malloc(4);
     #if 0
     /* net.route.0.inet.dump.0.0 ? */
     int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET,
     NET_RT_DUMP, 0, 0/*tableid*/};
     #endif
     /* net.route.0.inet.flags.gateway */
     int mib[] = {CTL_NET, PF_ROUTE, 0, AF_INET,
     NET_RT_FLAGS, RTF_GATEWAY};
     size_t l;
     char * buf, * p;
     struct rt_msghdr * rt;
     struct sockaddr * sa;
     struct sockaddr * sa_tab[RTAX_MAX];
     int i;
     if(sysctl(mib, sizeof(mib)/sizeof(int), 0, &l, 0, 0) < 0) {
     return octet;
     }
     if(l>0) {
     buf = malloc(l);
     if(sysctl(mib, sizeof(mib)/sizeof(int), buf, &l, 0, 0) < 0) {
     return octet;
     }
     for(p=buf; p<buf+l; p+=rt->rtm_msglen) {
     rt = (struct rt_msghdr *)p;
     sa = (struct sockaddr *)(rt + 1);
     for(i=0; i<RTAX_MAX; i++) {
     if(rt->rtm_addrs & (1 << i)) {
     sa_tab[i] = sa;
     sa = (struct sockaddr *)((char *)sa + ROUNDUP(sa->sa_len));
     } else {
     sa_tab[i] = NULL;
     }
     }
     
     if( ((rt->rtm_addrs & (RTA_DST|RTA_GATEWAY)) == (RTA_DST|RTA_GATEWAY))
     && sa_tab[RTAX_DST]->sa_family == AF_INET
     && sa_tab[RTAX_GATEWAY]->sa_family == AF_INET) {
     
     
     for (int i=0; i<4; i++){
     octet[i] = ( ((struct sockaddr_in *)(sa_tab[RTAX_GATEWAY]))->sin_addr.s_addr >> (i*8) ) & 0xFF;
     }
     
     }
     }
     free(buf);
     }
     return octet;
     }*/
}
