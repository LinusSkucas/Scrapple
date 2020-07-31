//
//  ContentView.swift
//  Scrapple
//
//  Created by Linus Skucas on 7/30/20.
//  Copyright © 2020 Linus Skucas. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        HStack {
            Text("Hello, World!")
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            Button("Hello", action: { print("Hello World") })
        }
    }
}


struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
