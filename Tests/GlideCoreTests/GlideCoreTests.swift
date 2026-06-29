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
