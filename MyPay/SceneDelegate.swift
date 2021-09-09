//
//  SceneDelegate.swift
//  MyPay
//
//  Created by Konrad Rybicki on 14/07/2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    @available(iOS 13, *)
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    @available(iOS 13, *)
    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    @available(iOS 13, *)
    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    @available(iOS 13, *)
    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    @available(iOS 13, *)
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    @available(iOS 13, *)
    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
        
        AccountAccessManager.lockAccess()
    }
}

fileprivate class AccountAccessManager {
    
    static func lockAccess() {
        
        // top view controller identification
        
        var currentVC = UIApplication.shared.keyWindow!.rootViewController
        
        while let currentVC_presentedVC = currentVC!.presentedViewController {
            currentVC = currentVC_presentedVC
        }
        
        let topVC = currentVC
        
        // SC entrance screen vc instantiation
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let scEntranceScreenVC = storyboard.instantiateViewController(withIdentifier: "SCEntranceScreenViewController") as! SCEntranceScreenViewController
        
        scEntranceScreenVC.loggingUsersId = GlobalVariables.currentlyLoggedUsersId
        
        // SC entrance screen vc presentation
        
        scEntranceScreenVC.modalTransitionStyle = .crossDissolve
        scEntranceScreenVC.modalPresentationStyle = .fullScreen
        
        topVC!.present(scEntranceScreenVC, animated: true) {
            
            // unwind arrow hide/lock
            scEntranceScreenVC.unwindButtonArrow.tintColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
            scEntranceScreenVC.unwindButton.isUserInteractionEnabled = false
        }
    }
}
