//
//  FinalizeLine.swift
//  GlideCore
//
//  Created by Pranay Venkat Aluri on 10/18/26.
//

import Foundation

public func finalizeLine(_ line: String, defaultDue: Date? = nil, now: Date = Date()) -> String {
    guard case .task(let task) = parseLine(line) else { return line }
    guard !task.text.isEmpty else {return line}
    
    let needsCreated = needsCreatedDate(line: line)
    let needsDue = needsDueDate(line: line)
    guard needsCreated || needsDue else { return line }
    
    var result = line
    while let last = result.last, last == " " || last == "\t" {
        result.removeLast()
    }
    
    let formatter = makeTagDateFormatter()
    
    if needsCreated {
        result += " @created(\(formatter.string(from: now)))"
    }
    
    if needsDue {
        let due: Date? = defaultDue ?? (task.time != nil ? now: nil)
        if let due {
            result += " @due(\(formatter.string(from: due)))"
        } else {
            result += " @due(nil)"
        }
    }
    
    return result
}

public func needsCreatedDate(line: String) -> Bool {
    guard case .task = parseLine(line) else { return false }
    return line.firstMatch(of: /@created\(/) == nil
}

public func needsDueDate(line: String) -> Bool {
    guard case .task = parseLine(line) else { return false }
    return line.firstMatch(of: /@due\(/) == nil
}
