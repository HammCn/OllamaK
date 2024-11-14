//
//  DateTimeUtil.swift
//  OllamaK
//
//  Created by Hamm on 2024/11/14.
//

import Foundation

/*
 日期时间助手
 */
class DateTimeUtil {
    /*
     完整格式
     */
    public static let YYYY_MM_DD_HH_MM_SS = "yyyy-MM-dd HH:mm:ss"

    /*
     时间格式
     */
    public static let HH_MM_SS = "HH:mm:ss"

    /*
     日期格式
     */
    public static let YYYY_MM_DD = "yyyy-MM-dd"

    /*
     年份
     */
    public static let FULL_YEAR = "yyyy"

    /*
     月份
     */
    public static let MONTH = "MM"

    /*
     日期
     */
    public static let DAY = "dd"

    /*
     时
     */
    public static let HOUR = "HH"

    /*
     分
     */
    public static let MINUTE = "mm"

    /*
    秒
     */
    public static let SECOND = "ss"
    
    /*
     格式化
     */
    public static func format(date: Date, formatter: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = formatter
        let currentTime = date
        return dateFormatter.string(from: currentTime)
    }

    /*
     格式化
     */
    public static func format(date: Date) -> String {
        return format(date: date, formatter: self.YYYY_MM_DD_HH_MM_SS)
    }
}
