//
//  CompatPack.swift
//  NPS Browser
//
//  Created by JK3Y on 8/10/18.
//  Copyright © 2018 JK3Y. All rights reserved.
//

import Foundation
import RealmSwift

class CompatPack: Object {
    enum Property: String {
        case titleId, downloadUrl, type, uuid
    }
    
    @Persisted var titleId: String?
    @Persisted var downloadUrl: String?
    @Persisted var type: String?
    @Persisted(primaryKey: true) var uuid: String = UUID().uuidString
}
