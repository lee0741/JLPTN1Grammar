//
//  HomeController.swift
//  JLPT N1 Grammar
//
//  Created by Yancen Li on 2/19/17.
//  Copyright © 2017 Yancen Li. All rights reserved.
//

import UIKit
import CoreData
import CoreSpotlight
import MobileCoreServices

class HomeController: UITableViewController, UISearchResultsUpdating {
  
  let cellId = "homeCell"
  let dataController = DataController.shareInstance
  var grammars = [GrammarMO]()
  var grammarsDict = [String: [GrammarMO]]()
  var grammarSectionTitles = [String]()
  var searchController = UISearchController(searchResultsController: nil)
  var searchResults = [GrammarMO]()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    configController()
    setupSearchableContent()
  }
  
  func configController() {
    
    navigationItem.title = "Grammar"
    navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    let bookmarkButtonItem = UIBarButtonItem(barButtonSystemItem: .bookmarks, target: self, action: #selector(HomeController.bookmarkAction))
    navigationItem.setRightBarButton(bookmarkButtonItem, animated: true)
    
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
    tableView.sectionIndexColor = UIColor.black
    tableView.sectionIndexBackgroundColor = UIColor.clear
    
    searchController.searchResultsUpdater = self
    searchController.dimsBackgroundDuringPresentation = false
    definesPresentationContext = true
    searchController.searchBar.tintColor = UIColor.black
    tableView.tableHeaderView = searchController.searchBar
    tableView.contentOffset = CGPoint(x: 0, y: searchController.searchBar.frame.height)
    searchController.loadViewIfNeeded()
    
    (grammars, grammarsDict, grammarSectionTitles) = dataController.fetchData()
    
    if traitCollection.forceTouchCapability == .available {
      registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: view)
    }
    
  }
  
  func bookmarkAction() {
    present(UINavigationController(rootViewController: BookmarkController()), animated: true, completion: nil)
  }
  
  // MARK: - Spotlight Search
  
  func setupSearchableContent() {
    var searchableItems = [CSSearchableItem]()
    
    for i in 0...(grammars.count - 1) {
      let grammar = grammars[i]
      let searchableItemAttributeSet = CSSearchableItemAttributeSet(itemContentType: kUTTypeText as String)
      
      searchableItemAttributeSet.title = grammar.grammar
      searchableItemAttributeSet.contentDescription = grammar.meaning
      searchableItemAttributeSet.keywords = [grammar.grammar!, grammar.meaning!]
      
      let searchableItem = CSSearchableItem(uniqueIdentifier: "org.yancen.grammar.\(i)", domainIdentifier: "grammar", attributeSet: searchableItemAttributeSet)
      searchableItems.append(searchableItem)
    }
    
    CSSearchableIndex.default().indexSearchableItems(searchableItems) { (error) -> Void in
      if error != nil {
        print(error?.localizedDescription ?? "Failed to index")
      }
    }
  }
  
  override func restoreUserActivityState(_ activity: NSUserActivity) {
    if activity.activityType == CSSearchableItemActionType {
      if let userInfo = activity.userInfo {
        let selectedGrammar = userInfo[CSSearchableItemActivityIdentifier] as! String
        let detailController = DetailController()
        detailController.grammar = grammars[Int(selectedGrammar.components(separatedBy: ".").last!)!]
        navigationController?.pushViewController(detailController, animated: true)
      }
    }
  }
  
  // MARK: - Table View Data Source
  
  override func numberOfSections(in tableView: UITableView) -> Int {
    return searchController.isActive ? 1 : grammarSectionTitles.count
  }
  
  override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
    return searchController.isActive ? nil: grammarSectionTitles
  }
  
  override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    return searchController.isActive ? nil : grammarSectionTitles[section]
  }
  
  override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    if searchController.isActive {
      return searchResults.count
    } else {
      let grammarKey = grammarSectionTitles[section]
      
      guard let grammarValues = grammarsDict[grammarKey] else {
        return 0
      }
      
      return grammarValues.count
    }
  }
  
  override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
    return cell
  }
  
  override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    return 60
  }
  
  override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
    let grammarKey = grammarSectionTitles[indexPath.section]
    let grammarValues = grammarsDict[grammarKey]!
    let grammar = searchController.isActive ? searchResults[indexPath.row] : grammarValues[indexPath.row]
    
    cell.textLabel?.text = grammar.grammar
    cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
    cell.detailTextLabel?.text = grammar.meaning
    cell.detailTextLabel?.textColor = UIColor.gray
  }
  
  // MARK: - Table View Delegate
  
  override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let grammarKey = grammarSectionTitles[indexPath.section]
    let grammarValues = grammarsDict[grammarKey]!
    let grammar = searchController.isActive ? searchResults[indexPath.row] : grammarValues[indexPath.row]
    
    let detailController = DetailController()
    detailController.grammar = grammar
    navigationController?.pushViewController(detailController, animated: true)
  }
  
  // MARK: - Search Logic
  
  func filterContent(for searchText: String) {
    searchResults = grammars.filter { (grammar) -> Bool in
      let isMatch = grammar.grammar!.localizedCaseInsensitiveContains(searchText) || grammar.meaning!.localizedCaseInsensitiveContains(searchText)
      return isMatch
    }
  }
  
  func updateSearchResults(for searchController: UISearchController) {
    if let searchText = searchController.searchBar.text {
      filterContent(for: searchText)
      tableView.reloadData()
    }
  }
  
}

// MARK: - 3D Touch

extension HomeController: UIViewControllerPreviewingDelegate {
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, viewControllerForLocation location: CGPoint) -> UIViewController? {
    
    guard let indexPath = tableView.indexPathForRow(at: location),
      let cell = tableView.cellForRow(at: indexPath),
      let grammar = grammarsDict[grammarSectionTitles[indexPath.section]]?[indexPath.row] else {
        return nil
    }
    
    let detailController = DetailController()
    detailController.grammar = grammar
    detailController.preferredContentSize = CGSize(width: 0, height: 500)
    previewingContext.sourceRect = cell.frame
    
    return detailController
  }
  
  func previewingContext(_ previewingContext: UIViewControllerPreviewing, commit viewControllerToCommit: UIViewController) {
    navigationController?.pushViewController(viewControllerToCommit, animated: true)
  }
}
