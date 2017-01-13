//
//  Constants.swift
//  networking
//
//  Created by Edward Bai on 12/19/16.
//  Copyright © 2016 Coconut Apps. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

struct Constants {
    struct Number {
        static let kInvalidTimestamp = -1
    }
    
    struct String {
        static let kUnknownUsername = "UNKNOWN_USER"
        static let kInvalidId = "INVALID_ID"
        static let kEmptyText = "EMPTY_TEXT"
        static let kReuseIdentifier = "socialCell"
        static let kPlaceholderUrl = "https://www.example.com/"
    }
}

enum Router: URLRequestConvertible {
    case instagram(username: String, max_id: String?)
    
    var baseUrl: String {
        switch self {
        case .instagram(let username, _):
            return "https://www.instagram.com/\(username)/media"
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try baseUrl.asURL()
        var urlRequest = URLRequest(url: url)
        
        switch self {
        case .instagram(_, let max_id) where max_id != nil:
            urlRequest = try URLEncoding.default.encode(urlRequest, with: ["max_id": max_id!])
        case .instagram(_, nil):
            urlRequest = try URLEncoding.default.encode(urlRequest, with: nil)
        default:
            break;
        }
        
        return urlRequest
    }
    
}

protocol NetworkingDataSource {
    func getBatchData(type: FetchType, completion: (() -> Void)?)
    func parseJSON(data: JSON) -> [AnyObject]
    func handleError(_ error: Error)
    func processBatchData(_ data: [AnyObject], type: FetchType, completion: (() -> Void)?)
}

enum FetchType {
    case new, old
}
