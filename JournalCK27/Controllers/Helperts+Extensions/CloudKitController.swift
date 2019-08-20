//
//  CloudKitController.swift
//  JournalCK27
//
//  Created by RYAN GREENBURG on 7/9/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit

public class CloudKitManager {
    
    static let shared = CloudKitManager()
    
    /// CloudKit Private Database
    private let privateDB = CKContainer.default().privateCloudDatabase
    ///
    private let sharedDB = CKContainer.default().sharedCloudDatabase
    
    /// CloudKit Shared Journals Zone
    var journalZone: CKRecordZone?
    
    /// Init the class to fetch or initialize a journalZone.
    init() {
        fetchZone(withName: "Journal") { (result) in
            switch result {
            case .success:
                print("RecordZone found")
            case .failure:
                self.createRecordZone(withName: "Journal", completion: { (result) in
                    switch result {
                    case .failure:
                        print("Could not create RecordZone")
                    case .success:
                        print("Successfully created RecordZone")
                    }
                })
            }
        }
    }
    
    /**
     Saves a CKRecord to the privateDatabase
     
     - Parameters:
        - T: Generic object that conforms to CloudKitSyncable
        - object: The object to save to CloudKit
        - completion: Completes with a Result
     
     - Returns:
        - Result Success: The object saved to CloudKit
        - Result Failure: The Error that was thrown
    */
    public func save<T: CloudKitSyncable>(object: T, completion: @escaping (Result<T, Error>) -> Void) {
        
        let record = object.ckRecord
        privateDB.save(record) { (_, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(error))
                return
            }
            print("Saved record to CloudKit")
            completion(.success(object))
        }
    }
    
    /**
     Creates a CKRecordZone if none is found on AppLaunch
     
     - Parameters:
        - name: The string value of the CKRecordZone's name in CloudKit
        - completion: Completes with a Result
     
     - Returns:
        - Result Success: Boolean value of a successful creation
        - Result Failure: The Error that was thrown
     */
    func createRecordZone(withName name: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        let newZone = CKRecordZone(zoneID: CKRecordZone.ID(zoneName: name))
        
        let operation = CKModifyRecordZonesOperation(recordZonesToSave: [newZone], recordZoneIDsToDelete: nil)
        operation.modifyRecordZonesCompletionBlock = { savedZone, _, error in
            
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(error))
                return
            }
            
            if savedZone != nil, newZone == savedZone?.first {
                self.journalZone = savedZone?.first
                completion(.success(true))
            }
        }
        privateDB.add(operation)
    }
    
    /**
     Updates a CKRecord that is saved to the privateDatabase
     
     - Parameters:
        - T: Generic object that conforms to CloudKitSyncable
        - object: The object to save to CloudKit
        - completion: Completes with a Result
     
     - Returns:
        - Result Success: The object saved to CloudKit
        - Result Failure: The Error that was thrown
     */
    public func update<T: CloudKitSyncable>(_ object: T, completion: @escaping (Result<T, Error>) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: [object.ckRecord], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (_, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(error))
            }
            print("Updated record in CloudKit")
            completion(.success(object))
        }
        privateDB.add(operation)
    }
    
    /**
     Fetches an array of CKRecords that are saved to the privateDatabase
     
     - Parameters:
        - T: Generic object that conforms to CloudKitSyncable
        - predicate: The CompoundPredicate of search parameters
        - completion: Completes with a Result
     
     - Returns:
        - .success: Result yields an array of objects saved to CloudKit
        - .failure: The Error that was thrown
     */
    public func performFetch<T: CloudKitSyncable>(predicate: NSCompoundPredicate, completion: @escaping (Result<[T]?, Error>) -> Void) {
        
        let query = CKQuery(recordType: T.recordType, predicate: predicate)
        privateDB.perform(query, inZoneWith: nil) { (records, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(error))
                return
            }
            guard let records = records else { completion(.failure(error!)) ; return }
            let objects: [T] = records.compactMap { T(record: $0) }
            print("Fetched objects from CloudKit")
            completion(.success(objects))
        }
    }
    
    func fetchZone(withName name: String, completion: @escaping (Result<Bool, Error>) -> Void) {
        privateDB.fetch(withRecordZoneID: CKRecordZone.ID(zoneName: name)) { (foundZone, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(error))
                return
            }
            
            if let foundZone = foundZone {
                self.journalZone = foundZone
                completion(.success(true))
            }
        }
    }
    
    /**
     Fetches the users appleUserReference
     
     - Returns:
        - CKRecord.Reference: The logged in user's appleUserReference
     */
    public func fetchAppleUserReference() -> CKRecord.Reference? {
        var referenceToReturn: CKRecord.Reference?
        CKContainer.default().fetchUserRecordID { (recordID, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return
            }
            
            if let recordID = recordID {
                let reference = CKRecord.Reference(recordID: recordID, action: .deleteSelf)
                referenceToReturn = reference
            }
        }
        return referenceToReturn
    }
    
    /**
     Fetches a Share from the metadata passed in from the AppDelegate.
     
     - Parameters:
        - T: Generic object that conforms to CloudKitSyncable
        - metadata: The metadata passed in from the AppDelegate
        - completion: Completes with a Result
     
     - Returns:
        - .success: Result yields an optional array of objects found from the share
        - .failure: Result yields an error from an unsuccessful share
     */
    public func fetchShare<T: CloudKitSyncable>(metadata: CKShare.Metadata, completion: @escaping (Result<[T]?, Error>) -> Void) {
        let operation = CKFetchRecordsOperation(recordIDs: [metadata.rootRecordID])
        
        operation.perRecordCompletionBlock = { record, _, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(error))
                return
            }
        }
        
        operation.fetchRecordsCompletionBlock = { recordDictionary, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(error))
                return
            }
            
            if let records = recordDictionary {
                let objects = records.compactMap({ T(record: $0.value) })
                completion(.success(objects))
            }
        }
        sharedDB.add(operation)
    }
    
    /**
     Shares a CKRecord located in the journalZone.
     
     - Parameters:
        - T: Generic object that conforms to CloudKitSyncable
        - object: The object to share to another user
        - completion: Completes with an optional CKShare, CKContainer, and Error
     */
    public func share<T: CloudKitSyncable>(object: T, completion: @escaping (CKShare?, CKContainer?, Error?) -> Void) {
        
        let shareRecordID = CKRecord.ID(recordName: object.recordID.recordName, zoneID: journalZone!.zoneID)
        let recordToShare = CKRecord(recordType: T.recordType, recordID: shareRecordID)
        let share = CKShare(rootRecord: recordToShare)
        
        share[CKShare.SystemFieldKey.title] = "\(object.recordID)" as CKRecordValue?
        share[CKShare.SystemFieldKey.shareType] = "com.A.JournalCK27" as CKRecordValue?
        
        let operation = CKModifyRecordsOperation(recordsToSave: [share, recordToShare], recordIDsToDelete: nil)
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInitiated
        
        operation.perRecordCompletionBlock = { record, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil, nil, error)
            }
        }
        
        operation.modifyRecordsCompletionBlock = { (_, _, error) in
            if let error = error {
                print("Failed Modify Completion")
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(nil, nil, error)
            } else {
                completion(share, CKContainer.default(), nil)
            }
        }
        
        privateDB.add(operation)
    }
    
    /**
     Deletes a CKRecord that is saved to the privateDatabase
     
     - Parameters:
        - T: Generic object that conforms to CloudKitSyncable
        - object: The object to save to CloudKit
        - completion: Completes with a Result
     
     - Returns:
        - Result Success: Boolean indicating success
        - Result Failure: The Error that was thrown
     */
    public func delete<T: CloudKitSyncable>(_ object: T, completion: @escaping (Result<Bool, Error>) -> Void) {
        let operation = CKModifyRecordsOperation(recordsToSave: nil, recordIDsToDelete: [object.recordID])
        operation.savePolicy = .changedKeys
        operation.qualityOfService = .userInteractive
        operation.modifyRecordsCompletionBlock = { (_, _, error) in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                completion(.failure(error))
            }
            print("Deleted object from CloudKit")
            completion(.success(true))
        }
        privateDB.add(operation)
    }
}

// MARK: - CloudKitSyncable Protocol
public protocol CloudKitSyncable {
    
    var recordID: CKRecord.ID { get set }
    var ckRecord: CKRecord { get }
    static var recordType: CKRecord.RecordType { get }
    init?(record: CKRecord)
}
