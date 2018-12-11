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
    
    
    /// loads all essentials needet at app start
    ///
    /// - Parameter completion: completion block after esstentials are loaded
    func loadAllEssentails(completion: ((_ success: Bool) -> Void)?) {
        let group = DispatchGroup()

        // loads categories
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
        
        // loads sorted array of category keys
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
        
        // loads credits
        group.enter()
        self.getCredits() {
            group.leave()
        }
        
        // loads bought articles
        group.enter()
        CreditsDataSource.shared.getBoughtArticles {
            group.leave()
        }
        
        group.notify(queue: DispatchQueue.main, execute: {
            print("All Essentials fetched")
            completion?(true)
        })
    }
    
    
    /// loads articles which are published
    ///
    /// - Parameters:
    ///   - isInitialLoad: boolean wheter it is first load
    ///   - completion: completion block after the load is completed
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
    
    /// loads HTML content of the article
    ///
    /// - Parameters:
    ///   - articleKey: key of the wanted article
    ///   - completion: completion block after the load is completed
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
    
    
    /// check wheter user is logged in
    ///
    /// - Returns: boolean value, true if logged in
    func isLoggedIn() -> Bool {
        if Auth.auth().currentUser != nil {
            // User is signed in.
            return true
        } else {
            // No user is signed in.
            return false
        }
    }
    
    /// loads sorted array of category keys
    ///
    /// - Parameter completion: completion block ater the load is completed
    func getCategoryKeys(completion: ((Result<[String]>) -> Void)?) {
        _ = ref.child("categoryKeys").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String] {
                completion?(.success(value))
            }
        }) { (error) in
            print(error.localizedDescription)
            
        }
    }
    
    /// loads categories, keys and names, unsorted
    ///
    /// - Parameter completion: completion block ater the load is completed
    func getCategories(completion: ((Result<[String : Any]>) -> Void)?) {
        
        
        _ = ref.child("categories").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                completion?(.success(value))
            }
        }) { (error) in
            print(error.localizedDescription)
            
        }
    }

    /// loads static pages keys, titles and subtitles
    ///
    /// - Parameter completion: completion block ater the load is completed
    func getStaticPageDict(completion: ((Result<[String : Any]>) -> Void)?) {
        _ = ref.child("pages").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                completion?(.success(value))
            }
        }) { (error) in
            print(error.localizedDescription)
            
        }
    }
    
    /// loads static page HTML content
    ///
    /// - Parameter completion: completion block ater the load is completed
    func getStaticPageText(completion: ((Result<[String : Any]>) -> Void)?) {
        _ = ref.child("pageContentsHTML").observeSingleEvent(of: .value, with: { (snapshot) in
            if let value = snapshot.value as? [String : Any] {
                completion?(.success(value))
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    /// loads and parse static pages
    ///
    /// - Parameter completion: completion block ater the load is completed
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
    
    
    /// logs user out of the app
    func logout() {
        try! Auth.auth().signOut()
        FBSDKAccessToken.setCurrent(nil)
    }
    
    
    /// upload article key to the server under userID/readArticles
    ///
    /// - Parameter articleKey: article key to upload
    func markArticleAsRead(articleKey: String) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        ref.child("user/\(userID)/readArticles/\(articleKey)").setValue(Date().timeIntervalSince1970)
    }
    
    
    /// loads array of read article keys
    ///
    /// - Parameter completion: completion block ater the load is completed
    func getReadArticles(completion: ((Result<[String : Any]>) -> Void)?) {
        guard let userID = Auth.auth().currentUser?.uid else {
            let error = NSError(domain:"No user logged in.", code:401, userInfo:nil)
            completion?(.failure(error))
            return
        }
        
        ref.child("user/\(userID)/readArticles/").observeSingleEvent(of: .value, with: { (snapshot) in
            if let articles = snapshot.value as? [String: Any] {
                completion?(.success(articles))
            } else {
                completion?(.success([:]))
            }
        }) { (error) in
            print(error.localizedDescription)
            completion?(.failure(error))
        }
    }
    
    
    /// loads bought article keys
    ///
    /// - Parameter completion: completion block ater the load is completed
    func getBoughtArticles(completion: ((Result<[String : Any]>) -> Void)?) {
        guard let userID = Auth.auth().currentUser?.uid else {
            let error = NSError(domain:"No user logged in.", code:401, userInfo:nil)
            completion?(.failure(error))
            return
        }
        
        ref.child("user/\(userID)/boughtArticles/").observeSingleEvent(of: .value, with: { (snapshot) in
            if let articles = snapshot.value as? [String: Any] {
                completion?(.success(articles))
                let nc = NotificationCenter.default
                nc.post(name: Notification.Name("bought_articles_loaded"), object: nil)
            } else {
                completion?(.success([:]))
            }
        }) { (error) in
            print(error.localizedDescription)
            completion?(.failure(error))
        }
    }
    
    
    /// upload article key to the server under userID/boughtArticles
    ///
    /// - Parameters:
    ///   - articleKey: key of the bought article
    ///   - completion: completion block ater the upload is completed
    func saveBuoghtArticle(articleKey: String, completion: ((Bool) -> Void)?) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        ref.child("user/\(userID)/boughtArticles/\(articleKey)").setValue(Date().timeIntervalSince1970) { (error, ref) in
            if let errorValue = error {
                print(errorValue)
                completion?(false)
            } else {
                completion?(true)
            }
        }
    }
    
    
    /// checks if Firebase is online
    ///
    /// - Parameter completion: completion block containing bool value wheter Firebase is online
    func isOnline(completion: ((Bool) -> Void)?) {
        ref.child(".info/connected").observe(.value, with: { snapshot in
            if let connected = snapshot.value as? Bool {
                completion?(connected)
            } else {
                completion?(false)
            }
        })

    }
    
    
    /// loads author name from the server
    ///
    /// - Parameters:
    ///   - authorID: id of the author
    ///   - completion: completion block ater the load is completed
    func getAuthorName(authorID: String, completion: ((String) -> Void)?) {

        ref.child("team/\(authorID)/name/").observeSingleEvent(of: .value, with: { snapshot in
            if let name = snapshot.value as? String {
                
                completion?(name)
            } else {
                completion?("")
            }
        }) { (error) in
            print(error.localizedDescription)
            completion?("")
        }
    }
    
    
    /// loads credits count
    ///
    /// - Parameter completion: completion block ater the load is completed
    func getCredits(completion: (() -> Void)?) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        ref.child("user/\(userID)/credits/").observeSingleEvent(of: .value, with: { [weak self] (snapshot) in
            if let credits = snapshot.value as? Int {
                CreditsDataSource.shared.numberOfCredits = credits
                CreditsDataSource.shared.creditsAreLoaded = true
                completion?()
            } else {
                self?.setInitialCredits(completion: {
                    completion?()
                })
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    
    
    /// substracts 1 credit from the user account
    ///
    /// - Parameter completion: completion block ater the substraction is completed
    func substractCredit(completion: ((Bool) -> Void)?) {
        if CreditsDataSource.shared.creditsAreLoaded == false { return }
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        
        let newCreditsCount = CreditsDataSource.shared.numberOfCredits - 1
        ref.child("user/\(userID)/credits/").setValue((newCreditsCount)) { (error, ref) in
            if let errorValue = error {
                print(errorValue)
                completion?(false)
            } else {
                CreditsDataSource.shared.numberOfCredits = newCreditsCount
                completion?(true)
            }
        }
    }
    
    
    /// sets users credits to the initial value on the server
    ///
    /// - Parameter completion: completion block ater the upload is completed
    func setInitialCredits(completion: (() -> Void)?) {
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        let initialCredits = Environment().configuration(.startingCredits).UIntValue()
        ref.child("user/\(userID)/credits/").setValue(Int(initialCredits)) { (error, ref) in
            if let errorValue = error {
                print(errorValue)
                completion?()
            } else {
                CreditsDataSource.shared.numberOfCredits = Int(initialCredits)
                CreditsDataSource.shared.creditsAreLoaded = true
                completion?()
            }
        }
    }
    
    
    /// adds more credits to the user account
    ///
    /// - Parameter completion: completion block ater the upload is completed
    func addCredits(completion: ((Bool) -> Void)?) {
        if CreditsDataSource.shared.creditsAreLoaded == false { return }
        guard let userID = Auth.auth().currentUser?.uid else {
            return
        }
        let newCreditsValue = CreditsDataSource.shared.numberOfCredits.advanced(by: Int(Environment().configuration(.creditsForPurchase).UIntValue()))
        ref.child("user/\(userID)/credits/").setValue(newCreditsValue) { (error, ref) in
            if let errorValue = error {
                print(errorValue)
                completion?(false)
            } else {
                completion?(true)
                CreditsDataSource.shared.numberOfCredits = newCreditsValue
            }
        }
    }
}

