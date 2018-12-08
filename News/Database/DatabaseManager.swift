//
//  DatabaseManager.swift
//  News
//
//  Created by Tomas Pecuch on 24/11/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
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
    
    
    /// instantiate Real database
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
    
    
    /// returns all saved objects of given type
    ///
    /// - Parameter type: type of the object to return
    /// - Returns: collection of saved objects
    func get<T: Object>(_ type: T.Type) -> Results<T> {
        let realm = try! Realm()
        return realm.objects(type)
    }
    
    
    /// returns saved object of given type and id
    ///
    /// - Parameters:
    ///   - type: type of the object
    ///   - id: id of the wanted object
    /// - Returns: returns the object or nil if not found
    func get<T: Object, Key>(type: T.Type, id: Key) -> T? {
        let realm = try! Realm()
        return realm.object(ofType: type, forPrimaryKey: id)
    }
    
    
    /// returns saved objects of given type and ids
    ///
    /// - Parameters:
    ///   - type: type of the objects
    ///   - idsArray: array of wanted object ids
    /// - Returns: returns array of the found objects or nil if none are found
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
    
    
    /// delete whole Realm database
    func deleteAll() {
        let realm = try! Realm()
        try! realm.write {
            realm.deleteAll()
        }
    }
    
    
    /// delete given object
    ///
    /// - Parameter object: object to delete
    func delete(_ object: Object) {
        let realm = try! Realm()
        
        try! realm.write {
            realm.delete(object)
        }
    }
    
    
    /// deletes objects of given type and ids
    ///
    /// - Parameters:
    ///   - type: type of the objects to delete
    ///   - id: ids of objects to delete
    func delete<T: Object, Key>(_ type: T.Type, id: Key) {
        let realm = try! Realm()
        
        guard let object = realm.object(ofType: type, forPrimaryKey: id) else { return }
        try! realm.write {
            realm.delete(object)
        }
    }
    
    // MARK: - REALM SET/ADD
    
    
    /// save given array of JSON object as database objects
    ///
    /// - Parameters:
    ///   - type: type of object to be saved
    ///   - arrayOfJson: array of JSON objects to save
    func addMultiple<T: MapableObject>(type: T.Type, arrayOfJson: [Dictionary<String, Any>]) {
        save(realmObjects: mapObjects(type: type, arrayOfJson: arrayOfJson))
    }
    
    
    /// map given JSONs to the database objects
    ///
    /// - Parameters:
    ///   - type: type of object to map to
    ///   - arrayOfJson: array of JSONs with object data
    /// - Returns: returns array of mapped database objects
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
    
    
    /// adds single object of given type to the database
    ///
    /// - Parameters:
    ///   - type: type of the object to be added
    ///   - json: data of object to add
    func addSingle<T: MapableObject>(type: T.Type, json: [String: Any]) {
        guard let newType = Mapper<T>().map(JSON: json) else { return }
        save(realmObject: newType)
    }
    
    
    /// map given JSON to database object
    ///
    /// - Parameters:
    ///   - type: type of the object to add
    ///   - json: JSON data of the object
    /// - Returns: returns created database object
    func mapObject<T: MapableObject>(type: T.Type, json: [String: Any]) -> T? {
        return Mapper<T>().map(JSON: json)
    }
    
    
    /// saves database object to the database
    ///
    /// - Parameters:
    ///   - realmObject: realm object to save
    ///   - additionalOperationsBlock: block to perfom after the object is saved
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
    
    
    /// saves database objects tot the database
    ///
    /// - Parameters:
    ///   - realmObjects: realm objects to save
    ///   - operationsBeforeBlock: block to perform before save
    ///   - operationsAfterBlock: block to perform after the objects are saved
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
