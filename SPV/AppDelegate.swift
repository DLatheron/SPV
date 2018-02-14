//
//  AppDelegate.swift
//  SPV
//
//  Created by dlatheron on 26/07/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import UIKit
import Foundation
import AVFoundation
import MediaPlayer
import Bluuur

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    let initialTabIndex = 0

    var window: UIWindow?
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
        [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        let documentsDirectory = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let documentsURL = URL(string: documentsDirectory)!

        do {
            try Settings.shared.load(fromFileURL: Settings.defaultURL)
        } catch {
            try? Settings.shared.save(toFileURL: Settings.defaultURL)
        }
        
        //copyTestResources()
    
        MediaManager.shared.scanForMedia(atPath: documentsURL)
        
        self.window = UIWindow(frame: UIScreen.main.bounds)
        self.window?.backgroundColor = UIColor.white
        self.window?.rootViewController = UITabBarController()
        self.window?.makeKeyAndVisible()

        let startOnAuthenticationScreen = true
        if startOnAuthenticationScreen && AuthenticationService.shared.pinHasBeenSet {
            requestAuthentication() {
                self.launchUI()
                self.unblur(view: self.getOrCreateBlurView())
            }
        } else {
            launchUI()
        }
        
        // Override point for customization after application launch.
        return true
    }
    
    func requestAuthentication(onSuccess: @escaping () -> Void) {
        let tabBarController = self.window!.rootViewController as! UITabBarController
        
        let authenticationService = AuthenticationService.shared
        
        let storyboard = UIStoryboard(name: "Authentication",
                                      bundle: nil)
        let authenticationNavVC = storyboard.instantiateInitialViewController() as! UINavigationController
        let authenticationVC = authenticationNavVC.viewControllers[0] as! AuthenticationViewController
        
        authenticationVC.authenticationService = authenticationService
        authenticationVC.authenticationDelegate = authenticationService
        authenticationVC.modalTransitionStyle = .coverVertical
        authenticationVC.entryMode = .pin
        authenticationVC.completionBlock = { success, pin in
            if success {
                onSuccess()
                
                authenticationNavVC.dismiss(animated: true,
                                            completion: nil)
            } else {
                // TODO: Kill app?
            }
        }
        
        tabBarController.present(authenticationNavVC,
                                 animated: true) {
            print("Presented \(self.window!.subviews)")
        }
    }
    
    func launchUI() {
        func addInitialViewController(fromStoryboardNamed storyboardName: String,
                                      toTabBar tabBarController: UITabBarController,
                                      forTabName tabName: String,
                                      withImageName imageName: String) {
            let storyboard = UIStoryboard(name: storyboardName, bundle: nil)
            if let viewController = storyboard.instantiateInitialViewController() {
                let image = UIImage(named: imageName)
                viewController.tabBarItem = UITabBarItem(title: tabName,
                                                         image: image,
                                                         selectedImage: image)
                tabBarController.addChildViewController(viewController)
            }
        }
        
        func addMediaViewer(to tabBarController: UITabBarController) {
            addInitialViewController(fromStoryboardNamed: "MediaViewer",
                                     toTabBar: tabBarController,
                                     forTabName: "Albums",
                                     withImageName: "albums")
        }
        
        func addBrowser(to tabBarController: UITabBarController) {
            addInitialViewController(fromStoryboardNamed: "Browser",
                                     toTabBar: tabBarController,
                                     forTabName: "Browser",
                                     withImageName: "browser")
        }
        
        func addCamera(to tabBarController: UITabBarController) {
            addInitialViewController(fromStoryboardNamed: "Camera",
                                     toTabBar: tabBarController,
                                     forTabName: "Camera",
                                     withImageName: "camera")
        }
        
        func addSettings(to tabBarController: UITabBarController) {
            addInitialViewController(fromStoryboardNamed: "Settings",
                                     toTabBar: tabBarController,
                                     forTabName: "Settings",
                                     withImageName: "settings")
        }

        let tabBarController = self.window!.rootViewController as! UITabBarController

        addMediaViewer(to: tabBarController)
        addBrowser(to: tabBarController)
        addCamera(to: tabBarController)
        addSettings(to: tabBarController)
        
        tabBarController.selectedIndex = initialTabIndex
        
        // Force layout so that it will redraw when we generate it behind the PIN screen - essential.
        tabBarController.view.setNeedsLayout()
    }
    
    let blurTag: Int = 1234
    let blurInDuration: TimeInterval = 0.3
    let blurOutDuration: TimeInterval = 0.3
    let blurRadius: CGFloat = 30.0
    
    func getOrCreateBlurView() -> MLWBluuurView? {
        let rootViewControllerView = self.window!.rootViewController!.view!
        if let blurView: MLWBluuurView = self.window!.rootViewController!.view.viewWithTag(blurTag) as? MLWBluuurView {
            return blurView
        } else if Settings.shared.blurInBackground.value == false {
            return nil
        } else {
            let blurView = MLWBluuurView(frame: (self.window?.frame)!)
            blurView.tag = blurTag
            
            rootViewControllerView.addSubview(blurView)
            rootViewControllerView.bringSubview(toFront: blurView)
            
            print("Blur added")

            return blurView
        }
    }
    
    func blur(view blurView: MLWBluuurView?) {
        if let blurView = blurView {
            blurView.blurRadius = 0
            
            UIView.animate(withDuration: blurInDuration) {
                blurView.blurRadius = self.blurRadius
            }
        }
    }
    
    func unblur(view blurView: MLWBluuurView?) {
        if let blurView = blurView {
            UIView.animate(withDuration: blurOutDuration,
                           animations: {
                blurView.blurRadius = 0
            }) { (complete) in
                if complete {
                    blurView.removeFromSuperview()
                    print("Blur removed")
                }
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        blur(view: getOrCreateBlurView())
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        if AuthenticationService.shared.pinHasBeenSet {
            requestAuthentication() {
                self.unblur(view: self.getOrCreateBlurView())
            }
        } else {
            unblur(view: getOrCreateBlurView())
        }
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }

    func copyTestResources() {
        let documentDirectoryPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString
        
        copyTestResources(filenames: [
            "Test01.jpg",
            "Test02.jpg",
            "Test03.jpg",
            "Test04.png",
            "Test05.jpg",
            "Test06.mp4",
            "Test07.gif",
            "Test08.mov"
            ], toPath: documentDirectoryPath)
    }
    
    func copyTestResources(filenames: [String], toPath dstPath: NSString) {
        for filename in filenames {
            let filenameExt = (filename as NSString).pathExtension
            let rawFilename = (filename as NSString).deletingPathExtension
            
            copyTestResource(resourceName: rawFilename,
                             ofType: filenameExt,
                             toPath: dstPath)
        }
    }
    
    func copyTestResource(resourceName srcFilename: String,
                          ofType srcType: String,
                          toPath dstPath: NSString) {
        let fileManger = FileManager.default
        var destinationPath = dstPath.appendingPathComponent(srcFilename) as NSString
        destinationPath = destinationPath.appendingPathExtension(srcType)! as NSString
        
        let srcPath = Bundle.main.path(forResource: srcFilename, ofType: srcType)
        do {
            try fileManger.copyItem(atPath: srcPath!, toPath: destinationPath as String)
        }
        catch let error as NSError {
            print("Unable to copy test resources because of \(error)")
        }
    }
    
    func application(_ application: UIApplication,
                     handleEventsForBackgroundURLSession identifier: String,
                     completionHandler: @escaping () -> Void) {
        debugPrint("handleEventsForBackgroundURLSession: \(identifier)")
        completionHandler()
    }
}
