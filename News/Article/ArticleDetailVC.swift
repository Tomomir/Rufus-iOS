//
//  ArticleDetailVC.swift
//  News
//
//  Created by Tomas Pecuch on 21/10/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import UIKit

class ArticleDetailVC: UIViewController {

    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var textTextView: UITextView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleContainerView.addShadow()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

    // MARK: - Other

}
