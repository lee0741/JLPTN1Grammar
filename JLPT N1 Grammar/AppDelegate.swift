//
//  AppDelegate.swift
//  JLPT Grammar
//
//  Created by Yancen Li on 10/18/15.
//  Copyright © 2015 Yancen Li. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  let dataController = DataController.shareInstance
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    let defaults = UserDefaults.standard
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    let isPreloaded = defaults.bool(forKey: "\(version)isPreloaded")
    
    let bookmarkItem = UIApplicationShortcutItem(type: "org.yancen.grammar.bookmark",
                                                 localizedTitle: "Bookmarks",
                                                 localizedSubtitle: nil,
                                                 icon: UIApplicationShortcutIcon(type: .bookmark),
                                                 userInfo: nil)
    
    let searchItem = UIApplicationShortcutItem(type: "org.yancen.grammar.search",
                                               localizedTitle: "Search",
                                               localizedSubtitle: nil,
                                               icon: UIApplicationShortcutIcon(type: .search),
                                               userInfo: nil)
    
    UIApplication.shared.shortcutItems = [bookmarkItem, searchItem]
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.makeKeyAndVisible()
    window?.rootViewController = UINavigationController(rootViewController: HomeController())
    UINavigationBar.appearance().tintColor = UIColor.black
    
    if !isPreloaded {
      dataController.preloadData()
      defaults.set(true, forKey: "\(version)isPreloaded")
    }
    
    if let item = launchOptions?[UIApplicationLaunchOptionsKey.shortcutItem] as? UIApplicationShortcutItem {
      switch item.type {
      case "org.yancen.grammar.bookmark":
        launchBookmarkController()
      case "org.yancen.grammar.search":
        launchSearchController()
      default:
        break
      }
    }
    
    return true
    
  }
  
  func applicationWillTerminate(_ application: UIApplication) {
    dataController.saveContext()
  }
  
  // MARK: - Spotlight Search
  
  func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([Any]?) -> Void) -> Bool {
    let viewController = window?.rootViewController?.childViewControllers[0] as! HomeController
    viewController.restoreUserActivityState(userActivity)
    return true
  }
  
  // MARK: - 3D Touch
  
  func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
    switch shortcutItem.type {
    case "org.yancen.grammar.bookmark":
      launchBookmarkController()
    case "org.yancen.grammar.search":
      launchSearchController()
    default:
      return
    }
  }
  
  func launchBookmarkController() {
    window?.rootViewController?.present(UINavigationController(rootViewController:BookmarkController()), animated: true, completion: nil)
  }
  
  func launchSearchController() {
    (window?.rootViewController?.childViewControllers[0] as! HomeController).searchController.isActive = true
    DispatchQueue.main.async {
      (self.window?.rootViewController?.childViewControllers[0] as! HomeController).searchController.searchBar.becomeFirstResponder()
    }
  }
  
}

