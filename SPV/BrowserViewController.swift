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
    
    let initialPageUrl = "https://cdn.pixabay.com/photo/2015/07/06/13/58/arlberg-pass-833326_1280.jpg"
    
    var urlBeforeEditing: String? = nil;
    var url: String = ""
    
    var webView: WKWebView!
    var scope: SearchScope = .all // TODO: Preserve as config.
    
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
    weak var searchField: UISearchBar!
    weak var searchFieldText: UITextField!
    weak var searchFieldBorder: UIImageView!
    
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
    var flexibleVfxView: UIVisualEffectView!
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
    }
    
    let compressedSearchBarHeight: CGFloat = 20.0
    let searchBarHeight: CGFloat = 46.0
    let progressBarHeight: CGFloat = 2
    
    private func setupSearchField(parentView: UIView) -> UISearchBar {
        let searchField = UISearchBar()
        let searchFieldText = searchField.value(forKey: "searchField") as! UITextField
        let searchFieldBorder = searchField.getSubview(byType: "UISearchBarBackground") as! UIImageView
        
        searchField.delegate = self
        searchField.autocapitalizationType = .none
        searchField.autocorrectionType = .no
        searchField.enablesReturnKeyAutomatically = true
        searchField.keyboardType = .URL
        searchField.placeholder = NSLocalizedString("Search or enter website name", comment: "Placeholder text displayed in browser search/url field")
        searchField.setBackgroundImage(UIImage(), for: .any, barMetrics: .default)
        
        searchFieldText.textAlignment = .center
        
        parentView.addSubview(searchField)
        
//        searchField.bounds = CGRect(x: 0,
//                                    y: 0,
//                                    width: screenWidth,
//                                    height: searchBarHeight)

//        let leftRightMargin: CGFloat = 8
//        let topBottomMargin: CGFloat = 4
//
//        searchFieldText.bounds = CGRect(x: leftRightMargin,
//                                        y: topBottomMargin,
//                                        width: screenWidth - (leftRightMargin * 2),
//                                        height: searchField.bounds.size.height - (topBottomMargin * 2))
//
        searchFieldText.leftViewMode = .never
        searchFieldText.rightViewMode = .whileEditing
        searchFieldText.clearButtonMode = .whileEditing
        
        searchFieldText.backgroundColor = barColour
        searchFieldText.background = UIImage()
        
        self.searchField = searchField
        self.searchFieldText = searchFieldText
        self.searchFieldBorder = searchFieldBorder
        
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
            return compressedSearchBarHeight + statusBarHeight
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
        let vfxView = UIVisualEffectView(effect: UIBlurEffect(style: .light))
//        vfxView.sizeToFit()
        vfxView.frame = CGRect(x: 0,
                               y: 0,
                               width: screenWidth,
                               height: maxBarHeight)
//        vfxView.autoresizingMask = [.flexibleHeight, .flexibleWidth]
        
        //flexibleHeightBar.clipsToBounds = true
        flexibleHeightBar.addSubview(vfxView)
        
        flexibleHeightBar.backgroundColor = barColour
        flexibleHeightBar.progressDelegate = self
        
        // Behaviour.
        let behaviourDefiner = FacebookBarBehaviorDefiner()
        behaviourDefiner.thresholdNegativeDirection = 0.0
        behaviourDefiner.thresholdFromTop = 0.0
        behaviourDefiner.thresholdPositiveDirection = 0.0
        flexibleHeightBar.behaviorDefiner = behaviourDefiner
        webView.scrollView.delegate = self
        
        self.flexibleHeightBar = flexibleHeightBar
        self.flexibleVfxView = vfxView

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
        
        progressView.frame = CGRect(x: 0,
                                    y: maxBarHeight - progressBarHeight,
                                    width: screenWidth,
                                    height: progressBarHeight)
        
        self.progressView = progressView
        
        return progressView
    }

    private func configureSearchController() {
        let flexibleHeightBar = setupFlexibleHeightBar()
        self.view.addSubview(flexibleHeightBar)

        let searchField = setupSearchField(parentView: flexibleHeightBar)
        
//        webView.scrollView.contentInset = UIEdgeInsetsMake(maxBarHeight - statusBarHeight, 0.0, 0.0, 0.0)
//        webView.scrollView.scrollIndicatorInsets = UIEdgeInsetsMake(maxBarHeight - statusBarHeight, 0.0, 0.0, 0.0)
        
        definesPresentationContext = true
        
        let progressView = setupProgressView()
        flexibleHeightBar.addSubview(progressView)

        setupSearchBarProgressStates(searchField: searchField,
                                     flexibleHeightBar: flexibleHeightBar)
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
            //layout.alpha = alpha
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
    
    func setupSearchBarProgressStates(searchField: UISearchBar,
                                      flexibleHeightBar: FlexibleHeightBar) {
        //let progress = flexibleHeightBar.progress
        flexibleHeightBar.progress = 0.0
        flexibleHeightBar.behaviorDefiner?.snap(with: webView.scrollView)
        
        flexibleHeightBar.removeAllLayoutAttributes()
        
        
        
        
        
        flexibleHeightBar.minimumBarHeight = minBarHeight
        flexibleHeightBar.maximumBarHeight = maxBarHeight
        
        flexibleHeightBar.frame = CGRect(x: 0.0,
                                         y: 0.0,
                                         width: screenWidth,
                                         height: maxBarHeight)
        flexibleVfxView.frame = CGRect(x: 0.0,
                                       y: statusBarHeight,
                                       width: screenWidth,
                                       height: searchBarHeight)
        flexibleVfxView.setNeedsLayout()
        print("flexibleVfxView.frame is now: \(flexibleVfxView.frame)")
        print("flexibleVfxView.bounds is now: \(flexibleVfxView.bounds)")


        progressView.frame = CGRect(x: 0,
                                    y: maxBarHeight - progressBarHeight,
                                    width: screenWidth,
                                    height: progressBarHeight)
        
        searchField.frame = CGRect(x: 0,
                                   y: statusBarHeight,
                                   width: screenWidth,
                                   height: searchBarHeight)
        searchField.setNeedsLayout()
//        print("searchField.frame is now: \(searchField.frame)")
//        print("searchField.bounds is now: \(searchField.bounds)")

        let leftRightMargin: CGFloat = 8
        let topBottomMargin: CGFloat = 4
        
        searchFieldText.bounds = CGRect(x: leftRightMargin,
                                        y: topBottomMargin,
                                        width: screenWidth - (leftRightMargin * 2),
                                        height: searchField.bounds.size.height - (topBottomMargin * 2))
        
        webView.scrollView.contentInset = UIEdgeInsetsMake(searchBarHeight, 0.0, 0.0, screenHeight - toolbar.frame.origin.y)

        
        
        
        let initialProgress: CGFloat = 0.0
        let middleProgress: CGFloat = 0.20
        let finalProgress: CGFloat = 1.0
        
        let translationY: CGFloat = landscape ? -14.0 : -16.0
        let progressTranslationY: CGFloat = -(searchBarHeight - compressedSearchBarHeight)
        let scale: CGFloat = 0.75
        
        let midTranslationY = interpolate(from: 0.0,
                                          to: translationY,
                                          withProgress: middleProgress)
        let finalTranslationY = interpolate(from: 0.0,
                                            to: translationY,
                                            withProgress: finalProgress)

        let midProgressTranslationY = interpolate(from: 0.0,
                                                  to: progressTranslationY,
                                                  withProgress: middleProgress)
        let finalProgressTranslationY = interpolate(from: 0.0,
                                                    to: progressTranslationY,
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
        
        layout = setLayout(flexibleVfxView,
                           forBar: flexibleHeightBar,
                           atProgress: initialProgress,
                           offset: CGPoint(x: 0.0, y: statusBarHeight))
        layout = setLayout(flexibleVfxView,
                           forBar: flexibleHeightBar,
                           atProgress: middleProgress,
                           withPreviousLayout: layout,
                           translationY: midProgressTranslationY)
        layout = setLayout(flexibleVfxView,
                           forBar: flexibleHeightBar,
                           atProgress: finalProgress,
                           withPreviousLayout: layout,
                           translationY: finalProgressTranslationY)
        
        layout = setLayout(searchFieldText,
                           forBar: flexibleHeightBar,
                           atProgress: initialProgress,
                           offset: CGPoint.zero)
        layout = setLayout(searchFieldText,
                           forBar: flexibleHeightBar,
                           atProgress: middleProgress,
                           withPreviousLayout: layout,
                           alpha: 0.0)
        layout = setLayout(searchFieldText,
                           forBar: flexibleHeightBar,
                           atProgress: finalProgress,
                           withPreviousLayout: layout,
                           alpha: 0.0)
        
        layout = setLayout(progressView,
                           forBar: flexibleHeightBar,
                           atProgress: initialProgress,
                           offset: CGPoint(x: 0.0,
                                           y: maxBarHeight - progressView.frame.size.height))
        layout = setLayout(progressView,
                           forBar: flexibleHeightBar,
                           atProgress: middleProgress,
                           withPreviousLayout: layout,
                           translationY: midProgressTranslationY)
        layout = setLayout(progressView,
                           forBar: flexibleHeightBar,
                           atProgress: finalProgress,
                           withPreviousLayout: layout,
                           translationY: finalProgressTranslationY)
        
//        flexibleHeightBar.progress = progress
//        flexibleHeightBar.behaviorDefiner?.snap(with: webView.scrollView)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureSearchController()
        configureWebView()
        
        navigateTo(url: url)
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
                UIView.animate(withDuration: 0.15,
                               animations: {
                    self.progressChanged(progress: 0.0)
                })
                
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
            self.flexibleHeightBar?.behaviorDefiner?.snappingCompleted(for: self.flexibleHeightBar!,
                                                                       with: self.webView.scrollView)
            self.setupSearchBarProgressStates(searchField: self.searchField,
                                              flexibleHeightBar: self.flexibleHeightBar!);
//            if size.width > size.height {
//                self.setLandscapeLayout()
//            } else {
//                self.setPortraitLayout()
//            }
            self.view.layer.shouldRasterize = true
        }) { (context: UIViewControllerTransitionCoordinatorContext) in
            self.view.layer.shouldRasterize = false
            self.flexibleHeightBar?.behaviorDefiner?.snappingCompleted(for: self.flexibleHeightBar!,
                                                                       with: self.webView.scrollView)
            self.setupSearchBarProgressStates(searchField: self.searchField,
                                              flexibleHeightBar: self.flexibleHeightBar!);
//            if size.width > size.height {
//                self.setLandscapeLayout()
//            } else {
//                self.setPortraitLayout()
//            }
        }
    }
}

//-----------------------------------------------------------------
//extension BrowserViewController : UITextFieldDelegate {
//    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
//        textField.text = self.url
//        return true
//    }
//
//    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
//        textField.resignFirstResponder()
//        flexibleHeightBar?.enableSubviewInteractions(false)
//        self.navigateTo(url: textField.text!)
//        return false
//    }
//
//    func textFieldDidEndEditing(_ textField: UITextField) {
//        textField.resignFirstResponder()
//        flexibleHeightBar?.enableSubviewInteractions(false)
//        setSearchBarText(urlString: url)
//    }
//}

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
                self.searchField.setShowsCancelButton(true,
                                                      animated: true)
                self.searchEffectsView.alpha = 1
                self.searchField.text = self.url
                let textFieldInsideSearchBar = self.searchField.value(forKey: "searchField") as! UITextField
                textFieldInsideSearchBar.textAlignment = .left

                
                //self.searchField.textAlignment = .left
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
                self.searchField.setShowsCancelButton(false,
                                                    animated: true)
                self.setSearchBarText(urlString: self.url)
                            
                let textFieldInsideSearchBar = self.searchField.value(forKey: "searchField") as! UITextField
                //textFieldInsideSearchBar.leftViewMode = UITextFieldViewMode.never
                textFieldInsideSearchBar.textAlignment = .center
                            
                //self.searchField.textAlignment = .center
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

//-----------------------------------------------------------------
extension BrowserViewController : FlexibleHeightBarProgressDelegate
{
    func progressChanged(progress: CGFloat) {
        // TODO: Change the positioning of the bottom bars.
        let tabBar = tabBarController!.tabBar
        let tabBarHeight = tabBar.frame.size.height
        let tabBarOnScreenY = screenHeight - tabBarHeight
        
        let toolBarHeight = toolbar.frame.size.height
        let toolbarOnScreenY = tabBarOnScreenY - toolBarHeight
        
        let totalBarHeights = tabBarHeight + toolBarHeight
        
        let tabBarOffScreenY = tabBarOnScreenY + totalBarHeights
        let toolbarOffScreenY = toolbarOnScreenY + totalBarHeights
        
        let tabBarYPosition = interpolate(from: tabBarOnScreenY,
                                          to: tabBarOffScreenY,
                                          withProgress: progress)
        let toolbarYPosition = interpolate(from: toolbarOnScreenY,
                                           to: toolbarOffScreenY,
                                           withProgress: progress)
        tabBar.frame = CGRect(x: tabBar.frame.origin.x,
                              y: tabBarYPosition,
                              width: tabBar.frame.size.width,
                              height: tabBar.frame.size.height)
        toolbar.frame = CGRect(x: toolbar.frame.origin.x,
                               y: toolbarYPosition,
                               width: toolbar.frame.size.width,
                               height: toolbar.frame.size.height)
        
        webView.scrollView.scrollIndicatorInsets = UIEdgeInsets(top: flexibleHeightBar!.bounds.height - statusBarHeight,
                                                                left: 0,
                                                                bottom: screenHeight - tabBarYPosition,
                                                                right: 0)
    }
}
