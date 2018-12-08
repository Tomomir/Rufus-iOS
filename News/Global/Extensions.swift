//
//  Extensions.swift
//  News
//
//  Created by Tomas Pecuch on 16/10/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit

extension UIViewController {
    
    
    /// adds given viewcontroller as a child vc
    ///
    /// - Parameters:
    ///   - child: view controller to add
    ///   - parent: parent view controller
    ///   - withView: view from which we perform function
    func addChildVC(_ child: UIViewController, toParent parent: UIViewController? = nil, withView: UIView? = nil) {
        let p = parent ?? self
        let pView : UIView = withView ?? p.view
        
        p.addChild(child)
        
        pView.addSubview(child.view)
        //child.view.autoPinEdgesToSuperviewEdges()
        
        child.didMove(toParent: p)
    }
}

extension UIView {
    
    
    /// adds shadow to a view
    func addShadow() {
        self.layer.cornerRadius = 5
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        self.layer.shadowRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
    }
}

extension UIImageView {
    
    
    
    /// Load image direclty to a ImageView
    ///
    /// - Parameter photoUrl: URL of the image
    func loadFromURL(photoUrl:String){
        //NSURL
        guard let url = URL(string: photoUrl) else { return }
        //Request
        let request = URLRequest(url:url)
        //Session
        let session = URLSession.shared
        //Data task
        let datatask = session.dataTask(with:request) { (data:Data?, response:URLResponse?, error:Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription ?? "no description")
            } else {
                DispatchQueue.main.async {
                    self.image = UIImage(data: data!)
                }
            }
        }
        datatask.resume()
    }
    
    
}

// Allows to init UIColor using hex color
extension UIColor {
    
    convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
}

extension String {

    
    /// Converts String to a CGFloat value
    ///
    /// - Returns: CGFloat value, nil if String cannot be converted
    func CGFloatValue() -> CGFloat? {
        guard let doubleValue = Double(self) else {
            return nil
        }
        
        return CGFloat(doubleValue)
    }
    
    
    /// Converts String to a UIColor, String has to be in hex format (e.g. #FFFFFF)
    ///
    /// - Returns: UIColor
    func hexStringToUIColor() -> UIColor {
        var cString:String = self.trimmingCharacters(in: .whitespacesAndNewlines).uppercased()
        
        if (cString.hasPrefix("#")) {
            cString.remove(at: cString.startIndex)
        }
        
        if ((cString.count) != 6) {
            return UIColor.gray
        }
        
        var rgbValue:UInt32 = 0
        Scanner(string: cString).scanHexInt32(&rgbValue)
        
        return UIColor(
            red: CGFloat((rgbValue & 0xFF0000) >> 16) / 255.0,
            green: CGFloat((rgbValue & 0x00FF00) >> 8) / 255.0,
            blue: CGFloat(rgbValue & 0x0000FF) / 255.0,
            alpha: CGFloat(1.0)
        )
    }
    
    
    /// Converts String to a Bool value
    ///
    /// - Returns: Bool value, nil if String is in a wrong format
    func BoolValue() -> Bool? {
        switch self {
        case "True", "true", "yes", "1":
            return true
        case "False", "false", "no", "0":
            return false
        default:
            return nil
        }
    }
    
    
    /// Converts String to a UInt value, String has to be in UInt format
    ///
    /// - Returns: UInt value
    func UIntValue() -> UInt {
        if let number = UInt(self) {
            return number
        } else {
            fatalError("wrong string passed to UIntValue func")
        }
    }
}

/// converts string containing HTML to the attributed string
extension String {
    
    var htmlToAttributedString: NSAttributedString? {
        guard let data = data(using: .utf8) else { return NSAttributedString() }
        do {
            return try NSAttributedString(data: data, options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding:String.Encoding.utf8.rawValue], documentAttributes: nil)
        } catch {
            return NSAttributedString()
        }
    }
    var htmlToString: String {
        return htmlToAttributedString?.string ?? ""
    }
}

extension Date {
    
    
    /// Converts the Date to a String
    ///
    /// - Returns: String representation of the date
    func toFormattedString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd. MMM yyyy"
        
        return formatter.string(from: self)
    }
}


/// extension used to determine label width according to the text it contains
extension UILabel {
    func textWidth() -> CGFloat {
        return UILabel.textWidth(label: self)
    }
    
    class func textWidth(label: UILabel) -> CGFloat {
        return textWidth(label: label, text: label.text!)
    }
    
    class func textWidth(label: UILabel, text: String) -> CGFloat {
        return textWidth(font: label.font, text: text)
    }
    
    class func textWidth(font: UIFont, text: String) -> CGFloat {
        let myText = text as NSString
        
        let rect = CGSize(width: CGFloat.greatestFiniteMagnitude, height: CGFloat.greatestFiniteMagnitude)
        let labelSize = myText.boundingRect(with: rect, options: .usesLineFragmentOrigin, attributes: [NSAttributedString.Key.font: font], context: nil)
        return ceil(labelSize.width)
    }
}

/// extension that allows to download image from url and set it to the imageview
extension UIImageView {
    func downloaded(from url: URL, contentMode mode: UIView.ContentMode = .scaleAspectFill) {
        //contentMode = mode
        URLSession.shared.dataTask(with: url) { data, response, error in
            guard
                let httpURLResponse = response as? HTTPURLResponse, httpURLResponse.statusCode == 200,
                let mimeType = response?.mimeType, mimeType.hasPrefix("image"),
                let data = data, error == nil,
                let image = UIImage(data: data)
                else { return }
            DispatchQueue.main.async() {
                self.image = image
            }
            }.resume()
    }
    func downloaded(from link: String, contentMode mode: UIView.ContentMode = .scaleAspectFit) {
        guard let url = URL(string: link) else { return }
        downloaded(from: url, contentMode: mode)
    }
}

/// used for setting up the font size from the config file
extension UIFont {
    func configFontOfSize(size: CGFloat) -> UIFont {
        let fontName = Environment().configuration(.textFont)

        if let font = UIFont(name: fontName, size: size) {
            return font
        } else {
            return UIFont.systemFont(ofSize: size)
        }
        
    }
}
