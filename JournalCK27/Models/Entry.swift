//
//  Entry.swift
//  JournalCK27
//
//  Created by RYAN GREENBURG on 7/9/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import Foundation
import CloudKit

class Entry: CloudKitSyncable {
    
    var title: String
    var body: String
    let timestamp: Date
    
    var ckRecord: CKRecord {
        let record = CKRecord(recordType: Entry.recordType, recordID: self.recordID)
        record.setValue(self.title, forKey: EntryConstants.titleKey)
        record.setValue(self.body, forKey: EntryConstants.bodyKey)
        record.setValue(self.timestamp, forKey: EntryConstants.timestampKey)
        record.setValue(self.reference, forKey: EntryConstants.referenceKey)
        return record
    }
    static var recordType: CKRecord.RecordType {
        return EntryConstants.typeKey
    }
    var recordID: CKRecord.ID
    let reference: CKRecord.Reference
    
    init(title: String, body: String, timestamp: Date = Date(), recordID: CKRecord.ID = CKRecord.ID(recordName: UUID().uuidString), reference: CKRecord.Reference) {
        
        self.title = title
        self.body = body
        self.timestamp = timestamp
        self.recordID = recordID
        self.reference = reference
    }
    
    required init?(record: CKRecord) {
        guard let title = record[EntryConstants.titleKey] as? String,
            let body = record[EntryConstants.bodyKey] as? String,
            let timestamp = record[EntryConstants.timestampKey] as? Date,
            let reference = record[EntryConstants.referenceKey] as? CKRecord.Reference
            else { return nil }
        
        self.title = title
        self.body = body
        self.timestamp = timestamp
        self.recordID = record.recordID
        self.reference = reference
    }
}

extension Entry: Equatable {
    static func == (lhs: Entry, rhs: Entry) -> Bool {
        return lhs.recordID == rhs.recordID
    }
}

struct EntryConstants {
    static let typeKey = "Entry"
    fileprivate static let titleKey = "title"
    fileprivate static let bodyKey = "body"
    fileprivate static let timestampKey = "timestamp"
    fileprivate static let referenceKey = "reference"
}
