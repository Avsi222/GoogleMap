//
//  AppDelegate.swift
//  MapProject
//
//  Created by Арсений Дорогин on 05/08/2019.
//  Copyright © 2019 Арсений Дорогин. All rights reserved.
//

import UIKit
import CoreData
import GoogleMaps
import UserNotifications

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        GMSServices.provideAPIKey("AIzaSyBp-QTKz-xN9CmhAMU8_1tf5QV1HiDAvB0")
        
        registrPush()
        return true
    }
    
    func registrPush(){
        let center = UNUserNotificationCenter.current()
        center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if granted {
                print("Разрешение получено.")
            } else {
                print("Разрешение не получено.")
            }
        }
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
        print("applicationWillResignActive")
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        sendPush()
        
        let imageView = UIImageView(frame: self.window!.bounds)
        imageView.tag = 101
        imageView.image = UIImage(named: "BG")
            
            UIApplication.shared.keyWindow?.subviews.last?.addSubview(imageView)
        print("applicationDidEnterBackground")
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
        
        if let imageView : UIImageView = UIApplication.shared.keyWindow?.subviews.last?.viewWithTag(101) as? UIImageView {
            imageView.removeFromSuperview()
        }
        
        print("applicationWillEnterForeground")
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        print("applicationDidBecomeActive")
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        sendPush()
        self.saveContext()
    }
    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "MapProject")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

//NOTIFICATIONS
extension AppDelegate{
    func makeNotificationContent() -> UNNotificationContent {
        // Внешний вид уведомления
        let content = UNMutableNotificationContent()
        // Заголовок
        content.title = "Привет"
        // Подзаголовок
        content.subtitle = "Скидки"
        // Основное сообщение
        content.body = "Заходи, будет интересно"
        // Цифра в бейдже на иконке
        content.badge = 1
        return content
    }
    
    func makeIntervalNotificatioTrigger() -> UNNotificationTrigger {
        return UNTimeIntervalNotificationTrigger(
            // Количество секунд до показа уведомления
            timeInterval: 5, //30 минут 30*60*60
            // Надо ли повторять
            repeats: false
        )
    }
    
    
    
    func sendPush(){
        self.sendNotificatioRequest(
            content: self.makeNotificationContent(),
            trigger: self.makeIntervalNotificatioTrigger()
        )
    }
    
    func sendNotificatioRequest(
        content: UNNotificationContent,
        trigger: UNNotificationTrigger) {
        
        // Создаём запрос на показ уведомления
        let request = UNNotificationRequest(
            identifier: "alarm",
            content: content,
            trigger: trigger
        )
        
        let center = UNUserNotificationCenter.current()
        // Добавляем запрос в центр уведомлений
        center.add(request) { error in
            // Если не получилось добавить запрос,
            // показываем ошибку, которая при этом возникла
            if let error = error {
                print(error.localizedDescription)
            }
        }
    }
}
