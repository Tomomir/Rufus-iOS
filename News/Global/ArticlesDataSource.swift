//
//  ArticlesDataSource.swift
//  News
//
//  Created by Tomas Pecuch on 10/11/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import Foundation
import UIKit
import DeepDiff

enum ArticleDataMode {
    case all
    case paid
    case saved
    case read
}

struct ArticleDataStruct: Hashable {
    let author: String
    let category: String
    let publishTime: Date?
    let title: String
    let subtitle: String
    let text: String?
    let key: String
    let imageURL: String
    let imageIsSaved: Bool
    let paid: Bool
    
    init(dict: [String: Any], key: String, imageSaved: Bool = false) {
        author = dict["author"] as! String
        if let newCategory = dict["category"] as? String {
            category = newCategory
        } else {
            category = ""
        }
         if let publishTimeInterval = dict["publishTime"] as? Double {
            publishTime = Date(timeIntervalSince1970: publishTimeInterval)
        } else {
            publishTime = nil
        }
        title = dict["title"] as! String
        subtitle = dict["subtitle"] as! String
        self.key = key
        if let image = dict["image"] as? String {
            self.imageURL = image
        } else {
            self.imageURL = ""
        }
        if let isPaid = dict["paid"] as? Bool {
            paid = isPaid
        } else {
            paid = false
        }
        if let data = dict["data"] as? String {
            text = data
        } else {
            text = nil
        }
        imageIsSaved = imageSaved
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
        dict["paid"] = self.paid
        
        return dict
    }
}


class ArticlesDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    // singleton
    static var shared = ArticlesDataSource()
    
    var tableView: UITableView? = nil
    
    var allArticles = [ArticleDataStruct]()
    var articlesToShow = [ArticleDataStruct]()
    
    var selectedCategoryKey = "all"
    var mode: ArticleDataMode = .all
    var parent: CategoryPageVC?
    
    override init() {
        super.init()
        
        // set observer for notification when articles are loaded
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(setInitialArticles(notification:)), name: Notification.Name("articles_inital_loaded"), object: nil)
        nc.addObserver(self, selector: #selector(updateArticles(notification:)), name: Notification.Name("articles_updated"), object: nil)

    }
    
    deinit {
        // removes the notification observer
        NotificationCenter.default.removeObserver(self)
    }
    
    
    /// sets articles array after initial load
    ///
    /// - Parameter notification: notification containing articles to show
    @objc func setInitialArticles(notification: NSNotification) {
        var dict = notification.object as! [String : Any]
        if let articles = dict["articles"] as? [ArticleDataStruct] {
            allArticles = articles
            self.setCategory(categoryKey: selectedCategoryKey, reloadData: true)
            if let parentVC = parent {
                if let label = parentVC.noArticlesLabel {
                    if selectedCategoryKey != "all" {
                        label.isHidden = articlesToShow.count != 0
                    }
                }
            }
        }
    }
    
    
    /// updates articles array
    ///
    /// - Parameter notification: notification containing articles to show
    @objc func updateArticles(notification: NSNotification) {
        var dict = notification.object as! [String : Any]
        if let articles = dict["articles"] as? [ArticleDataStruct] {
            allArticles = articles
            self.setCategory(categoryKey: selectedCategoryKey, reloadData: true)
            if let parentVC = parent {
                if let label = parentVC.noArticlesLabel {
                    if selectedCategoryKey != "all" {
                        label.isHidden = articlesToShow.count != 0
                    }
                }
            }
        }
    }
    
    // MARK: - UITableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return articlesToShow.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        // init and setup article cell
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath) as! ArticleCell
        if mode == .saved {
            cell.setData(articleData: articlesToShow[indexPath.row], isOfflineMode: true)
        } else {
            cell.setData(articleData: articlesToShow[indexPath.row])
        }
        
        cell.separatorView.isHidden = indexPath.row == articlesToShow.count - 1
    
        return cell
    }
    
    // MARK: - Other
    
    // filter articles to just given category
    func setCategory(categoryKey: String, reloadData: Bool) {
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
        if reloadData {
            let changes = diff(old: oldArticles, new: articlesToShow)
            tableView?.reload(changes: changes)
        }

        
        
    }
    
    // set displaying mode for the tableView
    func setMode(mode: ArticleDataMode) {
        self.mode = mode
        switch mode {
        case .all:
            self.setCategory(categoryKey: selectedCategoryKey, reloadData: true)
        case .paid:
            let oldArticles = articlesToShow
            self.setCategory(categoryKey: selectedCategoryKey, reloadData: false)
            articlesToShow = articlesToShow.filter({ (article) -> Bool in
                if article.paid == true {
                    if CreditsDataSource.shared.boughtArticleKeys.contains(article.key) {
                        return true
                    }
                }
                return false
            })
            let changes = diff(old: oldArticles, new: articlesToShow)
            tableView?.reload(changes: changes)
        case .saved:
            let oldArticles = articlesToShow
            let allSaved = DatabaseManager.shared.get(Article.self)
            articlesToShow.removeAll()
            for article in allSaved {
                let id = article.id
                articlesToShow.append(ArticleDataStruct(dict: article.getAsJSON(), key: id, imageSaved: true))
            }
            let changes = diff(old: oldArticles, new: articlesToShow)
            tableView?.reload(changes: changes)
        case .read:
            API.shared.getReadArticles { [weak self] (result) in
                switch result {
                case .success(let array):
                    guard let oldArticles = self?.articlesToShow else { return }
                    guard let allArticles = self?.allArticles else { return }
                    self?.articlesToShow = allArticles.filter({ (article) -> Bool in
                        if array[article.key] != nil {
                            return true
                        } else {
                            return false
                        }
                    })
                    let changes = diff(old: oldArticles, new: (self?.articlesToShow)!)
                    self?.tableView?.reload(changes: changes)
                case .failure(let error):
                    AlertManager.shared.showBasicAlert(title: "Could not load saved articles", text: error.localizedDescription)
                }
            }
        }
    }
    
}
