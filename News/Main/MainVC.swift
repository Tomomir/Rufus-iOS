//
//  MainVC.swift
//  News
//
//  Created by Tomas Pecuch on 16/10/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit
import NavigationDrawer

class MainVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    // navigation bar outlets
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var navigationBarBlurColorView: UIView!
    @IBOutlet weak var navigationLogoImageView: UIImageView!
    @IBOutlet weak var navigationCreditsImageView: UIImageView!
    @IBOutlet weak var navigationCreditsLabel: UILabel!
    @IBOutlet weak var navigationCreditsButton: UIButton!
    @IBOutlet weak var navigationHamburgerButton: UIButton!
    @IBOutlet weak var navigationBlurView: UIVisualEffectView!
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    
    let interactor = Interactor()
    let categoryDataSource: CategoryDataSource = CategoryDataSource.shared

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setupVC()
    }
    
    // MARK: - Actions
    
    @IBAction func creditsAction(_ sender: Any) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "CreditsVC") as? CreditsVC
        self.navigationController?.pushViewController(vc!, animated: true)

    }
    
    @IBAction func hamburgerAction(_ sender: Any) {
        performSegue(withIdentifier: "showSlidingMenu", sender: nil)

    }
    
    @IBAction func edgePanGesture(_ sender: UIScreenEdgePanGestureRecognizer) {
        let translation = sender.translation(in: view)
        
        let progress = MenuHelper.calculateProgress(translationInView: translation, viewBounds: view.bounds, direction: .Right)
        
        MenuHelper.mapGestureStateToInteractor(
            gestureState: sender.state,
            progress: progress,
            interactor: interactor){
                self.performSegue(withIdentifier: "showSlidingMenu", sender: nil)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? HamburgerMenuVC {
            destinationViewController.transitioningDelegate = self
            destinationViewController.interactor = self.interactor
        }
    }

    
    // MARK: - UITableView delegate
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            let firstCell = tableView.dequeueReusableCell(withIdentifier: "ArticlesCollectionCell", for: indexPath)
            return firstCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ArticleCell", for: indexPath)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //do nothing if the first cell was pressed
        if indexPath.row == 0 { return}
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ArticleDetailVC") as? ArticleDetailVC
        self.navigationController?.pushViewController(vc!, animated: true)
    }
    
    // MARK: - Other
    
    private func setupVC() {
        // set values from config file
        self.configurate()
        
        // allows us to have different cell heights without defiing exact height for every cell
        tableView.estimatedRowHeight = 299
        tableView.rowHeight = UITableView.automaticDimension
        
        // moves tableview starting position so it doesnt start under navigation bar
        tableView.contentInset = UIEdgeInsets(top: navigationBarView.bounds.origin.y + navigationBarView.bounds.size.height + 10, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
     
//        let appDelegate = (UIApplication.shared.delegate as! AppDelegate)
//        appDelegate.window?.rootViewController = self
        
        categoryDataSource.collectionView = categoryCollectionView
        categoryCollectionView.dataSource = categoryDataSource
        categoryCollectionView.delegate = categoryDataSource
        if let flowLayout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout,
            let collectionView = categoryCollectionView {
            flowLayout.estimatedItemSize = CGSize(width: 40, height: 35)
        }
        API.shared.getNews { (result) in
            
        }
    }
    
    private func configurate() {
//        if let navigationBarAlpha = Environment().configuration(.navigationBarBlurAlpha) as? String {
//            //self.navigationBarBlurColorView.alpha = CGFloat(navigationBarAlpha)
//            print(navigationBarAlpha)
//        }
//        if let navigationBarColor = Environment().configuration(.navigationBarColor) as? Int {
//            self.navigationBarBlurColorView.backgroundColor = UIColor(rgb: navigationBarColor)
//        }
//        if let server = Environment().configuration(.serverURL) {
//            print(server)
//        }
        let server_url = Environment().configuration(PlistKey.serverURL)
        print(server_url)
        
        print(Environment().configuration(PlistKey.serverURL))
        print(Environment().configuration(.navigationBarBlurAlpha))
         print(Environment().configuration(.navigationBarColor))
    }

}


extension MainVC: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return PresentMenuAnimator()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return DismissMenuAnimator()
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactor.hasStarted ? interactor : nil
    }
}
