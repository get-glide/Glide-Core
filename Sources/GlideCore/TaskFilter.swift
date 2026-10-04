//
//  TaskFilter.swift
//  GlideCore
//
//  Created by Pranay Venkat Aluri on 9/7/26.
//

import Foundation

public func fetchTasks(lines: [String], noteName: String) -> [NoteTask] {
    var result: [NoteTask] = []
    for (index, line) in lines.enumerated() {
        if case .task(let task) = parseLine(line) {
            result.append(NoteTask(line: line, task: task, noteName: noteName, lineIndex: index))
        }
    }
    return result
}

public enum TaskScope {
    case today
    case thisWeek
    case thisMonth
}

public enum TaskSource: Equatable {
    case currentNote(name: String)
    case allNotes
}

public struct TaskGroup {
    public var title: String
    public var tasks: [NoteTask]
    
    public init(title: String, tasks: [NoteTask]) {
        self.title = title
        self.tasks = tasks
    }
}

public func filterByScope(_ tasks: [NoteTask], scope: TaskScope) -> [NoteTask] {
    switch scope {
    case .today:
        return tasks.filter { task in
            guard let due = task.task.dueDate else { return false }
            return Calendar.current.isDateInToday(due)
        }
    case .thisWeek:
        return tasks.filter { task in
            guard let due = task.task.dueDate else { return false }
            return Calendar.current.isDate(due, equalTo: Date(), toGranularity: .weekOfYear)
        }
    case .thisMonth:
        return tasks.filter { task in
            guard let due = task.task.dueDate else { return false }
            return Calendar.current.isDate(due, equalTo: Date(), toGranularity: .month)
        }
    }
}

public func filterBySource(_ tasks: [NoteTask], source: TaskSource) -> [NoteTask] {
    switch source {
    case .currentNote(let name):
        return tasks.filter { $0.noteName == name }
    case .allNotes:
        return tasks
    }
}

public func sortAndGroup(_ tasks: [NoteTask]) -> [TaskGroup] {
    let timed = tasks
        .filter { $0.task.time != nil }
        .sorted {
            let a = $0.task.time!.hour * 60 + $0.task.time!.minute
            let b = $1.task.time!.hour * 60 + $1.task.time!.minute
            return a < b
        }
    
    let untimed = tasks.filter { $0.task.time == nil }
    
    var groups: [TaskGroup] = []
    if !timed.isEmpty { groups.append(TaskGroup(title: "scheduled", tasks: timed)) }
    if !untimed.isEmpty { groups.append(TaskGroup(title: "anytime", tasks: untimed)) }
    return groups
}

public func currentTask(from tasks: [NoteTask], at date: Date = Date()) -> NoteTask? {
    let calendar = Calendar.current
    let now = calendar.component(.hour, from: date) * 60 + calendar.component(.minute, from: date)
    
    let timedUnchecked = tasks.filter { $0.task.time != nil && !$0.task.checked }
    
    let overdue = timedUnchecked
        .filter { $0.task.time!.hour * 60 + $0.task.time!.minute <= now }
        .sorted { $0.task.time!.hour * 60 + $0.task.time!.minute > $1.task.time!.hour * 60 + $1.task.time!.minute }
        .first
    
    if let overdue = overdue { return overdue }
    
    let upcoming = timedUnchecked
        .filter { $0.task.time!.hour * 60 + $0.task.time!.minute > now }
        .sorted { $0.task.time!.hour * 60 + $0.task.time!.minute < $1.task.time!.hour * 60 + $1.task.time!.minute }
        .first
    
    if let upcoming = upcoming { return upcoming }
    
    return tasks.first { $0.task.time == nil && !$0.task.checked }
}

public func fetchAllTasks(from store: NoteStore) throws -> [NoteTask] {
    let noteNames = try store.listNotes()
    var result: [NoteTask] = []
    for name in noteNames {
        let contents = try store.read(name)
        let lines = contents.components(separatedBy: "\n")
        let tasks = fetchTasks(lines: lines, noteName: name)
        result.append(contentsOf: tasks)
    }
    return result
}

public func getTaskPanel(
    currentLines: [String],
    currentNoteName: String,
    scope: TaskScope,
    source: TaskSource,
    store: NoteStore
) throws -> (groups: [TaskGroup], current: NoteTask?, all: [NoteTask]) {
    let all: [NoteTask]
    
    switch source {
    case .currentNote:
        all = fetchTasks(lines: currentLines, noteName: currentNoteName)
    case .allNotes:
        all = try fetchAllTasks(from: store)
    }
    
    let bySource = filterBySource(all, source: source)
    let byScope = filterByScope(bySource, scope: scope)
    let groups = sortAndGroup(byScope)
    let current = currentTask(from: byScope)
    
    return (groups, current, all)
}
