//
//  ActivityIndicator.swift
//  Scrapple
//
//  Created by Linus Skucas on 7/31/20.
//  Copyright © 2020 Linus Skucas. All rights reserved.
//

import SwiftUI

struct ProgressIndicator: NSViewRepresentable {
    @Binding var isAnimating: Bool
    
    func makeNSView(context: Context) -> NSProgressIndicator {
        let indicator = NSProgressIndicator()
        indicator.style = .spinning
        indicator.isIndeterminate = true
        indicator.isDisplayedWhenStopped = false
        indicator.controlSize = .small
        return indicator
    }
    
    func updateNSView(_ nsView: NSProgressIndicator, context: Context) {
        isAnimating ? nsView.startAnimation(nil) : nsView.stopAnimation(nil)
    }
    
    typealias NSViewType = NSProgressIndicator
}
