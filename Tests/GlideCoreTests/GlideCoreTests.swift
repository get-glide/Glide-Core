import Testing
import Foundation
@testable import GlideCore

private func day(_ y: Int, _ m: Int, _ d: Int, hour: Int = 12) -> Date {
    Calendar.current.date(from: DateComponents(year: y, month: m, day: d, hour: hour))!
}

private func parsedTasks(_ lines: [String], note: String = "Today") -> [NoteTask] {
    fetchTasks(lines: lines, noteName: note)
}

@Test func anyDateKeepsOnlyDatedTasks() {
    let all = parsedTasks(["[] a @due(2026-10-01)", "[] b @due(nil)", "[] c @due(2027-01-01)"])
    let result = filterByScope(all, scope: .anyDate)
    #expect(result.map { $0.task.text } == ["a", "c"])
}

@Test func hasCheckboxFlag() {
    func flag(_ line: String) -> Bool? {
        if case .task(let t) = parseLine(line) { return t.hasCheckbox }
        return nil
    }
    #expect(flag("9:00 foo") == false)
    #expect(flag("9:00 [] foo") == true)
    #expect(flag("[] foo") == true)
    #expect(flag("[] 9:00 foo") == true)
    #expect(flag("just a note") == nil)
}

@Test func timeDoesNotEatWordsStartingWithAm() {
    guard case .task(let t) = parseLine("9:00 amazing") else {
        Issue.record("expected a task")
        return
    }
    #expect(t.text == "amazing")
    #expect(t.time?.hour == 9)
}

@Test func checkboxWithSpaceParses() {
    guard case .task(let t) = parseLine("[ ] foo") else {
        Issue.record("expected a task")
        return
    }
    #expect(t.checked == false)
    #expect(t.text == "foo")
}

@Test func currentTaskIgnoresOtherDays() {
    let now = day(2026, 10, 5, hour: 8)
    let both = parsedTasks(["9:00am [] today @due(2026-10-05)", "7:00pm [] later @due(2026-10-08)"])
    #expect(currentTask(from: both, at: now)?.task.text == "today")
    
    let onlyLater = parsedTasks(["7:00pm [] later @due(2026-10-08)"])
    #expect(currentTask(from: onlyLater, at: now) == nil)
}

@Test func currentTaskUsesUpcomingEventButDropsPastEvent() {
    let events = parsedTasks(["2:00pm class @due(2026-10-05)"])
    #expect(currentTask(from: events, at: day(2026, 10, 5, hour: 8))?.task.text == "class")
    #expect(currentTask(from: events, at: day(2026, 10, 5, hour: 15)) == nil)
}

@Test func carrySkipsPlainEventsKeepsRecurringEvents() {
    let lines = ["2:00pm class", "9:00 standup @weekday", "[] plain", "[x] done"]
    #expect(findNeedToCarry(lines: lines, includePlainUnchecked: true) == ["9:00 standup @weekday", "[] plain @carried"])
}

@Test func carryForwardSingleIgnoresEvents() {
    let lines = ["2:00pm class", "[] x"]
    #expect(carryForwardSingle(lineIndex: 0, lines: lines) == lines)
}

@Test func overdueSkipsEvents() {
    let t = parsedTasks(["2:00pm class @due(2026-10-01)", "[] late @due(2026-10-01)"])
    #expect(overdueTasks(t, now: day(2026, 10, 5)).map { $0.task.text } == ["late"])
}

@Test func finalizeTreatsEventsLikeTasks() {
    let fixed = day(2026, 10, 5)
    #expect(finalizeLine("9:00 class", now: fixed) == "9:00 class @created(2026-10-05) @due(2026-10-05)")
}
