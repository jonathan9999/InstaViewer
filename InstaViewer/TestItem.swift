//
//  TestItem.swift
//  networking
//
//  Created by Edward Bai on 1/4/17.
//  Copyright © 2017 Coconut Apps. All rights reserved.
//

import Foundation
import RealmSwift

class TestItem: Object {
    dynamic var itemId = "id"
    dynamic var text = "text"
    dynamic var timestamp = 100_000
    dynamic var imageUrl = Constants.String.kPlaceholderUrl
    dynamic var videoUrl = Constants.String.kPlaceholderUrl
    
    override class func primaryKey() -> String? {
        return "itemId"
    }
    
    override class func indexedProperties() -> [String] {
        return ["timestamp"]
    }
    
    func save() {
        let realm = try! Realm()
        try! realm.write {
            realm.add(self)
        }
    }
}
