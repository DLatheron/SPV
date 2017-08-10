//
//  BrowserViewController.swift
//  SPV
//
//  Created by dlatheron on 26/07/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController, WKNavigationDelegate, WKUIDelegate, UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate, UISearchResultsUpdating, UISearchBarDelegate, UITableViewDataSource, UITableViewDelegate {
    
    //let initialPageUrl = "http://arstechnica.co.uk"
    let initialPageUrl = "https://www.google.co.uk/search?q=test&source=lnms&tbm=isch&sa=X&ved=0ahUKEwjcvMHyrqvVAhXEAsAKHfdxAu0Q_AUICygC&biw=1680&bih=882#imgrc=_"
    let statusBarHeight = CGFloat.init(20)
    let urlBarHeight = CGFloat.init(44)
    let topBarHeight = CGFloat.init(20 + 44)
    let barViewAnimationSpeed = 0.25

    var webView: WKWebView!
    var searchController: UISearchController!
    
    var data = ["San Francisco","New York","San Jose","Chicago","Los Angeles","Austin","Seattle"]
    var filteredData:[String] = []
    var shouldShowSearchResults: Bool = false
    
    @IBOutlet weak var barView: UIView!
    
    @IBOutlet weak var searchResultsTable: UITableView!
    
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
        searchController = UISearchController(searchResultsController: nil)
        
        super.init(coder: aDecoder)!
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Search controller and bar.
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = NSLocalizedString("Search or enter website name", comment: "Placeholder text displayed in browser search/url field")
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        //searchController.searchBar.backgroundColor = UIColor.clear
        searchController.searchBar.subviews[0].subviews[0].removeFromSuperview()
        
        // Hide the search icon.
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).leftViewMode = .never
        
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar.leftViewMode = UITextFieldViewMode.never
        
        searchController.searchBar.text = initialPageUrl
        
        barView.insertSubview(searchController.searchBar, at: 0)
        
        // Web view
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
        
        longPressGesture.cancelsTouchesInView = true
        
        // TODO: Work out which ones we need to lose and which ones we should keep. Keep single click (or add them ourselves).
        // Remove all of the web view's gesture recognisers.
        webView.scrollView.subviews[0].gestureRecognizers?.forEach(webView.scrollView.subviews[0].removeGestureRecognizer)
        
        webView.addGestureRecognizer(longPressGesture)
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = false
        // Correctly disables interaction with the underlying view - but
        // then we can't navigate to links...
        //webView.scrollView.subviews[0].isUserInteractionEnabled = false
        
        navigateTo(url: searchController.searchBar.text!)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
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
            searchController.searchBar.text = modifiedUrl
        }
        
        let myURL = URL(string: modifiedUrl)
        let myRequest = URLRequest(url: myURL!)
        
        webView.load(myRequest)
    }
    
    //MARK:- UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchController.searchBar.resignFirstResponder()
        self.navigateTo(url: searchController.searchBar.text!)
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
    
    //MARK:- UISearchBarDelegate
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = true
        searchResultsTable.reloadData()
        searchResultsTable.isHidden = !shouldShowSearchResults
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        searchResultsTable.reloadData()
        searchResultsTable.isHidden = !shouldShowSearchResults
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        shouldShowSearchResults = false
        searchResultsTable.reloadData()
        searchResultsTable.isHidden = !shouldShowSearchResults
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if !shouldShowSearchResults {
            searchController.isActive = true
            searchResultsTable.isHidden = !shouldShowSearchResults
        }
        
        searchController.searchBar.resignFirstResponder()
        
        self.navigateTo(url: searchController.searchBar.text!)
    }
    
    func updateSearchResults(for searchController: UISearchController) {
        let searchString = searchController.searchBar.text
        
        if (searchString?.isEmpty)! {
            filteredData = data
        } else {
            // Filter the data array and get only those countries that match the search text.
            filteredData = data.filter({ (country) -> Bool in
                let countryText: NSString = country as NSString
                
                return (countryText.range(of: searchString!, options: NSString.CompareOptions.caseInsensitive).location) != NSNotFound
            })
        }
        
        // Reload the tableview.
        searchResultsTable.reloadData()
    }
    
    //MARK:- UITableViewDelegate
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // Proposed sections:
        // - Bookmarks
        // - History
        // - Google search
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filteredData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {        
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!;
        cell.textLabel?.text = filteredData[indexPath.row]
        
        return cell;
    }
}

