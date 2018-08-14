//  CWifiMeter.swift
//  HomePower
//
//  Created by triumph_sha on 2018/5/13.
//  Copyright © 2018年 triumph_sha. All rights reserved.
//

import Foundation
import CoreData

/// power data type
enum PowerDataType{
    case currentType
    case voltageType
    case activepowerType
    case reactivepowerType
    case freqType
    case factorType
    case gaugeType
    case gaugestatisticsType
    case volstatisticsType
    case powerstatisticsType
}

//struct MeterDoc {
//    var mserial:String
//    var mserverIP:String
//    var mserverPort:Int
//
//    init(serial:String,ip:String,port:Int) {
//        mserial = serial
//        mserverIP = ip
//        mserverPort = port
//    }
//
//    static func != (left:MeterDoc,right:MeterDoc) -> Bool {
//        if left.mserial == right.mserial && left.mserverIP == right.mserverIP
//        {
//            return true
//        }
//        return false
//    }
//}

/// protocol database operate strategy model
class NormalEnergyOperate : CCoreDataOperate {
    //override var energyData:NormalEnergyData
    override func saveTableItemData(_ delegate:AppDelegate,_ context:NSManagedObjectContext,_ entity:NSEntityDescription){
        let item = NSManagedObject(entity: entity, insertInto: context)
        let normalEnergyData = self.energyData as! NormalEnergyData
        item.setValue(normalEnergyData.code, forKey: "code")
        item.setValue(normalEnergyData.date, forKey: "date")
        item.setValue(normalEnergyData.atpower, forKey: "atpower")
        item.setValue(normalEnergyData.rtpower, forKey: "rtpower")
        item.setValue(normalEnergyData.energy, forKey: "energy")
        item.setValue(normalEnergyData.voltage, forKey: "voltage")
        item.setValue(normalEnergyData.current, forKey: "current")
        item.setValue(normalEnergyData.freq, forKey: "freq")
        
        delegate.saveContext()
    }
}
/// protocol coredata item
protocol CCoreDataItem {
    var name:String {get set}
}

/// voltage struct for table data
struct NormalEnergyData:CCoreDataItem {
    var name:String
    var code:String
    var date:Int
    var energy:Int
    var atpower:Int
    var rtpower:Int
    var voltage:Int
    var current:Int
    var freq:Int
    
    init(_ name:String,_ code:String,_ date:Int,_ energy:Int,_ atpower:Int,_ rtpower:Int,_ voltage:Int,_ current:Int,_ freq:Int) {
        self.name = name
        self.code = code
        self.date = date
        self.energy = energy
        self.atpower = atpower
        self.rtpower = rtpower
        self.voltage = voltage
        self.current = current
        self.freq = freq
    }
}
/// enum protocol type
enum EnumProtocolType {
    case MODBUS
    case GBW3761
    case IEC101
    case IEC104
    case JSON
}
/// class wifi meter
public class CWifiMeter: NSObject {
    // meter id
    var ID:Int
    
    // meter serial
    var Serial:String
    
    // meter belong to comm num
    // willSet 在新的值被设置之前调用
    // didSet 在新的值被设置之后立即调用
    // var BelongComms:[Int]
    // {
    //        willSet{
    //
    //        }
    //        didSet{
    //
    //        }
    // }
    var TCPClientConfig:[String:String]?
    
    // meter protocol type
    var ProtocolType:EnumProtocolType
    
    // meter doc
    // var mDoc:MeterDoc
    // communication change to protocol at future
    // var mCommTypes:[EnumCommType]
    // observer pattern:communication status change notify
    // let mnotifyHandle:[NotifyHandleDelegate]?
    
    // supplement stamp
    private var msupplementStamp:Int = 0
    
    // construction
    init(meter_id:Int,meter_serial:String) {  //,notifyHandle:NotifyHandleDelegate,commdataHandle:DataHandleDelegate
        
        ID = meter_id
        Serial = meter_serial
        //BelongComms = [Int]()
        ProtocolType = .JSON
        
        super.init()
        //mDoc = meterDoc
        //mnotifyHandle = notifyHandle
        //mtcpClient = CTCPClient(dataHandle:commdataHandle,notifyHandle:nil)
    }

//    static func get_meter_tcp_client_config(meterid:Int) -> [String:String]
//    {
//
//        for i in 0...gArrayMeter.count
//        {
//            if gArrayMeter[i].ID == meterid{
//                return gArrayMeter[i].TCPClientConfig!
//            }
//        }
//        return ["":""]
//    }
}
/// Meter data handle
class MeterDataHandle
{
    /// want handle meter
    var meter_handle:CWifiMeter
    
    /// laster data time
    var laster_data_time:u_long
    
    ///
    var coredata_operate:CCoreDataOperate
    
    /// init construction
    init(meter:CWifiMeter,item:CCoreDataItem) {
        meter_handle = meter
        coredata_operate = CCoreDataOperate(item)
        laster_data_time = getLasterDataTime()
    }
    
    ///
    func getLasterDataTime() -> u_long {
        let querydata = coredata_operate.queryData(queryDescribe: <#T##String#>, queryValue: <#T##[Any]#>, sortKey: <#T##String#>, sortAscending: <#T##Bool#>)
        
        // conditions: ["code":meter_handle.Serial,"sortkey":"date"]
        return 0
    }
    /// get realtime data,include laster 60 minute data
    func getRealTimeData(){
        
    }
    /// get history data
    func getHistoryData()
    {
        // msupplementStamp = CCommonFunc.getStartStamp(serial: self.Serial)
        
    }
    ///
    func setWifiInfo(commStr:String)
    {
        
    }
    
    ///
    func calcBillingEnengy(_ billingDay:Int)
    {
        // prepare billing day info
        let nowDate = NSDate()
        var tempValue = 0
        //let billingDay = CCommonFunc.getConfigValuesByKey(parent: "数据信息", sub: "结算日") as! Int
        tempValue = Int(nowDate.getMonthSpecificDay(billingDay).timeIntervalSince1970)
        let savebillingStamp = tempValue - (tempValue % 86400)
        
        var valleyPower:Int = 0
        var smoothPower:Int = 0
        var sharpPower:Int = 0
        var peakPower:Int = 0
        var allPower:Int = 0
        
        var predicate = NSPredicate()
        //        predicate = NSPredicate(format: "%K = %@ and %K = %@", argumentArray: ["code",self.mDoc.mserial,"date","\(savebillingStamp)"])
        //        //let sortdec = NSSortDescriptor(key: "date", ascending: true)
        //        var datalist = CCoreDataOperate.entitleGet(name: "GaugeMonth",predicate: predicate,sortdesc: nil)
        //        if datalist.count>0{
        //            valleyPower = datalist[0].value(forKey: "value01") as! Int
        //            smoothPower = datalist[0].value(forKey: "value02") as! Int
        //            peakPower = datalist[0].value(forKey: "value03") as! Int
        //            sharpPower = datalist[0].value(forKey: "value04") as! Int
        //            allPower = datalist[0].value(forKey: "value05") as! Int
        //        }
        //        else{
        //            return
        //        }
        //
        //        tempValue = Int(nowDate.getLastDate().getMonthSpecificDay(billingDay).timeIntervalSince1970)
        //        let lastbillingStamp = tempValue - (tempValue % 86400)
        //        //predicate = NSPredicate(format: "%K = %@ and %K = %@", argumentArray: ["code",self.mDoc.mserial,"date","\(lastbillingStamp)"])
        //        datalist = CCoreDataOperate.entitleGet(name: "GaugeMonth",predicate: predicate,sortdesc: nil)
        //        if datalist.count>0{
        //            valleyPower -= datalist[0].value(forKey: "value01") as! Int
        //            smoothPower -= datalist[0].value(forKey: "value02") as! Int
        //            peakPower -= datalist[0].value(forKey: "value03") as! Int
        //            sharpPower -= datalist[0].value(forKey: "value04") as! Int
        //            allPower -= datalist[0].value(forKey: "value05") as! Int
        //        }
        //
        //        var insertValue = [String:String]()
        //        //insertValue["serial"] = self.mDoc.mserial
        //        insertValue["datetime"] = String(savebillingStamp)
        //        insertValue["GaugeBilling"] = "\(valleyPower),\(smoothPower),\(peakPower),\(sharpPower),\(allPower)"
        
        //CCoreDataOperate.insertData(text: "GaugeBilling", values: insertValue)
    }
    
    /// current year statistics:
    /// include
    func getCurrentYearData() -> Int {
        let getStartStamp = Int(NSDate().getYearFirstDay().getDateZero().timeIntervalSince1970) + 28800
        var getEndStamp = Int(NSDate().timeIntervalSince1970) + 28800
        getEndStamp = getEndStamp - getEndStamp%3600
        
        //var predicate = NSPredicate(format: "%K = %@ and %K >= %@", argumentArray: ["code",self.mDoc.mserial,"date","\(getStartStamp)"])
        //        let sortdec = NSSortDescriptor(key: "date", ascending: true)
        //        var datalist = CCoreDataOperate.entitleGet(name: "Gauge",predicate: predicate,sortdesc: sortdec)
        //
        //        let initGauge = datalist[0].value(forKey: "value01") as! Int
        //
        //        predicate = NSPredicate(format: "%K = %@ and %K >= %@", argumentArray: ["code",self.mDoc.mserial,"date","\(getEndStamp)"])
        //        //let sortdec = NSSortDescriptor(key: "date", ascending: true)
        //        datalist = CCoreDataOperate.entitleGet(name: "Gauge",predicate: predicate,sortdesc: sortdec)
        //        let lastGauge = datalist[0].value(forKey: "value01") as! Int
        //
        //        return lastGauge - initGauge
        return 0
    }
    
    /// current day statistics,furture getway that send get current data command
    private func getCurrentData(_ type:PowerDataType,_ withTime:Bool) ->[Any]?{
        var entityName:String
        let getStartStamp = Int(NSDate().getDateZero().timeIntervalSince1970) + 28800
        let getEndStamp = Int(NSDate().timeIntervalSince1970) + 28800
        
        switch type {
        case .gaugestatisticsType:
            entityName = "Gauge"
        case .gaugeType:
            entityName = "Gauge"
        case .activepowerType:
            entityName = "ActivePower"
        case .voltageType:
            entityName = "Voltage"
        default:
            return nil
        }
        
        
        //        let predicate = NSPredicate(format: "%K = %@ and %K >= %@ and %K <= %@", argumentArray: ["code",self.mDoc.mserial,"date","\(getStartStamp)","date","\(getEndStamp)"])
        //        let sortdec = NSSortDescriptor(key: "date", ascending: true)
        //        let datalist = CCoreDataOperate.entitleGet(name: entityName,predicate: predicate,sortdesc: sortdec)
        //
        //        if datalist.count == 0{
        //            return loadDefaultData(type,withTime ? "all":"day")
        //        }
        //
        //        var gaugeResult = [String:Any]()
        //        var resultValues = [Any]()
        //
        //        // gauge statistics
        //        if type == .gaugestatisticsType{
        //            var valleyPower:Int = 0
        //            var peakPower:Int = 0
        //            if datalist.count > 0 {
        //                if datalist.count < 8 {
        //                    valleyPower += (datalist[datalist.count-1].value(forKey: "value01") as! Int) - (datalist[0].value(forKey: "value01") as! Int)
        //                    peakPower = 0
        //                }
        //                else if datalist.count < 22{
        //                    valleyPower += (datalist[7].value(forKey: "value01") as! Int) - (datalist[0].value(forKey: "value01") as! Int)
        //                    peakPower += (datalist[datalist.count-1].value(forKey: "value01") as! Int) -   (datalist[7].value(forKey: "value01") as! Int)
        //                }
        //                else
        //                {
        //                    valleyPower += (datalist[7].value(forKey: "value01") as! Int) - (datalist[0].value(forKey: "value01") as! Int)
        //                    peakPower += (datalist[22].value(forKey: "value01") as! Int) -   (datalist[7].value(forKey: "value01") as! Int)
        //                    valleyPower += (datalist[datalist.count-1].value(forKey: "value01") as! Int) - (datalist[22].value(forKey: "value01") as! Int)
        //                }
        //            }
        
        //            gaugeResult["name"] = "尖时电量"
        //            gaugeResult["y"] = 0
        //            resultValues.append(gaugeResult)
        //            gaugeResult["name"] = "峰时电量"
        //            gaugeResult["y"] = peakPower
        //            resultValues.append(gaugeResult)
        //            gaugeResult["name"] = "平时电量"
        //            gaugeResult["y"] = 0
        //            resultValues.append(gaugeResult)
        //            gaugeResult["name"] = "谷时电量"
        //            gaugeResult["sliced"] = true
        //            gaugeResult["selected"] = true
        //            gaugeResult["y"] = valleyPower
        //            resultValues.append(gaugeResult)
        //        }
        //        else if type == .gaugeType{
        //            if datalist.count > 1{
        //            for i in 0..<(datalist.count-1)
        //            {
        //                resultValues.append((datalist[i+1].value(forKey: "value01") as! Int) - (datalist[i].value(forKey: "value01") as! Int))
        //            }
        //            }
        //            for _ in resultValues.count..<25
        //            {
        //                resultValues.append(0)
        //            }
        //        }
        //        else{
        //            //for _ in 0...25
        //
        //            for elm in datalist{
        //                resultValues.append(elm.value(forKey: "value01") as! Int)
        //            }
        //
        //            for _ in resultValues.count..<25
        //            {
        //                resultValues.append(0)
        //            }
        //        }
        
        return nil
    }
    
    ///
    private func getCurrentMonthData(_ type:PowerDataType,_ withTime:Bool) ->[Any]?{
        var entityName:String
        let getStartStamp = Int(NSDate().getMonthFirstDay().getDateZero().timeIntervalSince1970) + 28800
        let getEndStamp = Int(NSDate().timeIntervalSince1970) + 28800
        
        switch type {
        case .gaugestatisticsType:
            entityName = "Gauge"
        case .gaugeType:
            entityName = "Gauge"
        case .activepowerType:
            entityName = "StatisticPower"
        case .voltageType:
            entityName = "StatisticVol"
        default:
            return nil
        }
        
        
        //        let predicate = NSPredicate(format: "%K = %@ and %K >= %@ and %K <= %@", argumentArray: ["code",self.mDoc.mserial,"date","\(getStartStamp)","date","\(getEndStamp)"])
        //        let sortdec = NSSortDescriptor(key: "date", ascending: true)
        //        let datalist = CCoreDataOperate.entitleGet(name: entityName,predicate: predicate,sortdesc: sortdec)
        //
        //        var gaugeResult = [String:Any]()
        //        var resultValues = [Any]()
        //
        //        // gauge statistics
        //        if datalist.count > 0
        //        {
        //            if type == .gaugestatisticsType{
        //                var valleyPower:Int = 0
        //                var peakPower:Int = 0
        //                var smoothPower:Int = 0
        //                var sharpPower:Int = 0
        //                for elm in datalist{
        //                    valleyPower += elm.value(forKey: "value01") as! Int
        //                    smoothPower += elm.value(forKey: "value02") as! Int
        //                    peakPower += elm.value(forKey: "value03") as! Int
        //                    sharpPower += elm.value(forKey: "value04") as! Int
        //                }
        //
        //                gaugeResult["name"] = "尖时电量"
        //                gaugeResult["y"] = 0
        //                resultValues.append(gaugeResult)
        //                gaugeResult["name"] = "峰时电量"
        //                gaugeResult["y"] = peakPower
        //                resultValues.append(gaugeResult)
        //                gaugeResult["name"] = "平时电量"
        //                gaugeResult["y"] = 0
        //                resultValues.append(gaugeResult)
        //                gaugeResult["name"] = "谷时电量"
        //                gaugeResult["sliced"] = true
        //                gaugeResult["selected"] = true
        //                gaugeResult["y"] = valleyPower
        //                resultValues.append(gaugeResult)
        //
        //                return resultValues
        //            }
        //            else if type == .gaugeType{
        //                for i in 0..<(datalist.count-1)
        //                {
        //                    resultValues.append((datalist[i+1].value(forKey: "value01") as! Int) - (datalist[i].value(forKey: "value01") as! Int))
        //                }
        //            }
        //            else{
        //                for elm in datalist{
        //                    resultValues.append(elm.value(forKey: "value01") as! Int)
        //                }
        //            }
        //        }
        //
        //        if type == .gaugestatisticsType{
        //
        //            if resultValues.count == 0
        //            {
        //                gaugeResult["name"] = "尖时电量"
        //                gaugeResult["y"] = 0
        //                resultValues.append(gaugeResult)
        //                gaugeResult["name"] = "峰时电量"
        //                gaugeResult["y"] = 50
        //                resultValues.append(gaugeResult)
        //                gaugeResult["name"] = "平时电量"
        //                gaugeResult["y"] = 0
        //                resultValues.append(gaugeResult)
        //                gaugeResult["name"] = "谷时电量"
        //                gaugeResult["sliced"] = true
        //                gaugeResult["selected"] = true
        //                gaugeResult["y"] = 50
        //                resultValues.append(gaugeResult)
        //
        //                return resultValues
        //            }
        //        }
        //
        //
        //        if Array([1,3,5,7,8,10,12]).contains(NSDate().getMonth()){
        //            for _ in resultValues.count..<31
        //            {
        //                resultValues.append(0)
        //            }
        //        }
        //        else
        //        {
        //            for _ in resultValues.count..<30
        //            {
        //                resultValues.append(0)
        //            }
        //        }
        
        
        return nil
    }
    
    /// history day data
    private func dayDataStatistics()
    {
        // GaugeMonth  86400
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
        valleyPower = 0
        smoothPower = 0
        sharpPower = 0
        peakPower = 0
        
        //        predicate = NSPredicate(format: "%K = %@ and %K = %@", argumentArray: ["code",self.mDoc.mserial,"date","\(nowZeroStamp)"])
        //        let sortdec = NSSortDescriptor(key: "date", ascending: true)
        //        datalist = CCoreDataOperate.entitleGet(name: "GaugeMonth",predicate: predicate,sortdesc: nil)
        //
        //        if datalist.count == 0
        //        {
        //            // gauge records
        //            predicate = NSPredicate(format: "%K = %@ and %K >= %@ and %K < %@", argumentArray: ["code",self.mDoc.mserial,"date","\(nowZeroStamp)","date","\(nowZeroStamp+86400)"])
        //            datalist = CCoreDataOperate.entitleGet(name: "Gauge",predicate: predicate,sortdesc: sortdec)
        //
        //            // if not exist data,func return
        //            if datalist.count >= 24
        //            {
        //                // 0~8 clock valley power
        //                valleyPower += datalist[7].value(forKey: "value01") as! Int - (datalist[0].value(forKey: "value01") as! Int)
        //                // 8~22 clock peak power
        //                peakPower += datalist[21].value(forKey: "value01") as! Int - (datalist[7].value(forKey: "value01") as! Int)
        //                // 22~24 clock valley power
        //                valleyPower += datalist[23].value(forKey: "value01") as! Int - (datalist[21].value(forKey: "value01") as! Int)
        //
        //                allPower = valleyPower+smoothPower+peakPower+sharpPower
        //                insertValue["serial"] = self.mDoc.mserial
        //                insertValue["datetime"] = String(nowZeroStamp)
        //                insertValue["GaugeMonth"] = "\(valleyPower),\(smoothPower),\(peakPower),\(sharpPower),\(allPower)"
        //
        //                CCoreDataOperate.insertData(text: "GaugeMonth", values: insertValue)
        //            }
        //        }
        
        // statistics max power
        //        predicate = NSPredicate(format: "%K = %@ and %K = %@", argumentArray: ["code",self.mDoc.mserial,"date","\(nowZeroStamp)"])
        //        datalist = CCoreDataOperate.entitleGet(name: "ActivePower",predicate: predicate,sortdesc: nil)
        //        if datalist.count == 0
        //        {
        //
        //        }
    }
    
    /// history month data
    private func monthDataStatistics()
    {
        // GaugeMonth  86400
        let nowDate = NSDate()
        let nowZero = nowDate.getLastDate().getDateZero()  //
        let nowZeroStamp = Int(nowZero.timeIntervalSince1970)  // previous
        
        let getZero = nowDate.getMonthFirstDay().getDateZero()
        let getZeroStamp = Int(getZero.timeIntervalSince1970)
        
        var valleyPower:Int = 0
        var smoothPower:Int = 0
        var sharpPower:Int = 0
        var peakPower:Int = 0
        var allPower:Int = 0
        var insertValue = [String:String]()
        var predicate = NSPredicate()
        var datalist = [NSManagedObject]()
        
        // energe statistics loop handle
        
        valleyPower = 0
        smoothPower = 0
        sharpPower = 0
        peakPower = 0
        
        //        predicate = NSPredicate(format: "%K = %@ and %K = %@", argumentArray: ["code",self.mDoc.mserial,"date","\(nowZeroStamp)"])
        //        let sortdec = NSSortDescriptor(key: "date", ascending: true)
        //        datalist = CCoreDataOperate.entitleGet(name: "GaugeYear",predicate: predicate,sortdesc: nil)
        //
        //        // if exist data,func return
        //        if datalist.count == 0
        //        {
        //            // gauge records
        //            //predicate = NSPredicate(format: "%K = %@ and %K >= %@ and %K < %@", argumentArray: ["code",self.mDoc.mserial,"date","\(nowZeroStamp)","date","\(getZeroStamp)"])
        ////            datalist = CCoreDataOperate.entitleGet(name: "GaugeMonth",predicate: predicate,sortdesc: sortdec)
        ////
        ////            if datalist.count == 0
        ////            {
        ////                return
        ////            }
        ////            // if not exist data,func return
        ////            for elm in datalist
        ////            {
        ////                valleyPower += elm.value(forKey: "value01") as! Int
        ////                smoothPower += elm.value(forKey: "value02") as! Int
        ////                peakPower += elm.value(forKey: "value03") as! Int
        ////                sharpPower += elm.value(forKey: "value04") as! Int
        ////                allPower += elm.value(forKey: "value05") as! Int
        ////                insertValue["serial"] = self.mDoc.mserial
        ////                insertValue["datetime"] = String(nowZeroStamp)
        ////                insertValue["GaugeYear"] = "\(valleyPower),\(smoothPower),\(peakPower),\(sharpPower),\(allPower)"
        ////
        ////                CCoreDataOperate.insertData(text: "GaugeYear", values: insertValue)
        ////            }
        //        }
    }
    
    /// pass day process
    func passdayProcess()
    {
        let lockData = NSLock()
        lockData.lock()
        getHistoryData()
        lockData.unlock()
        lockData.lock()
        dayDataStatistics()
        lockData.unlock()
    }
    
    /// pass month process
    func passmonthProcess()  {
        let lockData = NSLock()
        
        lockData.lock()
        getHistoryData()
        lockData.unlock()
        
        lockData.lock()
        dayDataStatistics()
        monthDataStatistics()
        lockData.unlock()
    }
    ///
    func loadDefaultData(_ type:PowerDataType,_ date:String) -> [Any]? {
        
        var result = [Any]()
        var sourceName:String
        
        switch type {
        case .activepowerType:
            sourceName = "DataActivePower"
        case .voltageType:
            sourceName = "DataVoltage"
        case .gaugeType:
            sourceName = "DataEnergy"
        case .gaugestatisticsType:
            sourceName = "DataGauge"
        default:
            return nil
        }
        
        do {
            //if let sourceName = self.configuration["source"] as? String
            if let sourcePath = Bundle.main.path(forResource: sourceName, ofType: "json"),
                let sourceData = try? Data(contentsOf: URL(fileURLWithPath: sourcePath)),
                let sourceJson = try JSONSerialization.jsonObject(with: sourceData) as? [String: Any] {
                result = sourceJson[date] as! [Any]
            }
        } catch {
            print("Error deserializing JSON: \(error)")
        }
        
        return result
    }
    
    
    
    /// get day data
    /// include statistic voltage percent of pass
    /// include statistic max power of day
    func getDayData(_ date:NSDate,_ type:PowerDataType,_ withTime:Bool) -> [Any]? {
        var entityName:String
        var getStartStamp:Int
        var getEndStamp:Int
        var resultValues = [Any]()
        var gaugeResult = [String:Any]()
        
        switch type {
        case .activepowerType:
            entityName = "ActivePower"
        case .voltageType:
            entityName = "Voltage"
        case .gaugeType:
            entityName = "Gauge"
        case .gaugestatisticsType:
            entityName = "GaugeDay"
        default:
            return nil
        }
        
        if date.getDay() == NSDate().getDay(){
            return getCurrentData(type,withTime)
        }
        else if date.getDay() >= NSDate().getDay()
        {
            return nil
        }
        else
        {
            getStartStamp = Int(date.getDateZero().timeIntervalSince1970) + 28800
            getEndStamp = getStartStamp + 86400
        }
        
        //        let predicate = NSPredicate(format: "%K = %@ and %K >= %@ and %K <= %@", argumentArray: ["code",self.mDoc.mserial,"date","\(getStartStamp)","date","\(getEndStamp)"])
        //        let sortdec = NSSortDescriptor(key: "date", ascending: true)
        //        let datalist = CCoreDataOperate.entitleGet(name: entityName,predicate: predicate,sortdesc: sortdec)
        //
        //        if datalist.count == 0{
        //            return loadDefaultData(type,"day")
        //        }
        //
        //        if type == .gaugestatisticsType{
        //            for elm in datalist
        //            {
        //                gaugeResult["name"] = "尖时电量"
        //                gaugeResult["y"] = elm.value(forKey: "value04") as! Int
        //                resultValues.append(gaugeResult)
        //                gaugeResult["name"] = "峰时电量"
        //                gaugeResult["y"] = elm.value(forKey: "value03") as! Int
        //                resultValues.append(gaugeResult)
        //                gaugeResult["name"] = "平时电量"
        //                gaugeResult["y"] = elm.value(forKey: "value02") as! Int
        //                resultValues.append(gaugeResult)
        //                gaugeResult["name"] = "谷时电量"
        //                gaugeResult["sliced"] = true
        //                gaugeResult["selected"] = true
        //                gaugeResult["y"] = elm.value(forKey: "value01") as! Int
        //                resultValues.append(gaugeResult)
        //            }
        //        }
        //        else{
        //            for elm in datalist
        //            {
        //                if withTime{
        //                    gaugeResult["sample"] = elm.value(forKey: "value01") as! Int
        //                    gaugeResult["date"] = elm.value(forKey: "date") as! Int
        //                    resultValues.append(gaugeResult)
        //                }
        //                else{
        //                    resultValues.append(elm.value(forKey: "value01") as! Int)
        //                }
        //            }
        //        }
        
        return resultValues
    }
    
    
    // get month data:
    // include statistic voltage percent of pass
    // include statistic max power of month
    func getMonthData(_ date:NSDate,_ type:PowerDataType,_ withTime:Bool) -> [Any]? {
        var entityName:String
        var getStartStamp:Int
        var getEndStamp:Int
        var resultValues = [Any]()
        var gaugeResult = [String:Any]()
        
        switch type {
        case .gaugestatisticsType:
            entityName = "GaugeMonth"
        case .gaugeType:
            entityName = "GaugeDay"
        case .activepowerType:
            entityName = "StatisticPower"
        case .voltageType:
            entityName = "StatisticVol"
        default:
            return nil
        }
        
        if date.getMonth() == NSDate().getMonth(){
            return getCurrentMonthData(type,withTime)
        }
        else if date.getMonth() >= NSDate().getMonth()
        {
            return nil
        }
        else
        {
            getStartStamp = Int(date.getMonthFirstDay().getDateZero().timeIntervalSince1970) + 28800
            getEndStamp = Int(date.getNextDate().getDateZero().timeIntervalSince1970) + 28800
        }
        
        //        let predicate = NSPredicate(format: "%K = %@ and %K >= %@ and %K <= %@", argumentArray: ["code",self.mDoc.mserial,"date","\(getStartStamp)","date","\(getEndStamp)"])
        //        let sortdec = NSSortDescriptor(key: "date", ascending: true)
        //        let datalist = CCoreDataOperate.entitleGet(name: entityName,predicate: predicate,sortdesc: sortdec)
        //
        //        if type == .gaugestatisticsType{
        //            for elm in datalist
        //            {
        //                gaugeResult["name"] = "尖时电量"
        //                gaugeResult["y"] = elm.value(forKey: "value04") as! Int
        //                resultValues.append(gaugeResult)
        //                gaugeResult["name"] = "峰时电量"
        //                gaugeResult["y"] = elm.value(forKey: "value03") as! Int
        //                resultValues.append(gaugeResult)
        //                gaugeResult["name"] = "平时电量"
        //                gaugeResult["y"] = elm.value(forKey: "value02") as! Int
        //                resultValues.append(gaugeResult)
        //                gaugeResult["name"] = "谷时电量"
        //                gaugeResult["sliced"] = true
        //                gaugeResult["selected"] = true
        //                gaugeResult["y"] = elm.value(forKey: "value01") as! Int
        //                resultValues.append(gaugeResult)
        //            }
        //        }
        //        else{
        //            for elm in datalist
        //            {
        //                if withTime{
        //                    gaugeResult["sample"] = elm.value(forKey: "value01") as! Int
        //                    gaugeResult["date"] = elm.value(forKey: "date") as! Int
        //                    resultValues.append(gaugeResult)
        //                }
        //                else{
        //                    resultValues.append(elm.value(forKey: "value01") as! Int)
        //                }
        //            }
        //        }
        
        return resultValues
    }
}

