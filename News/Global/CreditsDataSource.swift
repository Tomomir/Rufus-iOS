//
//  CreditsDataSource.swift
//  News
//
//  Created by Tomas Pecuch on 03/12/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import Foundation

class CreditsDataSource {
    
    // singleton
    static var shared = CreditsDataSource()
    
    // current number of credits
    var numberOfCredits: Int = 0 {
        didSet {
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("credits_updated"), object: nil)
        }
    }
    
    var creditsAreLoaded: Bool = false
    var boughtArticleKeys = [String]()
    var isOffline: Bool = false
    
    
    /// substracts number of credits and saves article key to the firebase as bought
    ///
    /// - Parameters:
    ///   - articleKey: key of the article
    ///   - completition: completition block after the operations are performed
    func articleBought(articleKey: String, completition: ((Bool) -> Void)?) {
        API.shared.saveBuoghtArticle(articleKey: articleKey) { (success) in
            if success {
                self.boughtArticleKeys.append(articleKey)
                API.shared.substractCredit(completition: { (success) in
                    if success {
                        completition?(true)
                    } else {
                        completition?(false)
                    }
                })
            } else {
                completition?(false)
            }
        }
    }
    
    
    /// loads array of bought articles
    ///
    /// - Parameter completition: completion block
    func getBoughtArticles(completition: (() -> Void)?) {
        API.shared.getBoughtArticles { [weak self] (result) in
            switch result {
            case .failure(let error):
                AlertManager.shared.showBasicAlert(title: "Could not load bought Articles", text: error.localizedDescription)
                completition?()
            case .success(let articles):
                for articleKey in articles.keys {
                    self?.boughtArticleKeys.append(articleKey)
                }
                completition?()
            }
        }
    }
    
    func isArticleBought(articleKey: String) -> Bool {
        if isOffline {
            return true
        }
        
        if boughtArticleKeys.contains(articleKey) {
            return true
        } else {
            return false
        }
    }
}
