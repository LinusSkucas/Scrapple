//
//  Update.swift
//  Scrapple
//
//  Created by Linus Skucas on 7/30/20.
//  Copyright © 2020 Linus Skucas. All rights reserved.
//

import Foundation
import SKWebAPI

struct MediaFile {
    var data: Data
    var filename: String
    var fileType: String
}


struct Update {
    var image: MediaFile
    var text: String
    
    #if DEBUG
    let channel = "#bot-spam"
    #else
    let channel = "#scrapbook"
    #endif
    
    func sendToSlack(successClosure: @escaping (_ file: File) -> Void, failureClosure: @escaping (_ error: SlackError) -> Void) {
        guard UserData.shared.oauthToken?.oauthToken != nil else { return }  // todo handle error
        let webAPI = WebAPI(token: UserData.shared.oauthToken!.oauthToken!)
        webAPI.uploadFile(file: image.data, filename: image.filename, filetype: image.fileType, initialComment: text, channels: [channel], success: successClosure, failure: failureClosure)
    }
}

