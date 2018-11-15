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
    @IBOutlet weak var saveButton: LoadingButton!
    
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var textTextView: UITextView!
    
    var articleData: ArticleDataStruct? = nil
    var isSaved: Bool = false {
        didSet {
            if isSaved {
                self.saveButton.setImage(UIImage(named: "delete-icon"), for: .normal)
            } else {
                self.saveButton.setImage(UIImage(named: "save-icon"), for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleContainerView.addShadow()
        if let data = articleData {
            API.shared.markArticleAsRead(articleKey: data.key)
            titleLabel.text = data.title
            if let date = data.publishTime {
                dateLabel.text = date.toFormattedString()
            }
            self.setSaveIcon(articleKey: data.key)
        } else {
            // TODO: Handle error
        }
    }
    
    // MARK: - Actions
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard let articleKey = articleData?.key else { return }
        saveButton.showLoading()
        switch isSaved {
        case true:
            API.shared.deleteSavedArticle(articleKey: articleKey) { [weak self] (isSuccess) in
                DispatchQueue.main.async{
                    self?.saveButton.hideLoading()
                    if isSuccess {
                        self?.isSaved = false
                    }
                }
            }
        case false:
            API.shared.saveArticle(articleKey: articleKey) { [weak self] (isSuccess) in
                DispatchQueue.main.async{
                    self?.saveButton.hideLoading()
                    if isSuccess {
                        self?.isSaved = true
                    }
                }
            }
        }
    }
    
    // MARK: - Other
    
    func setSaveIcon(articleKey: String) {
        API.shared.isSavedArticle(articleKey: articleKey) { (isArticleSaved) in
            DispatchQueue.main.async{
                self.saveButton.isHidden = false
                self.isSaved = isArticleSaved
            }
        }
    }
}
