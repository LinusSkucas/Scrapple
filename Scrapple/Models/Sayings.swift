//
//  Sayings.swift
//  ^ Don't ask about the name, I didn't know what to call it.
//  Scrapple
//
//  Created by Linus Skucas on 8/12/20.
//  Copyright © 2020 Linus Skucas. All rights reserved.
//

import Foundation

protocol Saying {
    static var status: String { get set }
    static var sayings: [String] { get set }
}

struct UpdateSuccessSaying: Saying {
    static var status: String = "Success!"
    static var sayings: [String] = ["You've just increased your virtual internet points!", "Your file has been uploaded 🚀", "Your sad little streak has been increased by the size of one."]
}

struct UpdateSendFailSaying: Saying {
    static var status: String = "Failure!"
    static var sayings: [String] = ["Oops! The file failed to send.", "The file wasn't sent; your streak wasn't increased 🧨", "I couldn't upload your file! No virtual internet points for you!"]
}

struct BadFileSaying: Saying {
    static var status: String = "Bad File!"
    static var sayings: [String] = ["Your file sucks!", "It was a bad file, so it didn't work", "Scrappy says your file sucks and you have to try again.", "Scrappy didn't like your file and got constipated from it.", "Scrappy didn't like your file and got diarrhea from it.", "Scrappy hated your file and got constipated AND diarrhea (at the same time) from it."]
}

struct ReminderSaying: Saying {
    static var status: String = "Don't loose your streak!"
    static var sayings: [String] = ["Scrappy is hungry; feed it!", "If you don't feed on Scrappy, it might feed on you...", "If you don't feed Scrappy, it might feed on your streak", "If you don't feed Scrappy, it might come after you...", "Don't loose your puny little streak", "If you don't feed Scrappy, it might eat you, and it'll have to go to court...."]
}

struct QuitScrappleSaying: Saying {
    static var status: String = "Quit Scrapple"
    static var sayings: [String] = ["Commit a bloody murder and kill Scrapple", "Dismember Scrapple", "Incinerate Scrapple", "Vaporize Scrapple"] // TODO: Add more
}
