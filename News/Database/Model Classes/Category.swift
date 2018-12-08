//
//  Category.swift
//  News
//
//  Created by Tomas Pecuch on 24/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import RealmSwift
import ObjectMapper

class Category: MapableObject {
    
    @objc dynamic var name: String = ""
    @objc dynamic var createdAt: Date = Date()

    override static func primaryKey() -> String {
        return "id"
    }
    
    required convenience init?(map: Map) {
        self.init()
    }
    
    override func mapping(map: Map) {
        id <- map["id"]
        name <- map["name"]
    }
}
