//
//  ArticlesDataSource.swift
//  News
//
//  Created by Tomas Pecuch on 10/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import Foundation
import UIKit
import DeepDiff

struct ArticleDataStruct: Hashable {
    let author: String
    let category: String
    let featured: Bool
    let publishTime: Date?
    let status: String
    let title: String
    let subtitle: String
    let text: String?
    let key: String
    
    init(dict: [String: Any], key: String) {
        author = dict["author"] as! String
        if let newCategory = dict["category"] as? String {
            category = newCategory
        } else {
            category = ""
        }
        featured = dict["featured"] as! Bool
        if let publishTimeInterval = dict["publishTime"] as? Double {
            publishTime = Date(timeIntervalSince1970: publishTimeInterval)
        } else {
            publishTime = nil
        }
        status = dict["status"] as! String
        title = dict["title"] as! String
        subtitle = dict["subtitle"] as! String
        text = nil
        self.key = key
    }
    
    // MARK: - Hashable protocol
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(key)
    }
    
    // MARK: - Other
    
    func getAsDict() -> [String: Any] {
        var dict = [String : Any]()
        
        dict["category"] = self.category
        dict["publishTime"] = publishTime?.timeIntervalSince1970
        dict["title"] = self.title
        dict["subtitle"] = self.subtitle
        dict["key"] = self.key
        
        return dict
    }
}


class ArticlesDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    static var shared = ArticlesDataSource()
    
    var tableView: UITableView? = nil
    
    var allArticles = [ArticleDataStruct]()
    var articlesToShow = [ArticleDataStruct]()
    
    var selectedCategoryKey = "all"
    
    override init() {
        super.init()
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(setInitialArticles(notification:)), name: Notification.Name("articles_inital_loaded"), object: nil)
        nc.addObserver(self, selector: #selector(updateArticles(notification:)), name: Notification.Name("articles_updated"), object: nil)

    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func setInitialArticles(notification: NSNotification) {
        var dict = notification.object as! [String : Any]
        if let articles = dict["articles"] as? [ArticleDataStruct] {
            allArticles = articles
            self.setCategory(categoryKey: selectedCategoryKey)
        }
    }
    
    @objc func updateArticles(notification: NSNotification) {
        //var articles = Array(arrayLiteral: notification.object!) as! [ArticleDataStruct]
        var dict = notification.object as! [String : Any]
        if let articles = dict["articles"] as? [ArticleDataStruct] {
            allArticles = articles
            self.setCategory(categoryKey: selectedCategoryKey)
        }
    }
    
    func setCategory(categoryKey: String) {
        selectedCategoryKey = categoryKey
        let oldArticles = articlesToShow
        
        if categoryKey == "all" {
            articlesToShow = allArticles
        } else {
            let filteredArticles = allArticles.filter { (article) -> Bool in
                if article.category == categoryKey {
                    return true
                } else {
                    return false
                }
            }
            articlesToShow = filteredArticles
        }
        let changes = diff(old: oldArticles, new: articlesToShow)
        tableView?.reload(changes: changes)
        
        
    }
    
    // MARK: - UITableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        //        if indexPath.row == 0 {
        //            let firstCell = tableView.dequeueReusableCell(withIdentifier: "ArticlesCollectionCell", for: indexPath)
        //            return firstCell
        //        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        cell.titleLabel.text = articlesToShow[indexPath.row].title
        cell.subtitleLabel.text = articlesToShow[indexPath.row].subtitle
        return cell
    }
    
}
