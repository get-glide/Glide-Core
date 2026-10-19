//
//  CreatedDate.swift
//  GlideCore
//
//  Created by Pranay Venkat Aluri on 8/2/26.
//

import Foundation

public func appendCreatedDate(line: String) -> String {
    let dateString = makeTagDateFormatter().string(from: Date())
    var result = line
    result.append(" @created(\(dateString))")
    
    return result
}

public func appendDueDate(line: String) -> String {
    var result = line
    result.append(" @due(nil)")
    return result
}
