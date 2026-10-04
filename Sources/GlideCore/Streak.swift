//
//  Streak.swift
//  GlideCore
//
//  Created by Aarnav on 7/30/26.
//

import Foundation

public func currentStreak(fromCompletedText text: String, today: Date = Date()) -> Int {
    let calendar = Calendar.current
    
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    
    var completedDays: Set<String> = []
    for line in text.split(separator: "\n") {
        if let range = line.range(of: #"\(done: (\d{4}-\d{2}-\d{2})\)"#, options: .regularExpression) {
            let matched = String(line[range])
            let datePart = matched
                .replacingOccurrences(of: "(done: ", with: "")
                .replacingOccurrences(of: ")", with: "")
            completedDays.insert(datePart)
        }
    }
    

    var streak = 0
    var day = today
    while completedDays.contains(formatter.string(from: day)) {
        streak += 1
        guard let previous = calendar.date(byAdding: .day, value: -1, to: day) else { break }
        day = previous
    }
    
    return streak
}
