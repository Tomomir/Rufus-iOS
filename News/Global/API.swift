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
    
    private init() {
        FirebaseApp.configure()
        Database.database().isPersistenceEnabled = true
        ref = Database.database().reference()
    }
    
    func getNews() {
        let categories = ref.child("postContents").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            let values = value?.allValues
            let dict = self.convertToDictionary(text: values?.first as! String)
            
        }) { (error) in
            print(error.localizedDescription)
            
        }
    }
    
    func getNews(completion: ((Result<[String : Any]>) -> Void)?) {
        ref.child("posts").queryLimited(toLast: 3).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
           // let values = value?.allValues
            //let dict = self.convertToDictionary(text: values?.first as! String)
            
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
    
//    func getCategories(completion: ((Result<Array>) -> Void)?) {
//        
//    }
}
