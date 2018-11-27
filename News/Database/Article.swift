//
//  Article.swift
//  News
//
//  Created by Tomas Pecuch on 24/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import RealmSwift
import ObjectMapper

class Article: MapableObject {
    
    @objc dynamic var title: String = ""
    @objc dynamic var subTitle: String = ""
    @objc dynamic var createdAt: Date = Date()
    @objc dynamic var authorName: String = ""
    @objc dynamic var categoryKey: String = ""
    //@objc dynamic var paid: Bool = false
    @objc dynamic var publishTime: Int64 = -1
    
    override static func primaryKey() -> String {
        return "id"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        id <- map["key"]
        title <- map["title"]
        subTitle <- map["subTitle"]
        categoryKey <- map["category"]
        //paid <- map["paid"]
        publishTime <- map["publishTime"]
    }
}
