//
//  CarryForward.swift
//  GlideCore
//
//  Created by Pranay Venkat Aluri on 7/16/26.
//

import Foundation

public func findNeedToCarry(lines: [String], includePlainUnchecked: Bool) -> [String] {
    var result: [String] = []
    
    for line in lines {
        let parsedLine = parseLine(line)
        
        if case .task(let task) = parsedLine {
            if task.recurrence != .none {
                result.append(line)
            }
            else if includePlainUnchecked && !task.checked && !task.isCarried {
                result.append(line + " @carried")
            }
        }
    }
    
    return result
}

public func applyMidnightRollover(lines: [String]) -> [String] {
    let toCarry = findNeedToCarry(lines: lines, includePlainUnchecked: false)
    
    guard !toCarry.isEmpty else { return lines }
    
    var result = lines
    
    for carryLine in toCarry.reversed() {
        if let index = result.firstIndex(of: carryLine) {
            result.remove(at: index)
        }
        result.insert(carryLine, at: 0)
    }
    
    return result
}

public func applyCarryForward(lines: [String]) -> [String] {
    let toCarry = findNeedToCarry(lines: lines, includePlainUnchecked: true)
    
    guard !toCarry.isEmpty else { return lines }
    
    var result = lines
    
    for carryLine in toCarry.reversed() {
        if let index = result.firstIndex(of: carryLine) {
            result.remove(at: index)
        }
        result.insert(carryLine, at: 0)
    }
    
    return result
}

public func carryForwardSingle(lineIndex: Int, lines: [String]) -> [String] {
    guard lineIndex < lines.count else { return lines }
    
    var result = lines
    let line = result[lineIndex]
    let parsed = parseLine(line)
    
    guard case .task(let task) = parsed, !task.checked else { return lines }
    
    result.remove(at: lineIndex)
    
    if task.recurrence != .none {
        result.insert(line, at: 0)
    } else {
        result.insert(line + " @carried", at: 0)
    }
    
    return result
}
