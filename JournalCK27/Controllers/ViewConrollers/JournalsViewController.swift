//
//  JournalsViewController.swift
//  JournalCK27
//
//  Created by RYAN GREENBURG on 8/15/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit

class JournalsViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        JournalController.shared.fetchJournals { (success) in
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    @IBAction func addJournalButtonTapped(_ sender: Any) {
        newJournalAlert()
    }
    

    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEntriesVC" {
            guard let index = tableView.indexPathForSelectedRow else { return }
            let journal = JournalController.shared.journals[index.row]
            let destinationVC = segue.destination as? EntriesTableViewController
            EntryController.shared.fetchEntries(forJournal: journal) { (entries) in
                if let entries = entries {
                    destinationVC?.journal = journal
                    journal.entries = entries
                    destinationVC?.entries = entries
                }
            }
        }
    }
    
    func updateTableView(atIndex index: IndexPath?) {
        DispatchQueue.main.async {
            if let index = index {
                self.tableView.deleteRows(at: [index], with: .automatic)
            }
            self.tableView.reloadData()
        }
    }
    
    func newJournalAlert() {
        let alert = UIAlertController(title: "New Journal", message: nil, preferredStyle: .alert)
        alert.addTextField { (textField) in
            textField.placeholder = "Journal Name..."
        }
        
        let addAction = UIAlertAction(title: "Add", style: .default) { (_) in
            if let nameTextField = alert.textFields?[0],
                let name = nameTextField.text, !name.isEmpty {
                JournalController.shared.createJournal(withName: name)
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in
            alert.dismiss(animated: true, completion: nil)
        }
        
        alert.addAction(addAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}

extension JournalsViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return JournalController.shared.journals.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "journalCell", for: indexPath)
        let journal = JournalController.shared.journals[indexPath.row]
        
        cell.textLabel?.text = journal.name
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        switch editingStyle {
        case .delete:
            let journalToDelete = JournalController.shared.journals[indexPath.row]
            JournalController.shared.delete(journal: journalToDelete) { (success) in
                if success {
                 self.updateTableView(atIndex: indexPath)
                }
            }
        default:
            return
        }
    }
}
