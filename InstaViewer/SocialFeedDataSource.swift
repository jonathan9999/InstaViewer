//
//  SocialFeedArray.swift
//  networking
//
//  Created by Edward Bai on 12/26/16.
//  Copyright © 2016 Coconut Apps. All rights reserved.
//

import Foundation
import UIKit
import AlamofireImage
import Alamofire
import SwiftyJSON
import RealmSwift

class SocialFeedDataSource: NSObject, UITableViewDataSource, NetworkingDataSource {
    
    private var _items: [SocialFeedItem]
    private var _startId: String?
    private var _endId: String?
    private var _latestTime: Int?
    private var _oldestTime: Int?
    
    fileprivate var _userId: String!
    
    // Image drawing related
    private let portraitFilter = RoundedCornersFilter(radius: 50)
    private let photoPlaceholderImage = UIImage(named: "photo-placeholder")
    private let portraitPlaceholderImage = UIImage(named: "person-placeholder")
    
    required init(with userId: String) {
        _items = [SocialFeedItem]()
        _userId = userId
    }

    // MARK: - Public methods
    
    // Updates datasource asynchronously
    // User perform UI changes in completion handler
    public func fetchData(type: FetchType, completion: @escaping () -> Void) {
        getBatchData(type: type, completion: completion)
    }
    
    public var isEmpty: Bool {
        get { return _items.isEmpty }
    }
    
    // MARK: - Fetchable protocol methods
    
    func handleError(_ error: Error) {
        print(error.localizedDescription)
    }
    
    func getBatchData(type: FetchType, completion: (() -> Void)?) {
        let maxId = type == .old ? _endId : nil
        
        Alamofire
            .request(Router.instagram(username: _userId, max_id: maxId))
            .validate()
            .responseJSON{
                response in
                switch response.result {
                case .failure(let error):
                    self.handleError(error)
                case .success(let value):
                    let json = JSON(value)
                    let items = self.parseJSON(data: json) as! [SocialFeedItem]
                    self.processBatchData(items, type: type, completion: completion)
                }
        }
    }
    
    func parseJSON(data: JSON) -> [AnyObject] {
        var result = [SocialFeedItem]()
        if let items = data["items"].array {
            for item in items {
                let user = SocialUser()
                user.id = item["user"]["id"].stringValue
                user.userName = item["user"]["username"].stringValue
                user.portraitImageUrl = item["user"]["profile_picture"].stringValue
                
                let feed = SocialFeedItem()
                let standardResUrl = RealmListString(string: item["images"]["standard_resolution"]["url"].stringValue)
                feed.id = item["id"].stringValue
                feed.timestamp = item["created_time"].intValue
                feed.user = user
                feed.text = item["caption"]["text"].stringValue
                feed.imageUrls.append(standardResUrl)
                feed.videoUrl = (item["type"].stringValue == "video") ?
                    Constants.String.kPlaceholderUrl :
                    item["videos"]["standard_resolution"]["url"].stringValue
                
                result.append(feed)
            }
        }
        
        return result
    }
    
    func processBatchData(_ data: [AnyObject], type: FetchType, completion: (() -> Void)?) {
        var items = data as! [SocialFeedItem]
        let realm = try! Realm()
        switch type {
        case .new:
            if let endTime = self._latestTime {
                items = items.filter { $0.timestamp > endTime }
                self.addLatest(data: items)
            } else {
                self.addOldest(data: items)
            }
        case .old:
            self.addOldest(data: items)
        }
        try! realm.write {
            for item in items {
                realm.add(item, update: true)
            }
        }

        completion?()
    }
    
    // MARK: - Dataset methods
    func addLatest(data: [SocialFeedItem]) {
        // dataset previously empty, update end as well
        if self._items.isEmpty, let lastItem = data.last {
            self._oldestTime = lastItem.timestamp
            self._endId = lastItem.id
        }
        
        self._items.insert(contentsOf: data, at: 0)
        if let firstItem = data.first {
            self._latestTime = firstItem.timestamp
            self._startId = firstItem.id
        }
        print("Datasource added \(data.count) items at front. Now data size = \(self._items.count)")
    }
    
    func addOldest(data: [SocialFeedItem]) {
        // dataset previously empty, update start as well
        if self._items.isEmpty, let firstItem = data.first {
            self._latestTime = firstItem.timestamp
            self._startId = firstItem.id
        }
        
        self._items.append(contentsOf: data)
        if let lastItem = data.last {
            self._oldestTime = lastItem.timestamp
            self._endId = lastItem.id
        }
        print("Datasource added \(data.count) items at back. Now data size = \(self._items.count)")
    }
    
    // MARK: - TableviewDataSource methods
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: Constants.String.kReuseIdentifier) as! SocialFeedTableViewCell
        let item = self._items[indexPath.row]
        let photoUrl = URL(string: item.imageUrls.isEmpty ?
            Constants.String.kPlaceholderUrl : item.imageUrls[0].stringValue)!
        
        let portraitUrl = URL(string: item.userPortraitImageUrl)!
        
        cell.usernameLabel.text = item.userName
        cell.mainTextlabel.text = item.text
        cell.mediaView.af_setImage(withURL: photoUrl, placeholderImage: photoPlaceholderImage)
        cell.portraitView.af_setImage(withURL: portraitUrl, placeholderImage: portraitPlaceholderImage, filter: portraitFilter)
        
        cell.separatorInset = .zero
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self._items.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self._items.isEmpty ? 0 : 1
    }

}
