public enum ParsedLine {
    case task(text: String, time: TaskTime?, checked: Bool, recurrence: Recurrence)
    case note(text: String)
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
