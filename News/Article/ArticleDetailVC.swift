//
//  ArticleDetailVC.swift
//  News
//
//  Created by Tomas Pecuch on 21/10/2018.
//  Copyright © 2018 Touch Art. All rights reserved.
//

import UIKit
import WebKit

class ArticleDetailVC: UIViewController, WKNavigationDelegate {

    @IBOutlet weak var titleContainerView: UIView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var saveButton: LoadingButton!
    
    @IBOutlet weak var textContainerView: UIView!
    @IBOutlet weak var textContainerViewHeightConst: NSLayoutConstraint!
    @IBOutlet weak var textTextView: UITextView!
    @IBOutlet weak var textWebView: WKWebView!
    
    var articleData: ArticleDataStruct? = nil
    var isSaved: Bool = false {
        didSet {
            if isSaved {
                self.saveButton.setImage(UIImage(named: "delete-icon"), for: .normal)
            } else {
                self.saveButton.setImage(UIImage(named: "save-icon"), for: .normal)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titleContainerView.addShadow()
        if let data = articleData {
            API.shared.markArticleAsRead(articleKey: data.key)
            titleLabel.text = data.title
            if let date = data.publishTime {
                dateLabel.text = date.toFormattedString()
            }
            self.setSaveIcon(articleKey: data.key)
            
            API.shared.getArticleContent(articleKey: data.key) { [weak self] (text) in
                self?.textTextView.attributedText = text.htmlToAttributedString
                //self?.textTextView.text = text.htmlToString
                self?.textContainerViewHeightConst.constant = 1500//self?.textTextView.contentSize.height ?? 0
                //self?.textTextView.isScrollEnabled = false
                let tmpText = "<html> <head><style type='text/css'>body {font-family: 'SourceSansPro-Regular';padding: 0}.point {font-size: 30pt}.pixel{font-size: 30px}</style></head><body><p><strong>Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.</strong> <em>Nulla pellentesque dignissim enim sit amet venenatis urna.</em> <u>Dolor sit amet consectetur adipiscing elit. Eu volutpat odio facilisis mauris.</u> <del>Netus et malesuada fames ac. At quis risus sed vulputate odio ut enim blandit.</del> Leo duis ut diam quam nulla porttitor massa id. Imperdiet nulla malesuada pellentesque elit. In dictum non consectetur a erat nam. Cursus mattis molestie a iaculis. Iaculis urna id volutpat lacus laoreet non curabitur gravida. Volutpat lacus laoreet non curabitur gravida arcu ac tortor. Sed odio morbi quis commodo odio aenean sed adipiscing diam. Enim sed faucibus turpis in eu mi bibendum neque egestas. Interdum varius sit amet mattis vulputate enim nulla aliquet porttitor.</p>\n<blockquote>Sit amet est placerat in egestas erat imperdiet. Adipiscing vitae proin sagittis nisl rhoncus mattis rhoncus urna. Viverra nam libero justo laoreet sit. Turpis nunc eget lorem dolor sed viverra ipsum nunc aliquet. Est ultricies integer quis auctor elit sed. In est ante in nibh mauris cursus mattis molestie a. Sagittis vitae et leo duis. Sed viverra tellus in hac habitasse platea.&nbsp;</blockquote>\n<h2><br></h2>\n<figure><left><img src=\"https://lh3.googleusercontent.com/PG7c26_awsqn327K1P9oUqk2HMu_iyjgLm8c3YCnERCiTolfA0SiaODfnoWspboNposlLxoveaPLKfefP0Voj84vGD0I9u9Bqjg=s750\" style=\"padding: 0px 0px 0px 0px;width:345px;height:345px;\" /></left></figure>\n<p><br></p>\n<h2>Lacus luctus accumsan tortor posuere ac ut consequat semper viverra. Lorem ipsum dolor sit amet consectetur adipiscing.</h2>\n<h3>Leo urna molestie at elementum. Aliquam nulla facilisi cras fermentum odio.&nbsp;</h3>\n<h4>In nibh mauris cursus mattis. Duis at consectetur lorem donec.&nbsp;</h4>\n<ul>\n  <li>One really long to test how it shows on the phone screen to see if its okay or we need to do something else</li>\n  <li>Two&nbsp;</li>\n  <li>Three</li>\n</ul>\n<ol>\n  <li>One</li>\n  <li>Two</li>\n  <li>Three</li>\n</ol>\n<p><br></p>\n<figure><iframe src=\"https://www.youtube.com/embed/cnMa-Sm9H4k\" frameborder=\"0\" allowfullscreen=\"true\" style=\"\">&nbsp;</iframe></figure>\n<p><br></p></body></html>"
                let html = """
                <html>
                <head>
                <meta name="viewport" content="width=330, initial-scale=1">
                <style> body { font-size: 150%; } </style>
                </head>
                <body>
                \(tmpText)
                </body>
                </html>
                """
             
                self?.textWebView.navigationDelegate = self
                self?.textWebView.loadHTMLString(html, baseURL: nil)

                guard let path = Bundle.main.path(forResource: "Style", ofType: "css") else { return }
                let cssString = try! String(contentsOfFile: path).trimmingCharacters(in: .whitespacesAndNewlines)
                let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
                //self?.textWebView.evaluateJavaScript(jsString, completionHandler: nil)
                //self?.textContainerViewHeightConst.constant = self?.textWebView.intrinsicContentSize.height ?? 0
            }

        } else {
            // TODO: Handle error
        }
        
        
    }
    
    // MARK: - Actions
    
    @IBAction func backAction(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func saveAction(_ sender: Any) {
        guard let articleKey = articleData?.key else { return }
        saveButton.showLoading()
        switch isSaved {
        case true:
            API.shared.deleteSavedArticle(articleKey: articleKey) { [weak self] (isSuccess) in
                DispatchQueue.main.async{
                    self?.saveButton.hideLoading()
                    if isSuccess {
                        self?.isSaved = false
                    }
                }
            }
        case false:
            API.shared.saveArticle(articleKey: articleKey) { [weak self] (isSuccess) in
                DispatchQueue.main.async{
                    self?.saveButton.hideLoading()
                    if isSuccess {
                        self?.isSaved = true
                    }
                }
            }
        }
    }
    
    // WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        
//        self.textWebView.evaluateJavaScript("document.readyState", completionHandler: { (complete, error) in
//            if complete != nil {
//                self.textWebView.evaluateJavaScript("document.body.scrollHeight", completionHandler: { (height, error) in
//                    self.textContainerViewHeightConst.constant = (height as! CGFloat) + 50
//                    self.textWebView.scrollView.isScrollEnabled = false
//                })
//            }
//
//        })
       // let jscript = "var meta = document.createElement('meta'); meta.setAttribute('name', 'viewport'); meta.setAttribute('content', 'width=device-width'); document.getElementsByTagName('head')[0].appendChild(meta);"
       // textWebView.evaluateJavaScript(jscript, completionHandler: nil)
        guard let path = Bundle.main.path(forResource: "Style", ofType: "css") else { return }
        let cssString = try! String(contentsOfFile: path).trimmingCharacters(in: .whitespacesAndNewlines)
        let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
        self.textWebView.evaluateJavaScript(jsString, completionHandler: nil)
        //self.insertCSSString(into: textWebView)
    }
    
    // MARK: - Other
    
    func insertCSSString(into webView: WKWebView) {
        let cssString = "body { font-size: 50px; color: #f00 }"
        let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
        webView.evaluateJavaScript(jsString, completionHandler: nil)
    }
    
    func insertContentsOfCSSFile(into webView: WKWebView) {
        guard let path = Bundle.main.path(forResource: "Style", ofType: "css") else { return }
        let cssString = try! String(contentsOfFile: path).trimmingCharacters(in: .whitespacesAndNewlines)
        let jsString = "var style = document.createElement('style'); style.innerHTML = '\(cssString)'; document.head.appendChild(style);"
        webView.evaluateJavaScript(jsString, completionHandler: nil)
    }
    
    func setSaveIcon(articleKey: String) {
        API.shared.isSavedArticle(articleKey: articleKey) { (isArticleSaved) in
            DispatchQueue.main.async{
                self.saveButton.isHidden = false
                self.isSaved = isArticleSaved
            }
        }
    }
}
