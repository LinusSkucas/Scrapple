//
//  UserData.swift
//  Scrapple
//
//  Created by Linus Skucas on 8/1/20.
//  Copyright © 2020 Linus Skucas. All rights reserved.
//

import Foundation
import UserNotifications
import SKWebAPI

class UserData: ObservableObject {
    @Published var runOnLogin: Bool = false // if true change
    @Published var notificationOnFinished = UserDefaults.standard.bool(forKey: "notificationOnFinished") {
        didSet { UserDefaults.standard.setValue(self.notificationOnFinished, forKey: "notificationOnFinished") }
    }
    @Published var shouldRemind = false
    @Published var remindTime = Date()
    @Published var oauthToken: OAuthToken? = OAuthToken.shared
//    var scrapbookUsername: String? {
//        let webAPI = WebAPI(token: UserData.shared.oauthToken!.oauthToken!)
//
//    }
    
    var lastUpdatedVersionBuild: String? = UserDefaults.standard.string(forKey: "lastUpdatedVersionBuild") {
        didSet { UserDefaults.standard.setValue(self.lastUpdatedVersionBuild, forKey: "lastUpdatedVersionBuild") }
    }
    
    static var shared = UserData()
    
    func sendNotification(title: String, subtitle: String, time: Date?, interval: DateComponents?) {
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.sound, .alert]) { (granted, error) in
            if let error = error {
                print(error)
                return
            }
            guard granted else { return }
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subtitle
            let uuidString = UUID().uuidString
            let request = UNNotificationRequest(identifier: uuidString, content: content, trigger: nil)
            center.add(request) { (error) in
                if error != nil {
                    print(error as Any)
                    return
                }
            }
        }
    }
}



