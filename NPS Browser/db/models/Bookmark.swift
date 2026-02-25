//
//  Bookmark.swift
//  NPS Browser
//
//  Created by JK3Y on 8/11/18.
//  Copyright © 2018 JK3Y. All rights reserved.
//

import Foundation
import RealmSwift

class Bookmark: Object {
    enum Property: String {
        case titleId,downloadUrl, name, type, zrif, uuid
    }
    
    @Persisted var titleId: String?
    @Persisted var downloadUrl: String?
    @Persisted var name: String?
    @Persisted var fileType: String?
    @Persisted var consoleType: String?
    @Persisted var zrif: String?
    @Persisted(primaryKey: true) var uuid: String?
    
    convenience init(item: Item) {
        self.init()
        self.titleId = item.titleId
        self.downloadUrl = item.pkgDirectLink
        self.name = item.name
        self.fileType = item.fileType
        self.consoleType = item.consoleType
        self.zrif = item.zrif
        self.uuid = item.pk
    }
}
