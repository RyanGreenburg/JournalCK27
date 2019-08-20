//
//  EntriesTableViewController.swift
//  JournalCK27
//
//  Created by RYAN GREENBURG on 7/9/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit

class EntriesTableViewController: UIViewController {
    
    var journal: Journal?
    var entries: [Entry] = [] {
        didSet {
            self.updateTableView(atIndex: nil)
        }
    }

    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.delegate = self
        tableView.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()

    }
    
    @IBAction func addButtonTapped(_ sender: Any) {
        
    }
    
    @IBAction func shareButtonTapped(_ sender: Any) {
        shareJournal()
    }
    
    func updateTableView(atIndex index: IndexPath?) {
        DispatchQueue.main.async {
            if let index = index {
                self.entries.remove(at: index.row)
                self.tableView.deleteRows(at: [index], with: .automatic)
            }
            self.tableView.reloadData()
        }
    }
    
    /// Helper function to set up the CloudSharing Controller
    func shareJournal() {
        guard let journal = self.journal else { return }

        let cloudSharingController = UICloudSharingController { (controller, preparationHandler) in
            CloudKitManager.shared.share(object: journal, completion: preparationHandler)
        }
        
        cloudSharingController.delegate = self
        
        DispatchQueue.main.async {
            self.present(cloudSharingController, animated: true)
        }
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toEntryDetailVC" {
            guard let index = tableView.indexPathForSelectedRow?.row else { return }
            let entry = entries[index]
            let destinationVC = segue.destination as? EntryDetailViewController
            destinationVC?.entry = entry
            destinationVC?.journal = journal
        }
        
        if segue.identifier == "toNewEntryVC" {
            let destinationVC = segue.destination as? EntryDetailViewController
            destinationVC?.journal = journal
        }
    }
}

extension EntriesTableViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return entries.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "entryCell", for: indexPath)
        let entry = entries[indexPath.row]
        
        cell.textLabel?.text = entry.title
        cell.detailTextLabel?.text = entry.timestamp.formatDate()
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        switch editingStyle {
        case .delete:
            guard let journal = journal else { return }
            let entryToDelete = entries[indexPath.row]
            EntryController.shared.delete(entry: entryToDelete, fromJournal: journal) { (success) in
                if success {
                    self.updateTableView(atIndex: indexPath)
                }
            }
        default:
            return
        }
    }
}

extension EntriesTableViewController: UICloudSharingControllerDelegate {
    
    func cloudSharingController(_ csc: UICloudSharingController, failedToSaveShareWithError error: Error) {
        print("failed to share")
    }
    
    func itemTitle(for csc: UICloudSharingController) -> String? {
        return csc.title
    }
    
    
}
