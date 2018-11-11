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
    
    func addShadow() {
        self.layer.cornerRadius = 5
        self.layer.shadowOpacity = 0.2
        self.layer.shadowOffset = CGSize(width: 0.0, height: 5.0)
        self.layer.shadowRadius = 10
        self.layer.shadowColor = UIColor.black.cgColor
    }
}

//allows to set borders and corner radius inside attribute inspector
@IBDesignable extension UIView {
    
    @IBInspectable var borderWidth: CGFloat {
        set {
            layer.borderWidth = newValue
        }
        get {
            return layer.borderWidth
        }
    }
    
    @IBInspectable var cornerRadius: CGFloat {
        set {
            layer.cornerRadius = newValue
        }
        get {
            return layer.cornerRadius
        }
    }
    
    @IBInspectable var borderColor: UIColor? {
        set {
            guard let uiColor = newValue else { return }
            layer.borderColor = uiColor.cgColor
        }
        get {
            guard let color = layer.borderColor else { return nil }
            return UIColor(cgColor: color)
        }
    }
}

extension UIImageView {
    
    
    //load image async from inaternet
    func loadFromURL(photoUrl:String){
        //NSURL
        let url = URL(string: photoUrl)
        //Request
        let request = URLRequest(url:url!)
        //Session
        let session = URLSession.shared
        //Data task
        let datatask = session.dataTask(with:request) { (data:Data?, response:URLResponse?, error:Error?) -> Void in
            if error != nil {
                print(error?.localizedDescription ?? "no description")
            }
            DispatchQueue.main.async {
                self.image = UIImage(data: data!)
            }
        }
        datatask.resume()
    }
    
    
}

//allows to init UIColor using hex color
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
