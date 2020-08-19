//
//  AppDelegate.swift
//  Scrapple
//
//  Created by Linus Skucas on 7/30/20.
//  Copyright © 2020 Linus Skucas. All rights reserved.
//

import Cocoa
import SwiftUI
import UserNotifications

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    var window: NSWindow!
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    private var appURL: URL { Bundle.main.bundleURL }


    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Create the SwiftUI view that provides the window contents.
        if UserData.shared.oauthToken?.oauthToken == nil {
            let preferencesView = PreferencesView(authShow: true).environmentObject(UserData.shared)
            UserData.shared.notificationOnFinished = true
            let controller = PreferencesWindowController(rootView: preferencesView)
            controller.window?.title = "Preferences"
            controller.showWindow(nil)
            controller.window?.becomeFirstResponder()
            controller.window?.center()
            controller.window?.makeKeyAndOrderFront(nil)
            NSApp.activate(ignoringOtherApps: true)
        }
        SharedFileList.sessionLoginItems().addItem(appURL)
        let contentView = ContentView().environmentObject(UserData.shared)

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 350, height: 250)
        popover.behavior = .transient
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.squareLength))
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: NSImage.Name("Icon"))
             button.action = #selector(togglePopover(_:))
        }
        UNUserNotificationCenter.current().delegate = self
        if (UserData.shared.lastUpdatedVersionBuild != NSApplication.appBuild) && UserData.shared.lastUpdatedVersionBuild != nil {
//             Preform updates and migration
            
        }
        UserData.shared.lastUpdatedVersionBuild = NSApplication.appBuild!
    }
    
    func applicationWillFinishLaunching(_ aNotification: Notification) {
          // Register for Call back URL events
          let aem = NSAppleEventManager.shared();
          aem.setEventHandler(self, andSelector: #selector(AppDelegate.handleGetURLEvent(event:replyEvent:)), forEventClass: AEEventClass(kInternetEventClass), andEventID: AEEventID(kAEGetURL))

      }

    @objc func handleGetURLEvent(event: NSAppleEventDescriptor, replyEvent: NSAppleEventDescriptor) {

      let urlString = event.paramDescriptor(forKeyword: AEKeyword(keyDirectObject))?.stringValue!
          let url = URL(string: urlString!)!
         // DO what you will you now have a url..
        let code = url.queryItem("code")
        sendRequest(code: code!)
      }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func togglePopover(_ sender: AnyObject?) {
        if let button = self.statusBarItem.button {
            if self.popover.isShown {
                self.popover.performClose(sender)
            } else {
                self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                self.popover.contentViewController?.view.window?.becomeKey()
            }
        }
    }

}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}

func sendRequest(code: String) {
    /* lol I just copied this from paw. */
    /* Configure session, choose between:
       * defaultSessionConfiguration
       * ephemeralSessionConfiguration
       * backgroundSessionConfigurationWithIdentifier:
     And set session-wide properties, such as: HTTPAdditionalHeaders,
     HTTPCookieAcceptPolicy, requestCachePolicy or timeoutIntervalForRequest.
     */
    let sessionConfig = URLSessionConfiguration.default

    /* Create session, and optionally set a URLSessionDelegate. */
    let session = URLSession(configuration: sessionConfig, delegate: nil, delegateQueue: nil)

    guard let URL = URL(string: "https://Scrapple.pythonanywhere.com/getAuth") else {return}
    var request = URLRequest(url: URL)
    request.httpMethod = "POST"

    // Headers

    request.addValue("text/plain; charset=utf-8", forHTTPHeaderField: "Content-Type")

    // Body

    let bodyString = code
    request.httpBody = bodyString.data(using: .utf8, allowLossyConversion: true)

    /* Start a new Task */
    let task = session.dataTask(with: request, completionHandler: { (data: Data?, response: URLResponse?, error: Error?) -> Void in
        if (error == nil) {
            let token = String(bytes: data!, encoding: .utf8)!
//            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("GotToken"), object: nil, userInfo: ["token": token])
                try! OAuthToken.shared.addToKeychain(name: "Scrapple Hack Club Account", token: token)
//            }
        }
        else {
            // Failure
            fatalError()
        }
    })
    task.resume()
    session.finishTasksAndInvalidate()
}

extension URL {
    func queryItem(_ name: String) -> String? {
        URLComponents(string: absoluteString)?
            .queryItems?
            .first { $0.name.caseInsensitiveCompare(name) == .orderedSame }?
            .value
    }
}
