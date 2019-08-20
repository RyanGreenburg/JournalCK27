//
//  JournalController.swift
//  JournalCK27
//
//  Created by RYAN GREENBURG on 8/15/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit

class JournalController {
    
    static let shared = JournalController()
    
    var journals: [Journal] = []
    
    // MARK: - CRUD
    // Create
    func createJournal(withName name: String) {
        guard let user = UserController.shared.currentUser else { return }
        let reference = CKRecord.Reference(recordID: user.recordID, action: .deleteSelf)
        let newJournal = Journal(name: name, reference: reference)
        
        CloudKitManager.shared.save(object: newJournal) { (result) in
            switch result {
            case .failure:
                print("Failed to save Journal to CloudKit")
            case .success:
                self.journals.append(newJournal)
            }
        }
    }
    
    // Read
    func fetchJournals(completion: @escaping (Bool) -> Void) {        
        let predicate = NSPredicate(value: true)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
        
        CloudKitManager.shared.performFetch(predicate: compoundPredicate) { (result: Result<[Journal]?, Error>) in
            if case .failure(let error) = result {
                print("Could not retrieve Journals from CloudKit : \(error)")
                completion(false)
                return
            }
            
            if case .success(let journals) = result {
                guard let journals = journals else { completion(false) ; return }
                print("Fetched journals successfully")
                self.journals.append(contentsOf: journals)
                completion(true)
            }
        }
    }
    
    // Update
    
    // Delete
    func delete(journal: Journal, completion: @escaping (Bool) -> Void) {
        guard let index = journals.firstIndex(of: journal) else { completion(false) ; return }
        
        CloudKitManager.shared.delete(journal) { (result) in
            switch result {
            case .failure:
                print("Error deleting journal from CloudKit)")
                completion(false)
            case .success:
                self.journals.remove(at: index)
                completion(true)
            }
        }
    }
}
