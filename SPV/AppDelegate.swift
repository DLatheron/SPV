//
//  AppDelegate.swift
//  SPV
//
//  Created by dlatheron on 26/07/2017.
//  Copyright © 2017 dlatheron. All rights reserved.
//

import UIKit
import Foundation

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
        [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        
        copyTestResources()
        
        MediaManager.shared.addMedia(rootDirectory: NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0])
        
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
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
            "Test07.gif"
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
        var destinationPath = dstPath.appendingPathComponent(srcFilename) as NSString;
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

