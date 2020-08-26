//
//  ShareViewController.swift
//  ShareToScrapbook
//
//  Created by Linus Skucas on 8/26/20.
//  Copyright © 2020 Linus Skucas. All rights reserved.
//

import Cocoa

class ShareViewController: NSViewController {
    @IBOutlet var textOutletField: NSTextField!

    override var nibName: NSNib.Name? {
        return NSNib.Name("ShareViewController")
    }

    override func loadView() {
        super.loadView()

        // Insert code here to customize the view
        let item = extensionContext!.inputItems[0] as! NSExtensionItem
        if let attachments = item.attachments {
            NSLog("Attachments = %@", attachments as NSArray)
        } else {
            NSLog("No Attachments")
        }
    }

    @IBAction func send(_ sender: AnyObject?) {
        let updateText = textOutletField.stringValue
        if let item = extensionContext?.inputItems.first as? NSExtensionItem {
            if let itemProvider = item.attachments?.first {
                if itemProvider.hasItemConformingToTypeIdentifier("public.file-url") {
                    itemProvider.loadItem(forTypeIdentifier: "public.url", options: nil, completionHandler: { (url, error) -> Void in
                        if let shareURL = url as? URL {
                            let update = Update(image: MediaFile(data: try! Data(contentsOf: shareURL), filename: shareURL.relativePath, fileType: shareURL.pathExtension), text: updateText)
                            update.sendToSlack(successClosure: {_ in UserData.shared.sendNotification(title: UpdateSuccessSaying.status, subtitle: UpdateSuccessSaying.sayings.randomElement()!, time: nil, interval: nil)}, failureClosure: { error in
                                NSLog(error.rawValue)
                                UserData.shared.sendNotification(title: UpdateSendFailSaying.status, subtitle: UpdateSendFailSaying.sayings.randomElement()!, time: nil, interval: nil)
                            })
                        }
                        self.extensionContext?.completeRequest(returningItems: [], completionHandler:nil)
                    })
                }
            }
        }
    }

    @IBAction func cancel(_ sender: AnyObject?) {
        let cancelError = NSError(domain: NSCocoaErrorDomain, code: NSUserCancelledError, userInfo: nil)
        extensionContext!.cancelRequest(withError: cancelError)
    }
}
