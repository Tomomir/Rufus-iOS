//
//  MainVC.swift
//  News
//
//  Created by Tomas Pecuch on 16/10/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // navigation bar outlets
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var navigationLogoImageView: UIImageView!
    @IBOutlet weak var navigationCreditsImageView: UIImageView!
    @IBOutlet weak var navigationCreditsLabel: UILabel!
    @IBOutlet weak var navigationBlurView: UIVisualEffectView!
    
    @IBOutlet weak var tableView: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let url = Environment().configuration(PlistKey.backgroundColor)
        print(url)
        
        self.setupVC()
    }
    
    // MARK: - UITableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let firstCell = tableView.dequeueReusableCell(withIdentifier: "ArticlesCollectionCell", for: indexPath)
            return firstCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)
        
        return cell
    }
    
    // MARK: - Other
    
    func setupVC() {
        // allows us to have different cell heights without defiing exact height for every cell
        tableView.estimatedRowHeight = 299
        tableView.rowHeight = UITableView.automaticDimension
        
        // moves tableview starting position so it doesnt start under navigation bar
        tableView.contentInset = UIEdgeInsets(top: navigationBarView.bounds.origin.y + navigationBarView.bounds.size.height, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
    }

}
