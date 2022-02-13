//
//  PreferenceKeyApp.swift
//  PreferenceKey
//
//  Created by Matthew Cox on 2/11/22.
//

import SwiftUI

@main
struct PreferenceKeyApp: App {
    static let columns: [[String]] = [
        ["Hello", "Longer title that is easy to forget", "This is an extremely long string just to see how this does now okay??", "Spider"],
        ["Longer title", "Hello", "Fish", "This is a long string just to see how this does now okay??"],
        ["A", "B", "C", "D"],
        ["A", "B", "C", "D"],
    ]
    
    var body: some Scene {
        WindowGroup {
            MultiColumnView(columns: Self.columns)
        }
    }
}
