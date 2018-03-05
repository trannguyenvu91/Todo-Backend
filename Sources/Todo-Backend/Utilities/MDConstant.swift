//
//  MDConstant.swift
//  CookRecipes
//
//  Created by VuVince on 2/7/18.
//

import Foundation

typealias JSON = Dictionary<String, Any>

struct MDConstant {
    
    //MARK: Date time
    static let dateFormater = DateFormatter()
    static let dateFormat = "HH:MM:SS DD/MM/YYYY"
    
    static func getDate(_ dateString: String) -> Date? {
        dateFormater.dateFormat = dateFormat
        return dateFormater.date(from: dateString)
    }
    
    static func getString(date: Date?) -> String {
        guard let value = date else { return "NULL" }
        return dateFormater.string(from: value)
    }
    
    static func getCurrentDate() -> Date {
        return Date()
    }
    
    static func now() -> Int {
        return Int(Date.timeIntervalSinceReferenceDate)
    }
    
    //MARK: Token prefix
    static let tokenPrefix = "Bearer "
    static let tokenIdleTime = 7 * 24 * 3600
}
