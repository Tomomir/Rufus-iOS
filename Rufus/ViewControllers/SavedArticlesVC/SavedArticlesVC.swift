//
//  SavedArticlesVC.swift
//  News
//
//  Created by Tomas Pecuch on 06/12/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit

class SavedArticlesVC: UIViewController {

    @IBOutlet weak var navigationBlurColorView: UIView!
    @IBOutlet weak var navigationBlurView: UIVisualEffectView!
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var navigationBackButton: UIButton!
    @IBOutlet weak var navigationLogoImageView: UIImageView!
    
    
    @IBOutlet weak var pageContainerView: UIView!
    
    var categoryPageVC: CategoryPageVC? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurate()
        let vc = storyboard?.instantiateViewController(withIdentifier: "CategoryPageVC") as! CategoryPageVC
        vc.articleDataSource.selectedCategoryKey = "All"
        vc.categoryName = "All"
        vc.navigationBarView = navigationBarView
        categoryPageVC = vc
        vc.articleDataSource.setMode(mode: .saved)
        vc.refreshControl?.removeFromSuperview()
        vc.refreshControl = nil
        vc.view.frame = pageContainerView.frame
        pageContainerView.addSubview(vc.view)
        addChild(vc)
        vc.didMove(toParent: self)
    }
    
    // MARK: - Actions
    
    /// Return to previous screen when back is pressed
    ///
    /// - Parameter sender: pressed button 
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    // MARK: - Other
    
    func configurate() {
        navigationLogoImageView.image = UIImage(named: Environment().configuration(.logoImageName))
        
        if let alpha = Environment().configuration(.navigationBarBlurAlpha).CGFloatValue() {
            self.navigationBlurColorView.alpha = alpha
        }
        let color = Environment().configuration(.navigationBarColor).hexStringToUIColor()
        self.navigationBlurColorView.backgroundColor = color
        
        if let useBlur = Environment().configuration(.navigationBarUseBlur).BoolValue() {
            self.navigationBlurView.isHidden = !useBlur
        }
    }

}
