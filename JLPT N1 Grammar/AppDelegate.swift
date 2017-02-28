//
//  AppDelegate.swift
//  JLPT Grammar
//
//  Created by Steven Lee on 10/18/15.
//  Copyright © 2015 Yancen Li. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
  
  var window: UIWindow?
  
  
  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
    
    window = UIWindow(frame: UIScreen.main.bounds)
    window?.makeKeyAndVisible()
    window?.rootViewController = UINavigationController(rootViewController: HomeController())
    
    UINavigationBar.appearance().tintColor = UIColor.black
    
    let defaults = UserDefaults.standard
    let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as! String
    let isPreloaded = defaults.bool(forKey: "\(version)isPreloaded")
    
    if !isPreloaded {
      preloadData()
      defaults.set(true, forKey: "\(version)isPreloaded")
    }
    
    let bookmarkItem = UIApplicationShortcutItem(type: "org.yancen.grammar.bookmark", localizedTitle: "Bookmarks", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .bookmark), userInfo: nil)
    let searchItem = UIApplicationShortcutItem(type: "org.yancen.grammar.search", localizedTitle: "Search", localizedSubtitle: nil, icon: UIApplicationShortcutIcon(type: .search), userInfo: nil)
    UIApplication.shared.shortcutItems = [bookmarkItem, searchItem]
    
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
  
  func applicationWillResignActive(_ application: UIApplication) {}
  func applicationDidEnterBackground(_ application: UIApplication) {}
  func applicationWillEnterForeground(_ application: UIApplication) {}
  func applicationDidBecomeActive(_ application: UIApplication) {}
  func applicationWillTerminate(_ application: UIApplication) {self.saveContext()}
  
  // MARK: - Core Data stack
  
  lazy var persistentContainer: NSPersistentContainer = {
    /*
     The persistent container for the application. This implementation
     creates and returns a container, having loaded the store for the
     application to it. This property is optional since there are legitimate
     error conditions that could cause the creation of the store to fail.
     */
    let container = NSPersistentContainer(name: "Grammar")
    container.loadPersistentStores(completionHandler: { (storeDescription, error) in
      if let error = error as NSError? {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        
        /*
         Typical reasons for an error here include:
         * The parent directory does not exist, cannot be created, or disallows writing.
         * The persistent store is not accessible, due to permissions or data protection when the device is locked.
         * The device is out of space.
         * The store could not be migrated to the current model version.
         Check the error message to determine what the actual problem was.
         */
        fatalError("Unresolved error \(error), \(error.userInfo)")
      }
    })
    return container
  }()
  
  // MARK: - Core Data Saving support
  
  func saveContext () {
    let context = persistentContainer.viewContext
    if context.hasChanges {
      do {
        try context.save()
      } catch {
        // Replace this implementation with code to handle the error appropriately.
        // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        let nserror = error as NSError
        fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
      }
    }
  }
  
  // MARK: - Preload Data
  
  func preloadData () {
    // Retrieve data from the source file
    if let contentsOfURL = Bundle.main.url(forResource: "Data", withExtension: "json") {
      
      // Remove all the menu items before preloading
      removeData()
      
      // Preload the grammar items
      let items = JSON(data: try! Data(contentsOf: contentsOfURL))
      let managedObjectContext = self.persistentContainer.viewContext
      for (_, subJson):(String, JSON) in items {
        let grammarItem = NSEntityDescription.insertNewObject(forEntityName: "Grammar", into: managedObjectContext) as! GrammarMO
        grammarItem.acronym = subJson["acronym"].string!
        grammarItem.grammar = subJson["grammar"].string!
        grammarItem.meaning = subJson["meaning"].string!
        grammarItem.conjunction = subJson["conjunction"].string!
        for (jp, en):(String, JSON) in subJson["example", 0] {
          grammarItem.example1 = jp
          grammarItem.example1En = en.string!
        }
        for (jp, en):(String, JSON) in subJson["example", 1] {
          grammarItem.example2 = jp
          grammarItem.example2En = en.string!
        }
        
        do {
          try managedObjectContext.save()
        } catch {
          fatalError("Failure to save context: \(error)")
        }
      }
    }
  }
  
  func removeData () {
    // Remove the exiting items
    let managedObjectContext = self.persistentContainer.viewContext
    let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Grammar")
    do {
      let grammars = try managedObjectContext.fetch(fetchRequest) as! [GrammarMO]
      
      for grammar in grammars {
        managedObjectContext.delete(grammar)
      }
    } catch let error as NSError{
      print("insert error: \(error.localizedDescription)")
    }
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

