//
//  Enviroment.swift
//  News
//
//  Created by Tomas Pecuch on 16/10/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import Foundation

public enum PlistKey {
    case backgroundColor
    case navigationBarBlurAlpha
    case navigationBarColor
    case navigationBarUseBlur
    case titleColor
    case hamburgerMenuColor
    case buttonColor
    case textFontSize
    case titleFontSize
    case subtitleFontSize
    case warningTextColor
    case creditsForPurchase
    
    func value() -> String {
        switch self {
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
        case .hamburgerMenuColor:
            return "hamburger_menu_color"
        case .buttonColor:
            return "button_color"
        case .textFontSize:
            return "text_font_size"
        case .titleFontSize:
            return "title_font_size"
        case .subtitleFontSize:
            return "subtitle_font_size"
        case .warningTextColor:
            return "warning_text_color"
        case .creditsForPurchase:
            return "credits_for_purchase"
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
        case .hamburgerMenuColor:
            return infoDict[PlistKey.hamburgerMenuColor.value()] as! String
        case .buttonColor:
            return infoDict[PlistKey.buttonColor.value()] as! String
        case .textFontSize:
            return infoDict[PlistKey.textFontSize.value()] as! String
        case .titleFontSize:
            return infoDict[PlistKey.titleFontSize.value()] as! String
        case .subtitleFontSize:
            return infoDict[PlistKey.subtitleFontSize.value()] as! String
        case .warningTextColor:
            return infoDict[PlistKey.warningTextColor.value()] as! String
        case .creditsForPurchase:
            return infoDict[PlistKey.creditsForPurchase.value()] as! String
        }
    }
}
