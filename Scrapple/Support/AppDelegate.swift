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
import Sparkle

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, NSMenuDelegate, NSPopoverDelegate {

    var window: NSWindow!
    var popover: NSPopover!
    var statusBarItem: NSStatusItem!
    var statusBarPrefsMenu: NSMenu!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        let imageView = NSImageView(image: NSImage(named: "AppIcon")!)
        if UserData.shared.bigSurIcon {
            imageView.image = NSImage(named: "BSAppIcon")!
        }
        NSApplication.shared.dockTile.contentView = imageView
        NSApplication.shared.dockTile.display()
        
        // Create the SwiftUI view that provides the window contents.
        if UserData.shared.oauthToken?.oauthToken == nil {
            showPrefsWindow(shouldPromptForAuth: true)
        }
        let contentView = ContentView().environmentObject(UserData.shared)

        let popover = NSPopover()
        popover.contentSize = NSSize(width: 350, height: 250)
        popover.behavior = .transient
        popover.delegate = self
        popover.contentViewController = NSHostingController(rootView: contentView)
        self.popover = popover
        
        self.statusBarItem = NSStatusBar.system.statusItem(withLength: CGFloat(NSStatusItem.squareLength))
        if let button = self.statusBarItem.button {
            button.image = NSImage(named: NSImage.Name("Icon"))
            button.action = #selector(togglePopover(_:))
            button.sendAction(on: [.leftMouseUp, .rightMouseUp])
        }
        
        UNUserNotificationCenter.current().delegate = self
        if (UserData.shared.lastUpdatedVersionBuild != NSApplication.appBuild) || UserData.shared.lastUpdatedVersionBuild == nil {
//             Preform updates and migration
        }
        UserData.shared.lastUpdatedVersionBuild = NSApplication.appBuild!
        
        // MARK - Touch Bar
        DFRSystemModalShowsCloseBoxWhenFrontMost(true)
        let kPandaIdentifier = NSTouchBarItem.Identifier(rawValue: "panda")
        let panda = NSCustomTouchBarItem.init(identifier: kPandaIdentifier)
        panda.view = NSButton(image: NSImage(named: NSImage.Name("AppIcon"))!, target: self, action: #selector(openPostWindow))
        NSTouchBarItem.addSystemTrayItem(panda)
        if UserData.shared.showTouchBarButton {
            DFRElementSetControlStripPresenceForIdentifier(kPandaIdentifier, true)
        }
        
        statusBarPrefsMenu = NSMenu(title: "Scrapple")
        statusBarPrefsMenu.delegate = self
        statusBarPrefsMenu.addItem(withTitle: "Preferences...", action: #selector(showPrefsWindow), keyEquivalent: ",")
        statusBarPrefsMenu.addItem(withTitle: "Check for Updates...", action: #selector(checkForUpdates), keyEquivalent: "")
        statusBarPrefsMenu.addItem(NSMenuItem.separator())
        statusBarPrefsMenu.addItem(withTitle: "Quit Scrapple", action: #selector(quitScrapple), keyEquivalent: "q")
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
    
    @objc func openPostWindow(sender: NSButton) {
        window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 400, height: 250),
            styleMask: [.titled, .closable],
            backing: .buffered, defer: false)
        window.isReleasedWhenClosed = false
        window.center()
        window.contentView = NSHostingView(rootView: ContentView(isPopover: false).environmentObject(UserData.shared).environment(\.hostingWindow, { [weak window] in
                                                                                    return window }))
        window.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    @objc func togglePopover(_ sender: NSStatusBarButton) {
        let event = NSApp.currentEvent!
        if event.type == NSEvent.EventType.leftMouseUp {
            if let button = self.statusBarItem.button {
                if self.popover.isShown {
                    self.popover.performClose(sender)
                } else {
                    self.popover.show(relativeTo: button.bounds, of: button, preferredEdge: NSRectEdge.minY)
                    self.popover.contentViewController?.view.window?.becomeKey()
                }
            }
        } else {
            // show prefs menu
            statusBarItem.menu = statusBarPrefsMenu
            statusBarItem.button?.performClick(nil)
        }
    }
    
    @objc private func showPrefsWindow(shouldPromptForAuth: Bool = false) {
        let preferencesView = PreferencesView(authShow: shouldPromptForAuth).environmentObject(UserData.shared)
        UserData.shared.notificationOnFinished = shouldPromptForAuth
        let controller = PreferencesWindowController(rootView: preferencesView)
        controller.window?.title = "Preferences"
        controller.showWindow(nil)
        controller.window?.becomeFirstResponder()
        controller.window?.center()
        controller.window?.makeKeyAndOrderFront(nil)
        NSApp.activate(ignoringOtherApps: true)
    }
    
    @objc private func checkForUpdates() {
        SUUpdater.shared()?.checkForUpdates(nil)
    }
    
    @objc private func quitScrapple() {
        NSApp.terminate(nil)
    }
    
    func popoverShouldDetach(_ popover: NSPopover) -> Bool {
        return true
    }
}

extension AppDelegate: UNUserNotificationCenterDelegate {
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }
}

func sendRequest(code: String) {
    /* I just copied this from paw ¯\_(ツ)_/¯ */
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
            DispatchQueue.main.async {
                NotificationCenter.default.post(name: Notification.Name("GotToken"), object: nil, userInfo: ["token": token])
                try! OAuthToken.shared.addToKeychain(name: "Scrapple Hack Club Account", token: token)
            }
        }
        else {
            // Failure
            UserData.shared.sendNotification(title: "Authorization failed", subtitle: "We were unable to authorize you with Slack", time: nil, interval: nil)
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
