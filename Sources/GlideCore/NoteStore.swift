//
//  File.swift
//  GlideCore
//
//  Created by Aarnav on 6/25/26.
//

import Foundation

public struct NoteStore{
    public let directory: URL
    
    public init(directory: URL) {
        self.directory = directory
    }
    
    public func read(_ name: String) throws -> String{
        let url = directory.appendingPathComponent("\( name).md")
        
        let contents = try String(contentsOf: url, encoding: .utf8)
        
        return contents
    }
    
    public func write(_ contents: String, to name: String) throws {
        let url = directory.appendingPathComponent("\( name).md")
        try contents.write(to: url, atomically: true, encoding: .utf8)
    }
    
    public func listNotes() throws -> [String] {
        let files = try FileManager.default.contentsOfDirectory(
            at: directory, includingPropertiesForKeys: nil)
        return files
            .filter {$0.pathExtension == "md"}
            .map { $0.deletingPathExtension().lastPathComponent}
    }
    
    public func createDefaultNotesIfNeeded() throws {
        for note in DefaultNote.allCases{
            let url = directory.appendingPathComponent("\(note.rawValue).md")
            if !FileManager.default.fileExists(atPath: url.path){
                try write("", to: note.rawValue)
            }
        }
    }
    
    public static func makeDefault() throws -> NoteStore {
        let documents = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        let glideFolder = documents.appendingPathComponent("Glide", isDirectory: true)
        try FileManager.default.createDirectory(atPath: glideFolder.path, withIntermediateDirectories: true)
        return NoteStore(directory: glideFolder)
    }
}
