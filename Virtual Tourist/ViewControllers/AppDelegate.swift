//
//  AppDelegate.swift
//  Virtual Tourist
//
//  Created by Leonardo Saippa on 06/04/21.
//

import UIKit
import CoreData

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    let dataController = DataController(modelName: "Virtual_Tourist")


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        let navigationController = window?.rootViewController as! UINavigationController
        let mapview = navigationController.topViewController as! MapViewController
        mapview.dataController = (UIApplication.shared.delegate as? AppDelegate)?.dataController
          
        dataController.load()
        return true
    }

    func applicationDidEnterBackground(_ application: UIApplication) {

        print("applicationDidEnterBackground")
        saveViewContext()
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        print("applicationWillTerminate")

        saveViewContext()
    }

    func saveViewContext() {
        try? dataController.viewContext.save()
    }

}

