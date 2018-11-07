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

class API {
    
    static var shared = API()
    var ref: DatabaseReference!
    
    private init() {
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

    func getStaticPageDict(completion: ((Result<[String : Any]>) -> Void)?) {
        let staticPages = ref.child("pages").observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            if let first = value?.allValues.first as? [String : Any] {
                completion?(.success(first))
            }
            
        }) { (error) in
            print(error.localizedDescription)
            
        }
    }
    
//    func getCategories(completion: ((Result<Array>) -> Void)?) {
//        
//    }
}
