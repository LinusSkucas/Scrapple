//
//  NSApp+AppBuild.swift
//  Scrapple
//
//  Created by Linus Skucas on 8/18/20.
//  Copyright © 2020 Linus Skucas. All rights reserved.
//

import Foundation
import AppKit

extension NSApplication {
    static var appBuild: String? {
        return Bundle.main.infoDictionary?["CFBundleVersion"] as? String
    }
}
