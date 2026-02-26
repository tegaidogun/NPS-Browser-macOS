//
//  DownloadViewController.swift
//  NPS Browser
//
//  Created by JK3Y on 5/18/18.
//  Copyright © 2018 JK3Y. All rights reserved.
//

import Cocoa

class DownloadViewController: NSViewController {

    @IBOutlet weak var dlTableView: NSTableView!
    @IBOutlet var dlArrayController: NSArrayController!

    private var refreshTimer: Timer?

    override func viewDidLoad() {
        super.viewDidLoad()
        updateView()
    }

    override func viewWillAppear() {
        super.viewWillAppear()
        updateView()
        resizePopoverToFit()
        refreshTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            self?.updateView()
        }
    }

    override func viewWillDisappear() {
        super.viewWillDisappear()
        refreshTimer?.invalidate()
        refreshTimer = nil
    }

    @IBAction func clearCompleted(_ sender: Any) {
        Helpers().getSharedAppDelegate().downloadManager.removeCompleted()
        updateView()
        resizePopoverToFit()
    }
    
    func updateView() {
        let content = Helpers().getSharedAppDelegate().downloadManager.getObjectQueue()
        dlArrayController.content = content
        dlTableView?.reloadData()
    }

    private func resizePopoverToFit() {
        let itemCount = Helpers().getSharedAppDelegate().downloadManager.getObjectQueue().count
        let rowHeight: CGFloat = 58
        let headerHeight: CGFloat = 33
        let minHeight: CGFloat = 150
        let maxHeight: CGFloat = 600
        let contentHeight = headerHeight + CGFloat(max(itemCount, 1)) * rowHeight
        let newHeight = min(max(contentHeight, minHeight), maxHeight)
        self.preferredContentSize = NSSize(width: 420, height: newHeight)
    }
}
