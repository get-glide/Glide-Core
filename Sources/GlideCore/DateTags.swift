//
//  DateTags.swift
//  GlideCore
//
//  Created by Pranay Venkat Aluri on 10/18/26.
//

import Foundation

func makeTagDateFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.calendar = Calendar(identifier: .gregorian)
    formatter.locale = Locale(identifier: "en_US_POSIX")
    formatter.timeZone = .current
    formatter.dateFormat = "yyyy-MM-dd"
    return formatter
}
