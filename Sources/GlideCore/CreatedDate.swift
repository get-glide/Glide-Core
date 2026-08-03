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
    let currentDate: String = Date.now.formatted(.iso8601.year().month().day().dateSeparator(.dash))
    var result = line
    result.append(" @created(\(currentDate))")
    return result
}
