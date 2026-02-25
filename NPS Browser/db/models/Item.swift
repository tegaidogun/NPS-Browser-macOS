//
//  Item.swift
//  NPS Browser
//
//  Created by JK3Y on 8/4/18.
//  Copyright © 2018 JK3Y. All rights reserved.
//

import Foundation
import RealmSwift

class Item: Object {
    enum Property: String {
        case uuid,
        titleId,
        region,
        contentId,
        consoleType,
        fileType,
        name,
        pkgDirectLink,
        rap,
        downloadRapFile,
        zrif,
        requiredFw,
        lastModificationDate,
        fileSize,
        sha256,
        pk
    }
    
    @Persisted(primaryKey: true) var uuid: String = UUID().uuidString
    @Persisted var titleId: String?
    @Persisted var region: String?
    @Persisted var contentId: String?
    @Persisted var consoleType: String?
    @Persisted var fileType: String?
    @Persisted var name: String?
    @Persisted var pkgDirectLink: String?
    @Persisted var rap: String?
    @Persisted var downloadRapFile: String?
    @Persisted var zrif: String?
    @Persisted var requiredFw: Float?
    @Persisted var lastModificationDate: Date?
    @Persisted var fileSize: Int64?
    @Persisted var sha256: String?
    
    @Persisted var pk: String = ""
    
    convenience required init(tsvData: TSVData) {
        self.init()
        self.titleId = tsvData.titleId
        self.region = tsvData.region
        self.name = tsvData.name!
        self.pkgDirectLink = tsvData.pkgDirectLink
        self.lastModificationDate = tsvData.lastModificationDate
        self.fileSize = tsvData.fileSize
        self.sha256 = tsvData.sha256
        self.contentId = tsvData.contentId
        
        self.consoleType = tsvData.consoleType.rawValue
        self.fileType = tsvData.fileType.rawValue
        
        self.zrif = tsvData.zrif
        self.requiredFw = tsvData.requiredFw
        self.rap = tsvData.rap
        self.downloadRapFile = tsvData.downloadRapFile
        
        self.pk = "\(region!)\(fileType!)\(titleId!)\(contentId!)"
    }
    
    static public func asObject(fromObject: Item) -> Item {
        let obj = Item()
        obj.titleId = fromObject.titleId
        obj.region = fromObject.region
        obj.name = fromObject.name
        obj.pkgDirectLink = fromObject.pkgDirectLink
        obj.lastModificationDate = fromObject.lastModificationDate
        obj.fileSize = fromObject.fileSize
        obj.sha256 = fromObject.sha256
        obj.contentId = fromObject.contentId
        obj.consoleType = fromObject.consoleType
        obj.fileType = fromObject.fileType
        
        obj.zrif = fromObject.zrif
        obj.requiredFw = fromObject.requiredFw
        obj.rap = fromObject.rap
        obj.downloadRapFile = fromObject.downloadRapFile
        
        let pk: String = "\(fromObject.region ?? "")\(fromObject.fileType ?? "")\(fromObject.titleId ?? "")\(fromObject.contentId ?? "")"
        obj.pk = pk
        
        return obj
    }
}
