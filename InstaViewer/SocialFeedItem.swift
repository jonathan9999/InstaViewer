//
//  SocialItem.swift
//  networking
//
//  Created by Edward Bai on 12/19/16.
//  Copyright © 2016 Coconut Apps. All rights reserved.
//

import UIKit
import RealmSwift

class SocialFeedItem: Object {
    
    dynamic var id: String = Constants.String.kInvalidId
    dynamic var timestamp: Int = Constants.Number.kInvalidTimestamp
    dynamic var user: SocialUser?
    dynamic var text: String = Constants.String.kEmptyText
    let imageUrls = List<RealmListString>()
    dynamic var videoUrl: String = Constants.String.kPlaceholderUrl
    
    var userName: String {
        return user?.userName ?? Constants.String.kUnknownUsername
    }
    
    var userPortraitImageUrl: String {
        return user?.portraitImageUrl ?? Constants.String.kPlaceholderUrl
    }
    
    override class func primaryKey() -> String? {
        return "id"
    }
    
    override class func indexedProperties() -> [String] {
        return ["timestamp"]
    }
}

class RealmListString: Object {
    dynamic var stringValue: String!
    
    convenience required init(string: String) {
        self.init()
        stringValue = string
    }
}
