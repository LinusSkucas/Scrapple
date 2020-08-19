//
//  ContentView.swift
//  Scrapple
//
//  Created by Linus Skucas on 7/30/20.
//  Copyright © 2020 Linus Skucas. All rights reserved.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var userData: UserData
    @State var draftImage: Data?
    @State var draftText = ""
    @State var isSubmitting = false
    var body: some View {
        VStack(alignment: .leading, spacing: 10.0) {
            HStack {
                Text("Write about what you did:")
                Spacer()
                Button(action: {
                    let preferencesView = PreferencesView().environmentObject(self.userData)
                    let controller = PreferencesWindowController(rootView: preferencesView)
                    controller.window?.title = "Preferences"
                    controller.showWindow(nil)
                    controller.window?.becomeFirstResponder()
                    NSApp.activate(ignoringOtherApps: true)
                }) {
                    Image(nsImage: NSImage(named: NSImage.actionTemplateName)!)
                    }.toolTip("Preferences").buttonStyle(BorderlessButtonStyle())
            }
            MacEditorTextView(text: self.$draftText)
            VStack(alignment: .leading, spacing: 0.0) {
                HStack {
                    Text("Choose your image or video")
                    Spacer()
                    Button("Choose File...", action: { self.openFile() })
                        .disabled(self.draftText == "")
                }
//                Text("You can also \"share\" files with Scrapple to post them.")
//                    .font(.caption)
//                    .fontWeight(.light)
//                    .foregroundColor(.secondary)
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    func openFile() {
        let panel = NSOpenPanel()
        panel.title = "Choose an image or picture for scrapbook"
        panel.prompt = "Post on Scrapbook ✈️"
        panel.message = "You'll get a notification when it's been posted!"

        panel.begin { response in
            if response == NSApplication.ModalResponse.OK,
                let url = panel.url {
                guard let imageData = try? Data(contentsOf: url) else { return }
                // fire off notification center, do on recieve
                let mediaFile = MediaFile(data: imageData, filename: url.relativePath, fileType: url.pathExtension)
                let update = Update(image: mediaFile, text: self.draftText)
                update.sendToSlack(successClosure: {_ in self.userData.sendNotification(title: UpdateSuccessSaying.status, subtitle: UpdateSuccessSaying.sayings.randomElement()!, time: nil, interval: nil)}, failureClosure: { error in
                    NSLog(error.rawValue)
                    self.userData.sendNotification(title: UpdateSendFailSaying.status, subtitle: UpdateSendFailSaying.sayings.randomElement()!, time: nil, interval: nil)
                })
                self.draftImage = nil
                self.draftText = ""
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
