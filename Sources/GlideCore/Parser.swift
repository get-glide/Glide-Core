import Foundation

private func parseTime(line: String) -> (time: TaskTime, remainder: String)? {
    let timeRegex = /^(\d{1,2}):(\d{2})\s*(am|pm)?/.ignoresCase()
    
    guard let match = line.firstMatch(of: timeRegex) else {return nil}
    guard var hour = Int(match.1), let minute = Int(match.2) else {return nil}
    let ampm = match.3
    
    if let period = ampm?.lowercased() {
        if (period == "pm" && hour != 12) {
            hour += 12
        } else if (period == "am" && hour == 12) {
            hour = 0
        }
    }
    
    let remaining = String(line[match.range.upperBound...])
    let remainder = remaining.trimmingCharacters(in: .whitespaces)
    
    return (TaskTime(hour: hour, minute: minute), remainder)
}

private func parseCheckbox(line: String) -> (checked: Bool, remainder: String)? {
    let checkedRegex = /^\[x\]/.ignoresCase()
    let uncheckedRegex = /^\[\]/
    
    if let checkedMatch = line.firstMatch(of: checkedRegex) {
        let remaining = String(line[checkedMatch.range.upperBound...])
        let remainder = remaining.trimmingCharacters(in: .whitespaces)
        
        return (true, remainder)
    }
    
    if let uncheckedMatch = line.firstMatch(of: uncheckedRegex) {
        let remaining = String(line[uncheckedMatch.range.upperBound...])
        let remainder = remaining.trimmingCharacters(in: .whitespaces)
        
        return (false, remainder)
    }
    
    return nil
}

private func parseRecurrence(line: String) -> (recurrence: Recurrence, remainder: String) {
    let recurrenceRegex = /\s*@(daily|weekly|weekday|monthly|mon|tue|wed|thu|fri|sat|sun)\b/.ignoresCase()
    
    if let match = line.firstMatch(of: recurrenceRegex) {
        let tag = match.1.lowercased()
        
        let recurrence: Recurrence
        switch tag {
            case "daily":    recurrence = .daily
            case "weekly":   recurrence = .weekly
            case "weekday":  recurrence = .weekday
            case "monthly":  recurrence = .monthly
            case "mon":      recurrence = .specificDay(.monday)
            case "tue":      recurrence = .specificDay(.tuesday)
            case "wed":      recurrence = .specificDay(.wednesday)
            case "thu":      recurrence = .specificDay(.thursday)
            case "fri":      recurrence = .specificDay(.friday)
            case "sat":      recurrence = .specificDay(.saturday)
            case "sun":      recurrence = .specificDay(.sunday)
            default:         recurrence = .none
        }
        
        let remaining = line.replacingCharacters(in: match.range, with: "")
        let remainder = remaining.trimmingCharacters(in: .whitespaces)
        
        return (recurrence, remainder)
    }
    
    return (.none, line)
}

public func parseLine(_ line: String) -> ParsedLine {
    let trimmedLine = line.trimmingCharacters(in: .whitespaces)
    
    if trimmedLine == "" {
        return .note(text: "")
    }
    
    if let (taskTime, timeRemainder) = parseTime(line: trimmedLine) {
        if let (checked, checkboxRemainder) = parseCheckbox(line: timeRemainder) {
            let (recurrence, recurrenceRemainder) = parseRecurrence(line: checkboxRemainder)
            return .task(text: recurrenceRemainder, time: taskTime, checked: checked, recurrence: recurrence)
        } else {
            let (recurrence, recurrenceRemainder) = parseRecurrence(line: timeRemainder)
            return .task(text: timeRemainder, time: taskTime, checked: false, recurrence: .none)
        }
    }
    
    if let (checked, checkboxRemainder) = parseCheckbox(line: trimmedLine) {
        let (recurrence, taskText) = parseRecurrence(line: checkboxRemainder)
        return .task(text: taskText, time: nil, checked: checked, recurrence: recurrence)
    }
    
    return .note(text: trimmedLine)
}
