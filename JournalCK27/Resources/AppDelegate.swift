//
//  AppDelegate.swift
//  JournalCK27
//
//  Created by RYAN GREENBURG on 7/9/19.
//  Copyright © 2019 RYAN GREENBURG. All rights reserved.
//

import UIKit
import CloudKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    /// Need this to accept share and init new object from the metadata
    func application(_ application: UIApplication, userDidAcceptCloudKitShareWith cloudKitShareMetadata: CKShare.Metadata) {
        
        let acceptSharesOperation = CKAcceptSharesOperation(shareMetadatas: [cloudKitShareMetadata])
        acceptSharesOperation.qualityOfService = .userInteractive
        acceptSharesOperation.perShareCompletionBlock = { metadata, share, error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return
            }
            print("Share was accepted")
        }
        
        acceptSharesOperation.acceptSharesCompletionBlock = { error in
            if let error = error {
                print("Error in \(#function) : \(error.localizedDescription) \n---\n \(error)")
                return
            }
            
            CloudKitManager.shared.fetchShare(metadata: cloudKitShareMetadata, completion: { (result: Result<[Journal]?, Error>) in
                if case .failure(let error) = result {
                    print("Could not retrieve Share from CloudKit : \(error)")
                    return
                }
                
                if case .success(let journals) = result {
                    guard let journals = journals else { return }
                    print("Fetched Share successfully")
                    JournalController.shared.journals.append(contentsOf: journals)
                    return
                }
            })
        }
        CKContainer(identifier: cloudKitShareMetadata.containerIdentifier).add(acceptSharesOperation)
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

