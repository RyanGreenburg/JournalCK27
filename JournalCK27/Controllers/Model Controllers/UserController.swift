//
//  UserController.swift
//  JournalCK27
//
//  Created by RYAN GREENBURG on 7/9/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit

class UserController {
    
    // Properties
    static let shared = UserController()
    
    var currentUser: User?
    
    // MARK: - CRUD
    
    // Create
    func createUser(withName name: String, email: String, completion: @escaping (Bool) -> Void) {
        guard let appleUserRef = CloudKitManager.shared.fetchAppleUserReference() else { completion(false) ; return }
        
        let newUser = User(username: name, email: email, appleUserReference: appleUserRef)
        CloudKitManager.shared.save(object: newUser) { (result) in
            switch result {
            case .failure:
                print("Failed to Create User")
                completion(false)
            case .success:
                print("Created User")
                self.currentUser = newUser
                completion(true)
            }
        }
    }
    
    // Read
    func fetchUser(completion: @escaping (Bool) -> Void) {
        let predicate = NSPredicate(value: true)
        let compoundPredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [predicate])
        
        CloudKitManager.shared.performFetch(predicate: compoundPredicate) { (result: Result<[User]?, Error>) in
            if case .failure(let error) = result {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(false)
            }
            
            if case .success(let users) = result {
                guard let user = users?.first else { completion(false) ; return }
                print("Fetched user successfully")
                self.currentUser = user
                completion(true)
            }
        }
    }

    // Update
    
    
    // Delete
}
