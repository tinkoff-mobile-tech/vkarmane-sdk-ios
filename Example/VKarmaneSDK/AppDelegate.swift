//
//  AppDelegate.swift
//  VKarmaneSDK
//
//  Created by a.kulabukhov on 09/13/2018.
//  Copyright (c) 2018 a.kulabukhov. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var navigationController: UINavigationController? { return window?.rootViewController as? UINavigationController }
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        return true
    }
    
    func application(_ application: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> Bool {
        if
            let privateKey = (navigationController?.viewControllers.first as? ViewController)?.keys?.privateKey,
            let controller = ResultViewController.make(withUrl: url, privateKey: privateKey)
        {
            navigationController?.pushViewController(controller, animated: true)
            return true
        }
        return false
    }

}

