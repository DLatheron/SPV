//
//  BrowserViewController.swift
//  SPV
//
//  Created by dlatheron on 26/07/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate {
    
    //let initialPageUrl = "http://arstechnica.co.uk"
    let initialPageUrl = "https://www.google.co.uk/search?q=test&source=lnms&tbm=isch&sa=X&ved=0ahUKEwjcvMHyrqvVAhXEAsAKHfdxAu0Q_AUICygC&biw=1680&bih=882#imgrc=_"
    let statusBarHeight = CGFloat.init(20)
    let urlBarHeight = CGFloat.init(44)
    let topBarHeight = CGFloat.init(20 + 44)
    let barViewAnimationSpeed = 0.25

    var webView: WKWebView!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var urlField: UITextField!
    @IBOutlet weak var doneButton: UIBarButtonItem!
    
    // Web Browser navigator
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var tabsButton: UIBarButtonItem!
    @IBOutlet weak var progressView: UIProgressView!
    
    @IBOutlet weak var longPressGesture: UILongPressGestureRecognizer!
    
    required init(coder aDecoder: NSCoder) {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true;
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        view.insertSubview(webView, at: 0)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView,
                                        attribute: .height,
                                        relatedBy: .equal,
                                        toItem: view,
                                        attribute: .height,
                                        multiplier: 1,
                                        constant: 0)
        let width = NSLayoutConstraint(item: webView,
                                       attribute: .width,
                                       relatedBy: .equal,
                                       toItem: view,
                                       attribute: .width,
                                       multiplier: 1,
                                       constant: 0)
        view.addConstraints([height, width])

        webView.scrollView.contentInset = UIEdgeInsetsMake(topBarHeight, 0, 0, 0)
        webView.scrollView.delegate = self;
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
        
        longPressGesture.cancelsTouchesInView = true;

        
        // TODO: Work out which ones we need to lose and which ones we should keep. Keep single click (or add them ourselves).
        // Remove all of the web view's gesture recognisers.
        webView.scrollView.subviews[0].gestureRecognizers?.forEach(webView.scrollView.subviews[0].removeGestureRecognizer)
        
        webView.addGestureRecognizer(longPressGesture)
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = false
        // Correctly disables interaction with the underlying view - but
        // then we can't navigate to links...
        //webView.scrollView.subviews[0].isUserInteractionEnabled = false
        
        //barView.frame = barViewOffScreenRect
        //showUrlBar()

        urlField.text = initialPageUrl
        navigateTo(url: urlField.text!)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Values are wrong... topBarHeight should be 64, topOffset should be 64 to totally hide the bar??? 
        
        let offset = max(min(-topBarHeight - scrollView.contentOffset.y, 0), -topBarHeight)
        
        barView.frame = CGRect(x: 0,
                               y: statusBarHeight + offset,
                               width: barView.frame.width,
                               height: barView.frame.height)
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    @IBAction func longPressDetected(_ sender: Any) {
        //print("Long press detected")
        
        let location = longPressGesture.location(in: webView);
        
        // TODO: Determine where was pressed in the document and what to do...
        let jsFunction = "console.log('\(location.x), \(location.y)'); return 'result string';"
        
        webView.evaluateJavaScript(jsFunction, completionHandler: {
            (result, error) -> Void in
                // Do stuff here...
                print(result ?? "")
        })
    }
//    
//    func hideUrlBar() {
//        UIView.animate(withDuration: barViewAnimationSpeed) {
//            self.barView.frame = self.barViewOffScreenRect
//            
//        }
//    }
//    
//    func showUrlBar() {
//        UIView.animate(withDuration: barViewAnimationSpeed) {
//            self.barView.frame = self.barViewOnScreenRect
//        }
//    }
//    
    override func observeValue(forKeyPath keyPath: String?,
                               of object: Any?,
                               change: [NSKeyValueChangeKey : Any]?,
                               context: UnsafeMutableRawPointer?) {
        if keyPath == #keyPath(WKWebView.estimatedProgress) {
            progressView.progress = Float(webView.estimatedProgress)
        }
        if keyPath == #keyPath(WKWebView.canGoBack) {
            backButton.isEnabled = webView.canGoBack
        }
        if keyPath == #keyPath(WKWebView.canGoForward) {
            forwardButton.isEnabled = webView.canGoForward
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func back(sender: UIBarButtonItem) {
        if (self.webView.canGoBack) {
            self.webView.goBack()
        }
    }
    
    @IBAction func forward(sender: UIBarButtonItem) {
        if (self.webView.canGoForward) {
            self.webView.goForward()
        }
    }
    
    @IBAction func refresh(sender: UIBarButtonItem) {
        self.webView.reload()
    }

    @IBAction func done(sender: UIBarButtonItem) {
        urlField.resignFirstResponder()
        self.navigateTo(url: urlField.text!)
    }
    
    func navigateTo(url: String) {
        var modifiedUrl = url
        
        let secureProtocol = "https://"
        let insecureProtocol = "http://"
        
        let lowercaseUrl = url.lowercased()
        if (!lowercaseUrl.hasPrefix(secureProtocol) &&
            !lowercaseUrl.hasPrefix(insecureProtocol)) {
            modifiedUrl = insecureProtocol + modifiedUrl
        }
        
        if (modifiedUrl != url) {
            urlField.text = modifiedUrl
        }
        
        let myURL = URL(string: modifiedUrl)
        let myRequest = URLRequest(url: myURL!)
        
        webView.load(myRequest)
    }
    
    //MARK:- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        urlField.resignFirstResponder()
        self.navigateTo(url: urlField.text!)
        return false
    }
    
    //MARK:- WKNavigationDelegate
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
        let alert = UIAlertController(title: "Error", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alert, animated: true, completion: nil)
        print(error.localizedDescription)
    }
    
    func webView(_ webView: WKWebView,
                 didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Navigating to page")
    }
    
    func webView(_ webView: WKWebView,
                 didFinish navigation: WKNavigation!) {
        print("Page loaded")
    }
}

