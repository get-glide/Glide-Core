//
//  TaskCompletion.swift
//  GlideCore
//
//  Created by Aarnav on 7/28/26.
//


import Foundation

private func todayStamp() -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter.string(from: Date())
}

public func toggleTaskCompletion(_ line: String) -> String {
    let trimmed = line.trimmingCharacters(in: .whitespaces)
    
    if trimmed.hasPrefix("[ ]") {
        let rest = trimmed.dropFirst(3)
        return "[x]\(rest) (done: \(todayStamp()))"
    } else if trimmed.hasPrefix("[x]") {
        let rest = trimmed.dropFirst(3)
        var text = String(rest)
        if let range = text.range(of: #"\(done: \d{4}-\d{2}-\d{2}\)"#, options: .regularExpression) {
            text.removeSubrange(range)
        }
        text = text.trimmingCharacters(in: .whitespaces)
        return "[ ] \(text)"
    } else {
        return line
    }
}
