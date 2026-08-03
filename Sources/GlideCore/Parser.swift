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

private func parseRecurrence(line: String) -> (recurrence: Recurrence, isCarried: Bool, createdDate: Date?, remainder: String) {
    let recurrenceRegex = /\s*@(daily|weekly|weekday|monthly|mon|tue|wed|thu|fri|sat|sun)\b/.ignoresCase()
    let carriedRegex = /\s*@carried\b/.ignoresCase()
    let createdDateRegex = /\s*@created\((\d{4}-\d{2}-\d{2})\)/.ignoresCase()
    
    var remainder = line
    var recurrence: Recurrence = .none
    var isCarried = false
    var createdDate: Date? = nil
    
    if let match = remainder.firstMatch(of: carriedRegex) {
        isCarried = true
        remainder = remainder.replacingCharacters(in: match.range, with: "").trimmingCharacters(in: .whitespaces)
    }
    
    if let match = remainder.firstMatch(of: recurrenceRegex) {
        let tag = match.1.lowercased()
        
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
        
        let remaining = remainder.replacingCharacters(in: match.range, with: "")
        remainder = remaining.trimmingCharacters(in: .whitespaces)
    }
    
    
    if let match = remainder.firstMatch(of: createdDateRegex) {
        let dateString = String(match.1)
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        createdDate = formatter.date(from: dateString)
        remainder = remainder.replacingCharacters(in: match.range, with: "").trimmingCharacters(in: .whitespaces)
    }
    
    return (recurrence, isCarried, createdDate, remainder)
}

public func parseLine(_ line: String) -> ParsedLine {
    let trimmedLine = line.trimmingCharacters(in: .whitespaces)
    
    guard !trimmedLine.isEmpty else { return .note(text: "", headingLevel: nil) }
    
    var headingLevel: Int? = nil
    var remainder = trimmedLine
    
    let headingRegex = /^(#{1,4})\s+/
    if let match = trimmedLine.firstMatch(of: headingRegex) {
        headingLevel = match.1.count
        remainder = String(trimmedLine[match.range.upperBound...]).trimmingCharacters(in: .whitespaces)
    }
    
    if let (taskTime, timeRemainder) = parseTime(line: remainder) {
        if let (checked, checkboxRemainder) = parseCheckbox(line: timeRemainder) {
            let (recurrence, isCarried, createdDate, taskText) = parseRecurrence(line: checkboxRemainder)
            return .task(TaskLine(text: taskText, time: taskTime, checked: checked, recurrence: recurrence, isCarried: isCarried, createdDate: createdDate, headingLevel: headingLevel))
        } else {
            let (recurrence, isCarried, createdDate, taskText) = parseRecurrence(line: timeRemainder)
            return .task(TaskLine(text: taskText, time: taskTime, checked: false, recurrence: recurrence, isCarried: isCarried, createdDate: createdDate, headingLevel: headingLevel))
        }
    }
    
    if let (checked, checkboxRemainder) = parseCheckbox(line: remainder) {
        if let (taskTime, timeRemainder) = parseTime(line: checkboxRemainder) {
            let (recurrence, isCarried, createdDate, taskText) = parseRecurrence(line: timeRemainder)
            return .task(TaskLine(text: taskText, time: taskTime, checked: checked, recurrence: recurrence, isCarried: isCarried, createdDate: createdDate, headingLevel: headingLevel))
        } else {
            let (recurrence, isCarried, createdDate, taskText) = parseRecurrence(line: checkboxRemainder)
            return .task(TaskLine(text: taskText, time: nil, checked: checked, recurrence: recurrence, isCarried: isCarried, createdDate: createdDate, headingLevel: headingLevel))
        }
    }
    
    return .note(text: remainder, headingLevel: headingLevel)
}
