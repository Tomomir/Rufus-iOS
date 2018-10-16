//
//  Enviroment.swift
//  News
//
//  Created by Tomas Pecuch on 16/10/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import Foundation

public enum PlistKey {
    case serverURL
    case backgroundColor
    
    func value() -> String {
        switch self {
        case .serverURL:
            return "server_url"
        case .backgroundColor:
            return "background_color"
        }

    }
}
public struct Environment {
    
    fileprivate var infoDict: [String: Any]  {
        get {
            if let dict = Bundle.main.infoDictionary {
                return dict
            }else {
                fatalError("Plist file not found")
            }
        }
    }
    public func configuration(_ key: PlistKey) -> String {
        switch key {
        case .serverURL:
            return infoDict[PlistKey.serverURL.value()] as! String
        case .backgroundColor:
            return infoDict[PlistKey.backgroundColor.value()] as! String
        }
    }
}
