public enum Recurrence {
    case daily
    case weekly
    case weekday
    case monthly
    case specificDay(Weekday)
    case none
}
