//
//  SocialUser.swift
//  networking
//
//  Created by Edward Bai on 12/26/16.
//  Copyright © 2016 Coconut Apps. All rights reserved.
//

import UIKit
import RealmSwift

class SocialUser: Object {
    dynamic var id: String = Constants.String.kInvalidId
    dynamic var userName: String = Constants.String.kUnknownUsername
    dynamic var portraitImageUrl: String = Constants.String.kPlaceholderUrl

    override class func primaryKey() -> String? {
        return "id"
    }
}
