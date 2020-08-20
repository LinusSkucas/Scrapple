//
//  EnvironmentKey+NSHostingWindow.swift
//  Scrapple
//
//  Created by Linus Skucas on 8/20/20.
//  Copyright © 2020 Linus Skucas. All rights reserved.
//

import Foundation
import SwiftUI

struct HostingWindowKey: EnvironmentKey {
    typealias WrappedValue = NSWindow
    typealias Value = () -> WrappedValue?
    static let defaultValue: Self.Value = { nil }
}

extension EnvironmentValues {
    var hostingWindow: HostingWindowKey.Value {
        get {
            return self[HostingWindowKey.self]
        }
        set {
            self[HostingWindowKey.self] = newValue
        }
    }
}
