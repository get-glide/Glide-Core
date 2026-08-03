//
//  TaskLine.swift
//  GlideCore
//
//  Created by Pranay Venkat Aluri on 8/2/26.
//

import Foundation

public struct TaskLine {
    public var text: String
    public var time: TaskTime?
    public var checked: Bool
    public var recurrence: Recurrence
    public var isCarried: Bool
    public var createdDate: Date?
    public var headingLevel: Int?
    
    public init(
        text: String,
        time: TaskTime? = nil,
        checked: Bool = false,
        recurrence: Recurrence = .none,
        isCarried: Bool = false,
        createdDate: Date? = nil,
        headingLevel: Int? = nil
    ) {
        self.text = text
        self.time = time
        self.checked = checked
        self.recurrence = recurrence
        self.isCarried = isCarried
        self.createdDate = createdDate
        self.headingLevel = headingLevel
    }
}
