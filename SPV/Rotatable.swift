/*
 This is an update to an example found on http://www.jairobjunior.com/blog/2016/03/05/how-to-rotate-only-one-view-controller-to-landscape-in-ios-slash-swift/
 
 The code there works, with some updating to the latest Swift, but the pattern isn't very Swifty. The following is what I found to be more helpful.
 */

/*
 First, create a protocol that UIViewController's can conform to.
 This is in opposition to using `Selector()` and checking for the presence of an empty function.
 */
import UIKit

/// UIViewControllers adopting this protocol will automatically be opted into rotating to all but bottom rotation.
///
/// - Important:
/// You must call resetToPortrait as the view controller is removed from view. Example:
///
/// ```
/// override func viewWillDisappear(_ animated: Bool) {
///   super.viewWillDisappear(animated)
///
///   if isMovingFromParentViewController {
///     resetToPortrait()
///   }
/// }
/// ```
protocol Rotatable: AnyObject {
    func resetToPortrait()
}

extension Rotatable where Self: UIViewController {
    func resetToPortrait() {
        UIDevice.current.setValue(
            Int(UIInterfaceOrientation.portrait.rawValue),
            forKey: "orientation"
        )
    }
}

/*
 Next, extend AppDelegate to check for VCs that conform to Rotatable. If they do allow device rotation.
 Remember, it's up to the conforming VC to reset the device rotation back to portrait.
 */

// MARK: - Device rotation support

extension AppDelegate {
    // The app disables rotation for all view controllers except for a few that opt-in by conforming to the Rotatable protocol
    func application(_ application: UIApplication,
                     supportedInterfaceOrientationsFor window: UIWindow?)
        -> UIInterfaceOrientationMask
    {
        guard
            let _ = topViewController(for: window?.rootViewController) as? Rotatable
            else { return .portrait }
        
        return .allButUpsideDown
    }
    
    private func topViewController(for rootViewController: UIViewController!)
        -> UIViewController?
    {
        guard let rootVC = rootViewController else { return nil }
        
        if rootVC is UITabBarController {
            let rootTabBarVC = rootVC as! UITabBarController
            
            return topViewController(for: rootTabBarVC.selectedViewController)
        } else if rootVC is UINavigationController {
            let rootNavVC = rootVC as! UINavigationController
            
            return topViewController(for: rootNavVC.visibleViewController)
        } else if let rootPresentedVC = rootVC.presentedViewController {
            return topViewController(for: rootPresentedVC)
        }
        
        return rootViewController
    }
}
