//
//  DetailsViewController.swift
//  NPS Browser
//
//  Created by JK3Y on 5/6/18.
//  Copyright © 2018 JK3Y. All rights reserved.
//

import Cocoa
import Promises

class DetailsViewController: NSViewController {
    
    @IBOutlet weak var chkBookmark: NSButton!
    @IBOutlet weak var btnDownload: NSButton!
    @IBOutlet weak var chkDLGame: NSButton!
    @IBOutlet weak var chkDLUpdate: NSButton!
    @IBOutlet weak var chkDLCompatPack: NSButton!
    @IBOutlet weak var lblName: NSTextField!
    @IBOutlet weak var lblRegionLabel: NSTextField!
    @IBOutlet weak var lblRegionValue: NSTextField!
    @IBOutlet weak var lblFWLabel: NSTextField!
    @IBOutlet weak var lblFWValue: NSTextField!
    @IBOutlet weak var detailSeparator: NSBox!
    
    var windowDelegate: WindowDelegate?
    var selectedItems: [Item] = []
    var multiSelectCount: Int = 1

    override var representedObject: Any? {
        didSet {
            if multiSelectCount > 1 {
                showMultiSelectUI()
            } else {
                showSingleItemUI()
            }
        }
    }

    private func showMultiSelectUI() {
        btnDownload.isEnabled = true
        updateDownloadButtonTitle()

        chkBookmark.isHidden = true

        DispatchQueue.main.async {
            self.lblName?.stringValue = "\(self.multiSelectCount) items selected"
        }
        lblRegionLabel?.isHidden = true
        lblRegionValue?.isHidden = true
        lblFWLabel?.isHidden = true
        lblFWValue?.isHidden = true
        detailSeparator?.isHidden = false

        chkDLGame.isEnabled = true
        chkDLGame.isHidden = false
        chkDLGame.title = "Game"
        chkDLUpdate.isHidden = true
        chkDLUpdate.isEnabled = false
        chkDLCompatPack.isHidden = true
        chkDLCompatPack.isEnabled = false

        getBoxartViewController().representedObject = nil
    }

    private func showSingleItemUI() {
        lblRegionLabel?.isHidden = false
        lblRegionValue?.isHidden = false
        lblFWLabel?.isHidden = false
        lblFWValue?.isHidden = false
        detailSeparator?.isHidden = false
        chkBookmark.isHidden = false

        enableBookmarkButton()
        toggleBookmark()
        enableDownloadOptions()
        updateDownloadButtonTitle()

        getBoxartViewController().representedObject = representedObject
    }

    private func updateDownloadButtonTitle() {
        if multiSelectCount > 1 {
            btnDownload.title = "Download (\(multiSelectCount))"
        } else {
            btnDownload.title = "Download"
        }
    }

    @IBAction func btnDownloadClicked(_ sender: Any) {
        let itemsToDownload: [Item]
        if multiSelectCount > 1 && !selectedItems.isEmpty {
            itemsToDownload = selectedItems
        } else {
            itemsToDownload = [getROManagedObject()]
        }

        var queuedCount = 0

        for obj in itemsToDownload {
            var baseDLItem: DLItem? = nil

            if chkDLGame.state == .on {
                if let url = try? obj.pkgDirectLink?.asURL() {
                    sendDLData(item: obj, url: url, fileType: .Game)
                    queuedCount += 1
                }
            }
            if chkDLUpdate.state == .on && chkDLUpdate.isEnabled && !chkDLUpdate.isHidden {
                let url = NetworkManager().getUpdateXMLURLFromHMAC(titleId: obj.titleId!)
                let pxml = NetworkManager().fetchUpdateXML(url: url)
                pxml().then { res in
                    self.sendDLData(item: obj, url: res, fileType: .Update)
                }
                queuedCount += 1
            }
            if chkDLCompatPack.state == .on && chkDLCompatPack.isEnabled && !chkDLCompatPack.isHidden {
                guard let ct = ConsoleType(rawValue: obj.consoleType!),
                      let ft = FileType(rawValue: obj.fileType!) else { continue }
                switch ct {
                case .PS3:
                    if let rapURL = obj.downloadRapFile.flatMap({ URL(string: $0) }) {
                        sendDLData(item: obj, url: rapURL, fileType: .RAP)
                        queuedCount += 1
                    }
                case .PSV:
                    if ft == .Game, let titleId = obj.titleId {
                        if let cpacko: CompatPack = DBManager().fetch(CompatPack.self, predicate: NSPredicate(format: "titleId == %@ AND type == 'CompatPack'", titleId), sorted: nil).first {
                            let url = URL(string: cpacko.downloadUrl!)!
                            baseDLItem = Helpers().makeDLItem(data: obj, downloadUrl: url, fileType: .CPack)
                        }
                        if let cpatcho: CompatPack = DBManager().fetch(CompatPack.self, predicate: NSPredicate(format: "titleId == %@ AND type == 'CompatPatch'", titleId), sorted: nil).first {
                            let url = URL(string: cpatcho.downloadUrl!)!
                            let item = Helpers().makeDLItem(data: obj, downloadUrl: url, fileType: .CPatch)
                            baseDLItem?.doNext = item
                            item.parentItem = baseDLItem
                        }
                        if let base = baseDLItem {
                            Helpers().getSharedAppDelegate().downloadManager.addToDownloadQueue(data: base)
                            queuedCount += 1
                        }
                    }
                default: break
                }
            }
        }

        if queuedCount > 0 {
            let dm = Helpers().getSharedAppDelegate().downloadManager
            dm.startBatch(count: queuedCount)

            if queuedCount == 1 {
                let name = itemsToDownload.first?.name ?? "Download"
                Helpers().makeNotification(title: "Downloading", subtitle: name)
            } else {
                Helpers().makeNotification(title: "Downloading \(queuedCount) packages", subtitle: "Added to download queue")
            }
        }
    }
    
    @IBAction func btnBookmarkToggle(_ sender: NSButton) {
        if (sender.state == .on) {
            let bookmark = Bookmark(item: getROManagedObject())
            DBManager().store(object: bookmark)
        } else {
            let bookmark = DBManager().fetch(Bookmark.self, predicate: NSPredicate(format: "uuid == %@", getROManagedObject().pk)).first
            DBManager().delete(object: bookmark!)
        }
    }

    func enableBookmarkButton() {
        let link = getROManagedObject().pkgDirectLink
        if (link == "MISSING") {
            btnDownload.isEnabled = false
            chkBookmark.isEnabled = false
        } else {
            btnDownload.isEnabled = true
            chkBookmark.isEnabled = true
        }
    }
    
    func enableDownloadOptions() {
        let ctype: ConsoleType = ConsoleType(rawValue: getROManagedObject().consoleType!)!
        let ftype: FileType = FileType(rawValue: getROManagedObject().fileType!)!
        
        chkDLGame.title = ftype.rawValue
        
        switch(ctype) {
        case .PSV:
            switch(ftype) {
            case .Game:
                let titleId = getROManagedObject().titleId
                chkDLCompatPack.title = "CPack"
                chkDLGame.isEnabled = true
                chkDLUpdate.isEnabled = true
                chkDLUpdate.isHidden = false
                chkDLCompatPack.isHidden = false
                
                try! RealmStorageContext().fetch(CompatPack.self, predicate: NSPredicate(format: "titleId == %@", titleId!)) { result in
                    if (result.isEmpty) {
                        chkDLCompatPack.isEnabled = false
                    } else {
                        chkDLCompatPack.isEnabled = true
                    }
                }
            default:
                chkDLCompatPack.isHidden = true
                chkDLCompatPack.isEnabled = false
                chkDLUpdate.isHidden = true
                chkDLUpdate.isEnabled = false
            }
        case .PS3:
            let rap = getROManagedObject().rap!
            chkDLCompatPack.isHidden = false
            chkDLUpdate.isHidden = true
            if (rap == "NOT REQUIRED" || rap == "UNLOCK/LICENSE BY DLC" || rap == "MISSING") {
                chkDLCompatPack.title = rap
                chkDLCompatPack.isEnabled = false
            } else {
                chkDLCompatPack.title = "RAP"
                chkDLCompatPack.isEnabled = true
            }
        default:
            chkDLUpdate.isHidden = true
            chkDLCompatPack.isHidden = true
        }
    }
    
    func toggleBookmark() {
        let predicate = NSPredicate(format: "uuid == %@", getROManagedObject().pk)
        let bookmark = DBManager().fetch(Bookmark.self, predicate: predicate)

        if bookmark.isEmpty {
            chkBookmark.state = .off
        } else {
            chkBookmark.state = .on
        }
    }
    
    func toggleBookmark(comparePK: String) {
        if getROManagedObject().pk == comparePK {
            chkBookmark.state = .off
        }
    }

    func sendDLData(url: URL, fileType: FileType) {
        sendDLData(item: getROManagedObject(), url: url, fileType: fileType)
    }

    func sendDLData(item: Item, url: URL, fileType: FileType) {
        let dlItem = Helpers().makeDLItem(data: item, downloadUrl: url, fileType: fileType)
        Helpers().getSharedAppDelegate().downloadManager.addToDownloadQueue(data: dlItem)
    }
    
    func getROManagedObject() -> Item {
        return representedObject as! Item
    }
    
    func getBoxartViewController() -> GameArtworkViewController {
        let vc: GameArtworkViewController = parent?.children[1] as! GameArtworkViewController
        return vc
    }
}
