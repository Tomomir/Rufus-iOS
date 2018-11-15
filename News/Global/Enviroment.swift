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
    case navigationBarBlurAlpha
    case navigationBarColor
    case navigationBarUseBlur
    case titleColor
    case initialPostFetchCount
    
    func value() -> String {
        switch self {
        case .serverURL:
            return "server_url"
        case .backgroundColor:
            return "background_color"
        case .navigationBarBlurAlpha:
            return "navigation_bar_blur_alpha"
        case .navigationBarColor:
            return "navigation_bar_color"
        case .navigationBarUseBlur:
            return "navigation_bar_use_blur"
        case .titleColor:
            return "title_color"
        case .initialPostFetchCount:
            return "initial_post_fetch_count"
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
        case .navigationBarBlurAlpha:
            return infoDict[PlistKey.navigationBarBlurAlpha.value()] as! String
        case .navigationBarColor:
            return infoDict[PlistKey.navigationBarColor.value()] as! String
        case .navigationBarUseBlur:
            return infoDict[PlistKey.navigationBarUseBlur.value()] as! String
        case .titleColor:
            return infoDict[PlistKey.titleColor.value()] as! String
        case .initialPostFetchCount:
            return infoDict[PlistKey.initialPostFetchCount.value()] as! String
        }
    }
}
