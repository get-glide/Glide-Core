//
//  CreatedDate.swift
//  GlideCore
//
//  Created by Pranay Venkat Aluri on 8/2/26.
//

import Foundation

public func needsCreatedDate(line: String) -> Bool {
    if case .task(let task) = parseLine(line) {
        return task.createdDate == nil
    }
    return false
}

public func appendCreatedDate(line: String) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    formatter.timeZone = TimeZone.current
    
    let dateString = formatter.string(from: Date())
    var result = line
    result.append(" @created(\(dateString))")
    
    return result
}
