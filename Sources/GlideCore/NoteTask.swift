//
//  NoteTask.swift
//  GlideCore
//
//  Created by Pranay Venkat Aluri on 9/7/26.
//

public struct NoteTask {
    public var line: String
    public var task: TaskLine
    public var noteName: String
    public var lineIndex: Int
    
    public init(line: String, task: TaskLine, noteName: String, lineIndex: Int) {
        self.line = line
        self.task = task
        self.noteName = noteName
        self.lineIndex = lineIndex
    }
}
