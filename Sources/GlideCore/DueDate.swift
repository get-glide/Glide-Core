//
//  DueDate.swift
//  GlideCore
//
//  Created by Pranay Venkat Aluri on 9/7/26.
//

import Foundation

public func needsDueDate(line: String) -> Bool {
    if case .task(let task) = parseLine(line) {
        return !task.hasDueDate
    }
    return false
}

public func appendDueDate(line: String) -> String {
//    let formatter = DateFormatter()
//    formatter.dateFormat = "yyyy-MM-dd"
//    formatter.timeZone = TimeZone.current
//    formatter.locale = Locale.current
//    
//    let dateString = formatter.string(from: Date())
//    var result = line
//    result.append(" @due(\(dateString))")
//    
//    return result
    var result = line
    result.append(" @due(nil)")
    return result
}
