public enum ParsedLine {
    case task(text: String, time: String?, checked: Bool, recurrence: Recurrence)
    case note(text: String)
}

public enum Recurrence {
    case daily
    case weekly
    case weekday
    case monthly
    case specificDay(Weekday)
    case none
}

public enum Weekday {
    case monday
    case tuesday
    case wednesday
    case thursday
    case friday
    case saturday
    case sunday
}

public func parseLine(_ line: String) -> ParsedLine {
    return ParsedLine.note(text: line)
}
