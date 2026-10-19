//
//  ToggleTask.swift
//  GlideCore
//
//  Created by Pranay Venkat Aluri on 10/18/26.
//

import Foundation

public func toggledLine(_ line: String) -> String? {
    guard case .task(let parsed) = parseLine(line), parsed.hasCheckbox else { return nil }
    
    let leading = /\s*(?:#{1,3}\s+)?/
    let timeToken = /\d{1,2}:\d{2}\s*(?:(?:[aA][mM]|[pP][mM])\b)?\s*/
    let checkboxToken = /\[([xX]| ?)\]/
    
    guard let lead = line.prefixMatch(of: leading) else { return nil }
    let start = lead.range.upperBound
    
    if let box = line[start...].prefixMatch(of: checkboxToken) {
        return flipped(line, box.range, wasChecked: !box.output.1.isEmpty && box.output.1 != " ")
    }
    
    if let time = line[start...].prefixMatch(of: timeToken) {
        let afterTime = time.range.upperBound
        
        if let box = line[afterTime...].prefixMatch(of: checkboxToken) {
            return flipped(line, box.range, wasChecked: !box.output.1.isEmpty && box.output.1 != " ")
        }
    }
    
    return nil
}

private func flipped(_ line: String, _ range: Range<String.Index>, wasChecked: Bool) -> String {
    var result = line
    result.replaceSubrange(range, with: wasChecked ? "[]" : "[x]")
    return result
}

@discardableResult
public func toggleTask(_ task: NoteTask, in store: NoteStore) throws -> Bool {
    let contents = try store.read(task.noteName)
    var lines = contents.components(separatedBy: "\n")
    
    guard lines.indices.contains(task.lineIndex),
          lines[task.lineIndex] == task.line,
          let toggled = toggledLine(task.line) else { return false }
    
    lines[task.lineIndex] = toggled
    try store.write(lines.joined(separator: "\n"), to: task.noteName)
    return true
}
