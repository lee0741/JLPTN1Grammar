//
//  BookmarkController.swift
//  JLPT N1 Grammar
//
//  Created by Yancen Li on 2/19/17.
//  Copyright © 2017 Yancen Li. All rights reserved.
//

import UIKit
import CoreData

class BookmarkController: UITableViewController {
    
    let cellId = "bookmarkCell"
    let dataController = DataController.shareInstance
    var grammars = [GrammarMO]()
    var grammarsDict = [String: [GrammarMO]]()
    var grammarSectionTitles = [String]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configUi()
        configController()
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return grammarSectionTitles.count
    }
    
    override func sectionIndexTitles(for tableView: UITableView) -> [String]? {
        return grammarSectionTitles
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return grammarSectionTitles[section]
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let grammarKey = grammarSectionTitles[section]
        
        guard let grammarValues = grammarsDict[grammarKey] else {
            return 0
        }
        
        return grammarValues.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellId)
        configCell(cell, atIndexPath: indexPath)
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    // MARK: - Table View Delegate
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let grammar = grammarsDict[grammarSectionTitles[indexPath.section]]![indexPath.row]
            grammar.saved = !grammar.saved
            dataController.saveContext()
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grammarKey = grammarSectionTitles[indexPath.section]
        let grammarValues = grammarsDict[grammarKey]!
        let grammar = grammarValues[indexPath.row]
        
        let detailController = DetailController()
        detailController.grammar = grammar
        navigationController?.pushViewController(detailController, animated: true)
    }
}

// MARK: - Controller Helpers

extension BookmarkController {
    
    func configUi() {
        navigationItem.title = "Bookmarks"
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        let doneButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(BookmarkController.doneAction))
        navigationItem.setRightBarButton(doneButtonItem, animated: true)
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellId)
        tableView.sectionIndexColor = UIColor.black
        tableView.sectionIndexBackgroundColor = UIColor.clear
    }
    
    func configController() {
        fetchData()
        
        if traitCollection.forceTouchCapability == .available {
            registerForPreviewing(with: self as UIViewControllerPreviewingDelegate, sourceView: view)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(BookmarkController.fetchData), name: NSNotification.Name.NSManagedObjectContextDidSave, object: nil)
    }
    
    func fetchData() {
        (grammars, grammarsDict, grammarSectionTitles) = dataController.fetchData(with: "saved == true")
        tableView.reloadData()
    }
    
    func doneAction() {
        self.dismiss(animated: true, completion: nil)
    }
    
    func configCell(_ cell: UITableViewCell, atIndexPath indexPath: IndexPath) {
        let grammarKey = grammarSectionTitles[indexPath.section]
        let grammarValues = grammarsDict[grammarKey]!
        let grammar = grammarValues[indexPath.row]
        
        cell.textLabel?.text = grammar.grammar
        cell.textLabel?.font = UIFont.preferredFont(forTextStyle: .headline)
        cell.detailTextLabel?.text = grammar.meaning
        cell.detailTextLabel?.textColor = UIColor.gray
    }
    
}

// MARK: - 3D Touch

extension BookmarkController: UIViewControllerPreviewingDelegate {
    
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

