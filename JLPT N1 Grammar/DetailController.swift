//
//  DetailController.swift
//  JLPT N1 Grammar
//
//  Created by Yancen Li on 2/19/17.
//  Copyright © 2017 Yancen Li. All rights reserved.
//

import UIKit
import CoreData

class DetailController: UITableViewController {
    
    var grammar: GrammarMO!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configController()
    }
    
    func configController() {
        
        if grammar.grammar!.characters.count >= 10 {
            navigationItem.title = grammar.grammar!.components(separatedBy: " / ").first
        } else {
            navigationItem.title = grammar.grammar
        }
        
        let buttonImage = grammar.saved ? UIImage(named: "ic_bookmark_fill") : UIImage(named: "ic_bookmark")
        let saveButtonItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(DetailController.saveAction))
        navigationItem.setRightBarButton(saveButtonItem, animated: true)
        
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.estimatedRowHeight = 80.0
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.separatorColor = UIColor(red: 240.0/255.0, green: 240.0/255.0, blue: 240.0/255.0, alpha: 0.8)
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "baseCell")
        tableView.register(ExampleCell.self, forCellReuseIdentifier: "exampleCell")
        tableView.allowsSelection = false
        
    }
    
    func saveAction() {
        grammar.saved = !grammar.saved
        let buttonImage = grammar.saved ? UIImage(named: "ic_bookmark_fill") : UIImage(named: "ic_bookmark")
        let saveButtonItem = UIBarButtonItem(image: buttonImage, style: .plain, target: self, action: #selector(DetailController.saveAction))
        navigationItem.setRightBarButton(saveButtonItem, animated: true)
        
        if let appDelegate = (UIApplication.shared.delegate as? AppDelegate) {
            appDelegate.saveContext()
        }
    }
    
    // MARK: - Table View Data Source
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return nil
        case 1:
            return "Meaning"
        case 2:
            return "Conjunction"
        case 3:
            return "Examples"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 3:
            return 2
        default:
            return 1
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch indexPath.section {
        case 3:
            let cell = tableView.dequeueReusableCell(withIdentifier: "exampleCell", for: indexPath) as! ExampleCell
            if indexPath.row == 0 {
                cell.jpLabel.text = grammar.example1
                cell.enLabel.text = grammar.example1En
            } else {
                cell.jpLabel.text = grammar.example2
                cell.enLabel.text = grammar.example2En
            }
            return cell
        case 2:
            let cell = tableView.dequeueReusableCell(withIdentifier: "baseCell", for: indexPath)
            cell.textLabel?.text = grammar.conjunction
            cell.textLabel?.numberOfLines = 0
            return cell
        case 1:
            let cell = tableView.dequeueReusableCell(withIdentifier: "baseCell", for: indexPath)
            cell.textLabel?.text = grammar.meaning
            cell.textLabel?.numberOfLines = 0
            return cell
        case 0:
            let cell = tableView.dequeueReusableCell(withIdentifier: "baseCell", for: indexPath)
            cell.textLabel?.text = grammar.grammar
            cell.textLabel?.numberOfLines = 0
            cell.textLabel?.font = UIFont.boldSystemFont(ofSize: 25.0)
            return cell
        default:
            fatalError()
        }
    }
}
