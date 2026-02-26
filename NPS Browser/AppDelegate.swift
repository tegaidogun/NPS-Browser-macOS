//
//  AppDelegate.swift
//  NPS Browser
//
//  Created by JK3Y on 4/28/18.
//  Copyright © 2018 JK3Y. All rights reserved.
//

import Cocoa
import SwiftyBeaver
import RealmSwift
import SwiftyUserDefaults
import UserNotifications

let log = SwiftyBeaver.self

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate, UNUserNotificationCenterDelegate {
    
    lazy var downloadManager: DownloadManager = DownloadManager()
    private var notificationsAuthorized = false

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        setupSwiftyBeaverLogging()
        setupDownloadsDirectory()
        setupNotifications()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        downloadManager.stopAndStoreDownloadList()
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }

    func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }

    func setupSwiftyBeaverLogging() {
        let console = ConsoleDestination()
        let file = FileDestination()

        log.addDestination(console)
        log.addDestination(file)
    }
    
    func setupDownloadsDirectory() {
        var dlFolder: URL? = Defaults[.dl_library_location]
        
        let dlDirName = "NPS Downloads"
        
        do {
            try Folder(path: dlFolder!.path).createSubfolderIfNeeded(withName: dlDirName)
        } catch {
            dlFolder = try! NSHomeDirectory().asURL().appendingPathComponent("Downloads")
            Defaults.set(dlFolder!.absoluteURL, forKey: "dl_library_location")
            try! Folder(path: dlFolder!.path).createSubfolderIfNeeded(withName: dlDirName)
        }
    }
    
    // MARK: - Notifications
    
    private func setupNotifications() {
        let center = UNUserNotificationCenter.current()
        center.delegate = self
        center.requestAuthorization(options: [.alert, .sound]) { granted, error in
            DispatchQueue.main.async {
                self.notificationsAuthorized = granted
            }
        }
    }
    
    func showNotification(title: String, subtitle: String) {
        if notificationsAuthorized {
            let content = UNMutableNotificationContent()
            content.title = title
            content.subtitle = subtitle
            content.sound = .default
            
            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil
            )
            UNUserNotificationCenter.current().add(request)
        } else {
            DispatchQueue.main.async {
                self.showInAppBanner(title: title, subtitle: subtitle)
            }
        }
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .sound])
    }

    // MARK: - In-App Banner Fallback

    private func showInAppBanner(title: String, subtitle: String) {
        guard let window = NSApp.mainWindow ?? NSApp.windows.first else { return }
        guard let contentView = window.contentView else { return }

        let bannerHeight: CGFloat = 52
        let bannerWidth: CGFloat = min(contentView.bounds.width - 40, 360)
        let bannerX = (contentView.bounds.width - bannerWidth) / 2

        let banner = NSVisualEffectView(frame: NSRect(x: bannerX, y: contentView.bounds.height, width: bannerWidth, height: bannerHeight))
        banner.material = .hudWindow
        banner.blendingMode = .withinWindow
        banner.state = .active
        banner.wantsLayer = true
        banner.layer?.cornerRadius = 10
        banner.layer?.masksToBounds = true

        let titleLabel = NSTextField(labelWithString: title)
        titleLabel.font = NSFont.systemFont(ofSize: 13, weight: .semibold)
        titleLabel.textColor = .labelColor
        titleLabel.frame = NSRect(x: 12, y: 26, width: bannerWidth - 24, height: 18)
        banner.addSubview(titleLabel)

        let subtitleLabel = NSTextField(labelWithString: subtitle)
        subtitleLabel.font = NSFont.systemFont(ofSize: 11)
        subtitleLabel.textColor = .secondaryLabelColor
        subtitleLabel.lineBreakMode = .byTruncatingTail
        subtitleLabel.frame = NSRect(x: 12, y: 8, width: bannerWidth - 24, height: 16)
        banner.addSubview(subtitleLabel)

        contentView.addSubview(banner)

        let targetY = contentView.bounds.height - bannerHeight - 8
        NSAnimationContext.runAnimationGroup({ ctx in
            ctx.duration = 0.3
            ctx.timingFunction = CAMediaTimingFunction(name: .easeOut)
            banner.animator().frame.origin.y = targetY
        })

        DispatchQueue.main.asyncAfter(deadline: .now() + 3.0) {
            NSAnimationContext.runAnimationGroup({ ctx in
                ctx.duration = 0.3
                ctx.timingFunction = CAMediaTimingFunction(name: .easeIn)
                banner.animator().alphaValue = 0
            }, completionHandler: {
                banner.removeFromSuperview()
            })
        }
    }

}

