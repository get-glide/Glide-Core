//
//  DailyRollover.swift
//  GlideCore
//
//  Created by Aarnav on 7/28/26.
//

import Foundation

import Foundation

public func sweepCompletedTasks(from noteText: String) -> (kept: String, archived: [String]) {
    let lines = noteText.split(separator: "\n", omittingEmptySubsequences: false)
    
    var keptLines: [String] = []
    var archivedLines: [String] = []
    
    for line in lines {
        let trimmed = line.trimmingCharacters(in: .whitespaces)
        if trimmed.hasPrefix("[x]") {
            archivedLines.append(String(line))
        } else {
            keptLines.append(String(line))
        }
    }
    
    let kept = keptLines.joined(separator: "\n")
    return (kept, archivedLines)
}

public func shouldRunRollover(lastActive: Date?, today: Date = Date()) -> Bool{
    guard let lastActive else { return false }
    let calendar = Calendar.current
    return !calendar.isDate(lastActive, inSameDayAs: today)
}
