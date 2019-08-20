//
//  EntryController.swift
//  JournalCK27
//
//  Created by RYAN GREENBURG on 7/9/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit

class EntryController {
    
    static let shared = EntryController()
    
    // MARK: - CRUD
    // Create
    func createEntryWith(title: String, body: String, inJournal journal: Journal, completion: @escaping (Bool) -> Void) {
        let reference = CKRecord.Reference(recordID: journal.recordID, action: .deleteSelf)
        let newEntry = Entry(title: title, body: body, reference: reference)
        
        CloudKitManager.shared.save(object: newEntry) { (result: Result<Entry, Error>) in
            switch result {
            case .failure:
                print("Failed to save Entry to CloudKit")
                completion(false)
            case .success:
                journal.entries.append(newEntry)
                completion(true)
            }
        }
    }
    
    // Read
    func fetchEntries(forJournal journal: Journal, completion: @escaping ([Entry]?) -> Void) {
        
        let predicate = NSPredicate(format: "%K == %@", argumentArray: [JournalStrings.referenceKey, journal.recordID])
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
        
        CloudKitManager.shared.performFetch(predicate: compoundPredicate) { (result: Result<[Entry]?, Error>) in
            if case .failure(let error) = result {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil)
                return
            }
            
            if case .success(let entries) = result {
                completion(entries)
                return
            }
        }
    }
    
    // Update
    func update(entry: Entry, withTitle title: String, body: String, completion: @escaping (Bool) -> Void) {
        entry.title = title
        entry.body = body
        
        CloudKitManager.shared.update(entry) { (result: Result<Entry, Error>) in
            switch result {
            case .failure:
                print("Failed to update the entry")
                completion(false)
            case .success:
                completion(true)
            }
        }
    }
    
    // Delete
    func delete(entry: Entry, fromJournal journal: Journal, completion: @escaping (Bool) -> Void) {
        guard let index = journal.entries.firstIndex(of: entry) else { return }
        journal.entries.remove(at: index)
        
        CloudKitManager.shared.delete(entry) { (result) in
            switch result {
            case .failure:
                print("Failed to delete entry")
                completion(false)
            case .success:
                print("Deleted entry successfully")
                completion(true)
            }
        }
    }
}
