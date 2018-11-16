//
//  ArticlesDataSource.swift
//  News
//
//  Created by Tomas Pecuch on 10/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import Foundation
import UIKit

struct ArticleDataStruct {
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
}


class ArticlesDataSource: NSObject, UITableViewDelegate, UITableViewDataSource {
    
    static var shared = ArticlesDataSource()
    
    var tableView: UITableView? = nil
    
    var allArticles = [ArticleDataStruct]()
    var articlesToShow = [ArticleDataStruct]()
    
    var selectedCategoryKey = "all"
    
    func setInitialArticles(articles: [ArticleDataStruct]) {
        self.allArticles = articles
        self.articlesToShow = articles
    }
    
    func setCategory(categoryKey: String) {
        guard let table = tableView else { return }
        
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
        UIView.transition(with: table, duration: 0.2, options: .transitionCrossDissolve, animations: {table.reloadData()}, completion: nil)

    }
    
    // MARK: - UITableView datasource
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ArticlesDataSource.shared.articlesToShow.count
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
