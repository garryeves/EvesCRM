//
//  AppDelegate.swift
//  EvesCRM
//
//  Created by Garry Eves on 15/04/2015.
//  Copyright (c) 2015 Garry Eves. All rights reserved.
//

import UIKit
import CoreData
import CloudKit
import SwiftyDropbox
import TextExpander
import UserNotifications
import GoogleSignIn
import GGLSignIn

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, GIDSignInDelegate
{
    var window: UIWindow?
    static var SMAppDelegateCustomKeyboardWillAppearToken: Int = 0

    var SMTEExpansionEnabled: String = "SMTEExpansionEnabled"
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
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
        
        
 //GRE       DropboxClientsManager.setupWithAppKeyDesktop("1qayzo6cmw8v6nr")
        
        // Initialize Google sign-in
        var configureErr: NSError?
        GGLContext.sharedInstance().configureWithError(&configureErr)
        if configureErr != nil {
            print("Error configuring the Google context: \(configureErr)")
        }
        
        GIDSignIn.sharedInstance().delegate = self
        
        
      //  let notificationSettings = UIUserNotificationSettings(types: [.badge, .alert, .sound], categories: nil)
        remoteCenter.requestAuthorization(options:[.badge, .alert, .sound]) { (granted, error) in
            
            if granted
            {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }

        
        
       // UIApplication.sharedApplication().registerForRemoteNotifications()
        
        return true
    }

    func application(_ application: UIApplication, didReceiveRemoteNotification userInfo: [AnyHashable: Any])
    {
   //     NSLog("yep, a notificaton")
        
        let cloudKitNotification = CKNotification(fromRemoteNotificationDictionary: userInfo as! [String : NSObject])
        
        if cloudKitNotification.notificationType == .query
        {
            let queryNotification = cloudKitNotification as! CKQueryNotification
            _ = queryNotification.recordID!.recordName
            
//            NSLog("initial record ID = \(recordID)")
            
            myCloudDB.getRecords(queryNotification.recordID!)
        }
    }
    
    func application(_ application: UIApplication, handleOpen url: URL) -> Bool
    {
        
print("appdelegate application - handleOpenURL = \(url.scheme)")
        var retVal: Bool = false
  
   /*
        // Textexpander
        
        var textExpander: SMTEDelegateController!
        
        if "EvesCRM-fill-xc" == url.scheme
        {
            //var tabController: UITabBarController = self.window.rootViewController
            //var currentViewController: UIViewController = self
            
       //     var textExpander: SMTEDelegateController = SMTEDelegateController()
           // textExpander = currentViewController.performSelector(textExpander)
            
            textExpander = SMTEDelegateController()
            
            if textExpander.handleFillCompletionURL(url)
            {
                retVal = true
            }
        }
        else if "EvesCRM-get-snippets-xc" == url.scheme
        {
            //   UITabBarController *tabController = (UITabBarController*)self.window.rootViewController;
            //   UIViewController *currentViewController = tabController.selectedViewController;
            //SMTEDelegateController *textExpander = [currentViewController performSelector:@selector(textExpander)];
      //      var textExpander: SMTEDelegateController = SMTEDelegateController()
            
            // textExpander = currentViewController.performSelector(textExpander)

            textExpander = SMTEDelegateController()
            
            var cancel: ObjCBool = false

            if textExpander.handleGetSnippetsURL(url, error:&error, cancelFlag:&cancel) == false
            {
                NSLog("Failed to handle URL: user canceled: %@, error: %@", cancel ? "yes" : "no", error!)
            }
            else
            {
                if cancel
                {
                    NSLog("User cancelled get snippets");
                    var standardUserDefaults: NSUserDefaults = NSUserDefaults()
                    standardUserDefaults.setBool(false, forKey:SMTEExpansionEnabled)
                }
                else if error != nil
                {
                    NSLog("Error updating TextExpander snippets: %@", error!);
                }
                else
                {
                    NSLog("Successfully updated TextExpander Snippets");
                }
                retVal = true
            }
        }
        else
        {
            retVal = ENSession.sharedSession().handleOpenURL(url)
        }
    */
        
        retVal = ENSession.shared().handleOpen(url)
        return retVal
    }
    
    func application(_ application: UIApplication, open url: URL, sourceApplication: String?, annotation: Any) -> Bool {
//print("appdelegate application - source Application = \(sourceApplication)")
//print("appdelegate application - source Application URL = \(url.scheme)")
        
        var error: NSError?
        var textExpander: SMTEDelegateController!
        var retVal: Bool = false
        
        if sourceApplication == "dropboxCoreService"
        {
 //GRE           retVal = dropboxCoreService.finalizeAuthentication(url)
        }
        else if "EvesCRM-fill-xc" == url.scheme
        {
            var textExpander: SMTEDelegateController!
            if myCurrentViewController is agendaItemViewController
            {
                var tempController: agendaItemViewController!
                tempController = myCurrentViewController as! agendaItemViewController
                textExpander = tempController.textExpander
            }
            else if myCurrentViewController is meetingAgendaViewController
            {
                var tempController: meetingAgendaViewController!
                tempController = myCurrentViewController as! meetingAgendaViewController
                textExpander = tempController.textExpander
            }
            else if myCurrentViewController is taskViewController
            {
                var tempController: taskViewController!
                tempController = myCurrentViewController as! taskViewController
                textExpander = tempController.textExpander
            }
            else if myCurrentViewController is meetingsViewController
            {
                var tempController: meetingsViewController!
                tempController = myCurrentViewController as! meetingsViewController
                textExpander = tempController.textExpander
            }
            else if myCurrentViewController is reminderViewController
            {
                var tempController: reminderViewController!
                tempController = myCurrentViewController as! reminderViewController
                textExpander = tempController.textExpander
            }
            else if myCurrentViewController is MaintainProjectViewController
            {
                var tempController: MaintainProjectViewController!
                tempController = myCurrentViewController as! MaintainProjectViewController
                textExpander = tempController.textExpander
            }
            else if myCurrentViewController is taskUpdatesViewController
            {
                var tempController: taskUpdatesViewController!
                tempController = myCurrentViewController as! taskUpdatesViewController
                textExpander = tempController.textExpander
            }

            
//            var textExpander: SMTEDelegateController = tempController.textExpander

            // let myURL = NSURL(string: "EvesCRM://x-callback-url/SMTEsetlog?log=off")
            // let myURL = NSURL(string: "EvesCRM://x-callback-url/SMTEsetlog?log=detailed")
            // textExpander.handleFillCompletionURL(myURL)
            
            if textExpander.handleFillCompletionURL(url) == true
            {
                retVal = true
            }
            else
            {
                print("failed")
            }
        }
        else if "EvesCRM-get-snippets-xc" == url.scheme
        {
    
            /*
            UITabBarController *tabController = (UITabBarController*)self.window.rootViewController;
                UIViewController *currentViewController = tabController.selectedViewController;
                SMTEDelegateController *textExpander = [currentViewController performSelector:@selector(textExpander)];
                NSError *error = nil;
                BOOL cancel = NO;
                if ([textExpander handleGetSnippetsURL:url error:&error cancelFlag:&cancel] == NO) {
                    NSLog(@"Failed to handle URL: user canceled: %@, error: %@", cancel ? @"yes" : @"no", error);
                } else {
                    if (cancel) {
                        NSLog(@"User cancelled get snippets");
                        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:SMTEExpansionEnabled];
                    } else if (error != nil) {
                        NSLog(@"Error updating TextExpander snippets: %@", error);
                    } else {
                        NSLog(@"Successfully updated TextExpander Snippets");
                    }
                    return YES;
                }
*/
            
      //      var tabController: UITabBarController = self.window.rootViewController
    //        let currentViewController: ViewController = self.window!.rootViewController!
            //  textExpander = currentViewController.textExpander as SMTEDelegateController
            
            if myCurrentViewController is ViewController
            {
                var tempController: ViewController!
                tempController = myCurrentViewController as! ViewController
                textExpander = tempController.textExpander
            }
                
            //textExpander = myCurrentViewController.textExpander as SMTEDelegateController
            
            var cancel: ObjCBool = false
         //   textExpander = SMTEDelegateController()
            
            if textExpander.handleGetSnippetsURL(url, error:&error, cancelFlag:&cancel) == false
            {
                NSLog("Failed to handle URL: user canceled: %@, error: %@", cancel.boolValue ? "yes" : "no", error!)
            }
            else
            {
                if cancel.boolValue
                {
                    NSLog("User cancelled get snippets");
                    let standardUserDefaults: UserDefaults = UserDefaults()
                    standardUserDefaults.set(false, forKey:SMTEExpansionEnabled)
                }
                else if error != nil
                {
                    NSLog("Error updating TextExpander snippets: %@", error!);
                }
                else
                {
                    NSLog("Successfully updated TextExpander Snippets");
                }
                retVal = true
            }
        }

        else //if sourceApplication!.rangeOfString("google") != nil
        {
            retVal = GIDSignIn.sharedInstance().handle(url, sourceApplication: sourceApplication, annotation: annotation)
        }
        
        return retVal
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
//   println("applicationWillEnterForeground")
//        ENSession.sharedSession().listNotebooksWithCompletion{(a :[AnyObject]!, b : NSError!) -> Void in print(a)}
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        
      //  ENSession.handleDidBecomeActive
        
        // Facebook
     //   FBSDKAppEvents.activateApp()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
     //   self.saveContext()
    }
    
    // GRE Added for Google sign in
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!,
        withError error: Error!) {
            if (error == nil) {
                // Perform any operations on signed in user here.
                // ...
                
            } else {
                print("\(error.localizedDescription)")
            }
            notificationCenter.post(name: NotificationGmailSignedIn, object: nil)
    }
    
    @objc(signIn:didDisconnectWithUser:withError:) func sign(_ signIn: GIDSignIn!, didDisconnectWith user:GIDGoogleUser!,
        withError error: Error!) {
            // Perform any operations when the user disconnects from app here.
            // ...
    }
    
    

//    // MARK: - Core Data stack
//
//    lazy var applicationDocumentsDirectory: URL = {
//        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.garryeves.EvesCRM" in the application's documents Application Support directory.
//        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
//        return urls[urls.count-1] 
//    }()
//
//    lazy var managedObjectModel: NSManagedObjectModel = {
//        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
//        let modelURL = Bundle.main.url(forResource: "EvesCRM", withExtension: "momd")!
//        return NSManagedObjectModel(contentsOf: modelURL)!
//    }()
//    
//    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator? = {
//        // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
//        // Create the coordinator and store
//        var coordinator: NSPersistentStoreCoordinator? = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
//        let url = self.applicationDocumentsDirectory.appendingPathComponent("EvesCRM.sqlite")
//        var error: NSError? = nil
//        var failureReason = "There was an error creating or loading the application's saved data."
//        let mOptions = [NSMigratePersistentStoresAutomaticallyOption: true,
//            NSInferMappingModelAutomaticallyOption: true]
//
//  do {
//      try coordinator!.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url, options: mOptions)
//  } catch var error1 as NSError {
//      error = error1
//      coordinator = nil
//      // Report any error we got.
//      var dict = [String: AnyObject]()
//      dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data" as AnyObject?
//      dict[NSLocalizedFailureReasonErrorKey] = failureReason as AnyObject?
//      dict[NSUnderlyingErrorKey] = error
//      error = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
//      // Replace this with code to handle the error appropriately.
//      // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//      NSLog("Unresolved error \(error), \(error!.userInfo)")
//      abort()
//  } catch {
//      fatalError()
//  }
//
//        self.registerCoordinatorForStoreNotifications (coordinator!)
//
//        return coordinator
//    }()
//
//    lazy var managedObjectContext: NSManagedObjectContext? = {
//        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
//        let coordinator = self.persistentStoreCoordinator
//        if coordinator == nil {
//            return nil
//        }
//        
//        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        managedObjectContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
//        managedObjectContext.persistentStoreCoordinator = coordinator
//        
//        return managedObjectContext
//    }()
//
//    // MARK: - Core Data Saving support
//
//    func saveContext () {
//        if let moc = self.managedObjectContext {
//            var error: NSError? = nil
//            if moc.hasChanges {
//                do {
//
//                    try moc.save()
//                    
//                } catch let error1 as NSError {
//                    error = error1
//                    // Replace this implementation with code to handle the error appropriately.
//                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
//                    NSLog("Unresolved error \(error), \(error!.userInfo)")
//                    abort()
//                }
//            }
//        }
//    }
//
//    // GRE Added notification for iCloud storage
//    
//    func registerCoordinatorForStoreNotifications (_ coordinator : NSPersistentStoreCoordinator) {
//      //  let nc : NotificationCenter = notificationCenter;
//        
//        notificationCenter.addObserver(self, selector: #selector(AppDelegate.storesWillChange(_:)),
//            name: NSNotification.Name.NSPersistentStoreCoordinatorStoresWillChange,
//            object: coordinator)
//        
//        notificationCenter.addObserver(self, selector: #selector(AppDelegate.storesDidChange(_:)),
//            name: NSNotification.Name.NSPersistentStoreCoordinatorStoresDidChange,
//            object: coordinator)
//        
////        notificationCenter.addObserver(self, selector: #selector(AppDelegate.persistentStoreDidImportUbiquitousContentChanges(_:)),
////            name: NSNotification.Name.NSPersistentStoreDidImportUbiquitousContentChanges,
////            object: coordinator)
//        
//        notificationCenter.addObserver(self, selector: #selector(AppDelegate.mergeChanges(_:)), name: NSNotification.Name.NSManagedObjectContextDidSave, object: coordinator);
//    }
//    
//
//    
//    
//    // GRE coredata
//    
//    // Subscribe to NSPersistentStoreCoordinatorStoresWillChangeNotification
//    // most likely to be called if the user enables / disables iCloud
//    // (either globally, or just for your app) or if the user changes
//    // iCloud accounts.
//    func storesWillChange(_ notification: Notification)
//    {
//        NSLog("storesWillChange notif:\(notification)");
//        if let moc = self.managedObjectContext
//        {
//            moc.performAndWait
//            {
//                let error: NSError? = nil;
//                if moc.hasChanges
//                {
//                    do
//                    {
//                        try moc.save()
//                    }
//                    catch let error as NSError
//                    {
//                        NSLog("Unresolved error \(error), \(error.userInfo), \(error.localizedDescription)")
//                        
//                        print("Failure in appDelegate: storesWillChange: \(error)")
//                    }
//                    NSLog("Save error: \(error)");
//                }
//                else
//                {
//                    // drop any managed objects
//                }
//                
//                // Reset context anyway, as suggested by Apple Support
//                // The reason is that when storesWillChange notification occurs, Core Data is going to switch the stores. During and after that switch (happening in background), your currently fetched objects will become invalid.
//                
//                moc.reset();
//            }
//            
//            // now reset your UI to be prepared for a totally different
//            // set of data (eg, popToRootViewControllerAnimated:)
//            // BUT don't load any new data yet.
//        }
//    }
//    
//    // Subscribe to NSPersistentStoreCoordinatorStoresDidChangeNotification
//    func storesDidChange(_ notification: Notification) {
//        // here is when you can refresh your UI and
//        // load new data from the new store
//        NSLog("storesDidChange posting notif");
//        self.postRefetchDatabaseNotification();
//    }
//    
//    func postRefetchDatabaseNotification() {
//        NSLog("postRefetchDatabaseNotification posting notif")
//        DispatchQueue.main.async(execute: { () -> Void in
//            notificationCenter.post(
//                name: kRefetchDatabaseNotification, // Replace with your constant of the refetch name, and add observer in the proper place - e.g. RootViewController
//                object: nil);
//        })
//    }
//    
//    func mergeChanges(_ notification: Notification) {
//        NSLog("mergeChanges notif:\(notification)")
//        if let moc = managedObjectContext {
//            moc.perform {
//                moc.mergeChanges(fromContextDidSave: notification)
//                self.postRefetchDatabaseNotification()
//            }
//        }
//    }
//    
//    func persistentStoreDidImportUbiquitousContentChanges(_ notification: Notification) {
//        self.mergeChanges(notification);
//        NSLog("persistentStoreDidImportUbiquitousContentChanges posting notif");
//    }
}

