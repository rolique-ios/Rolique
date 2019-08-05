//
//  AppDelegate.swift
//  Rolique
//
//  Created by Bohdan Savych on 8/5/19.
//  Copyright © 2019 Bohdan Savych. All rights reserved.
//

import UIKit
import UI

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?


  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.rootViewController = Router.getStartViewController()
    window?.makeKeyAndVisible()
    
    if let shortcutItem = launchOptions?[.shortcutItem] as? UIApplicationShortcutItem {
      let _ = ShortcutManager.shared.handle(shortcutItem: shortcutItem)
    }
    
    
    return true
  }

  func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
    return true
  }
  
  func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    completionHandler(ShortcutManager.shared.handle(shortcutItem: shortcutItem))
  }
}


