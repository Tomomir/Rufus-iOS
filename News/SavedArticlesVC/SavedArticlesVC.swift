//
//  SavedArticlesVC.swift
//  News
//
//  Created by Tomas Pecuch on 06/12/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
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
        // Do any additional setup after loading the view.
    }
    
    // MARK: - Actions
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
