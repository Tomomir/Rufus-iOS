//
//  MappableObject.swift
//  News
//
//  Created by Tomas Pecuch on 24/11/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import RealmSwift
import ObjectMapper

class MapableObject: Object, Mappable {
    
    @objc dynamic var id: String = ""
    
    
    /// init if the mappable realm object
    ///
    /// - Parameter map: map to perform
    required convenience init?(map: Map) {
        self.init()
    }
    
    func mapping(map: Map) {
    }
}

