//
//  BrowserViewController.swift
//  SPV
//
//  Created by dlatheron on 26/07/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController, WKUIDelegate, UIGestureRecognizerDelegate, UISearchResultsUpdating {
    
    //let initialPageUrl = "http://arstechnica.co.uk"
//    let initialPageUrl = "https://www.google.co.uk/search?q=test&source=lnms&tbm=isch&sa=X&ved=0ahUKEwjcvMHyrqvVAhXEAsAKHfdxAu0Q_AUICygC&biw=1680&bih=882#imgrc=_"
    //let initialPageUrl = "http://www.smartcc365.com/group/landscape-image/"
    let initialPageUrl = "https://cdn.pixabay.com/photo/2015/07/06/13/58/arlberg-pass-833326_1280.jpg"
    
    let statusBarHeight = CGFloat.init(20)
    let urlBarHeight = CGFloat.init(56)
    let topBarHeight = CGFloat.init(20 + 44)
    let barViewAnimationSpeed = 0.25

    var webView: WKWebView!
    var searchController: UISearchController!
    
    var data = [
        "San Francisco",
        "New York",
        "San Jose",
        "Chicago",
        "Los Angeles",
        "Austin",
        "Seattle"
    ]
    var filteredData:[String] = []
    var shouldShowSearchResults: Bool = false
    
    let getImageJS: String;
    
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
    
    @IBAction func unwindToBrowserViewController(segue:UIStoryboardSegue) {
        
    }
    
    required init(coder aDecoder: NSCoder) {
        let webConfiguration = WKWebViewConfiguration()
        webConfiguration.allowsInlineMediaPlayback = true;
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        searchController = UISearchController(searchResultsController: nil) // <-- TODO: This will need to be populated.
        
        let bundle = Bundle.main
        let path = bundle.path(forResource: "GetImage", ofType: "js")
        
        do {
            getImageJS = try String(contentsOfFile: path!)
        }
        catch {
            NSLog("Failed to load javascript file")
            getImageJS = ""
        }
        
        super.init(coder: aDecoder)!
    }

    private func configureWebView() {
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
        
        webView.scrollView.delegate = self;
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.estimatedProgress), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoBack), options: .new, context: nil)
        webView.addObserver(self, forKeyPath: #keyPath(WKWebView.canGoForward), options: .new, context: nil)
        
        longPressGesture.cancelsTouchesInView = true
        
        // Remove all of the web view's long press gesture recognisers.
        for recognizer in webView.scrollView.subviews[0].gestureRecognizers ?? [] {
            if recognizer is UILongPressGestureRecognizer {
                webView.scrollView.subviews[0].removeGestureRecognizer(recognizer)
            }
        }
        
        webView.addGestureRecognizer(longPressGesture)
        webView.allowsBackForwardNavigationGestures = true
        webView.allowsLinkPreview = false
        
        updateContentInsets()
    }
    
    private func configureSearchController() {
        searchController.searchResultsUpdater = self
        searchController.dimsBackgroundDuringPresentation = true
        searchController.searchBar.placeholder = NSLocalizedString("Search or enter website name",
                                                                   comment: "Placeholder text displayed in browser search/url field")
        searchController.searchBar.delegate = self
        searchController.searchBar.sizeToFit()
        searchController.searchBar.frame = barView.bounds
        searchController.searchBar.autoresizingMask = [ .flexibleWidth ]
        searchController.searchBar.barTintColor = UIColor(white: 0.9, alpha: 1.0)
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.autocorrectionType = .no
        searchController.searchBar.enablesReturnKeyAutomatically = true
        searchController.searchBar.keyboardType = .URL
        
        // Hide the search icon.
        UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).leftViewMode = .never
        
        let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as! UITextField
        textFieldInsideSearchBar.leftViewMode = UITextFieldViewMode.never
        
        searchController.searchBar.text = initialPageUrl
        
        barView.insertSubview(searchController.searchBar,
                              at: 0)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        configureWebView()
        
        navigateTo(url: searchController.searchBar.text!)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateScrollInsets()
    }
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                           shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    
    func getURLForDocumentsDirectory() -> NSURL {
        let paths = FileManager.default.urls(for: .documentDirectory,
                                             in: .userDomainMask)

        return paths[0] as NSURL
    }
    
    func makeFileDownloadURL(downloadURL: NSString) -> URL {
        let originalFilename = downloadURL.lastPathComponent
        let documentsDirectoryURL = getURLForDocumentsDirectory()
        let localFileURL = documentsDirectoryURL.appendingPathComponent(originalFilename);
        
        return localFileURL!
    }
    
    @IBAction func longPressDetected(_ sender: UIGestureRecognizer) {
        if sender.state != .ended {
            return
        }
        
        let location = longPressGesture.location(in: webView);
        var js = getImageJS as NSString
        
        js = js.replacingOccurrences(of: "{x}", with: location.x.description) as NSString
        js = js.replacingOccurrences(of: "{y}", with: location.y.description) as NSString
        
        webView.evaluateJavaScript(js as String, completionHandler: {
            (result, error) -> Void in
            if error != nil {
                NSLog("evaluteJavaScript error: \(error!.localizedDescription)")
            } else {
                print(result ?? "")
                let imageURLString = "\(result ?? "")"
                
                let downloadActionHandler = { (action: UIAlertAction!) -> Void in
                    DownloadManager.shared.download(remoteURL: URL(string: imageURLString)!)
                }
                
                let alertController = UIAlertController(title: "Image",
                                                        message: imageURLString,
                                                        preferredStyle: .actionSheet)
                let downloadAction = UIAlertAction(title: "Download",
                                                   style: .default,
                                                   handler: downloadActionHandler)
                let cancelAction = UIAlertAction(title: "Cancel",
                                                 style: .cancel,
                                                 handler: nil)
                
                alertController.addAction(downloadAction)
                alertController.addAction(cancelAction)
                
                self.present(alertController,
                             animated: true,
                             completion: nil)
            }
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
    
    func updateScrollInsets() {
        let statusBarOffset = CGFloat(UIApplication.shared.isStatusBarHidden ? 0 : statusBarHeight)
        let topInset = max(barView.frame.origin.y + barView.frame.height, 0)
        let bottomInset = max(UIScreen.main.bounds.height - toolbar.frame.origin.y, 0) - self.tabBarController!.tabBar.frame.size.height
        
        let insets = UIEdgeInsets(top: topInset - statusBarOffset,
                                  left: 0,
                                  bottom: bottomInset,
                                  right: 0)
        
        webView.scrollView.scrollIndicatorInsets = insets
    }
    
    func updateContentInsets() {
        let bottomInset = max(UIScreen.main.bounds.height - toolbar.frame.origin.y, 0) - self.tabBarController!.tabBar.frame.size.height
        
        webView.scrollView.contentInset = UIEdgeInsets(top: barView.frame.size.height,
                                                       left: 0,
                                                       bottom: bottomInset,
                                                       right: 0)
    }
}

//-----------------------------------------------------------------
extension BrowserViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchController.searchBar.resignFirstResponder()
        self.navigateTo(url: searchController.searchBar.text!)
        return false
    }
}

//-----------------------------------------------------------------
extension BrowserViewController : UISearchBarDelegate {
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
}

//-----------------------------------------------------------------
extension BrowserViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let statusBarOffset = CGFloat(UIApplication.shared.isStatusBarHidden ? 0 : statusBarHeight)
        let offset = max(min(-urlBarHeight - (scrollView.contentOffset.y + statusBarOffset), 0), -urlBarHeight)

        barView.frame = CGRect(x: 0,
                               y: statusBarOffset + offset,
                               width: barView.frame.width,
                               height: barView.frame.height)
        updateScrollInsets()
    }
}

//-----------------------------------------------------------------
extension BrowserViewController : UITableViewDelegate {
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

//-----------------------------------------------------------------
extension BrowserViewController : UITableViewDataSource {
}

//-----------------------------------------------------------------
extension BrowserViewController : WKNavigationDelegate {
    func webView(_ webView: WKWebView,
                 decidePolicyFor navigationAction: WKNavigationAction,
                 decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        if let urlStr = navigationAction.request.url?.absoluteString {
            searchController.searchBar.text = urlStr
        }
        decisionHandler(.allow)
    }
    
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

//-----------------------------------------------------------------
extension BrowserViewController {
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size,
                                 with: coordinator)
        
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
            self.view.layer.shouldRasterize = true
        }) { (context: UIViewControllerTransitionCoordinatorContext) in
            self.view.layer.shouldRasterize = false
            self.updateContentInsets()
        }
    }
}
