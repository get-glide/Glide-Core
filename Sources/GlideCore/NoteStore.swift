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
}
