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

@Test func searchFindsMatchingLines() throws {
    // 1. set up
    let tempDir = URL.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    let store = NoteStore(directory: tempDir)
    
    // 2. act: write notes with known content, then search
    try store.write("buy milk\nwalk dog", to: "Today")
    try store.write("finish MILK report", to: "Projects")
    let results = try store.search("milk")
    
    // 3. check: two lines match "milk", case-insensitive
    #expect(results.count == 2)
}

@Test func togglesTaskCompletion() throws {
    // unchecked → checked: gets [x] and a done stamp
    let checked = toggleTaskCompletion("[ ] buy milk")
    #expect(checked.hasPrefix("[x] buy milk"))
    #expect(checked.contains("(done:"))
    
    // checked → unchecked: back to [ ], stamp stripped
    let unchecked = toggleTaskCompletion("[x] buy milk (done: 2026-07-28)")
    #expect(unchecked == "[ ] buy milk")
    
    // non-task line: unchanged
    let plain = toggleTaskCompletion("just a note")
    #expect(plain == "just a note")
}

@Test func sweepSeparatesCompletedTasks() throws {
    let note = """
    [ ] buy milk
    [x] finish essay (done: 2026-07-28)
    some note text
    [x] email professor (done: 2026-07-28)
    """
    
    let result = sweepCompletedTasks(from: note)
    
    // two completed tasks archived
    #expect(result.archived.count == 2)
    
    // kept text has the incomplete task and the note, but not the completed ones
    #expect(result.kept.contains("[ ] buy milk"))
    #expect(result.kept.contains("some note text"))
    #expect(!result.kept.contains("[x]"))
}

@Test func rolloverMovesCompletedTasks() throws {
    let tempDir = URL.temporaryDirectory.appending(path: UUID().uuidString)
    try FileManager.default.createDirectory(at: tempDir, withIntermediateDirectories: true)
    let store = NoteStore(directory: tempDir)
    
    // Today has one done, one not
    try store.write("[ ] buy milk\n[x] finish essay (done: 2026-07-28)", to: DefaultNote.today.rawValue)
    
    try store.runDailyRollover()
    
    // Today keeps only the incomplete task
    let today = try store.read(DefaultNote.today.rawValue)
    #expect(today.contains("[ ] buy milk"))
    #expect(!today.contains("[x]"))
    
    // Completed Tasks got the finished one
    let completed = try store.read(DefaultNote.completed.rawValue)
    #expect(completed.contains("[x] finish essay"))
}

@Test func countsConsecutiveStreak() throws {
    // fixed "today" so the test is stable
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy-MM-dd"
    let today = formatter.date(from: "2026-07-30")!
    
    // completions on the 30th, 29th, 28th — then a gap (skips 27th), then 26th
    let completed = """
    [x] task a (done: 2026-07-30)
    [x] task b (done: 2026-07-29)
    [x] task c (done: 2026-07-28)
    [x] task d (done: 2026-07-26)
    """
    
    let streak = currentStreak(fromCompletedText: completed, today: today)
    
    // 30, 29, 28 are consecutive → streak of 3. The 26th doesn't count (27th missing).
    #expect(streak == 3)
}
