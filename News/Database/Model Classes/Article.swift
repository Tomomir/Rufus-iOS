//
//  Article.swift
//  News
//
//  Created by Tomas Pecuch on 24/11/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import RealmSwift
import ObjectMapper


/// article object of realm database
class Article: MapableObject {
    
    @objc dynamic var title: String = ""
    @objc dynamic var subtitle: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var authorName: String = ""
    @objc dynamic var categoryKey: String = ""
    @objc dynamic var paid: Bool = false
    @objc dynamic var publishTime: Int64 = -1
    @objc dynamic var data: String = ""
    @objc dynamic var author: String = ""
    
    
    /// returns object id
    ///
    /// - Returns: object id
    override static func primaryKey() -> String {
        return "id"
    }
    
    
    required convenience init?(map: Map) {
        self.init()
    }
   
    
    /// maps given Map to the object data
    ///
    /// - Parameter map: object data to map
    override func mapping(map: Map) {
        if id == "" {
            id <- map["key"]
        }
        title <- map["title"]
        subtitle <- map["subtitle"]
        categoryKey <- map["category"]
        paid <- map["paid"]
        publishTime <- map["publishTime"]
        author <- map["author"]
        data <- map["data"]
    }
    
    
    /// returns object attributes as a JSON dictionart
    ///
    /// - Returns: JSON dictionary
    func getAsJSON() -> [String: Any] {
        var json = [String: Any]()
        json["key"] = self.id
        json["title"] = self.title
        json["subtitle"] = self.subtitle
        json["category"] = self.categoryKey
        json["paid"] = self.paid
        json["publishTime"] = self.publishTime
        json["data"] = self.data
        json["createdAt"] = self.createdAt
        json["author"] = self.author
        json["text"] = self.data
        
        return json
    }
}
