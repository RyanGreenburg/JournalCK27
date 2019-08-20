//
//  Journal.swift
//  JournalCK27
//
//  Created by RYAN GREENBURG on 8/15/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit

class Journal: CloudKitSyncable {
    
    let name: String
    var entries: [Entry]
    
    var ckRecord: CKRecord {
        let record = CKRecord(recordType: Journal.recordType, recordID: self.recordID)
        record.setValue(self.name, forKey: JournalStrings.nameKey)
        record.setValue(self.reference, forKey: JournalStrings.referenceKey)
        return record
    }
    
    var recordID: CKRecord.ID

    static var recordType: CKRecord.RecordType {
        return JournalStrings.typeKey
    }
    let reference: CKRecord.Reference
    
    init(name: String, entries: [Entry] = [], recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), reference: CKRecord.Reference) {
        self.name = name
        self.entries = entries
        self.recordID = recordID
        self.reference = reference
    }
    
    required init?(record: CKRecord) {
        guard let name = record[JournalStrings.nameKey] as? String,
            let user = UserController.shared.currentUser
            else { return nil }
        
        let ref = CKRecord.Reference(recordID: user.recordID, action: .deleteSelf)
        let entries: [Entry] = []
        
        self.name = name
        self.entries = entries
        self.recordID = record.recordID
        self.reference = ref
    }
}

extension Journal: Equatable {
    static func == (lhs: Journal, rhs: Journal) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}

struct JournalStrings {
    static let typeKey = "Journal"
    fileprivate static let nameKey = "name"
    fileprivate static let entriesKey = "entries"
    static let referenceKey = "reference"
}
