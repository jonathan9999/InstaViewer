//
//  SocialFeedViewController
//  networking
//
//  Created by Edward Bai on 12/18/16.
//  Copyright © 2016 Coconut Apps. All rights reserved.
//

import Foundation
import UIKit
import Alamofire
import AlamofireImage
import SwiftyJSON
import RealmSwift

class SocialFeedViewController: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
//    @IBOutlet weak var emptyTableLabel: UILabel!
    
    private var socialDataSource = SocialFeedDataSource(with: "9gag") // datasource instance
    private var reachedBottom = false // indicate if tableview has scrolled bottom
    
    init() {
        super.init(nibName: "SocialFeedViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureStyle()
        configureTableView()
        configureViews()
        
        // populate tableview from cache
        loadDataFromDisk()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    private func configureStyle() {
        self.navigationController?.hidesNavigationBarHairline = true
    }
    
    private func configureTableView() {
        // tableview settings
        self.tableView.register(UINib(nibName: "SocialFeedTableViewCell", bundle: nil), forCellReuseIdentifier: Constants.String.kReuseIdentifier)
        self.tableView.allowsSelection = false
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 410
        self.tableView.separatorStyle = .singleLine
        self.tableView.dataSource = socialDataSource
        self.tableView.tableFooterView = UIView()
        self.tableView.delegate = self
        
        // refresh control settings
        self.tableView.refreshControl = UIRefreshControl()
        if let refreshControl = self.tableView.refreshControl {
            self.tableView.addSubview(refreshControl)
            let title = NSAttributedString.init(
                string: "Release to update amazing content!",
                attributes: [NSForegroundColorAttributeName: UIColor.flatWhite])
            
            refreshControl.tintColor = UIColor.flatWhite
            refreshControl.backgroundColor = UIColor.flatMint
            refreshControl.attributedTitle = title
            refreshControl.addTarget(self, action: #selector(self.handleRefresh(refreshControl:)), for: .valueChanged)
        }
        
        // background view
        let emptyTableLabel = UILabel(frame: self.tableView.bounds)
        emptyTableLabel.text = "No data here. Pull to refresh"
        emptyTableLabel.numberOfLines = 0
        emptyTableLabel.textAlignment = .center
        emptyTableLabel.sizeToFit()
        self.tableView.backgroundView = emptyTableLabel
    }

    private func configureViews() {
        self.title = "Feeds"
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Settings", style: .plain, target: self, action: #selector(self.settings(_:)))
    }
    
    @objc private func settings(_: UIBarButtonItem) {
    }
    
    private func loadDataFromDisk() {
        let realm = try! Realm()
        let cachedFeeds: Results<SocialFeedItem> = realm.objects(SocialFeedItem.self).sorted(byProperty: "timestamp", ascending: false)
        print("Loaded \(cachedFeeds.count) feeds from disk")
        socialDataSource.addOldest(data: Array(cachedFeeds))
    }
    
    // refresh control handler
    @objc private func handleRefresh(refreshControl: UIRefreshControl) {
        refreshNewData()
    }
    // load newest data
    private func refreshNewData() {
        socialDataSource.fetchData(type: .new) {
            self.fetchDataCompleted()
        }
    }
    
    // load older data
    private func loadMoreData() {
        socialDataSource.fetchData(type: .old) {
            self.fetchDataCompleted()
        }
    }
    
    private func fetchDataCompleted() {
        self.tableView.reloadData()
        self.tableView.refreshControl?.endRefreshing()
        self.reachedBottom = false
//        self.emptyTableLabel.isHidden = !self.socialDataSource.isEmpty
//        self.tableView.isHidden = self.socialDataSource.isEmpty
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offsetY = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let frameHeight = scrollView.frame.size.height
        let threshold: CGFloat = 1000
        
        if offsetY > contentHeight - frameHeight - threshold
            && contentHeight > 0
            && !reachedBottom {
            reachedBottom = true
            self.loadMoreData()
        }
    }
}

