//
//  DBMigration.swift
//  NPS Browser
//
//  Created by JK3Y on 8/25/18.
//  Copyright © 2018 JK3Y. All rights reserved.
//

import Foundation
import RealmSwift

final class DBMigration {
    // MARK: - Properties
    static let currentSchemaVersion: UInt64 = 2
    
    static func configureMigration() -> Realm {
        let config = Realm.Configuration(
            schemaVersion: 2,
            
            migrationBlock: { migration, oldSchemaVersion in
                if oldSchemaVersion < 1 {
                    zeroToOne(with: migration)
                }
            },
            deleteRealmIfMigrationNeeded: true
        )
        
        do {
            return try Realm(configuration: config)
        } catch {
            // If the DB file is from an incompatible Realm version, delete and recreate
            if let realmURL = config.fileURL {
                let realmURLs = [
                    realmURL,
                    realmURL.appendingPathExtension("lock"),
                    realmURL.appendingPathExtension("note"),
                    realmURL.appendingPathExtension("management")
                ]
                for url in realmURLs {
                    try? FileManager.default.removeItem(at: url)
                }
            }
            return try! Realm(configuration: config)
        }
    }
    
    
    // MARK: - Migrations
    static func zeroToOne(with migration: Migration) {
        migration.enumerateObjects(ofType: Item.className()) { oldItem, newItem in
            let filetype = oldItem!["fileType"] as! String
            let tid = oldItem!["titleId"] as! String
            let reg = oldItem!["region"] as! String
            let cid = oldItem!["contentId"] as! String
            
            newItem?["pk"] = "\(reg)\(filetype)\(tid)\(cid)"
        }
    }
}
