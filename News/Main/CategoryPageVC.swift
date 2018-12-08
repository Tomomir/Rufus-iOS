//
//  CategoryPageVC.swift
//  News
//
//  Created by Tomas Pecuch on 16/11/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit

class CategoryPageVC: UIViewController, UITableViewDelegate {

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noArticlesLabel: UILabel!
    
    var refreshControl : UIRefreshControl? = UIRefreshControl()
    var articleDataSource = ArticlesDataSource()
    var categoryName = ""
    var navigationBarView: UIView?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        articleDataSource.tableView = tableView
        tableView.dataSource = articleDataSource
        tableView.delegate = self
        
        // allows us to have different cell heights without defiing exact height for every cell
        tableView.estimatedRowHeight = 299
        tableView.rowHeight = UITableView.automaticDimension
        
        // moves tableview starting position so it doesnt start under navigation bar
        if let navBar = navigationBarView {
            tableView.contentInset = UIEdgeInsets(top: navBar.bounds.origin.y + navBar.bounds.size.height + 10, left: 0, bottom: 0, right: 0)
            tableView.scrollIndicatorInsets = tableView.contentInset
        }

        //refresh controll
        refreshControl?.addTarget(self, action: #selector(pullToRefreshAction), for: .valueChanged)
        articleDataSource.parent = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        print("did appear \(categoryName)")
        CategoryDataSource.shared.selectCategory(categoryKey: articleDataSource.selectedCategoryKey)
        tableView.refreshControl = refreshControl
        if articleDataSource.selectedCategoryKey != "all" {
            noArticlesLabel.isHidden = articleDataSource.articlesToShow.count != 0
        }
    }
    
    @objc func pullToRefreshAction(_ sender: Any) {
        API.shared.getArticles(isInitialLoad: false) { [weak self] success in
            self?.refreshControl?.endRefreshing()
        }
        //        API.shared.getArticles { [weak self] in
        //            self?.refreshControl.endRefreshing()
        //            if let table = self?.tableView {
        //                UIView.transition(with: table, duration: 0.6, options: .transitionCrossDissolve, animations: {table.reloadData()}, completion: nil)
        //            }
        //        }
    }
    
    // MARK: - UITableView delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let article = articleDataSource.articlesToShow[indexPath.row]
        if article.paid == true {
            if CreditsDataSource.shared.isArticleBought(articleKey: article.key) == false {
                if DatabaseManager.shared.get(type: Article.self, id: article.key) == nil {
                    AlertManager.shared.showBasicAlert(title: "Can't open artile", text: "You need to unlock it first.")
                    return
                }
            }
        }
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ArticleDetailVC") as? ArticleDetailVC
        vc?.articleData = articleDataSource.articlesToShow[indexPath.row]
        if self.articleDataSource.mode == .saved {
            vc?.mode = .offline
        }
        self.navigationController?.pushViewController(vc!, animated: true)
    }


    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
