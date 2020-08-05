//
//  MainTableViewController+NSToolbar.swift
//  Mensaplan
//
//  Created by Marc Hein on 05.08.20.
//  Copyright © 2020 Marc Hein. All rights reserved.
//

import Foundation

import UIKit

#if targetEnvironment(macCatalyst)
extension MainTableViewController: NSToolbarDelegate {
    
    enum Toolbar {
        static let back = NSToolbarItem.Identifier(rawValue: "back")
        static let reload = NSToolbarItem.Identifier(rawValue: "reload")
        static let settings = NSToolbarItem.Identifier(rawValue: "settings")
    }
    
    
    func toolbar(_ toolbar: NSToolbar, itemForItemIdentifier itemIdentifier: NSToolbarItem.Identifier, willBeInsertedIntoToolbar flag: Bool) -> NSToolbarItem? {
        if itemIdentifier == Toolbar.back {
            let item = NSToolbarItem(itemIdentifier: Toolbar.back)
            item.image = UIImage(systemName: "chevron.left")
            item.target = self
            item.isBordered = true
            item.action = #selector(goBack)
            item.label = "Zurück"
            item.isEnabled = false
            return item
        } else if itemIdentifier == Toolbar.settings {
            let item = NSToolbarItem(itemIdentifier: Toolbar.settings)
            item.image = UIImage(systemName: "gear")
            item.target = self
            item.isBordered = true
            item.action = #selector(openSettings)
            item.label = "Einstellungen"
            return item
        } else if itemIdentifier == Toolbar.reload {
            let item = NSToolbarItem(itemIdentifier: Toolbar.reload)
            item.image = UIImage(systemName: "arrow.clockwise")
            item.isBordered = true
            item.target = self
            item.action = #selector(refreshAction)
            item.label = "Aktualisieren"
            
            return item

        }
        return nil
    }
    
    //5
    func toolbarDefaultItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return [Toolbar.back, .flexibleSpace, Toolbar.settings, Toolbar.reload]
    }
    
    func toolbarAllowedItemIdentifiers(_ toolbar: NSToolbar) -> [NSToolbarItem.Identifier] {
        return self.toolbarDefaultItemIdentifiers(toolbar)
    }
    
    @objc func goBack() {
        guard let detailNavVC = splitViewController?.viewControllers[1] as? UINavigationController else { return }
        detailNavVC.popToRootViewController(animated: true)
    }
}
#endif

extension MainTableViewController {
    func buildMacToolbar() {
        #if targetEnvironment(macCatalyst)
        guard let windowScene = view.window?.windowScene else {
            return
        }
        
        if let titlebar = windowScene.titlebar {
            let toolbar = NSToolbar(identifier: "toolbar")
            titlebar.titleVisibility = .hidden
            toolbar.delegate = self
            titlebar.toolbar = toolbar
            titlebar.autoHidesToolbarInFullScreen = false
        }
        
        #endif
    }
}
