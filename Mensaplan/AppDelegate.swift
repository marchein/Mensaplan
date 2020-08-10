//
//  AppDelegate.swift
//  Mensaplan
//
//  Created by Marc Hein on 18.10.19.
//  Copyright © 2019 Marc Hein. All rights reserved.
//

import UIKit
import WatchSync

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Hide Autolayout Warning
        UserDefaults.standard.set(false, forKey: "UIConstraintBasedLayoutLogUnsatisfiable")
        UserDefaults.standard.set(false, forKey: "_UIConstraintBasedLayoutLogUnsatisfiable")
        UserDefaults.standard.set(false, forKey: "NSConstraintBasedLayoutLogUnsatisfiable")
        UserDefaults.standard.set(false, forKey: "__NSConstraintBasedLayoutLogUnsatisfiable")
        
        // Override point for customization after application launch.
        let splitViewController = self.window!.rootViewController as! UISplitViewController
        let navigationController = splitViewController.viewControllers[splitViewController.viewControllers.count-1] as! UINavigationController
        navigationController.topViewController!.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem
        splitViewController.delegate = self
        splitViewController.preferredDisplayMode = .allVisible
        #if targetEnvironment(macCatalyst)
        splitViewController.primaryBackgroundStyle = .sidebar
        #endif
        
        WatchSync.shared.activateSession { error in
            if let error = error {
                print("Error activating session \(error.localizedDescription)")
                return
            }
            print("Activated")
        }
        
        let showTodayShortcut = UIMutableApplicationShortcutItem(type: Shortcuts.showToday,
                                                                 localizedTitle: "Mensaplan für heute anzeigen",
                                                                 localizedSubtitle: nil,
                                                                 icon: UIApplicationShortcutIcon(type: .date),
                                                                 userInfo: nil
        )
        
        let showTomorrowShortcut = UIMutableApplicationShortcutItem(type: Shortcuts.showTomorrow,
                                                                    localizedTitle: "Mensaplan für morgen anzeigen",
                                                                    localizedSubtitle: nil,
                                                                    icon: UIApplicationShortcutIcon(type: .date),
                                                                    userInfo: nil
        )
        
        application.shortcutItems = [showTodayShortcut, showTomorrowShortcut]
        
        return true
    }
    
    func application(_ application: UIApplication, performActionFor shortcutItem: UIApplicationShortcutItem, completionHandler: @escaping (Bool) -> Void) {
        if let splitVC = self.window?.rootViewController as? UISplitViewController, let splitNavVC = splitVC.viewControllers[0] as? UINavigationController, let mainVC = splitNavVC.viewControllers[0] as? MainTableViewController {
            if shortcutItem.type == Shortcuts.showToday {
                mainVC.showDay(dayValue: DayValue.TODAY)
            } else if shortcutItem.type == Shortcuts.showTomorrow {
                mainVC.showDay(dayValue: DayValue.TOMORROW)
            }
        }
        completionHandler(true)
    }
    
    func application(_ application: UIApplication, continue userActivity: NSUserActivity, restorationHandler: @escaping ([UIUserActivityRestoring]?) -> Void) -> Bool {
        if #available(iOS 12.0, *) {
            if let splitVC = self.window?.rootViewController as? UISplitViewController, let splitNavVC = splitVC.viewControllers[0] as? UINavigationController, let mainVC = splitNavVC.viewControllers[0] as? MainTableViewController {
                if userActivity.activityType == Shortcuts.showToday {
                    mainVC.showDay(dayValue: DayValue.TODAY)
                } else if userActivity.activityType == Shortcuts.showTomorrow {
                    mainVC.showDay(dayValue: DayValue.TOMORROW)
                }
                return true
            }
            
            
        }
        return false
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
        if let viewController = self.window?.rootViewController as? UINavigationController, let mainVC = viewController.viewControllers[0] as? MainTableViewController {
            mainVC.tableView.reloadData()
        }
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }
    
    // MARK: - Split view
    
    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {
        
        return true
    }
}

#if targetEnvironment(macCatalyst)

let SettingsButtonTouchBarIdentifier = NSTouchBarItem.Identifier("settingsButton")
let RefreshButtonTouchBarIdentifier = NSTouchBarItem.Identifier("refreshButton")


extension AppDelegate: NSTouchBarDelegate {
    override func makeTouchBar() -> NSTouchBar? {
        let touchBar = NSTouchBar()
        touchBar.defaultItemIdentifiers = [SettingsButtonTouchBarIdentifier, RefreshButtonTouchBarIdentifier]
        touchBar.delegate = self
        
        return touchBar
    }
    
    func touchBar(_ touchBar: NSTouchBar, makeItemForIdentifier identifier: NSTouchBarItem.Identifier) -> NSTouchBarItem? {
        if identifier == SettingsButtonTouchBarIdentifier {
            let item = NSButtonTouchBarItem(
                identifier: SettingsButtonTouchBarIdentifier)
            item.target = self
            item.image = UIImage(systemName: "gear")
            item.title = "Einstellungen"
            item.action = #selector(showSettings)
            return item
        } else if identifier == RefreshButtonTouchBarIdentifier {
            let item = NSButtonTouchBarItem(
                identifier: RefreshButtonTouchBarIdentifier)
            item.target = self
            item.image = UIImage(systemName: "arrow.clockwise")
            item.title = "Aktualisieren"
            item.action = #selector(refresh)
            return item
        }
        return nil
    }
    
    @objc func refresh() {
        let mainVC = getMainVC()
        mainVC.refreshAction(self)
    }
    
    @objc func showSettings() {
        let mainVC = getMainVC()
        mainVC.openSettings()
    }
    
    func getMainVC() -> MainTableViewController {
        if let splitVC = self.window?.rootViewController as? UISplitViewController, let splitNavVC = splitVC.viewControllers[0] as? UINavigationController, let mainVC = splitNavVC.viewControllers[0] as? MainTableViewController {
            return mainVC
        }
        return MainTableViewController()
    }
    
    override func buildMenu(with builder: UIMenuBuilder) {
        super.buildMenu(with: builder)
        
        builder.remove(menu: .services)
        builder.remove(menu: .toolbar)
        builder.remove(menu: .format)
        
        addRefreshToMenubar(with: builder)
        addPreferencesToMenubar(with: builder)
    }
    
    func addRefreshToMenubar(with builder: UIMenuBuilder) {
        let refreshCommand = UIKeyCommand(input: "R", modifierFlags: [.command], action: #selector(refresh))
        refreshCommand.title = "Aktualisieren"
        let reloadDataMenu = UIMenu(title: "Aktualisieren", image: nil, identifier: UIMenu.Identifier("refresh"), options: .displayInline, children: [refreshCommand])
        builder.insertChild(reloadDataMenu, atStartOfMenu: .file)
    }
    
    func addPreferencesToMenubar(with builder: UIMenuBuilder) {
        let preferencesCommand = UIKeyCommand(input: ",", modifierFlags: [.command], action: #selector(showSettings))
        preferencesCommand.title = "Einstellungen..."
        let openPreferences = UIMenu(title: "Einstellungen...", image: nil, identifier: UIMenu.Identifier("showSettings"), options: .displayInline, children: [preferencesCommand])
        builder.insertSibling(openPreferences, afterMenu: .about)
    }
}
#endif

