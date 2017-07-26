//
//  BrowserViewController.swift
//  SPV
//
//  Created by dlatheron on 26/07/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UITextFieldDelegate {
    
    var webView: WKWebView!
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var urlField: UITextField!
    
    // Web Browser navigator
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var progressView: UIProgressView!
    
    required init(coder aDecoder: NSCoder) {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true;
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
        super.init(coder: aDecoder)!
    }
//    
//    override func loadView() {
//        //super.loadView()
//        webView.uiDelegate = self
//        webView.navigationDelegate = self
//        
////        webViewHost = webView
//    }

    override func viewDidLoad() {
        let topBarHeight = CGFloat.init(64)
        
        super.viewDidLoad()
        
        barView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: topBarHeight)
        webView.uiDelegate = self
        webView.navigationDelegate = self
        
        view.insertSubview(webView, at: 0)
        
        webView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: webView, attribute: .height, relatedBy: .equal, toItem: view, attribute: .height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: webView, attribute: .width, relatedBy: .equal, toItem: view, attribute: .width, multiplier: 1, constant: 0)
        view.addConstraints([height, width])

        webView.scrollView.contentInset = UIEdgeInsetsMake(topBarHeight, 0, 0, 0)
        
        let myURL = URL(string: "http://arstechnica.co.uk/")
        let myRequest = URLRequest(url: myURL!)
        webView.load(myRequest)
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

    
    //MARK:- WKNavigationDelegate
    func webView(_ webView: WKWebView,
                 didFailProvisionalNavigation navigation: WKNavigation!,
                 withError error: Error) {
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

