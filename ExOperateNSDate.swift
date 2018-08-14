//
//  ExOperateNSDate.swift
//  HomePower
//
//  Created by triumph_sha on 2018/4/27.
//  Copyright © 2018年 triumph_sha. All rights reserved.
//

import Foundation

extension NSDate {
    /**
     
     获取这个月有多少天
     
     */
    
    func getMonthHowManyDay() ->Int {
        
        //我们大致可以理解为：某个时间点所在的“小单元”，在“大单元”中的数量
        
        return (NSCalendar.current.range(of: .day, in: .month, for: self as Date)?.count)!
        
    }
    // 获取日期是星期几
    
    func getDateWeekDay() ->Int {
        
        let dateFmt = DateFormatter()
        
        dateFmt.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let interval        = Int(self.timeIntervalSince1970)
        
        let days            = Int(interval/86400)
        
        let weekday         = ((days + 4)%7+7)%7
        
        return weekday
        
    }
    
    /**
     
     *  获取这个月第一天是星期几
     
     */
    
    func getMontFirstWeekDay() ->Int {
        
        //1.Sun. 2.Mon. 3.Thes. 4.Wed. 5.Thur. 6.Fri. 7.Sat.
        
        let calendar = NSCalendar.current
        
        //这里注意 swift要用[,]这样方式写
        
        //let com = calendar.component(.day, from: self as Date)//([.Year,.Month,.Day], fromDate:self)
        
        //设置成第一天
        var dateComponents = DateComponents()
        dateComponents.year = calendar.component(.year, from: self as Date)
        dateComponents.month = calendar.component(.month, from: self as Date)
        dateComponents.day = calendar.component(.day, from: self as Date)
        dateComponents.hour = calendar.component(.hour, from: self as Date)
        dateComponents.minute = calendar.component(.minute, from: self as Date)
        dateComponents.second = calendar.component(.second, from: self as Date)
        
        let date = calendar.date(from: dateComponents)
        
        //我们大致可以理解为：某个时间点所在的“小单元”，在“大单元”中的位置  ordinalityOfUnit
        
        let firstWeekDay = calendar.ordinality(of: .weekday, in: .weekOfMonth, for: date!)
        
        return firstWeekDay! - 1
        
    }
    /**
     
     *  获取当前Day
     
     */
    
    func getDay() ->Int {
        
        let calendar = NSCalendar.current
        
        //这里注意 swift要用[,]这样方式写
        
        let com = calendar.component(.day, from: self as Date)//([.Year,.Month,.Day], fromDate:self)
        
        return com
        
    }
    
    func getHour() ->Int {
        
        let calendar = NSCalendar.current
        
        //这里注意 swift要用[,]这样方式写
        
        let com = calendar.component(.hour, from: self as Date)//([.Year,.Month,.Day], fromDate:self)
        
        return com
        
    }
    
    func getMinute() ->Int {
        
        let calendar = NSCalendar.current
        
        //这里注意 swift要用[,]这样方式写
        
        let com = calendar.component(.minute, from: self as Date)//([.Year,.Month,.Day], fromDate:self)
        
        return com
        
    }
    
    func getSecond() ->Int {
        
        let calendar = NSCalendar.current
        
        //这里注意 swift要用[,]这样方式写
        
        let com = calendar.component(.second, from: self as Date)//([.Year,.Month,.Day], fromDate:self)
        
        return com
        
    }
    
    /**
     
     *  获取当前Month
     
     */
    
    func getMonth() ->Int {
        
        let calendar = NSCalendar.current
        
        //这里注意 swift要用[,]这样方式写
        
        let com = calendar.component(.month, from:self as Date)
        
        return com
        
    }
    
    
    
    /**
     
     *  获取当前Year
     
     */
    
    func getYear() ->Int {
        
        let calendar = NSCalendar.current
        
        //这里注意 swift要用[,]这样方式写
        
        let com = calendar.component(.year, from: self as Date)//.year, from:self as Date)
        
        return com
        
    }
    
    /**
     
     获取指定时间下一个月的时间
     
     */
    
    func getNextDate() ->NSDate {
        
        let calendar = NSCalendar.current
        
        //let com = calendar.component([.Year,.Month,.Day], fromDate:self)
        
        var com = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day]), from: self as Date)
        
        com.month! += 1
        com.day = 1
        
        if com.month == NSDate().getMonth() {
            
            com.day = NSDate().getDay()
            
        }
        
        return calendar.date(from: com)! as NSDate//(com)!
    }
    
    func getMonthFirstDay()->NSDate{
        let calendar = NSCalendar.current
        
        //let com = calendar.component([.Year,.Month,.Day], fromDate:self)
        
        var com = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day]), from: self as Date)
        
        //com.month! += 1
        com.day = 1
        
        return calendar.date(from: com)! as NSDate//(com)!
    }
    
    
    
    func getDateZero() -> NSDate {
        let calendar = NSCalendar.current
        
        //var com = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day,.hour,.minute,.second]), from: self as Date)
        
        var comSelf = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day,.hour,.minute,.second]), from: self as Date)
        
        comSelf.hour! = 0
        comSelf.minute = 0
        comSelf.second = 0
        
        //return calendar.date(from: com)! as NSDate//(com)! calendar.date(from: comSelf)! as NSDate
        return NSDate(timeInterval: 28800, since: calendar.date(from: comSelf)!)
    }
    
    
    func getMonthSpecificDay(_ day:Int) -> NSDate {
        let calendar = NSCalendar.current
        
        var com = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day]), from: self as Date)
        
        com.day = day
        return calendar.date(from: com)! as NSDate
    }
    
    /**
     
     获取指定时间上一个月的时间
     
     */
    
    func getLastDate() ->NSDate {
        
        let calendar = NSCalendar.current
        
        var com = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day]), from: self as Date)//([.Year,.Month,.Day], fromDate:self)
        
        com.month! -= 1
        
        com.day = 1
        
        if com.month == NSDate().getMonth() {
            com.day = NSDate().getDay()
        }
        
        return calendar.date(from: com)! as NSDate
        
    }
    
    
    
    func getYearFirstDay() ->NSDate {
        
        let calendar = NSCalendar.current
        
        var com = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day]), from: self as Date)//([.Year,.Month,.Day], fromDate:self)
        
        com.month = 1
        com.day = 1
        
        return calendar.date(from: com)! as NSDate
        
    }
    
    /**
     
     获取指定时间下一个月的长度
     
     */
    func getNextDateLenght() ->Int {
        
        let date = self.getNextDate()
        
        return date.getMonthHowManyDay()
    }
    
    
    
    /**
     
     获取指定时间上一个月的长度
     
     */
    
    func getLastDateLenght() ->Int {
        
        let date = self.getLastDate()
        
        return date.getMonthHowManyDay()
        
    }
    
    
    
    //当前时间label内容
    
    func getTimeYYYY_MM() ->String {
        
        let day        = getDay()
        
        let month      = getMonth()
        
        let year       = getYear()
        
        let dateString = String("\(year)年\(month)月\(day)日")
        
        return dateString
        
    }
    
    /**
     
     是否是今天
     
     */
    
    func isToday()->Bool {
        
        let calendar = NSCalendar.current
        
        /// 获取self的时间
        
        let comSelf = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day]), from: self as Date)//([.Year,.Month,.Day], fromDate:self)
        
        /// 获取当前的时间
        
        let comNow = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day]), from: self as Date)//([.Year,.Month,.Day], fromDate:NSDate())
        
        return comSelf.year==comNow.year && comSelf.month==comNow.month && comSelf.day==comNow.day
        
    }
    
    
    
    /**
     
     是否是这个月
     
     */
    
    func isEqualMonth(date :NSDate)->Bool {
        
        let calendar = NSCalendar.current
        
        /// 获取self的时间
        
        let comSelf = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day]), from: self as Date)//([.Year,.Month,.Day], fromDate:self)
        
        /// 获取当前的时间
        
        let comNow = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day]), from: self as Date)//([.Year,.Month,.Day], fromDate: date)
        
        return comSelf.year==comNow.year && comSelf.month==comNow.month
        
    }
    
    
    
    /**
     
     是否是这个月
     
     */
    
    func isThisMonth()->Bool {
        
        let calendar = NSCalendar.current
        
        /// 获取self的时间
        
        let comSelf = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day]), from: self as Date)//([.Year,.Month,.Day], fromDate:self)
        
        /// 获取当前的时间
        
        let comNow = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day]), from: self as Date)//([.Year,.Month,.Day], fromDate:NSDate())
        
        return comSelf.year==comNow.year && comSelf.month==comNow.month
        
    }
    
    
    
    /**
     
     分别获取准确的年月日
     
     */
    
    func getDateY_M_D(day :Int)->(year:Int,month:Int,day:Int) {
        
        let calendar = NSCalendar.current
        
        var comSelf = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day]), from: self as Date)//([.Year,.Month,.Day], fromDate:self)
        
        comSelf.day = day
        
        return (comSelf.year!,comSelf.month!,comSelf.day!)
        
    }
    
    
    
    /**
     
     获取指定date
     
     */
    
    func getDate(day :Int)-> NSDate {
        
        let calendar = NSCalendar.current
        
        var comSelf = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day]), from: self as Date)//([.Year,.Month,.Day], fromDate:self)
        
        comSelf.day = day
        
        return calendar.date(from: comSelf)! as NSDate
    }
    
    func  getNextDay() -> NSDate {
        
        //var day = self.getDay()
        //var month = self.getMonth()
        //var year = self.getYear()
        let calendar = NSCalendar.current
        var comSelf = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day]), from: self as Date)//([.Year,.Month,.Day], fromDate:self)
        
        
        comSelf.day = comSelf.day! + 1
        
        let monthDays = self.getMonthHowManyDay()
        
        if comSelf.day! > monthDays
        {
            comSelf.month = comSelf.month! + 1      // next month
            comSelf.day = 1
            
            if comSelf.month! > 12
            {
                comSelf.year = comSelf.year! + 1
                comSelf.month = 1
            }
        }
        
        return calendar.date(from: comSelf)! as NSDate
        
    }
    
    func  getPrevDay() -> NSDate {
        let calendar = NSCalendar.current
        //calendar.timeZone = NSTimeZone(forSecondsFromGMT: 0) as TimeZone
        //let calendar = Calendar( //calendarChina
        //calendar.timeZone.abbreviation().
        var comSelf = calendar.dateComponents(Set<Calendar.Component>([.year,.month,.day,.hour,.minute,.second]), from: self as Date)//([.Year,.Month,.Day], fromDate:self)
        
        comSelf.day = comSelf.day! - 1
        
        if comSelf.day! < 1
        {
            comSelf.month = comSelf.month! - 1      // next month
            comSelf.day = 1 // self.getMonthHowManyDay()
            
            if comSelf.month! < 1
            {
                comSelf.year = comSelf.year! - 1
                comSelf.month = 1
            }
            
            let dateWant = calendar.date(from: comSelf)! as NSDate
            comSelf.day! = dateWant.getMonthHowManyDay()
        }
        
        return NSDate(timeInterval: 28800, since: calendar.date(from: comSelf)!)
        
    }
    
    /**
     
     把当前时间转化为字符串
     
     */
    
    func currentDateIntoString()->String {
        
        let dateFormatter        = DateFormatter()
        
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        
        let timeString           = dateFormatter.string(from: self as Date)
        
        return timeString
        
    }
    
}
