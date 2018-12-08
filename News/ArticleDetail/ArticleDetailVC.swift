//
//  ArticleDetailVC.swift
//  News
//
//  Created by Tomas Pecuch on 21/10/2018.
//  Copyright © 2018 Tomas Pecuch. All rights reserved.
//

import UIKit
import WebKit
import JGProgressHUD

enum ArticleDetailMode {
    case online
    case offline
}

class ArticleDetailVC: UIViewController, WKUIDelegate, WKNavigationDelegate, UIScrollViewDelegate, WKScriptMessageHandler {

    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var authorLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var saveButton: LoadingButton!
    
    @IBOutlet weak var loadingIndicatorContentView: UIView!
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var textContainerViewHeightConst: NSLayoutConstraint!
    
    private var shouldListenToResizeNotification = false
    private var progressHUD = JGProgressHUD(style: .extraLight)
    
    var mode: ArticleDetailMode = .online
    
    lazy var webView:WKWebView = {
        //Javascript string
        let source = "window.onload=function () {window.webkit.messageHandlers.sizeNotification.postMessage({justLoaded:true,height: document.body.scrollHeight});};"
        let source2 = "document.body.addEventListener( 'resize', incrementCounter); function incrementCounter() {window.webkit.messageHandlers.sizeNotification.postMessage({height: document.body.scrollHeight});};"
        
        //UserScript object
        let script = WKUserScript(source: source, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        let script2 = WKUserScript(source: source2, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        
        //Content Controller object
        let controller = WKUserContentController()
        
        //Add script to controller
        controller.addUserScript(script)
        controller.addUserScript(script2)
        
        //Add message handler reference
        controller.add(self, name: "sizeNotification")
        
        //Create configuration
        let configuration = WKWebViewConfiguration()
        configuration.userContentController = controller
        
        return WKWebView(frame: CGRect.zero, configuration: configuration)
    }()
    
    var articleData: ArticleDataStruct? = nil
    var isSaved: Bool = false {
        didSet {
            if isSaved {
                self.saveButton.setImage(UIImage(named: "round_delete_outline_black_36pt"), for: .normal)
            } else {
                self.saveButton.setImage(UIImage(named: "round_save_alt_black_36pt"), for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleContainerView.addShadow()
        self.configurate()
        
        textContainerView.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .trailing, relatedBy: .equal, toItem: textContainerView, attribute: .trailing, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .leading, relatedBy: .equal, toItem: textContainerView, attribute: .leading, multiplier: 1, constant: 0))
        
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .top, relatedBy: .equal, toItem: textContainerView, attribute: .top, multiplier: 1, constant: 0))
        view.addConstraint(NSLayoutConstraint(item: webView, attribute: .bottom, relatedBy: .equal, toItem: textContainerView, attribute: .bottom,multiplier: 1, constant: 0))
        
        progressHUD.textLabel.text = ""
        progressHUD.show(in: loadingIndicatorContentView)
        progressHUD.dismiss(afterDelay: 10.0)
        webView.alpha = 0
        webView.scrollView.isScrollEnabled = false
        webView.navigationDelegate = self
        webView.uiDelegate = self
        
        
        self.fillArticleData()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        AlertManager.shared.currentVC = self
    }
    
    // MARK: - Actions
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard let articleKey = articleData?.key else { return }

        switch isSaved {
        case true:
            DatabaseManager.shared.delete(Article.self, id: articleKey)
            ImageManager.shared.removeSavedImage(key: articleKey)
            self.isSaved = false
        case false:
            saveButton.setImage(nil, for: .normal)
            saveButton.showLoading()
            API.shared.getArticleContent(articleKey: articleKey) { [weak self] (content) in
                self?.saveButton.hideLoading()
                if var articleJSON = self?.articleData?.getAsDict() {
                    articleJSON["data"] = content
                    if let imageURL = self?.articleData?.imageURL {
                        ImageManager.shared.imageDownloaded(from: imageURL, completion: { (image) in
                            _ = ImageManager.shared.saveImageToDocumentsUnderKey(image: image, key: articleKey)
                            DatabaseManager.shared.addSingle(type: Article.self, json: articleJSON)
                            self?.isSaved = true
                        })
                    } else {
                        DatabaseManager.shared.addSingle(type: Article.self, json: articleJSON)
                        self?.isSaved = true
                    }
                }
            }
        }
        
//        saveButton.showLoading()
//        switch isSaved {
//        case true:
//            API.shared.deleteSavedArticle(articleKey: articleKey) { [weak self] (isSuccess) in
//                DispatchQueue.main.async{
//                    self?.saveButton.hideLoading()
//                    if isSuccess {
//                        self?.isSaved = false
//                    }
//                }
//            }
//        case false:
//            API.shared.saveArticle(articleKey: articleKey) { [weak self] (isSuccess) in
//                DispatchQueue.main.async{
//                    self?.saveButton.hideLoading()
//                    if isSuccess {
//                        self?.isSaved = true
//                    }
//                }
//            }
//        }
    }
    
    // MARK: - UIScrollViewDelegate
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        return nil
    }
    
    // WKScriptMessageHandler
        
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let responseDict = message.body as? [String:Any],
        let height = responseDict["height"] as? Float else {return}
        if let _ = responseDict["justLoaded"] {
            print("just loaded, height: \(height)")
            //shouldListenToResizeNotification = true
            self.textContainerViewHeightConst.constant = CGFloat(height)
            self.progressHUD.dismiss()
            UIView.animate(withDuration: 0.2) { [weak self] in
                self?.webView.alpha = 1
            }
        }
        else if shouldListenToResizeNotification {
            print("height is \(height)")
            self.textContainerViewHeightConst.constant = CGFloat(height)
        }
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        decisionHandler(WKNavigationActionPolicy.allow)
    }
    
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil {
            webView.load(navigationAction.request)
        }
        
        return nil
    }
    // MARK: - Other
    
    func getCSSStringFromFile() -> String? {
        guard let path = Bundle.main.path(forResource: "Style", ofType: "css") else { return nil }
        let cssString = try! String(contentsOfFile: path).trimmingCharacters(in: .whitespacesAndNewlines)
        //let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
        return cssString
    }
    
    func setSaveIcon(articleKey: String) {
        if DatabaseManager.shared.get(type: Article.self, id: articleKey) != nil {
            isSaved = true
        } else {
            isSaved = false
        }
    }
    
    func configurate() {
        titleLabel.textColor = Environment().configuration(.titleColor).hexStringToUIColor()
        subtitleLabel.textColor = Environment().configuration(.titleColor).hexStringToUIColor()
        
        titleLabel.font = UIFont().configFontOfSize(size: titleLabel.font.pointSize)
        subtitleLabel.font = UIFont().configFontOfSize(size: subtitleLabel.font.pointSize)
        authorLabel.font = UIFont().configFontOfSize(size: authorLabel.font.pointSize)
        dateLabel.font = UIFont().configFontOfSize(size: dateLabel.font.pointSize)
        
        saveButton.tintColor = UIColor.black //Environment().configuration(.buttonColor).hexStringToUIColor()
        backButton.tintColor = UIColor.black //Environment().configuration(.buttonColor).hexStringToUIColor()
        backgroundImageView.backgroundColor = Environment().configuration(.placeholderColor).hexStringToUIColor()
    }
    
    func fillArticleData() {
        switch mode {
        case .online:
            self.donwloadArticleData()
        case .offline:
            self.loadArticleData()
        }
    }
    
    func loadArticleData() {
        if let data = articleData {
            isSaved = true
            
            titleLabel.text = data.title
            subtitleLabel.text = data.subtitle
            if let date = data.publishTime {
                dateLabel.text = date.toFormattedString()
            }
            
            if let image = ImageManager.shared.getSavedImage(key: data.key) {
                backgroundImageView.image = image
            } else {
                backgroundImageView.image = UIImage(named: "placeholder_transparent")
            }
            
            self.setSaveIcon(articleKey: data.key)
            
            if let text = articleData?.text {
                let parsedText = text.replacingOccurrences(of: "target=\"_blank\"", with: "target=\"_top\"", options: .literal, range: nil)
                print(text)
                var cssString = ""
                if let stringFromFile = self.getCSSStringFromFile() {
                    cssString = stringFromFile
                }
                let finalHTML = """
                <html>
                \(cssString)
                <body>
                \(parsedText)
                </body>
                </html>
                """
                
                self.webView.loadHTMLString(finalHTML, baseURL: nil)
            }
            
        } else {
            // TODO: Handle error
        }
    }
    
    func donwloadArticleData() {
        if let data = articleData {

            
            API.shared.markArticleAsRead(articleKey: data.key)
            titleLabel.text = data.title
            subtitleLabel.text = data.subtitle
            if let date = data.publishTime {
                dateLabel.text = date.toFormattedString()
            }
            API.shared.getAuthorName(authorID: data.author) { [weak self] (authorName) in
                self?.authorLabel.text = authorName
            }
            backgroundImageView.downloaded(from: data.imageURL)
            
            self.setSaveIcon(articleKey: data.key)
            
            
            API.shared.getArticleContent(articleKey: data.key) { [weak self] (text) in
                let parsedText = text.replacingOccurrences(of: "target=\"_blank\"", with: "target=\"_top\"", options: .literal, range: nil)
                print(text)
                var cssString = ""
                if let stringFromFile = self?.getCSSStringFromFile() {
                    cssString = stringFromFile
                }
                let finalHTML = """
                <html>
                \(cssString)
                <body>
                \(parsedText)
                </body>
                </html>
                """
                
                self?.webView.loadHTMLString(finalHTML, baseURL: nil)
                
            }
            
        } else {
            // TODO: Handle error
        }
    }
}

