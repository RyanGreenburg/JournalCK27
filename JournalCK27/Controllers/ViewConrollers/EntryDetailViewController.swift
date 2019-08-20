//
//  EntryDetailViewController.swift
//  JournalCK27
//
//  Created by RYAN GREENBURG on 7/9/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class EntryDetailViewController: UIViewController {
    
    var journal: Journal?
    var entry: Entry?
    
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var bodyTextView: UITextView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        guard let entry = entry else { return }
        titleTextField.text = entry.title
        bodyTextView.text = entry.body
    }
    
    @IBAction func saveButtonTapped(_ sender: Any) {
        guard let title = titleTextField.text, !title.isEmpty,
            let body = bodyTextView.text, !body.isEmpty
            else { return }
        if let entry = entry {
            EntryController.shared.update(entry: entry, withTitle: title, body: body) { (success) in
                if success {
                    self.popView()
                }
            }
        } else if let journal = journal {
            EntryController.shared.createEntryWith(title: title, body: body, inJournal: journal) { (success) in
                if success {
                    self.popView()
                }
            }
        }
    }
    
    @IBAction func clearButtonTapped(_ sender: Any) {
        bodyTextView.text = ""
    }
    
    func popView() {
        DispatchQueue.main.async {
            self.navigationController?.popViewController(animated: true)
        }
    }
}
