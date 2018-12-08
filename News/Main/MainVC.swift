//
//  MainVC.swift
//  News
//
//  Created by Tomas Pecuch on 16/10/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit
import NavigationDrawer
import JGProgressHUD

class MainVC: UIViewController, UITableViewDelegate, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // navigation bar outlets
    @IBOutlet weak var navigationBarView: UIView!
    @IBOutlet weak var navigationBarBlurColorView: UIView!
    @IBOutlet weak var navigationLogoImageView: UIImageView!
    @IBOutlet weak var navigationCreditsImageView: UIImageView!
    @IBOutlet weak var navigationCreditsLabel: UILabel!
    @IBOutlet weak var navigationCreditsButton: UIButton!
    @IBOutlet weak var navigationHamburgerButton: UIButton!
    @IBOutlet weak var navigationBlurView: UIVisualEffectView!
    
    @IBOutlet weak var pagesContainerView: UIView!
    @IBOutlet weak var categoryCollectionView: UICollectionView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var categoryDataSource: CategoryDataSource? = nil //CategoryDataSource.shared
    let interactor = Interactor()
    
    let pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    var pages = [UIViewController]()
    var mode: ArticleDataMode = .all
    
    private var isInitialLoaded = false
    private var warningLabel: UILabel?
    private var hud = JGProgressHUD(style: .light)
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.configurate()
        self.setupVC()
//        API.shared.isOnline { [weak self] (isOnline) in
//            if isOnline {
//                self?.loadEssentails(showLoading: true)
//            } else {
//                self?.loadEssentails(showLoading: false)
//                self?.showIsOfflineWarning()
//            }
//        }
        self.loadEssentails(showLoading: true)
        self.observeCreditsChange()
//        API.shared.observeUserLogin { [weak self] in
//            //self?.setupVC()
//        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.updateCredits()
        AlertManager.shared.currentVC = self
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
            destinationViewController.mainVC = self
        }
    }
    
    // MARK: - UIPageViewControllerDelegate
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        if let index = pages.firstIndex(of: viewController) {
            if index == 0 {
                return nil
            } else {
                return pages[index - 1]
            }
        } else {
            return nil
        }


    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        if let index = pages.firstIndex(of: viewController) {
            if index == pages.count - 1 {
                return nil
            } else {
                return pages[index + 1]
            }
        } else {
            return nil
        }


    }
    
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        for vc in previousViewControllers {
            let index = pages.firstIndex(of: vc)
            //print("\((vc as! CategoryPageVC).categoryName), index:\(index), realCategory: \(categoryDataSource?.categories[index ?? -1])")
        }
        if let firstVC = previousViewControllers[0] as? CategoryPageVC {
            if let firstVCIndex = pages.firstIndex(of: firstVC) {
                //print("\(firstVC.categoryName) completed: \(completed), index:\(firstVCIndex)")
                //CategoryDataSource.shared.selectCategoryAtIndex(index: firstVCIndex)
            }
        }
    }

    
    // MARK: - Other
    
    func showIsOfflineWarning() {
        warningLabel = UILabel(frame: CGRect(x: (self.view.frame.width / 2) - 120, y: (self.view.frame.height / 2) - 35, width: 240, height: 70))
        warningLabel?.textColor = Environment().configuration(.warningTextColor).hexStringToUIColor()
        warningLabel?.numberOfLines = 0
        warningLabel?.textAlignment = .center
        warningLabel?.text = "It appears you are offline. Data will load when you come back online."
        self.view.addSubview(warningLabel!)
    }
    
    func hideWarningLabel() {
        if let label = warningLabel {
            label.removeFromSuperview()
            self.warningLabel = nil
        }
    }
    
    func loadEssentails(showLoading: Bool) {
        // shows loading indicator

        API.shared.isOnline { [weak self] (isOnline) in
            if self?.isInitialLoaded == true { return }
            switch isOnline {
            case false:
                
                UIView.animateKeyframes(withDuration: 0.2, delay: 3, options: [], animations: {
                    self?.noDataLabel.alpha = 1
                }, completion: nil)
            case true:
                self?.isInitialLoaded = true
                self?.noDataLabel.isHidden = true
                if showLoading {
                    self?.hud.textLabel.text = ""
                    self?.hud.show(in: (self?.view)!)
                    self?.hud.dismiss(afterDelay: 10.0)
                }
            }
            print("is online - \(isOnline)")
        }
        
        API.shared.loadAllEssentails { [weak self] (success) in
            self?.isInitialLoaded = success
            self?.setCategoryPages(categories: self?.categoryDataSource?.categories)
            API.shared.getArticles(completion: { _ in
                self?.hud.dismiss()
                self?.hideWarningLabel()
            })
        }
    }
    
    private func setupVC() {
        self.configurate()
        self.categoryDataSource = CategoryDataSource.shared
        categoryDataSource?.collectionView = categoryCollectionView
        categoryDataSource?.mainVC = self
        categoryCollectionView.dataSource = categoryDataSource
        categoryCollectionView.delegate = categoryDataSource
//        if let flowLayout = categoryCollectionView.collectionViewLayout as? UICollectionViewFlowLayout {
//            flowLayout.estimatedItemSize = CGSize(width: 80, height: 35)
//        }
        
        //self.setCategoryPages(categories: categoryDataSource?.categories)
    }
    
    
    /// sets values from config file
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
        
        noDataLabel.font = UIFont().configFontOfSize(size: noDataLabel.font.pointSize)
        noDataLabel.textColor = Environment().configuration(.warningTextColor).hexStringToUIColor()
    }
    
    func selectCategoryAtIndex(newIndex: Int, oldIndex: Int) {
        
        pageViewController.setViewControllers([pages[newIndex]],
                                              direction: newIndex > oldIndex ? .forward : .reverse,
                                              animated: true,
                                              completion: nil)
    }
    
    func setCategoryPages(categories: [CategoryData]?) {
        
        for category in categories ?? [] {
            let vc = storyboard?.instantiateViewController(withIdentifier: "CategoryPageVC") as! CategoryPageVC
            vc.articleDataSource.selectedCategoryKey = category.key
            vc.categoryName = category.name
            vc.navigationBarView = navigationBarView
            pages.append(vc)
        }
        
        pageViewController.dataSource = self
        pageViewController.delegate = self
        pageViewController.setViewControllers([pages.first!], direction: .forward, animated: false, completion: nil)
        pageViewController.view.frame = pagesContainerView.frame
        
        for page in pages {
            print((page as! CategoryPageVC).categoryName)
        }
        
        addChild(pageViewController)
        pagesContainerView.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
    }
    
    func pushLoginVC() {
        let loginVC = self.storyboard?.instantiateViewController(withIdentifier: "LoginVC") as! LoginVC
        navigationController?.pushViewController(loginVC, animated: true)
    }

    func observeCreditsChange() {
        let nc = NotificationCenter.default
        nc.addObserver(self, selector: #selector(updateCredits(notification:)), name: Notification.Name("credits_updated"), object: nil)
    }
    
    @objc func updateCredits(notification: NSNotification) {
        let credits = CreditsDataSource.shared.numberOfCredits
        self.navigationCreditsLabel.text = "\(credits)"
    }
    
    func updateCredits() {
        let credits = CreditsDataSource.shared.numberOfCredits
        self.navigationCreditsLabel.text = "\(credits)"
    }
    
    func setPagesMode(mode: ArticleDataMode) {
        self.mode = mode
        for page in pages {
            if let vc = page as? CategoryPageVC {
                vc.articleDataSource.setMode(mode: mode)
                if mode == .all {
                    
                    vc.refreshControl = UIRefreshControl()
                    if let table = vc.tableView {
                        table.refreshControl = vc.refreshControl 
                    }
                    vc.refreshControl?.addTarget(vc, action: #selector(vc.pullToRefreshAction), for: .valueChanged)
                } else {
                    if let refresh = vc.refreshControl {
                        refresh.removeFromSuperview()
                        vc.refreshControl = nil
                    }

                }
            }
        }
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
