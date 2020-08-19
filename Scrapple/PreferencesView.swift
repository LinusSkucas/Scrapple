//
//  PreferencesView.swift
//  Scrapple
//
//  Created by Linus Skucas on 8/2/20.
//  Copyright © 2020 Linus Skucas. All rights reserved.
//

import SwiftUI

struct PreferencesView: View {
    @EnvironmentObject var userData: UserData
    @State var authShow: Bool = false
    @State var quitButtonText = QuitScrappleSaying.status
    var body: some View {
        VStack(alignment: .leading) {
            GroupBox {
                VStack(alignment: .leading) {
                    HStack {
                        Text("Hack Club Account ")
                        Spacer()
                        Button("Reconnect...") {
                            OAuthToken.shared.deleteFromKeychain()
                            self.authShow = true
                        }
                    }
                }
                .padding()
            }
            .frame(height: 100)
//            .padding(.bottom)
            VStack(alignment: .leading, spacing: 0.0) {
                Toggle(isOn: self.$userData.notificationOnFinished) {
                    Text("Send notification when finished sending to Scrappy")
                }
                Text("It's recommended you keep this on, so you know you \nhave posted.")
                    .font(.caption)
                    .fontWeight(.light)
                    .foregroundColor(.secondary)
                    .lineLimit(2)
            }
            HStack {
                Spacer()
                Button(action: {
                    NSApplication.shared.terminate(nil)
                }, label: {
                    Text(quitButtonText)
                })
                .buttonStyle(BorderlessButtonStyle())
            }.onHover(perform: { hovering in
                if hovering {
                    self.quitButtonText = QuitScrappleSaying.sayings.randomElement()!
                } else {
                    self.quitButtonText = QuitScrappleSaying.status
                }
            })
//            Toggle(isOn: self.$userData.runOnLogin) {
//                Text("Run on Login")
//            }
//            Toggle(isOn: self.$userData.shouldRemind) {
//                Text("Get a reminder to post on your Scrapbook.")
//            }
//            if self.userData.shouldRemind {
//                DatePicker("Notification time", selection: self.$userData.remindTime, displayedComponents: .hourAndMinute)
//            }
        }
        .sheet(isPresented: self.$authShow, content: {
            WelcomeView()
        })
        .padding()
    }
}

struct PreferencesView_Previews: PreviewProvider {
    static var previews: some View {
        PreferencesView()
    }
}
