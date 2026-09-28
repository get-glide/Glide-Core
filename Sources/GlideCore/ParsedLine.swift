public enum ParsedLine {
    case task(TaskLine)
    case note(text: String, headingLevel: Int?)
}
