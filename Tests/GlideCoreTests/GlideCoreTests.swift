import Testing
import Foundation
@testable import GlideCore

@Test func readWriteRoundTrip() throws {
    // 1. set up
    let tempDir = URL.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    let store = NoteStore(directory: tempDir)
    
    // 2. act
    try store.write("hello", to: "Test")
    let readBack = try store.read("Test")
    
    // 3. check
    #expect(readBack == "hello")
}

@Test func createsDefaultNotes() throws {
    // 1. set up: fresh temp folder + store
    let tempDir = URL.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    let store = NoteStore(directory: tempDir)
    
    // 2. act: create the default notes
    try store.createDefaultNotesIfNeeded()
    
    // 3. check: all three notes now exist
    let notes = try store.listNotes()
    #expect(notes.contains("Today"))
    #expect(notes.contains("Classes"))
    #expect(notes.contains("Projects"))
}

@Test func fetchTasksReturnsOnlyTasks() {
    let lines = [
        "9:00 [] morning review",
        "just a note",
        "[] pick up lunch",
        "[x] already done"
    ]
    let tasks = fetchTasks(lines: lines, noteName: "Today")
    #expect(tasks.count == 3)
    #expect(tasks[0].task.checked == false)
    #expect(tasks[2].task.checked == true)
}

@Test func sortAndGroupSeparatesTimedAndUntimed() {
    let lines = [
        "9:00 [] standup",
        "[] pick up lunch",
        "11:00 [] meeting"
    ]
    let tasks = fetchTasks(lines: lines, noteName: "Today")
    let groups = sortAndGroup(tasks)
    #expect(groups.count == 2)
    #expect(groups[0].title == "scheduled")
    #expect(groups[1].title == "anytime")
    #expect(groups[0].tasks.count == 2)
    #expect(groups[0].tasks[0].task.time!.hour == 9)
    #expect(groups[0].tasks[1].task.time!.hour == 11)
}

@Test func filterBySourceCurrentNote() {
    let tasks = [
        NoteTask(line: "[] task a", task: TaskLine(text: "task a"), noteName: "Today", lineIndex: 0),
        NoteTask(line: "[] task b", task: TaskLine(text: "task b"), noteName: "Classes", lineIndex: 0)
    ]
    let filtered = filterBySource(tasks, source: .currentNote(name: "Today"))
    #expect(filtered.count == 1)
    #expect(filtered[0].noteName == "Today")
}

@Test func filterBySourceAllNotes() {
    let tasks = [
        NoteTask(line: "[] task a", task: TaskLine(text: "task a"), noteName: "Today", lineIndex: 0),
        NoteTask(line: "[] task b", task: TaskLine(text: "task b"), noteName: "Classes", lineIndex: 0)
    ]
    let filtered = filterBySource(tasks, source: .allNotes)
    #expect(filtered.count == 2)
}

@Test func currentTaskReturnsOverdueFirst() {
    let now = Calendar.current.date(bySettingHour: 11, minute: 0, second: 0, of: Date())!
    let tasks = [
        NoteTask(line: "9:00 [] standup", task: TaskLine(text: "standup", time: TaskTime(hour: 9, minute: 0), checked: false), noteName: "Today", lineIndex: 0),
        NoteTask(line: "2:00 [] meeting", task: TaskLine(text: "meeting", time: TaskTime(hour: 14, minute: 0), checked: false), noteName: "Today", lineIndex: 1)
    ]
    let current = currentTask(from: tasks, at: now)
    #expect(current?.task.text == "standup")
}

@Test func currentTaskReturnsUpcomingWhenNothingOverdue() {
    let now = Calendar.current.date(bySettingHour: 8, minute: 0, second: 0, of: Date())!
    let tasks = [
        NoteTask(line: "9:00 [] standup", task: TaskLine(text: "standup", time: TaskTime(hour: 9, minute: 0), checked: false), noteName: "Today", lineIndex: 0),
        NoteTask(line: "2:00 [] meeting", task: TaskLine(text: "meeting", time: TaskTime(hour: 14, minute: 0), checked: false), noteName: "Today", lineIndex: 1)
    ]
    let current = currentTask(from: tasks, at: now)
    #expect(current?.task.text == "standup")
}

@Test func getTaskPanelIntegration() throws {
    let tempDir = URL.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    let store = NoteStore(directory: tempDir)
    
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let today = formatter.string(from: Date())

    let lines = [
        "9:00 [] standup @due(\(today))",
        "[] pick up lunch @due(\(today))",
        "just a note"
    ]
    
    let result = try getTaskPanel(
        currentLines: lines,
        currentNoteName: "Today",
        scope: .today,
        source: .currentNote(name: "Today"),
        store: store
    )
    
    #expect(result.groups.count == 2)
    #expect(result.current != nil)
}
