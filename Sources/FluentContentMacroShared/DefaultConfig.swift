//
//  DefaultConfig.swift
//  FluentContentMacro
//
//  Created by Dionisis Karatzas on 4/2/25.
//

import Foundation

public enum DefaultConfig: Sendable {
    public static let immutable = true
    public static var includeRelations: IncludeRelations {
        IncludeRelations.children
    }

    public static var accessLevel: AccessLevel {
        AccessLevel.public
    }
}
