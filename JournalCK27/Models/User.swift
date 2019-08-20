//
//  User.swift
//  JournalCK27
//
//  Created by RYAN GREENBURG on 7/9/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit

class User: CloudKitSyncable {
    
    // Class properties
    var username: String
    var email: String
    // iCloud Properties
    var ckRecord: CKRecord {
        let record = CKRecord(recordType: User.recordType, recordID: self.recordID)
        record.setValue(self.username, forKey: UserConstants.usernameKey)
        record.setValue(self.email, forKey: UserConstants.emailKey)
        record.setValue(self.appleUserReference, forKey: UserConstants.appleUserReferenceKey)
        return record
    }
    static var recordType: CKRecord.RecordType {
        return UserConstants.typeKey
    }
    var recordID: CKRecord.ID
    
    let appleUserReference: CKRecord.Reference
    
    init(username: String, email: String, recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), appleUserReference: CKRecord.Reference) {
        self.username = username
        self.email = email
        self.recordID = recordID
        self.appleUserReference = appleUserReference
    }
    
    required init?(record: CKRecord) {
        guard let username = record[UserConstants.usernameKey] as? String,
            let email = record[UserConstants.emailKey] as? String,
            let appleUserReference = record[UserConstants.appleUserReferenceKey] as? CKRecord.Reference
            else { return nil }
        
        self.username = username
        self.email = email
        self.appleUserReference = appleUserReference
        self.recordID = record.recordID
    }
}

struct UserConstants {
    static let typeKey = "User"
    fileprivate static let usernameKey = "username"
    fileprivate static let emailKey = "email"
    fileprivate static let appleUserReferenceKey = "appleUserReference"
}
