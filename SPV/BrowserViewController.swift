//
//  BrowserViewController.swift
//  SPV
//
//  Created by dlatheron on 26/07/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import UIKit
import WebKit

class BrowserViewController: UIViewController, WKUIDelegate, UIGestureRecognizerDelegate {
    
    //let initialPageUrl = "http://arstechnica.co.uk"
//    let initialPageUrl = "https://www.google.co.uk/search?q=test&source=lnms&tbm=isch&sa=X&ved=0ahUKEwjcvMHyrqvVAhXEAsAKHfdxAu0Q_AUICygC&biw=1680&bih=882#imgrc=_"
    //let initialPageUrl = "http://www.smartcc365.com/group/landscape-image/"
    let initialPageUrl = "https://cdn.pixabay.com/photo/2015/07/06/13/58/arlberg-pass-833326_1280.jpg"
    var urlBeforeEditing: String? = nil;
    
    let statusBarHeight = CGFloat.init(20)
    let urlBarHeight = CGFloat.init(56)
    let searchBarHeight = CGFloat.init(100)
    let topBarHeight = CGFloat.init(20 + 44)
    let barViewAnimationSpeed = 0.25

    var webView: WKWebView!
    var scope: SearchScope = .all // TODO: Preserve as config.
    //var searchController: UISearchController! = nil
    
    @IBOutlet weak var barHeightConstraint: NSLayoutConstraint!
    
    typealias HistoryEntry = (url: String, category: SearchScope)
    
    var data: [HistoryEntry] = [
        HistoryEntry(url: "www.google.co.uk", category: .bookmarks),
        HistoryEntry(url: "www.arstechnica.co.uk", category: .bookmarks)
    ]
//    [
//        "San Francisco",
//        "New York",
//        "San Jose",
//        "Chicago",
//        "Los Angeles",
//        "Austin",
//        "Seattle"
//    ]
    var filteredData: [HistoryEntry] = []
    var shouldShowSearchResults: Bool = false
    
    let getImageJS: String;
    
    @IBOutlet weak var barView: UIView!
    @IBOutlet weak var searchBar: UISearchBar!
    
    @IBOutlet weak var searchResultsTable: UITableView!
    @IBOutlet weak var searchEffectsView: UIVisualEffectView!
    
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
        //view.addSubview(webView)

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
        let searchBar = self.searchBar!
        
        searchBar.delegate = self
        searchBar.showsCancelButton = false
        searchBar.showsScopeBar = false
        searchBar.autocapitalizationType = .none
        searchBar.autocorrectionType = .no
        searchBar.enablesReturnKeyAutomatically = true
        searchBar.keyboardType = .URL
        searchBar.placeholder = NSLocalizedString("Search or enter website name", comment: "Placeholder text displayed in browser search/url field")
        
        definesPresentationContext = true

        navigationItem.titleView = searchBar
        
//        searchController.searchResultsUpdater = self
//        searchController.dimsBackgroundDuringPresentation = false
//        searchController.definesPresentationContext = true
//        searchController.searchBar.placeholder = NSLocalizedString("Search or enter website name",
//                                                                   comment: "Placeholder text displayed in browser search/url field")
//        searchController.searchBar.delegate = self
//        searchController.searchBar.sizeToFit()
//        searchController.searchBar.frame = barView.bounds
//        searchController.searchBar.autoresizingMask = [ .flexibleWidth, .flexibleHeight ]
//        //searchController.searchBar.barTintColor = UIColor(white: 0.9, alpha: 1.0)
//        searchController.searchBar.autocapitalizationType = .none
//        searchController.searchBar.autocorrectionType = .no
//        searchController.searchBar.enablesReturnKeyAutomatically = true
//        searchController.searchBar.keyboardType = .URL
//
//        searchController.searchBar.scopeButtonTitles = ["All", "History", "Bookmarks", "Other"]
//        searchController.searchBar.delegate = self

        let barColour = UIColor(red: (247/255),
                                green: (247/255),
                                blue: (247/255),
                                alpha: 1)
        UISearchBar.appearance().barTintColor = barColour
        UISearchBar.appearance().tintColor = self.tabBarController!.tabBar.tintColor
        UITextView.appearance(whenContainedInInstancesOf: [UISearchBar.self]).tintColor = barColour
        
        // Hide the search icon.
        //UITextField.appearance(whenContainedInInstancesOf: [UISearchBar.self]).leftViewMode = .never
        
        //let textFieldInsideSearchBar = searchController.searchBar.value(forKey: "searchField") as! UITextField
        //textFieldInsideSearchBar.leftViewMode = UITextFieldViewMode.never
        
        searchBar.text = initialPageUrl
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        configureWebView()
        
        navigateTo(url: searchBar.text!)
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
            searchBar.text = modifiedUrl
        }
        
        let myURL = URL(string: modifiedUrl)
        let myRequest = URLRequest(url: myURL!)
        
        webView.load(myRequest)
    }
    
    func updateBarFrame() {
//        let statusBarOffset = CGFloat(UIApplication.shared.isStatusBarHidden ? 0 : statusBarHeight)
//        let offset = max(min(-urlBarHeight - (webView.scrollView.contentOffset.y + statusBarOffset), 0), -urlBarHeight)
//        let barHeight = shouldShowSearchResults ? searchBarHeight : urlBarHeight
//
//        
//        barView.frame = CGRect(x: 0,
//                               y: statusBarOffset + offset,
//                               width: barView.frame.width,
//                               height: barHeight)
    }
    
    func updateScrollInsets() {
//        let statusBarOffset = CGFloat(UIApplication.shared.isStatusBarHidden ? 0 : statusBarHeight)
//        let topInset = max(barView.frame.origin.y + barView.frame.height, 0)
//        let bottomInset = max(UIScreen.main.bounds.height - toolbar.frame.origin.y, 0) - self.tabBarController!.tabBar.frame.size.height
//
//        let insets = UIEdgeInsets(top: topInset - statusBarOffset,
//                                  left: 0,
//                                  bottom: bottomInset,
//                                  right: 0)
//
//        webView.scrollView.scrollIndicatorInsets = insets
    }
    
    func updateContentInsets() {
//        let bottomInset = max(UIScreen.main.bounds.height - toolbar.frame.origin.y, 0) - self.tabBarController!.tabBar.frame.size.height
//
//        webView.scrollView.contentInset = UIEdgeInsets(top: barView.frame.size.height,
//                                                       left: 0,
//                                                       bottom: bottomInset,
//                                                       right: 0)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchBar.text?.isEmpty ?? true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = searchBar.selectedScopeButtonIndex != 0
        return !searchBarIsEmpty() || searchBarScopeIsFiltering
    }
    
    func filterContentsBy(searchText: String?,
                          scope: SearchScope = .all) {
        let searchTextLowerCased = (searchText ?? "").lowercased()
        
        if searchBarIsEmpty() {
            filteredData = data
        } else {
            filteredData = data.filter({(data: HistoryEntry) -> Bool in
                let doesCategoryMatch = (scope == .all) || (data.category == scope)
                
                if searchBarIsEmpty() {
                    return doesCategoryMatch
                } else {
                    return doesCategoryMatch && data.url.lowercased().contains(searchTextLowerCased)
                }
            })
        }
        
        searchResultsTable.reloadData()
    }
}

//-----------------------------------------------------------------
extension BrowserViewController : UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        searchBar.resignFirstResponder()
        self.navigateTo(url: searchBar.text!)
        return false
    }
}

//-----------------------------------------------------------------
extension BrowserViewController : UISearchBarDelegate {
    func activateSearch() {
        if !shouldShowSearchResults {
            print("Activating...");
            shouldShowSearchResults = true

            // Reveal the effects via - but make it invisible so we can fade it in.
            searchEffectsView.alpha = 0
            searchEffectsView.isHidden = false

            UIView.animate(withDuration: 0.3,
                           delay: 0.1,
                           options: [ .curveEaseInOut ],
                           animations: {
                self.searchBar.setShowsCancelButton(true,
                                                    animated: true)
                self.searchEffectsView.alpha = 1
            })
        } else {
            print("Already activating!")
        }
    }
    
    func deactivateSearch() {
        if (shouldShowSearchResults) {
            print("...Deactivating");
            shouldShowSearchResults = false

            // Dismiss the keyboard - causes a recursive call into this function.
            searchBar.resignFirstResponder()

            UIView.animate(withDuration: 0.3,
                           delay: 0.1,
                           options: [ .curveEaseInOut ],
                           animations: {
                self.searchEffectsView.alpha = 0
                self.searchBar.setShowsCancelButton(false,
                                                    animated: true)
            }) { (complete) in
                if complete {
                    self.searchEffectsView.isHidden = true
                }
            }
        } else {
            print("...already deactivating!")
        }
    }
    
    func searchBar(_ searchBar: UISearchBar,
                   textDidChange searchText: String) {
        filterContentsBy(searchText: searchText,
                         scope: scope)
    }
    
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        activateSearch()
        
        urlBeforeEditing = searchBar.text
        filterContentsBy(searchText: searchBar.text,
                         scope: scope)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = urlBeforeEditing

        deactivateSearch()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = urlBeforeEditing
        
        deactivateSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = searchBar.text {
//            if !shouldShowSearchResults {
//                //searchController.isActive = true
//                searchResultsTable.isHidden = !shouldShowSearchResults
//            }
            
//            searchBar.resignFirstResponder()
            
            self.navigateTo(url: searchText)
            
            addHistory(forURL: searchText)
        }

        deactivateSearch()
    }
    
//    func searchBar(_ searchBar: UISearchBar,
//                   selectedScopeButtonIndexDidChange selectedScope: Int) {
//        filterContentsBy(searchText: searchBar.text!,
//                         scope: selectedScope)
//    }
    
    func addHistory(forURL textURL: String, category: String = "History") {
        if let index = data.index(where: { (entryURL, entryCategory) -> Bool in
            return entryURL == textURL
        }) {
            data.remove(at: index)
        }
        
        data.insert(HistoryEntry(textURL, .history),
                    at: 0)
    }
}

//-----------------------------------------------------------------
//extension BrowserViewController : UISearchResultsUpdating {
//    func updateSearchResults(for searchController: UISearchController) {
//        let searchBar = searchController.searchBar
//        let scope = searchBar.scopeButtonTitles![searchBar.selectedScopeButtonIndex]
//
//        filterContentsBy(searchText: searchController.searchBar.text!, scope: scope)
//    }
//}

//-----------------------------------------------------------------
extension BrowserViewController : UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        updateBarFrame()
        updateScrollInsets()
    }
}

//-----------------------------------------------------------------
extension BrowserViewController : UITableViewDelegate {
    func tableView(_ tableView: UITableView,
                   heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    func tableView(_ tableView: UITableView,
                   viewForHeaderInSection section: Int) -> UIView? {
        let scopeCell = tableView.dequeueReusableCell(withIdentifier: "Scope") as! SearchScopeCell
        
        scopeCell.delegate = self
        scopeCell.configure(withInitialScope: scope)
        
        return scopeCell
    }
    
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
    
    func tableView(_ tableView: UITableView,
                   cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell")!;
        cell.textLabel?.text = filteredData[indexPath.row].url
        
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
            searchBar.text = urlStr
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

//-----------------------------------------------------------------
extension BrowserViewController : SearchScopeDelegate {
    func changed(scope: SearchScope) {
        self.scope = scope
        
        filterContentsBy(searchText: searchBar.text!,
                         scope: scope)
    }
}

//extension BrowserViewController : UISearchControllerDelegate {
//    func didPresentSearchController(_ searchController: UISearchController) {
//        //searchResultsTable.isHidden = false
//    }
//
//    func didDismissSearchController(_ searchController: UISearchController) {
//        //searchResultsTable.isHidden = true
//    }
//}

