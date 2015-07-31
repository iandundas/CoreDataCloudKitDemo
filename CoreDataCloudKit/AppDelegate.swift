//
//  AppDelegate.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 28/07/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import UIKit
import CoreData

//@UIApplicationMain
class TestingAppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?
}
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    var persistenceController: MCPersistenceController!

    var navigationController: UINavigationController!
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

        window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window?.backgroundColor = UIColor.purpleColor()
        
        let blankViewController = UIViewController(nibName: nil, bundle: nil)
        blankViewController.view.backgroundColor = UIColor.blueColor()
        
        navigationController = UINavigationController(rootViewController: blankViewController)
        
        persistenceController = MCPersistenceController(persistenceReady: {
            // persistence stack is now ready, and we can add the real VC:
            let listVC = ListViewController(viewModel: ListViewModel(persistenceController: self.persistenceController))
            self.navigationController.setViewControllers([listVC], animated: false)
        }, persistenceType: PersistenceType.SQLLite)
        
        window?.rootViewController = navigationController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        
        self.persistenceController.save()
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        
        self.persistenceController.save()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        
        self.persistenceController.save()
    }
}

