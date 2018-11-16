//
//  MainVC.swift
//  News
//
//  Created by Tomas Pecuch on 16/10/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit
import NavigationDrawer

class MainVC: UIViewController, UITableViewDelegate {
    
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
    private let refreshControl = UIRefreshControl()
    var categoryDataSource: CategoryDataSource? = nil //CategoryDataSource.shared
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = ArticlesDataSource.shared
        ArticlesDataSource.shared.tableView = tableView
        
        // allows us to have different cell heights without defiing exact height for every cell
        tableView.estimatedRowHeight = 299
        tableView.rowHeight = UITableView.automaticDimension
        
        // moves tableview starting position so it doesnt start under navigation bar
        tableView.contentInset = UIEdgeInsets(top: navigationBarView.bounds.origin.y + navigationBarView.bounds.size.height + 10, left: 0, bottom: 0, right: 0)
        tableView.scrollIndicatorInsets = tableView.contentInset
        
        //refresh controll
        tableView.refreshControl = refreshControl
        refreshControl.addTarget(self, action: #selector(pullToRefreshAction), for: .valueChanged)
        
        
        API.shared.observeUserLogin { [weak self] in
            self?.setupVC()
        }
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
    
    @objc func pullToRefreshAction(_ sender: Any) {
        API.shared.getArticles(isInitialLoad: false) { [weak self] in
            self?.refreshControl.endRefreshing()
        }
//        API.shared.getArticles { [weak self] in
//            self?.refreshControl.endRefreshing()
//            if let table = self?.tableView {
//                UIView.transition(with: table, duration: 0.6, options: .transitionCrossDissolve, animations: {table.reloadData()}, completion: nil)
//            }
//        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destinationViewController = segue.destination as? HamburgerMenuVC {
            destinationViewController.transitioningDelegate = self
            destinationViewController.interactor = self.interactor
            destinationViewController.mainVC = self
        }
    }
    
    // MARK: - UITableView delegate
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let vc = storyboard?.instantiateViewController(withIdentifier: "ArticleDetailVC") as? ArticleDetailVC
        vc?.articleData = ArticlesDataSource.shared.articlesToShow[indexPath.row]
        self.navigationController?.pushViewController(vc!, animated: true)
    }

    
    // MARK: - Other
    
    private func setupVC() {
        // set values from config file
        self.configurate()
        self.categoryDataSource = CategoryDataSource.shared
        
        categoryDataSource?.collectionView = categoryCollectionView
        categoryCollectionView.dataSource = categoryDataSource
        categoryCollectionView.delegate = categoryDataSource
        if let flowLayout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
            flowLayout.estimatedItemSize = CGSize(width: 80, height: 35)
        }
    }
    
    private func configurate() {

        if let alpha = Environment().configuration(.navigationBarBlurAlpha).CGFloatValue() {
            self.navigationBarBlurColorView.alpha = alpha
        }
        let color = Environment().configuration(.navigationBarColor).hexStringToUIColor()
        self.navigationBarBlurColorView.backgroundColor = color
        
        if let useBlur = Environment().configuration(.navigationBarUseBlur).BoolValue() {
           self.navigationBlurView.isHidden = !useBlur
        }
        
        let titleColor = Environment().configuration(.titleColor).hexStringToUIColor()
        if let myImage = UIImage(named: "menu-512") {
            let tintableImage = myImage.withRenderingMode(.alwaysTemplate)
            navigationHamburgerButton.tintColor = titleColor
            navigationHamburgerButton.setImage(tintableImage, for: .normal)
        }
        
        self.navigationCreditsLabel.textColor = titleColor
        
    }
    
    func pushLoginVC() {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        navigationController?.pushViewController(loginVC, animated: true)
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
