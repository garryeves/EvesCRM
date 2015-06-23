//
//  AppDelegate.swift
//  EvesCRM
//
//  Created by Garry Eves on 15/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
            // Initial development is done on the sandbox service
            // Change this to BootstrapServerBaseURLStringUS to use the production Evernote service
            // Change this to BootstrapServerBaseURLStringCN to use the Yinxiang Biji production service
            // Bootstrapping is supported by default with either BootstrapServerBaseURLStringUS or BootstrapServerBaseURLStringCN
            // BootstrapServerBaseURLStringSandbox does not support the  Yinxiang Biji service
 //           NSString *EVERNOTE_HOST = BootstrapServerBaseURLStringUS;
            
            // Fill in the consumer key and secret with the values that you received from Evernote
            // To get an API key, visit http://dev.evernote.com/documentation/cloud/
 //           NSString *CONSUMER_KEY = @"garryeves";
 //           NSString *CONSUMER_SECRET = @"527092b280bfd300";
        
       
    //    ENSession.setSharedSessionDeveloperToken("S=s2:U=1be4f:E=15460135598:C=14d086227c0:P=1cd:A=en-devtoken:V=2:H=31d18476ae197914f35d507e3ec34251", noteStoreUrl: "https://www.evernote.com/shard/s2/notestore")
      //  ENSession.setSharedSessionConsumerKey("garryeves", consumerSecret: "527092b280bfd300", optionalHost: "sandbox.evernote.com")
        
        ENSession.setSharedSessionConsumerKey("garryeves", consumerSecret: "527092b280bfd300", optionalHost: "www.evernote.com")
        
        
        dropboxCoreService.setup()
        
        // Initialize Google sign-in
        var configureErr: NSError?
        GGLContext.sharedInstance().configureWithError(&configureErr)
        if configureErr != nil {
            println("Error configuring the Google context: \(configureErr)")
        }
        
        GIDSignIn.sharedInstance().delegate = self
        
        return true
    }

    
    func application(application: UIApplication, handleOpenURL url: NSURL) -> Bool {
        return ENSession.sharedSession().handleOpenURL(url)
    }
    
    func application(application: UIApplication, openURL url: NSURL, sourceApplication: String?, annotation: AnyObject?) -> Bool {
println("appdelegate application - source Application = \(sourceApplication)")
        if sourceApplication == "dropboxCoreService"
        {
            return dropboxCoreService.finalizeAuthentication(url)
        }
        else
        {
            return GIDSignIn.sharedInstance().handleURL(url, sourceApplication: sourceApplication, annotation: annotation)
        }
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        
        ENSession.sharedSession().listNotebooksWithCompletion{(a :[AnyObject]!, b : NSError!) -> Void in print(a)}
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
      //  ENSession.handleDidBecomeActive
        
        // Facebook
     //   FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.garryeves.EvesCRM" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1] as! NSURL
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("EvesCRM", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("EvesCRM.sqlite")
        var error: NSError? = nil
        var failureReason = "There was an error creating or loading the application's saved data."
        
  // GRE start add section
        
     //   var options:NSMutableDictionary = NSMutableDictionary
    //    options.setValue(YES, forKey: "NSMigratePersistentStoresAutomaticallyOption")
    //    options.setValue(YES, forKey: "NSInferMappingModelAutomaticallyOption")
        
        let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
            NSInferMappingModelAutomaticallyOption: true,
            NSPersistentStoreUbiquitousContentNameKey : "EvesCRMStore"]
      
        //_persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
       // if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:options error:&error]) {

        
  //       self.registerCoordinatorForStoreNotifications (coordinator!)
        
  // GRE end add section
        
       // if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil, error: &error) == nil {
        if coordinator!.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: mOptions, error: &error) == nil {
            coordinator = nil
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason
            dict[NSUnderlyingErrorKey] = error
            error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog("Unresolved error \(error), \(error!.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext? = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        if coordinator == nil {
            return nil
        }
        var managedObjectContext = NSManagedObjectContext()
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if let moc = self.managedObjectContext {
            var error: NSError? = nil
            if moc.hasChanges && !moc.save(&error) {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                NSLog("Unresolved error \(error), \(error!.userInfo)")
                abort()
            }
        }
    }

    // GRE Added notification for iCloud storage
    
    func registerCoordinatorForStoreNotifications (coordinator : NSPersistentStoreCoordinator) {
        let nc : NSNotificationCenter = NSNotificationCenter.defaultCenter();
        
        nc.addObserver(self, selector: "handleStoresWillChange:",
            name: NSPersistentStoreCoordinatorStoresWillChangeNotification,
            object: coordinator)
        
        nc.addObserver(self, selector: "handleStoresDidChange:",
            name: NSPersistentStoreCoordinatorStoresDidChangeNotification,
            object: coordinator)
        
        nc.addObserver(self, selector: "handleStoresWillRemove:",
            name: NSPersistentStoreCoordinatorWillRemoveStoreNotification,
            object: coordinator)
        
        nc.addObserver(self, selector: "handleStoreChangedUbiquitousContent:",
            name: NSPersistentStoreDidImportUbiquitousContentChangesNotification,
            object: coordinator)
    }
    
    // GRE Added for Google sign in
    
    func signIn(signIn: GIDSignIn!, didSignInForUser user: GIDGoogleUser!,
        withError error: NSError!) {
            if (error == nil) {
                // Perform any operations on signed in user here.
                // ...
                
            } else {
                println("\(error.localizedDescription)")
            }
            NSNotificationCenter.defaultCenter().postNotificationName("NotificationGmailSignedIn", object: nil)
    }
    func signIn(signIn: GIDSignIn!, didDisconnectWithUser user:GIDGoogleUser!,
        withError error: NSError!) {
            // Perform any operations when the user disconnects from app here.
            // ...
    }
}

