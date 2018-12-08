//
//  API.swift
//  News
//
//  Created by Tomas Pecuch on 06/11/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import Foundation
import Firebase
import FirebaseDatabase
import FBSDKLoginKit

enum Result<T> {
    case success(T)
    case failure(Error)
}

struct StaticPageData {
    var key: String
    var title: String
    var subTitle: String
    var text: String
}

class API {
    
    // singleton
    static var shared = API()
    var ref: DatabaseReference!
    
    private init() {
        FirebaseApp.configure()
        //Database.database().isPersistenceEnabled = true
        ref = Database.database().reference()
    }
    
    func loadAllEssentails(completion: ((_ success: Bool) -> Void)?) {
        let group = DispatchGroup()

        group.enter()
        self.getCategories { (result) in
            switch result {
                case .failure(let error):
                print(error)
                case .success(let dict):
                print(dict)
                CategoryDataSource.shared.setCategories(categories: dict)
            }
            group.leave()
        }
        
        group.enter()
        self.getCategoryKeys { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let array):
                print(array)
                CategoryDataSource.shared.sortCategories(keysArray: array)
            }
            group.leave()
        }
        
        group.enter()
        self.getCredits() {
            group.leave()
        }
        
        group.enter()
        CreditsDataSource.shared.getBoughtArticles {
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main, execute: {
            print("All Essentials fetched")
            completion?(true)
        })
    }
    
//    func getNews() {
//        let categories = ref.child("postContents").observeSingleEvent(of: .value, with: { (snapshot) in
//            // Get user value
//            let value = snapshot.value as? NSDictionary
//            let values = value?.allValues
//            let dict = self.convertToDictionary(text: values?.first as! String)
//
//        }) { (error) in
//            print(error.localizedDescription)
//
//        }
//    }
    
    func getArticles(isInitialLoad: Bool = true, completion: ((Bool) -> Void)?) {
        
        ref.child("posts").queryOrdered(byChild: "status").queryEqual(toValue: "published").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? NSDictionary {
                var parsedArray = [ArticleDataStruct]()
                
                for key in value.allKeys {
                    parsedArray.append(ArticleDataStruct(dict: value[key] as! [String : Any], key: key as! String))
                }
                if isInitialLoad {
                    let nc = NotificationCenter.default
                    nc.post(name: Notification.Name("articles_inital_loaded"), object: ["articles" :parsedArray])
                } else {
                    let nc = NotificationCenter.default
                    nc.post(name: Notification.Name("articles_updated"), object: ["articles" :parsedArray])
                }
                let isSuccess = parsedArray.count == 0 ? false : true
                completion?(isSuccess)
            }
        }) { (error) in
            print(error.localizedDescription)
            completion?(false)
        }
    }
    
    func getArticles(categoryKey: String, batchSize: UInt, completion: (() -> Void)?) {
        
        let ref1 = ref.child("posts").queryLimited(toLast: 1000)
        let query = ref1.queryOrdered(byChild: "category").queryEqual(toValue: categoryKey)
        query.observe(.value, with: { (snapshot) in
            
            //.queryEqual(toValue: "published", childKey: "status").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? NSDictionary {
                var parsedArray = [ArticleDataStruct]()
                
                for key in value.allKeys {
                    parsedArray.append(ArticleDataStruct(dict: value[key] as! [String : Any], key: key as! String))
                }
                //ArticlesDataSource.shared.setInitialArticles(articles: parsedArray)
                completion?()
            }
        }) { (error) in
            print(error.localizedDescription)
            
        }
    }
    
    func getArticleContent(articleKey: String, completion: ((String) -> Void)?) {
        ref.child("postContentsHTML/\(articleKey)").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            if let value = snapshot.value as? String {
                completion?(value)
            }

        }) { (error) in
            print(error.localizedDescription)

        }
    }
    
    func convertToDictionary(text: String) -> [String: Any]? {
        if let data = text.data(using: .utf8) {
            do {
                return try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
            } catch {
                print(error.localizedDescription)
            }
        }
        return nil
    }
    
    func isLoggedIn() -> Bool {
        if Auth.auth().currentUser != nil {
            // User is signed in.
            return true
        } else {
            // No user is signed in.
            return false
        }
    }
    
    func getCategoryKeys(completion: ((Result<[String]>) -> Void)?) {
        _ = ref.child("categoryKeys").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String] {
                completion?(.success(value))
            } else {
                //TODO: handle error
            }
        }) { (error) in
            print(error.localizedDescription)
            
        }
    }
    
    func getCategories(completion: ((Result<[String : Any]>) -> Void)?) {
        
        
        _ = ref.child("categories").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                completion?(.success(value))
            } else {
                //TODO: handle error
            }
        }) { (error) in
            print(error.localizedDescription)
            
        }
    }

    func getStaticPageDict(completion: ((Result<[String : Any]>) -> Void)?) {
        _ = ref.child("pages").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                completion?(.success(value))
            } else {
                //TODO: handle error
            }
        }) { (error) in
            print(error.localizedDescription)
            
        }
    }
    
    func getStaticPageText(completion: ((Result<[String : Any]>) -> Void)?) {
        _ = ref.child("pageContentsHTML").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                completion?(.success(value))
            } else {
                //TODO: handle error
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    func getFullStaticPageDict(completion: ((Result<[StaticPageData]>) -> Void)?) {
        self.getStaticPageDict { (result) in
            switch result {
            case .failure(let error):
                completion?(.failure(error))
                
            case .success(var dict):
                self.getStaticPageText(completion: { (result) in
                    switch result {
                    
                    case .failure(let error):
                        completion?(.failure(error))
                    
                    case .success(let dictFullText):
                        var pagesArray = [StaticPageData]()
                        for key in dictFullText.keys {
                            //(finaldict as! [String: [String: Any]])[key]!["text"] = dictFullText[key] as! String
                            //(finaldict[key] as! [String : Any])["text"] = dictFullText[key] as! String
                            pagesArray.append(StaticPageData(key: key,
                                                           title: (dict[key] as! [String : Any])["title"] as! String,
                                                           subTitle: (dict[key] as! [String : Any])["subtitle"] as! String,
                                                           text: dictFullText[key] as! String))
                        }
                        completion?(.success(pagesArray))
                    }
                })
            }
            
            
        }
    }
    
    func saveStaticPageAcceptance(userID: String) {
        ref.child("users/\(userID)/").setValue(["staticPage": true])
    }
    
    func logout() {
        try! Auth.auth().signOut()
        FBSDKAccessToken.setCurrent(nil)
    }
    
    func observeUserLogin(completition: (() -> Void)?) {
        Auth.auth().addStateDidChangeListener { (auth, user) in
            completition?()
        }
    }

    func didUserAcceptStaticPage(completition: ((Bool) -> Void)?) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completition?(false)
            return
            // TODO: handle error
        }
        ref.child("user/\(userID)/staticPage/").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? Bool {
                completition?(value)
            } else {
                //TODO: handle error
                completition?(false)
            }
        }) { (error) in
            print(error.localizedDescription)
            completition?(false)
        }
    }
    
    func markArticleAsRead(articleKey: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
            // TODO: handle error
        }
        
        ref.child("user/\(userID)/readArticles/\(articleKey)").setValue(Date().timeIntervalSince1970)
    }
    
    // MARK: - Saved article management
    
    func isSavedArticle(articleKey: String, completition: ((Bool) -> Void)?) {
        guard let userID = Auth.auth().currentUser?.uid else {
            completition?(false)
            return
            // TODO: handle error
        }
        ref.child("user/\(userID)/savedArticles/\(articleKey)/").observeSingleEvent(of: .value, with: { (snapshot) in
            if let _ = snapshot.value as? Double {
                completition?(true)
            } else {
                completition?(false)
            }
        }) { (error) in
            print(error.localizedDescription)
            //completition?(false)
        }
    }
    
    func saveArticle(articleKey: String, completition: ((Bool) -> Void)?) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
            // TODO: handle error
        }
        
        ref.child("user/\(userID)/savedArticles/\(articleKey)").setValue(Date().timeIntervalSince1970) { (error, ref) in
            if let errorValue = error {
                print(errorValue)
                completition?(false)
            } else {
                completition?(true)
            }
        }
    }
    
    func deleteSavedArticle(articleKey: String, completition: ((Bool) -> Void)?) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
            // TODO: handle error
        }
        
        ref.child("user/\(userID)/savedArticles/\(articleKey)").removeValue() { (error, ref) in
            if let errorValue = error {
                print(errorValue)
                completition?(false)
            } else {
                completition?(true)
            }
        }
    }
    
    func getReadArticles(completition: ((Result<[String : Any]>) -> Void)?) {
        guard let userID = Auth.auth().currentUser?.uid else {
            let error = NSError(domain:"No user logged in.", code:401, userInfo:nil)
            completition?(.failure(error))
            return
        }
        
        ref.child("user/\(userID)/readArticles/").observeSingleEvent(of: .value, with: { (snapshot) in
            if let articles = snapshot.value as? [String: Any] {
                completition?(.success(articles))
            } else {
                completition?(.success([:]))
            }
        }) { (error) in
            print(error.localizedDescription)
            completition?(.failure(error))
        }
    }
    
    func getBoughtArticles(completition: ((Result<[String : Any]>) -> Void)?) {
        guard let userID = Auth.auth().currentUser?.uid else {
            let error = NSError(domain:"No user logged in.", code:401, userInfo:nil)
            completition?(.failure(error))
            return
        }
        
        ref.child("user/\(userID)/boughtArticles/").observeSingleEvent(of: .value, with: { (snapshot) in
            if let articles = snapshot.value as? [String: Any] {
                completition?(.success(articles))
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name("bought_articles_loaded"), object: nil)
            } else {
                completition?(.success([:]))
            }
        }) { (error) in
            print(error.localizedDescription)
            completition?(.failure(error))
        }
    }
    
    func saveBuoghtArticle(articleKey: String, completition: ((Bool) -> Void)?) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
            // TODO: handle error
        }
        
        ref.child("user/\(userID)/boughtArticles/\(articleKey)").setValue(Date().timeIntervalSince1970) { (error, ref) in
            if let errorValue = error {
                print(errorValue)
                completition?(false)
            } else {
                completition?(true)
            }
        }
    }
    
    func isOnline(completition: ((Bool) -> Void)?) {
        ref.child(".info/connected").observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool {
                completition?(connected)
            } else {
                completition?(false)
            }
        })

    }
    
    func observeOnline(completition: ((Bool) -> Void)?) {
        
    }
    
    func getAuthorName(authorID: String, completition: ((String) -> Void)?) {

        ref.child("team/\(authorID)/name/").observeSingleEvent(of: .value, with: { snapshot in
            if let name = snapshot.value as? String {
                
                completition?(name)
            } else {
                // TODO: handle error
                completition?("")
            }
        }) { (error) in
            print(error.localizedDescription)
            completition?("")
        }
    }
    
    func getCredits(completition: (() -> Void)?) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
            // TODO: handle error
        }
        ref.child("user/\(userID)/credits/").observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            if let credits = snapshot.value as? Int {
                CreditsDataSource.shared.numberOfCredits = credits
                CreditsDataSource.shared.creditsAreLoaded = true
                completition?()
            } else {
                self?.setInitialCredits(completition: {
                    completition?()
                })
            }
        }) { (error) in
            print(error.localizedDescription)
            //completition?(false)
        }
    }
    
    func substractCredit(completition: ((Bool) -> Void)?) {
        if CreditsDataSource.shared.creditsAreLoaded == false { return }
        guard let userID = Auth.auth().currentUser?.uid else {
            return
            // TODO: handle error
        }
        
        let newCreditsCount = CreditsDataSource.shared.numberOfCredits - 1
        ref.child("user/\(userID)/credits/").setValue((newCreditsCount)) { (error, ref) in
            if let errorValue = error {
                print(errorValue)
                completition?(false)
            } else {
                CreditsDataSource.shared.numberOfCredits = newCreditsCount
                completition?(true)
            }
        }
    }
    
    func setInitialCredits(completition: (() -> Void)?) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
            // TODO: handle error
        }
        let initialCredits = Environment().configuration(.startingCredits).UIntValue()
        ref.child("user/\(userID)/credits/").setValue(Int(initialCredits)) { (error, ref) in
            if let errorValue = error {
                print(errorValue)
                completition?()
            } else {
                CreditsDataSource.shared.numberOfCredits = Int(initialCredits)
                CreditsDataSource.shared.creditsAreLoaded = true
                completition?()
            }
        }
    }
    
    func addCredits(completition: ((Bool) -> Void)?) {
        if CreditsDataSource.shared.creditsAreLoaded == false { return }
        guard let userID = Auth.auth().currentUser?.uid else {
            return
            // TODO: handle error
        }
        let newCreditsValue = CreditsDataSource.shared.numberOfCredits.advanced(by: Int(Environment().configuration(.creditsForPurchase).UIntValue()))
        ref.child("user/\(userID)/credits/").setValue(newCreditsValue) { (error, ref) in
            if let errorValue = error {
                print(errorValue)
                completition?(false)
            } else {
                completition?(true)
                CreditsDataSource.shared.numberOfCredits = newCreditsValue
            }
        }
    }
}

