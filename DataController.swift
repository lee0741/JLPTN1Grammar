//
//  DataController.swift
//  JLPT N1 Grammar
//
//  Created by Yancen Li on 3/26/17.
//  Copyright © 2017 Yancen Li. All rights reserved.
//

import Foundation
import CoreData

class DataController: NSObject {
    
    static let shareInstance = DataController()
    
    fileprivate override init() {}
    
    lazy var persistentContainer: NSPersistentContainer = {
    
        let container = NSPersistentContainer(name: "Grammar")
        
        container.loadPersistentStores { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        }
        
        return container
    }()
    
    // MARK: - Core Data Saving Suppot
    
    func saveContext() {
        
        let context = persistentContainer.viewContext
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
        
    }
    
    // MARK: - Core Data Removing Suppot
    
    func removeData () {
        let context = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Grammar")
        
        do {
            let grammars = try context.fetch(fetchRequest) as! [GrammarMO]
            
            for grammar in grammars {
                context.delete(grammar)
            }
        } catch let error as NSError{
            print("insert error: \(error.localizedDescription)")
        }
    }
    
    // MARK: - Core Data Fetch Request
    
    func fetchData(with predicate: String? = nil) -> ([GrammarMO], [String: [GrammarMO]], [String]) {
        
        var grammars = [GrammarMO]()
        var grammarsDict = [String: [GrammarMO]]()
        var grammarSectionTitles = [String]()
        let managedObjectContext = persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Grammar")
        
        if let predicate = predicate {
            fetchRequest.predicate = NSPredicate(format: predicate)
        }
        
        grammars = (try! managedObjectContext.fetch(fetchRequest)) as! [GrammarMO]
        
        for grammar in grammars {
            guard let grammarKey = grammar.acronym else {
                break
            }
            
            if grammarsDict[grammarKey] != nil {
                grammarsDict[grammarKey]?.append(grammar)
            } else {
                grammarsDict[grammarKey] = [grammar]
            }
        }
        
        grammarSectionTitles = [String](grammarsDict.keys)
        grammarSectionTitles.sort(by: { $0 < $1 })
        
        return (grammars, grammarsDict, grammarSectionTitles)
        
    }
    
    // MARK: - Preload Data
    
    func preloadData () {

        if let contentsOfURL = Bundle.main.url(forResource: "Data", withExtension: "json") {
            
            removeData()
            
            let items = JSON(data: try! Data(contentsOf: contentsOfURL))
            let context = persistentContainer.viewContext
            
            for (_, subJson):(String, JSON) in items {
                let grammarItem = NSEntityDescription.insertNewObject(forEntityName: "Grammar", into: context) as! GrammarMO
                
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
                    try context.save()
                } catch {
                    fatalError("Failure to save context: \(error)")
                }
            }
        }
    }
    
}
