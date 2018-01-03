//
//  BrowserViewController.swift
//  SPV
//
//  Created by dlatheron on 26/07/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import UIKit
import WebKit

/* REFACTOR THIS COMPLETELY
 - Should be do able with auto-layout... top bar var at 88 with a flexible inset constraint
 - Bottom should also be constraint based. Should be able to animate it out by affecting the constraint.
 
 */

class BrowserViewController: UIViewController, WKUIDelegate, UIGestureRecognizerDelegate {
    
    let initialPageUrl = "https://cdn.pixabay.com/photo/2015/07/06/13/58/arlberg-pass-833326_1280.jpg"
    
    @IBOutlet weak var webView: WKWebView!
    @IBOutlet weak var topBar: UIView!
    @IBOutlet weak var searchBar: CollapsibleSearchBar!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var searchBarBottomOffsetConstraint: NSLayoutConstraint!
    @IBOutlet weak var topBarHeightConstraint: NSLayoutConstraint!
    
    var scrollOffsetStart: CGFloat? = nil
    var canCollapse: Bool = false

    var scope: SearchScope = .all // TODO: Preserve as config.
    
    typealias HistoryEntry = (url: String, category: SearchScope)
    
    var data: [HistoryEntry] = [
        HistoryEntry(url: "www.google.co.uk",
                     category: .bookmarks),
        HistoryEntry(url: "www.arstechnica.co.uk",
                     category: .bookmarks),
        HistoryEntry(url: "https://cdn.pixabay.com/photo/2015/07/06/13/58/arlberg-pass-833326_1280.jpg",
                     category: .history)
    ]

    var filteredData: [HistoryEntry] = []
    
    let getImageJS: String
    
    @IBOutlet weak var searchResultsTable: UITableView!
    @IBOutlet weak var searchEffectsView: UIVisualEffectView!
    
    // Web Browser navigator
    @IBOutlet weak var toolbar: UIToolbar!
    @IBOutlet weak var backButton: UIBarButtonItem!
    @IBOutlet weak var forwardButton: UIBarButtonItem!
    @IBOutlet weak var reloadButton: UIBarButtonItem!
    @IBOutlet weak var tabsButton: UIBarButtonItem!
    @IBOutlet weak var longPressGesture: UILongPressGestureRecognizer!
    
    var tapOnBarGesture: UITapGestureRecognizer?

    @IBAction func unwindToBrowserViewController(segue:UIStoryboardSegue) {
        
    }
    
    required init(coder aDecoder: NSCoder) {
//        let webConfiguration = WKWebViewConfiguration()
//        webConfiguration.allowsInlineMediaPlayback = true
//        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        
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
        
        webView.scrollView.contentInset = UIEdgeInsets(top: 44,
                                                       left: 0,
                                                       bottom: 88,
                                                       right: 0)
        webView.scrollView.delegate = self
        
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
    }

    func calcSearchBarHeight(at interpolant: CGFloat) -> CGFloat {
        searchBar.interpolant = interpolant
        let topBarHeight = searchBar.bounds.origin.y + searchBar.bounds.size.height
        let bottomBarHeight: CGFloat = 44//UIScreen.main.bounds.height - toolbar.bounds.origin.y
        
        webView.scrollView.contentInset = UIEdgeInsets(top: topBarHeight,
                                                       left: 0,
                                                       bottom: bottomBarHeight,
                                                       right: 0)
        webView.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: topBarHeight,
                                                                left: 0,
                                                                bottom: bottomBarHeight,
                                                                right: 0)
        
        return 44 + searchBar.bounds.size.height
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureWebView()
        
        updateConstraints()
        
        navigateTo(url: initialPageUrl)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
        let localFileURL = documentsDirectoryURL.appendingPathComponent(originalFilename)
        
        return localFileURL!
    }
    
    @IBAction func longPressDetected(_ sender: UIGestureRecognizer) {
        if sender.state != .ended {
            return
        }
        
        let location = longPressGesture.location(in: webView)
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
    
    @objc func tapOnBarDetected(_ sender: UIGestureRecognizer) {
        if sender.state != .ended {
            return
        }
        
//        if let flexibleHeightBar = flexibleHeightBar {
//            if let behaviourDefiner = flexibleHeightBar.behaviorDefiner {
//                UIView.animate(withDuration: 0.15,
//                               animations: {
//                    self.progressChanged(progress: 0.0)
//                })
//
//                flexibleHeightBar.progress = 0.0
//
//                behaviourDefiner.snap(with: webView.scrollView) {
//                    flexibleHeightBar.enableSubviewInteractions(true)
//                    self.searchField.becomeFirstResponder()
//                }
//            }
//        }
    }
    
    // TODO: Only show domain and lock symbol (centred) when the search is inactive.
    // On activation display the whole thing AND left justify it (with animation).
   
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
    
    func ensureValidProtocol(urlString: String) -> String {
        let insecureProtocol = "http"
        
        if let url = URL(string: urlString) {
            if url.scheme == nil {
                if let url = URL(string: "\(insecureProtocol)://\(urlString)") {
                    return url.absoluteString
                }
            }
        }
        return urlString
    }
    
    func setSearchBarText(urlString: String) {
        let closedLock = "🔒"
        let openLock = "🔓"
        
        if let urlBuilder = URLBuilder(string: urlString) {
            let lockState = urlBuilder.isSchemeSecure ? closedLock : openLock
            let domainText = "\(lockState) \(urlBuilder.host ?? "")"
            searchBar.text = domainText
//            searchField.text = domainText
        } else {
            searchBar.text = nil
//            searchField.text = nil
        }
    }
    
    func navigateTo(url newURLString: String?) {
        if let newURLString = newURLString {
            let modifiedNewURLString = ensureValidProtocol(urlString: newURLString)
            let newURL = URL(string: modifiedNewURLString)
            let myRequest = URLRequest(url: newURL!)
            
            searchBar.urlString = modifiedNewURLString
            
            addHistory(forURL: modifiedNewURLString)
            
            webView.load(myRequest)
        }
    }
    
    func searchBarIsEmpty() -> Bool {
        return /*searchField.text?.isEmpty ?? */true
    }
    
    func isFiltering() -> Bool {
        let searchBarScopeIsFiltering = scope != .all
        return !searchBarIsEmpty() || searchBarScopeIsFiltering
    }
    
    func filterContentsBy(searchText: String?,
                          scope: SearchScope = .all) {
        let searchTextLowerCased = (searchText ?? "").lowercased()
        
        filteredData = data.filter({(data: HistoryEntry) -> Bool in
            let doesCategoryMatch = (scope == .all) || (data.category == scope)
            
            if searchBarIsEmpty() {
                return doesCategoryMatch
            } else {
                return doesCategoryMatch && data.url.lowercased().contains(searchTextLowerCased)
            }
        })
        
        searchResultsTable.reloadData()
    }
    
    func updateConstraints() {
        let searchBarBottomOffset: CGFloat = UIScreen.main.isLandscape ? -6 : 0
        
        searchBarBottomOffsetConstraint.constant = searchBarBottomOffset
        toolbar.invalidateIntrinsicContentSize()
    }
    
    func changeOrientation() {
        updateConstraints()
        searchBar.changeOrientation()
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        guard
            tabBarController?.selectedViewController === self
        else {
            return
        }
        
        super.viewWillTransition(to: size,
                                 with: coordinator)        
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
            self.changeOrientation()
        }) { (context: UIViewControllerTransitionCoordinatorContext) in
            self.changeOrientation()
        }
    }
}

//-----------------------------------------------------------------
extension BrowserViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        textField.text = self.url
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        //flexibleHeightBar?.enableSubviewInteractions(false)
        self.navigateTo(url: textField.text!)
        return false
    }

    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        //flexibleHeightBar?.enableSubviewInteractions(false)
        //setSearchBarText(urlString: url)
    }
}

//-----------------------------------------------------------------
extension BrowserViewController : UISearchBarDelegate {
    func activateSearch() {
        if !searchBar.editing {
            print("Activating...")
            searchBar.activate()

            // Reveal the effects via - but make it invisible so we can fade it in.
            searchEffectsView.alpha = 0
            searchEffectsView.isHidden = false

            UIView.animate(withDuration: 0.3,
                           delay: 0.1,
                           options: [ .curveEaseInOut ],
                           animations: {
                self.searchEffectsView.alpha = 1
            })
        } else {
            print("Already activating!")
        }
    }
    
    func deactivateSearch() {
        if searchBar.editing {
            print("...Deactivating")
            searchBar.deactivate()

            UIView.animate(withDuration: 0.3,
                           delay: 0.1,
                           options: [ .curveEaseInOut ],
                           animations: {
                self.searchEffectsView.alpha = 0
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
        
        filterContentsBy(searchText: self.searchBar.urlString,
                         scope: scope)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        deactivateSearch()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        deactivateSearch()
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        if let searchText = self.searchBar.text {
//            if !shouldShowSearchResults {
//                //searchController.isActive = true
//                searchResultsTable.isHidden = !shouldShowSearchResults
//            }
            
//            searchBar.resignFirstResponder()
            
            self.navigateTo(url: searchText)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchCell") as! SearchCell
        cell.textLabel?.text = filteredData[indexPath.row].url
        cell.delegate = self
        
        return cell
    }
}

//-----------------------------------------------------------------
extension BrowserViewController : SearchCellDelegate {
    func tableViewCell(singleTapActionFromCell cell: SearchCell) {
        DispatchQueue.main.async {
            self.searchBar.urlString = cell.textLabel!.text!
        }
    }
    
    func tableViewCell(doubleTapActionFromCell cell: SearchCell) {
        DispatchQueue.main.async {
            self.navigateTo(url: cell.textLabel!.text!)
            self.deactivateSearch()
        }
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
            setSearchBarText(urlString: urlStr)
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
extension BrowserViewController : SearchScopeCellDelegate {
    func changed(scope: SearchScope) {
        self.scope = scope
        
        filterContentsBy(searchText: ""/*searchField.text!*/,
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

//-----------------------------------------------------------------
extension BrowserViewController : UIScrollViewDelegate
{
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
//        if !shouldShowSearchResults {
//            let delegate: UIScrollViewDelegate? = flexibleHeightBar?.behaviorDefiner
//            delegate?.scrollViewDidEndDecelerating?(scrollView)
//        }
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        if scrollOffsetStart == nil {
            scrollOffsetStart = scrollView.contentOffset.y
            if searchBar.interpolant == 1 {
                // View is fully collapsed.
            } else if searchBar.interpolant == 0 {
                // View is fully expanded.
                canCollapse = true
            }
        }
//        if !shouldShowSearchResults {
//            let delegate: UIScrollViewDelegate? = flexibleHeightBar?.behaviorDefiner
//            delegate?.scrollViewWillBeginDragging?(scrollView)
//        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        canCollapse = false
        scrollOffsetStart = nil
        
        //topBarHeightConstraint.constant = calcSearchBarHeight(at: searchBar.snap())

//        if !shouldShowSearchResults {
//            let delegate: UIScrollViewDelegate? = flexibleHeightBar?.behaviorDefiner
//            delegate?.scrollViewDidEndDragging?(scrollView,
//                                                willDecelerate: decelerate)
//        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if let scrollOffsetStart = scrollOffsetStart {
            let offset = scrollView.contentOffset.y - scrollOffsetStart
            
            if canCollapse && offset > 0 {
                let interpolant = offset / 40
                
                topBarHeightConstraint.constant = calcSearchBarHeight(at: interpolant)
                
                // TODO: Update scroll content inset...
            } else if scrollView.contentOffset.y < -88 + 40 {
                let interpolant = offset / 40
                
                topBarHeightConstraint.constant = calcSearchBarHeight(at: interpolant)
            }
        
        
//        if !shouldShowSearchResults {
//            let delegate: UIScrollViewDelegate? = flexibleHeightBar?.behaviorDefiner
//            delegate?.scrollViewDidScroll?(scrollView)
//
//            if let flexibleHeightBar = flexibleHeightBar {
//                if flexibleHeightBar.progress > 0.0 {
//                    flexibleHeightBar.enableSubviewInteractions(false)
//                }
//            }
//        }
        }
    }
}
