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
    var url: String = ""
    
    //let statusBarHeight = CGFloat.init(20)
    //let urlBarHeight = CGFloat.init(56)
    //let searchBarHeight = CGFloat.init(100)
    let barViewAnimationSpeed = 0.25

    var webView: WKWebView!
    var scope: SearchScope = .all // TODO: Preserve as config.
    //var searchController: UISearchController! = nil
    
    @IBOutlet weak var barHeightConstraint: NSLayoutConstraint!
    
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
    var shouldShowSearchResults: Bool = false
    
    let getImageJS: String;
    
    @IBOutlet weak var barView: UIView!
    weak var searchField: UITextField!
    weak var searchFieldBorder: UIImageView?
    
//    @IBOutlet weak var titleBar: UILabel!
    
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
    
    var flexibleHeightBar: FlexibleHeightBar?
    var tapOnBarGesture: UITapGestureRecognizer?

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
        
        url = initialPageUrl
        
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
        
        //webView.scrollView.delegate = self;
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
    
    //let statusBarHeight: CGFloat = 20.0
    let labelBarHeight: CGFloat = 20.0
    let searchBarHeight: CGFloat = 46.0
    
    private func setupSearchField(parentView: UIView) -> UITextField {
        let searchField = UITextField()
        
        searchField.delegate = self
        searchField.autocapitalizationType = .none
        searchField.autocorrectionType = .no
        searchField.enablesReturnKeyAutomatically = true
        searchField.keyboardType = .URL
        searchField.placeholder = NSLocalizedString("Search or enter website name", comment: "Placeholder text displayed in browser search/url field")
        searchField.borderStyle = .roundedRect
        searchField.textAlignment = .center
        //searchField.backgroundColor = UIColor.clear
        searchField.clearButtonMode = .whileEditing
        searchField.backgroundColor = barColour
        
        parentView.addSubview(searchField)
        
        searchField.bounds = CGRect(x: 8,
                                    y: 8,
                                    width: screenWidth - 16,
                                    height: 30)
//        searchField.frame = CGRect(x: 8,
//                                   y: 8,
//                                   width: screenWidth - 16,
//                                   height: 30)

        self.searchField = searchField
        self.searchFieldBorder = searchField.subviews[0] as? UIImageView

        return searchField
    }
    
    private var screenWidth: CGFloat {
        get {
            return UIScreen.main.bounds.width
        }
    }
    
    private var screenHeight: CGFloat {
        get {
            return UIScreen.main.bounds.height
        }
    }
    
    private var landscape: Bool {
        get {
            return screenWidth > screenHeight
        }
    }
    
    private var statusBarHeight: CGFloat {
        get {
            return landscape ? 0 : 20.0
        }
    }
    
    private var minBarHeight: CGFloat {
        get {
            return labelBarHeight + statusBarHeight
        }
    }
    
    private var maxBarHeight: CGFloat {
        get {
            return searchBarHeight + statusBarHeight
        }
    }
    
    private var barColour: UIColor {
        get {
            return UIColor(red: 247/255,
                           green: 247/255,
                           blue: 247/255,
                           alpha: 1)
        }
    }
    
    private func setupFlexibleHeightBar() -> FlexibleHeightBar {
        let flexibleHeightBar = FlexibleHeightBar(frame: CGRect(x: 0.0,
                                                                y: 0.0,
                                                                width: self.view.frame.size.width,
                                                                height: maxBarHeight))
        
        // Effect view.
        let fxView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
        fxView.sizeToFit()
        fxView.frame = CGRect(x: 0,
                              y: 0,
                              width: screenWidth,
                              height: maxBarHeight)
        flexibleHeightBar.clipsToBounds = true
        flexibleHeightBar.addSubview(fxView)
        
        flexibleHeightBar.minimumBarHeight = minBarHeight
        flexibleHeightBar.maximumBarHeight = maxBarHeight
        flexibleHeightBar.backgroundColor = barColour
        
        // Behaviour.
        let behaviourDefiner = FacebookBarBehaviorDefiner()
        behaviourDefiner.thresholdNegativeDirection = 0.0
        behaviourDefiner.thresholdFromTop = 0.0
        behaviourDefiner.thresholdPositiveDirection = 0.0
        flexibleHeightBar.behaviorDefiner = behaviourDefiner
        webView.scrollView.delegate = self
        
        self.flexibleHeightBar = flexibleHeightBar

        // Gesture recogniser.
        tapOnBarGesture = UITapGestureRecognizer(target: self,
                                                 action: #selector(self.tapOnBarDetected(_:)))
        if let tapOnBarGesture = tapOnBarGesture {
            tapOnBarGesture.numberOfTapsRequired = 1
            tapOnBarGesture.numberOfTouchesRequired = 1
            flexibleHeightBar.addGestureRecognizer(tapOnBarGesture)
        }
        
        return flexibleHeightBar
    }
    
    private func setupProgressView() -> UIProgressView {
        let progressView = UIProgressView()
        
        progressView.sizeToFit()
        
        self.progressView = progressView
        
        return progressView
    }

    private func configureSearchController() {
        let flexibleHeightBar = setupFlexibleHeightBar()
        self.view.addSubview(flexibleHeightBar)

        let searchField = setupSearchField(parentView: flexibleHeightBar)
        
        webView.scrollView.contentInset = UIEdgeInsetsMake(maxBarHeight - statusBarHeight, 0.0, 0.0, 0.0)
        webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(maxBarHeight - statusBarHeight, 0.0, 0.0, 0.0)
        
        definesPresentationContext = true
        
        let progressView = setupProgressView()
        
        //searchBar.bounds = CGRect(x: 0, y: 20.0, width: flexibleHeightBar!.bounds.size.width, height: flexibleHeightBar!.bounds.size.height)

        //barView.removeFromSuperview()
        //barView.isHidden = true
        //barView.frame = CGRect(x: 0.0, y: statusBarHeight, width: UIScreen.main.bounds.size.width, height: barView.frame.height)
        flexibleHeightBar.addSubview(progressView)

        setupSearchFieldProgressStates(searchField: searchField,
                                       flexibleHeightBar: flexibleHeightBar)

        
        //navigationController!.navigationItem.titleView = searchBar
        
        //let titleBar = self.titleBar!
        
        //navigationController!.navigationItem.titleView = titleBar

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
    }
    
    func setSearchFieldBorderProgressState(flexibleHeightBar: FlexibleHeightBar,
                                           searchFieldBorder: UIImageView?) {
        if let searchFieldBorder = searchFieldBorder {
            let initialState = FlexibleHeightBarSubviewLayoutAttributes()
            initialState.alpha = 1
            flexibleHeightBar.addLayoutAttributes(initialState,
                                                  forSubview: searchFieldBorder,
                                                  forProgress: 0.0)
            
            let finalState = FlexibleHeightBarSubviewLayoutAttributes()
            finalState.alpha = 0
            flexibleHeightBar.addLayoutAttributes(finalState,
                                                  forSubview: searchFieldBorder,
                                                  forProgress: 0.2)
        }
    }
    
    func setLayout(_ view: UIView?,
                   forBar flexibleHeightBar: FlexibleHeightBar,
                   atProgress progress: CGFloat,
                   withPreviousLayout previousLayout: FlexibleHeightBarSubviewLayoutAttributes? = nil,
                   offset: CGPoint? = nil,
                   translationY: CGFloat? = nil,
                   scale: CGFloat? = nil,
                   alpha: CGFloat? = nil) -> FlexibleHeightBarSubviewLayoutAttributes? {
        let layout: FlexibleHeightBarSubviewLayoutAttributes
        if let previousLayout = previousLayout {
            layout = FlexibleHeightBarSubviewLayoutAttributes(layoutAttributes: previousLayout)
        } else {
            layout = FlexibleHeightBarSubviewLayoutAttributes()
            if let view = view {
                layout.size = view.frame.size
            }
        }
        
        let translationTransform: CGAffineTransform
        if let translationY = translationY {
            translationTransform = CGAffineTransform(translationX: 0.0,
                                                     y: translationY)
        } else {
            translationTransform = CGAffineTransform.identity
        }
        
        let scaleTransform: CGAffineTransform
        if let scale = scale {
            scaleTransform = CGAffineTransform(scaleX: scale,
                                               y: scale)
        } else {
            scaleTransform = CGAffineTransform.identity
        }
        
        layout.transform = scaleTransform.concatenating(translationTransform)
        
        if let alpha = alpha {
            layout.alpha = alpha
            layout.borderAlpha = alpha
            layout.backgroundAlpha = alpha
        }
        
        if let view = view {
            if let offset = offset {
                layout.center = CGPoint(x: view.bounds.midX + offset.x,
                                        y: view.bounds.midY + offset.y)
            }
            
            flexibleHeightBar.addLayoutAttributes(layout,
                                                  forSubview: view,
                                                  forProgress: progress)
        }
        
        return layout
    }
    
    func interpolate(from fromValue: CGFloat,
                     to toValue: CGFloat,
                     withProgress progress: CGFloat) -> CGFloat {
        return fromValue - ((fromValue - toValue) * progress)
    }
    
    func setupSearchFieldProgressStates(searchField: UITextField,
                                        flexibleHeightBar: FlexibleHeightBar) {
        let initialProgress: CGFloat = 0.0
        let middleProgress: CGFloat = 0.20
        let finalProgress: CGFloat = 1.0
        
        let translationY: CGFloat = -16.0
        let scale: CGFloat = 0.75
        
        let midTranslationY = interpolate(from: 0.0,
                                          to: translationY,
                                          withProgress: middleProgress)
        let finalTranslationY = interpolate(from: 0.0,
                                            to: translationY,
                                            withProgress: finalProgress)
        
        let midScale = interpolate(from: 1.0,
                                   to: scale,
                                   withProgress: middleProgress)
        let finalScale = interpolate(from: 1.0,
                                     to: scale,
                                     withProgress: finalProgress)
        
        var layout: FlexibleHeightBarSubviewLayoutAttributes?
        
        layout = setLayout(searchField,
                           forBar: flexibleHeightBar,
                           atProgress: initialProgress,
                           offset: CGPoint(x: 0.0, y: statusBarHeight))
        layout = setLayout(searchField,
                           forBar: flexibleHeightBar,
                           atProgress: middleProgress,
                           withPreviousLayout: layout,
                           translationY: midTranslationY,
                           scale: midScale)
        layout = setLayout(searchField,
                           forBar: flexibleHeightBar,
                           atProgress: finalProgress,
                           withPreviousLayout: layout,
                           translationY: finalTranslationY,
                           scale: finalScale)

        layout = setLayout(searchFieldBorder,
                           forBar: flexibleHeightBar,
                           atProgress: initialProgress,
                           offset: CGPoint.zero)
        layout = setLayout(searchFieldBorder,
                           forBar: flexibleHeightBar,
                           atProgress: middleProgress,
                           withPreviousLayout: layout,
                           alpha: 0.0)
        layout = setLayout(searchFieldBorder,
                           forBar: flexibleHeightBar,
                           atProgress: finalProgress,
                           withPreviousLayout: layout,
                           alpha: 0.0)
    }
    
//    func setFXViewProgressStates(_ fxView: UIVisualEffectView,
//                                 for flexibleHeightBar: FlexibleHeightBar) {
//        let initialLayoutAttributes = FlexibleHeightBarSubviewLayoutAttributes()
//        initialLayoutAttributes.size = fxView.frame.size
//        initialLayoutAttributes.center = CGPoint(x: fxView.bounds.midX,
//                                                 y: fxView.bounds.midY)
//
//        flexibleHeightBar!.addLayoutAttributes(initialLayoutAttributes,
//                                               forSubview: fxView,
//                                               forProgress: 0.0)
//
//        // Create a final set of layout attributes based on the same values as the initial layout attributes
//        let finalLayoutAttributes = FlexibleHeightBarSubviewLayoutAttributes(layoutAttributes: initialLayoutAttributes)
//        finalLayoutAttributes.alpha = 0.0
//        let translation = CGAffineTransform(translationX: 0.0,
//                                            y: -statusBarHeight)
//        let scale = CGAffineTransform(scaleX: 0.2,
//                                      y: 0.2)
//        finalLayoutAttributes.transform = scale.concatenating(translation)
//
//        flexibleHeightBar!.addLayoutAttributes(finalLayoutAttributes,
//                                               forSubview: searchBar,
//                                               forProgress: 0.0)
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        configureWebView()
        
        navigateTo(url: url)
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
    
    @objc func tapOnBarDetected(_ sender: UIGestureRecognizer) {
        if sender.state != .ended {
            return
        }
        
        if let flexibleHeightBar = flexibleHeightBar {
            if let behaviourDefiner = flexibleHeightBar.behaviorDefiner {
                flexibleHeightBar.progress = 0.0
                behaviourDefiner.snap(with: webView.scrollView) {
                    flexibleHeightBar.enableSubviewInteractions(true)
                    self.searchField.becomeFirstResponder()
                }
            }
        }
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
            searchField.text = domainText
        } else {
            searchField.text = nil
        }
    }
    
    func navigateTo(url newURLString: String) {
        let modifiedNewURLString = ensureValidProtocol(urlString: newURLString)
        let newURL = URL(string: modifiedNewURLString)
        let myRequest = URLRequest(url: newURL!)
        
        url = modifiedNewURLString
        setSearchBarText(urlString: url)
        
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
//        let topInset = self.navigationController!.navigationBar.frame.size.height + statusBarOffset
//        let bottomInset = UIScreen.main.bounds.height - toolbar.frame.origin.y
        
        let insets = UIEdgeInsets(top: 0,
                                  left: 0,
                                  bottom: 0,
                                  right: 0)
        webView.scrollView.scrollIndicatorInsets = insets
    }
        
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
//    }
    
    func updateContentInsets() {
//        let bottomInset = max(UIScreen.main.bounds.height - toolbar.frame.origin.y, 0) - self.tabBarController!.tabBar.frame.size.height
//
//        webView.scrollView.contentInset = UIEdgeInsets(top: barView.frame.size.height,
//                                                       left: 0,
//                                                       bottom: bottomInset,
//                                                       right: 0)
    }
    
    func searchBarIsEmpty() -> Bool {
        return searchField.text?.isEmpty ?? true
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
    
//    var lastContentOffsetAtY : CGFloat = 0.0
    
//    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
////        self.lastContentOffsetAtY = scrollView.contentOffset.y
//    }
//    
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
////        if lastContentOffsetAtY < scrollView.contentOffset.y {
////            print("Bottom")
////            shrinkTheCustomNavigationBar(contentOffsetY: scrollView.contentOffset.y)
////        } else if lastContentOffsetAtY > scrollView.contentOffset.y {
////            print("Top")
////            shrinkTheCustomNavigationBar(contentOffsetY: scrollView.contentOffset.y)
////        }
//    }
    
//    func shrinkTheCustomNavigationBar(contentOffsetY: CGFloat) {
//        print("ContentYOffset: \(contentOffsetY)")
//        let navBar = self.navigationController!.navigationBar
//        let rect = navBar.frame
//
//        let navBarHeight: CGFloat = UIScreen.main.bounds.size.width > UIScreen.main.bounds.height ? 32 : 44
//
//        let yOffset = min(max(-(contentOffsetY + navBarHeight), -10), 20)
//        let alpha = yOffset / 20
//        let invAlpha = 1 - alpha
//
//        print("Offset is: \(yOffset), alpha: \(alpha), invAlpha: \(invAlpha)")
//
//        UIView.animate(withDuration: 0.1,
//                       animations: {
//            navBar.frame = CGRect(x: rect.origin.x,
//                                  y: yOffset,
//                                  width: rect.size.width,
//                                  height: rect.size.height)
////            self.titleBar.alpha = invAlpha
//            self.searchField.alpha = alpha
//        }) { complete in
//            self.updateScrollInsets()
//        }
//    }
    
    func setPortraitLayout() {
        let portraitFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width - 16, height: 44)
        barView.frame = portraitFrame
    }
    
    func setLandscapeLayout() {
        let landscapeFrame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 32)
        barView.frame = landscapeFrame
    }
    
    override func viewWillTransition(to size: CGSize,
                                     with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size,
                                 with: coordinator)
        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
            if size.width > size.height {
                self.setLandscapeLayout()
            } else {
                self.setPortraitLayout()
            }
            self.view.layer.shouldRasterize = true
        }) { (context: UIViewControllerTransitionCoordinatorContext) in
            self.view.layer.shouldRasterize = false
            if size.width > size.height {
                self.setLandscapeLayout()
            } else {
                self.setPortraitLayout()
            }
        }
    }
}

//-----------------------------------------------------------------
extension BrowserViewController : UITextFieldDelegate {
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        textField.text = self.url
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        flexibleHeightBar?.enableSubviewInteractions(false)
        self.navigateTo(url: textField.text!)
        return false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        textField.resignFirstResponder()
        flexibleHeightBar?.enableSubviewInteractions(false)
        setSearchBarText(urlString: url)
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
//                self.searchBar.setShowsCancelButton(true,
//                                                    animated: true)
                self.searchEffectsView.alpha = 1
                self.searchField.text = self.url
                
                self.searchField.textAlignment = .left
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
            searchField.resignFirstResponder()

            UIView.animate(withDuration: 0.3,
                           delay: 0.1,
                           options: [ .curveEaseInOut ],
                           animations: {
                self.searchEffectsView.alpha = 0
//                self.searchBar.setShowsCancelButton(false,
//                                                    animated: true)
                self.setSearchBarText(urlString: self.url)
                            
                let textFieldInsideSearchBar = self.searchField.value(forKey: "searchField") as! UITextField
                textFieldInsideSearchBar.leftViewMode = UITextFieldViewMode.never
                            
                self.searchField.textAlignment = .center
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
        
        filterContentsBy(searchText: searchBar.text,
                         scope: scope)
    }
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        deactivateSearch()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
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
//extension BrowserViewController : UIScrollViewDelegate {
//    func scrollViewDidScroll(_ scrollView: UIScrollView) {
//        updateBarFrame()
//        updateScrollInsets()
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
//extension BrowserViewController {
//    override func viewWillTransition(to size: CGSize,
//                                     with coordinator: UIViewControllerTransitionCoordinator) {
//        super.viewWillTransition(to: size,
//                                 with: coordinator)
//        
//        coordinator.animate(alongsideTransition: { (context: UIViewControllerTransitionCoordinatorContext) in
//            self.view.layer.shouldRasterize = true
//        }) { (context: UIViewControllerTransitionCoordinatorContext) in
//            self.view.layer.shouldRasterize = false
//            self.updateContentInsets()
//        }
//    }
//}

//-----------------------------------------------------------------
extension BrowserViewController : SearchScopeDelegate {
    func changed(scope: SearchScope) {
        self.scope = scope
        
        filterContentsBy(searchText: searchField.text!,
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
        let delegate: UIScrollViewDelegate? = flexibleHeightBar?.behaviorDefiner
        delegate?.scrollViewDidEndDecelerating?(scrollView)
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        let delegate: UIScrollViewDelegate? = flexibleHeightBar?.behaviorDefiner
        delegate?.scrollViewWillBeginDragging?(scrollView)
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        let delegate: UIScrollViewDelegate? = flexibleHeightBar?.behaviorDefiner
        delegate?.scrollViewDidEndDragging?(scrollView,
                                           willDecelerate: decelerate)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let delegate: UIScrollViewDelegate? = flexibleHeightBar?.behaviorDefiner
        delegate?.scrollViewDidScroll?(scrollView)
        
        if let flexibleHeightBar = flexibleHeightBar {
            if flexibleHeightBar.progress > 0.0 {
                flexibleHeightBar.enableSubviewInteractions(false)
            }
        }
    }
}
