//
//  ArticleCell.swift
//  News
//
//  Created by Tomas Pecuch on 19/10/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import UIKit

enum ArticleCellBoughtState {
    case freeArticle
    case boughtArticle
    case notBoughtPaidArticle
}

enum ArticleCellSavedState {
    case saved
    case notSaved
    case cantSave
}

enum ArticleCellMode {
    case articleCellModeAll
    case articleCellModeSaved
}

class ArticleCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var articleImageView: UIImageView!
    
    @IBOutlet weak var buyButton: LoadingButton!
    @IBOutlet weak var saveButton: LoadingButton!
    @IBOutlet weak var separatorView: UIView!
    
    var articleData: ArticleDataStruct?
    var saveState: ArticleCellSavedState = .notSaved
    var boughtState: ArticleCellBoughtState = .freeArticle
    var observerIsSet: Bool = false
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.configurate()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: - Actions
    
    @IBAction func buyAction(_ sender: Any) {
        guard let articleKey = articleData?.key else { return }
        if CreditsDataSource.shared.numberOfCredits < 1 {
            AlertManager.shared.showBasicAlert(title: "Can't buy article", text: "Not enough credits.")
            return
        }
        buyButton.setImage(nil, for: .normal)
        buyButton.showLoading()
        CreditsDataSource.shared.articleBought(articleKey: articleKey) { [weak self] (success) in
            self?.buyButton.hideLoading()
            if success {
                self?.setBoughtState(state: .boughtArticle)
                if DatabaseManager.shared.get(type: Article.self, id: articleKey) != nil {
                    self?.setSavedState(state: .saved)
                } else {
                    self?.setSavedState(state: .notSaved)
                }
            } else {
                AlertManager.shared.showBasicAlert(title: "Something went wrong", text: "Could not unlock the article.")
            }
        }
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard let articleKey = articleData?.key else { return }
        
        switch saveState {
        case .saved:
            DatabaseManager.shared.delete(Article.self, id: articleKey)
            ImageManager.shared.removeSavedImage(key: articleKey)
            self.setSavedState(state: .notSaved)
        case .notSaved:
            saveButton.setImage(nil, for: .normal)
            saveButton.showLoading()
            API.shared.getArticleContent(articleKey: articleKey) { [weak self] (content) in
                if var articleJSON = self?.articleData?.getAsDict() {
                    articleJSON["data"] = content
                    if let imageURL = self?.articleData?.imageURL {
                        ImageManager.shared.imageDownloaded(from: imageURL, completition: { (image) in
                            _ = ImageManager.shared.saveImageToDocumentsUnderKey(image: image, key: articleKey)
                            DatabaseManager.shared.addSingle(type: Article.self, json: articleJSON)
                            self?.saveButton.hideLoading()
                            self?.setSavedState(state: .saved)
                        })
                    } else {
                        DatabaseManager.shared.addSingle(type: Article.self, json: articleJSON)
                        self?.setSavedState(state: .saved)
                    }
                }
            }
        case .cantSave:
            return
        }
    }
    
    func setData(articleData: ArticleDataStruct, isOfflineMode: Bool = false) {
        self.articleData = articleData
        titleLabel.text = articleData.title
        subtitleLabel.text = articleData.subtitle
        if isOfflineMode {
            if let image = ImageManager.shared.getSavedImage(key: articleData.key) {
                articleImageView.image = image
            } else {
                articleImageView.image = UIImage(named: "placeholder_transparent")
            }
        } else {
            if articleData.imageURL != "" {
                articleImageView.downloaded(from: articleData.imageURL)
            } else {
                articleImageView.image = UIImage(named: "placeholder_transparent")
            }
        }
        
        if DatabaseManager.shared.get(type: Article.self, id: articleData.key) != nil {
            self.setSavedState(state: .saved)
        } else {
            self.setSavedState(state: .notSaved)
        }
        
        switch articleData.paid {
        case true:
            if CreditsDataSource.shared.isArticleBought(articleKey: articleData.key) || isOfflineMode {
                self.setBoughtState(state: .boughtArticle)
            } else {
                self.setBoughtState(state: .notBoughtPaidArticle)
                self.setSavedState(state: .cantSave)
            }
        case false:
            self.setBoughtState(state: .freeArticle)
        }
        
        if self.observerIsSet == false {
            let nc = NotificationCenter.default
            nc.addObserver(self, selector: #selector(updateBoughtState(notification:)), name: Notification.Name("bought_articles_loaded"), object: nil)
        }
    }
    
    // MARK: - Other
    
    /// sets values from config file
    func configurate() {
        titleLabel.textColor = Environment().configuration(.titleColor).hexStringToUIColor()
        subtitleLabel.textColor = Environment().configuration(.titleColor).hexStringToUIColor()
        
        if let titleSize = Environment().configuration(.titleFontSize).CGFloatValue() {
            titleLabel.font = UIFont().configFontOfSize(size: titleSize)
        }
        if let subtitleSize = Environment().configuration(.subtitleFontSize).CGFloatValue() {
            subtitleLabel.font = UIFont().configFontOfSize(size: subtitleSize)
        }
        buyButton.tintColor = Environment().configuration(.buttonColor).hexStringToUIColor()
        saveButton.tintColor = Environment().configuration(.buttonColor).hexStringToUIColor()
        articleImageView.backgroundColor = Environment().configuration(.placeholderColor).hexStringToUIColor()
    }
    
    func setBoughtState(state: ArticleCellBoughtState) {
        switch state {
        case .freeArticle:
            buyButton.isHidden = true
        case .boughtArticle:
            buyButton.isHidden = false
            buyButton.setImage(UIImage(named: "baseline_lock_open_black_24pt"), for: .normal)
            buyButton.isEnabled = false
        case .notBoughtPaidArticle:
            buyButton.isHidden = false
            buyButton.setImage(UIImage(named: "baseline_lock_black_24pt"), for: .normal)
            buyButton.isEnabled = true
        }
        boughtState = state
    }
    
    func setSavedState(state: ArticleCellSavedState) {
        switch state {
        case .saved:
            saveButton.isEnabled = true
            saveButton.setImage(UIImage(named: "round_delete_outline_black_24pt"), for: .normal)
            saveButton.isHidden = false
        case .notSaved:
            saveButton.isEnabled = true
            saveButton.setImage(UIImage(named: "round_save_alt_black_24pt"), for: .normal)
            saveButton.isHidden = false
        case .cantSave:
            saveButton.isEnabled = false
            saveButton.setImage(UIImage(named: "round_save_alt_black_24pt"), for: .normal)
        }
        saveState = state
    }
    
    @objc func updateBoughtState(notification: NSNotification) {
        guard let data = articleData else { return }
        switch data.paid {
        case true:
            if CreditsDataSource.shared.isArticleBought(articleKey: data.key) {
                self.setBoughtState(state: .boughtArticle)
            } else {
                self.setBoughtState(state: .notBoughtPaidArticle)
            }
        case false:
            self.setBoughtState(state: .freeArticle)
        }
    }
}

