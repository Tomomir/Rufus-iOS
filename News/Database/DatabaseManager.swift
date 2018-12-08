//
//  DatabaseManager.swift
//  News
//
//  Created by Tomas Pecuch on 24/11/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import Foundation
import RealmSwift
import ObjectMapper

class DatabaseManager {

    static var shared = DatabaseManager()
    let currentSchemaVersion: Int = 5
    
    private init() {
        configureRealm()
    }
    
    func configureRealm() {
        let realmConfig = Realm.Configuration(
            // Set the new schema version. This must be greater than the previously used
            // version (if you've never set a schema version before, the version is 0).
            schemaVersion: UInt64(currentSchemaVersion),
            
            // Set the block which will be called automatically when opening a Realm with
            // a schema version lower than the one set above
            migrationBlock: { migration, oldSchemaVersion in
                // We haven’t migrated anything yet, so oldSchemaVersion == 0
                if (oldSchemaVersion < 0) {
                    // Nothing to do!
                    // Realm will automatically detect new properties and removed properties
                    // And will update the schema on disk automatically
                }
                
        })
        
        Realm.Configuration.defaultConfiguration = realmConfig
    }
    
    // MARK: - REALM GET
    
    func get<T: Object>(_ type: T.Type) -> Results<T> {
        let realm = try! Realm()
        return realm.objects(type)
    }
    
    func get<T: Object, Key>(type: T.Type, id: Key) -> T? {
        let realm = try! Realm()
        return realm.object(ofType: type, forPrimaryKey: id)
    }
    
    func get<T: Object, Key>(type: T.Type, idsArray: [Key]) -> [T]? {
        let realm = try! Realm()
        var resultObjects: Array<T> = []
        for key in idsArray {
            if let object = realm.object(ofType: type, forPrimaryKey: key) {
                resultObjects.append(object)
            }
        }
        return resultObjects
    }
    
    // MARK: - REALM DELETE
    
    func deleteAll() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    func delete(_ object: Object) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.delete(object)
        }
    }
    
    func delete<T: Object, Key>(_ type: T.Type, id: Key) {
        let realm = try! Realm()
        
        guard let object = realm.object(ofType: type, forPrimaryKey: id) else { return }
        try! realm.write {
            realm.delete(object)
        }
    }
    
    // MARK: - REALM SET/ADD
    
    func addMultiple<T: MapableObject>(type: T.Type, arrayOfJson: [Dictionary<String, Any>]) {
        save(realmObjects: mapObjects(type: type, arrayOfJson: arrayOfJson))
    }
    
    func mapObjects<T: MapableObject>(type: T.Type, arrayOfJson: [Dictionary<String, Any>]) -> [T] {
        var typeArray = [T]()
        for json in arrayOfJson {
            guard let newType = Mapper<T>().map(JSON: json) else {
                continue
            }
            typeArray.append(newType)
        }
        return typeArray
    }
    
    func addSingle<T: MapableObject>(type: T.Type, json: [String: Any]) {
        guard let newType = Mapper<T>().map(JSON: json) else { return }
        save(realmObject: newType)
    }
    
    func mapObject<T: MapableObject>(type: T.Type, json: [String: Any]) -> T? {
        return Mapper<T>().map(JSON: json)
    }
    
    func save(realmObject: Object, additionalOperationsBlock: (() -> Void)? = nil) {
        let realm = try! Realm()
        if realm.isInWriteTransaction {
            print("REALM Is IN WRITE TRANSACTION EXPECTING CRASH SOLO")
        }
        try! realm.write {
            realm.add(realmObject, update: true)
            additionalOperationsBlock?()
        }
    }
    
    func save(realmObjects: [Object], operationsBeforeBlock: ((_ realm: Realm) -> Void)? = nil, operationsAfterBlock: ((_ realm: Realm) -> Void)? = nil) {
        let realm = try! Realm()
        if realm.isInWriteTransaction {
            print("REALM Is IN WRITE TRANSACTION EXPECTING CRASH MULTI")
            return
        }
        try! realm.write {
            operationsBeforeBlock?(realm)
            realm.add(realmObjects, update: true)
            operationsAfterBlock?(realm)
        }
    }
}
