public enum Recurrence: Equatable {
    case daily
    case weekly
    case weekday
    case monthly
    case specificDay(Weekday)
    case carried
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
