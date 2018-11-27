//
//  API.swift
//  News
//
//  Created by Tomas Pecuch on 06/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
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
    
    static var shared = API()
    var ref: DatabaseReference!
    private var creditsLoaded = false
    var numberOfCredits = 0 {
        didSet {
            let nc = NotificationCenter.default
            nc.post(name: Notification.Name("credits_updated"), object: nil)
        }
    }
    
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
        self.getCredits() { [weak self] (result) in
            self?.creditsLoaded = true 
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
        let postCount = UInt(1000)
        
        ref.child("posts").queryLimited(toLast: postCount).observeSingleEvent(of: .value, with: { (snapshot) in
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
        let postCount = 1000
        
        let ref1 = ref.child("posts").queryLimited(toLast: 15)
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
        _ = ref.child("pageContents").observeSingleEvent(of: .value, with: { (snapshot) in
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
        let handle = Auth.auth().addStateDidChangeListener { (auth, user) in
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
    
    func isOnline(completition: ((Bool) -> Void)?) {
        ref.child(".info/connected").observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool {
                completition?(connected)
            } else {
                completition?(false)
            }
        })

    }
    
    func getCredits(completition: ((Bool) -> Void)?) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
            // TODO: handle error
        }
        ref.child("user/\(userID)/credits/").observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            if let credits = snapshot.value as? Int {
                self?.numberOfCredits = credits
                completition?(true)
            } else {
                // TODO: handle error
                completition?(false)
            }
        }) { (error) in
            print(error.localizedDescription)
            //completition?(false)
        }
    }
    
    func substractCredit(completition: ((Bool) -> Void)?) {
        if creditsLoaded == false { return }
        guard let userID = Auth.auth().currentUser?.uid else {
            return
            // TODO: handle error
        }
        ref.child("user/\(userID)/credits/").setValue((numberOfCredits - 1)) { (error, ref) in
            if let errorValue = error {
                print(errorValue)
                completition?(false)
            } else {
                completition?(true)
            }
        }
    }
    
    func addCredits(completition: ((Bool) -> Void)?) {
        if creditsLoaded == false { return }
        guard let userID = Auth.auth().currentUser?.uid else {
            return
            // TODO: handle error
        }
        let newCreditsValue = numberOfCredits.advanced(by: Int(Environment().configuration(.creditsForPurchase).UIntValue()))
        ref.child("user/\(userID)/credits/").setValue(newCreditsValue) { [weak self] (error, ref) in
            if let errorValue = error {
                print(errorValue)
                completition?(false)
            } else {
                completition?(true)
                self?.numberOfCredits = newCreditsValue
            }
        }
    }
}
