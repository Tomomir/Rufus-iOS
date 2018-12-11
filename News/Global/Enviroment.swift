//
//  Enviroment.swift
//  News
//
//  Created by Tomas Pecuch on 16/10/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import Foundation

/// used for loading values from config file
public enum PlistKey {
    case logoImageName
    case backgroundColor
    case navigationBarBlurAlpha
    case navigationBarColor
    case navigationBarUseBlur
    case titleColor
    case textColor
    case hamburgerMenuColor
    case buttonColor
    case placeholderColor
    case textFontSize
    case titleFontSize
    case subtitleFontSize
    case warningTextColor
    case creditsForPurchase
    case startingCredits
    case textFont
    
    func value() -> String {
        switch self {
        case .logoImageName:
            return "logo_image_name"
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
        case .textColor:
            return "text_color"
        case .hamburgerMenuColor:
            return "hamburger_menu_color"
        case .buttonColor:
            return "button_color"
        case .placeholderColor:
            return "placeholder_color"
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
        case .startingCredits:
            return "starting_credits"
        case .textFont:
            return "text_font"
        }
    }
}

/// used for loading the values from config file
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
        case .logoImageName:
            return infoDict[PlistKey.logoImageName.value()] as! String
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
        case .textColor:
            return infoDict[PlistKey.textColor.value()] as! String
        case .hamburgerMenuColor:
            return infoDict[PlistKey.hamburgerMenuColor.value()] as! String
        case .buttonColor:
            return infoDict[PlistKey.buttonColor.value()] as! String
        case .placeholderColor:
            return infoDict[PlistKey.placeholderColor.value()] as! String
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
        case .startingCredits:
            return infoDict[PlistKey.startingCredits.value()] as! String
        case .textFont:
            return infoDict[PlistKey.textFont.value()] as! String
        }
    }
    
}
