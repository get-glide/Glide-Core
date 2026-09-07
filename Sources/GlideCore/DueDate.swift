//
//  DueDate.swift
//  GlideCore
//
//  Created by Pranay Venkat Aluri on 9/7/26.
//

import Foundation

public func needsDueDate(line: String) -> Bool {
    if case .task(let task) = parseLine(line) {
        return task.dueDate == nil
    }
    return false
}

public func appendDueDate(line: String) -> String {
    let currentDate: String = Date.now.formatted(.iso8601.year().month().day().dateSeparator(.dash))
    var result = line
    result.append(" @due(\(currentDate))")
    return result
}
