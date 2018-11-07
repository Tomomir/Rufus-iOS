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
