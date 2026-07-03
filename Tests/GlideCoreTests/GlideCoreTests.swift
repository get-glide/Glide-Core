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
