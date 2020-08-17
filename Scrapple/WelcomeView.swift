//
//  WelcomeView.swift
//  Scrapple
//
//  Created by Linus Skucas on 8/2/20.
//  Copyright © 2020 Linus Skucas. All rights reserved.
//

import SwiftUI
import AppKit

struct WelcomeView: View {
    @EnvironmentObject var userData: UserData
    @Environment(\.presentationMode) var presentationMode
    @State var isConnecting = false
    let oauthURL = URL(string: "https://slack.com/oauth/v2/authorize?client_id=2210535565.1275826279571&scope=&user_scope=files:write,files:read,chat:write,remote_files:share,remote_files:write")!
    
    var body: some View {
        VStack(alignment: .center) {
            Image(nsImage: NSApplication.shared.applicationIconImage)
            Text("Welcome to Scrapple")
                .font(.title)
                .fontWeight(.medium)
            Spacer()
            Text("Connect your slack account to get started")
            HStack {
                Button("Connect...") {
                    self.isConnecting = true
                    NSWorkspace.shared.open(self.oauthURL)
                }
                if self.isConnecting {
                    ProgressIndicator(isAnimating: $isConnecting)
                }
            }
            .onReceive(NotificationCenter.default.publisher(for: Notification.Name("GotToken")), perform: {output in
                DispatchQueue.main.async {
                    self.presentationMode.wrappedValue.dismiss()
                }
            })
        }
    .padding()
    }
}

struct WelcomeView_Previews: PreviewProvider {
    static var previews: some View {
        WelcomeView()
    }
}
