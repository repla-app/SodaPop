//
//  PluginsDataControllerEventTestCase+FileSystemHelpers.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/19/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation
import XCTest

@testable import Web_Console

extension PluginsDataControllerEventTestCase {
    // MARK: Move Helpers
    
    func moveWithConfirmation(_ plugin: Plugin, destinationPluginPath: String, handler: @escaping (_ plugin: Plugin?) -> Void) {
        let removeExpectation = expectation(description: "Plugin was removed")
        pluginDataEventManager.add(pluginWasRemovedHandler: { (removedPlugin) -> Void in
            if (plugin == removedPlugin) {
                removeExpectation.fulfill()
            }
        })
        
        var newPlugin: Plugin?
        let createExpectation = expectation(description: "Plugin was added")
        pluginDataEventManager.add(pluginWasAddedHandler: { (addedPlugin) -> Void in
            let path = addedPlugin.bundle.bundlePath
            if (path == destinationPluginPath) {
                newPlugin = addedPlugin
                handler(newPlugin)
                createExpectation.fulfill()
            }
        })
        
        let pluginPath = plugin.bundle.bundlePath
        SubprocessFileSystemModifier.moveItem(atPath: pluginPath, toPath: destinationPluginPath)
        
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    
    
    // MARK: Copy Helpers
    
    func copyWithConfirmation(_ plugin: Plugin, destinationPluginPath: String, handler: @escaping (_ plugin: Plugin?) -> Void) {
        var newPlugin: Plugin?
        let createExpectation = expectation(description: "Plugin was added")
        pluginDataEventManager.add(pluginWasAddedHandler: { (addedPlugin) -> Void in
            let path = addedPlugin.bundle.bundlePath
            if (path == destinationPluginPath) {
                newPlugin = addedPlugin
                handler(newPlugin)
                createExpectation.fulfill()
            }
        })
        
        
        let pluginPath = plugin.bundle.bundlePath
        let copyExpectation = expectation(description: "Copy finished")
        SubprocessFileSystemModifier.copyDirectory(atPath: pluginPath, toPath: destinationPluginPath, handler: {
            copyExpectation.fulfill()
        })
        
        // TODO: Once the requirement that no two plugins have the same identifier is enforced, we'll also have to change the new plugins identifier here
        
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    
    
    // MARK: Remove Helpers
    
    func removeWithConfirmation(_ plugin: Plugin) {
        let removeExpectation = expectation(description: "Plugin was removed")
        pluginDataEventManager.add(pluginWasRemovedHandler: { (removedPlugin) -> Void in
            if (plugin == removedPlugin) {
                removeExpectation.fulfill()
            }
        })
        
        let pluginPath = plugin.bundle.bundlePath
        let deleteExpectation = expectation(description: "Remove finished")
        SubprocessFileSystemModifier.removeDirectory(atPath: pluginPath, handler: {
            deleteExpectation.fulfill()
        })
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    
    
    // MARK: Modify Helpers
    
    func modifyWithConfirmation(_ plugin: Plugin, handler: @escaping (_ plugin: Plugin?) -> Void) {

        // Get the old identifier
        let infoDictionary = NSDictionary(contentsOf: plugin.infoDictionaryURL)! as Dictionary
        let identifier: String = infoDictionary[Plugin.InfoDictionaryKeys.identifier as NSString] as! String

        // Make a new identifier
        let UUID = Foundation.UUID()
        let newIdentifier = UUID.uuidString

        // Get the info dictionary contents
        let infoDictionaryPath = plugin.infoDictionaryURL.path

        var infoDictionaryContents: String!
        do {
            infoDictionaryContents = try String(contentsOfFile: infoDictionaryPath, encoding: String.Encoding.utf8)
        } catch {
            XCTAssertNil(false, "Getting the info dictionary contents shoudld succeed.")
        }
        
        // Replace the old identifier with the new identifier
        let newInfoDictionaryContents = infoDictionaryContents.replacingOccurrences(of: identifier, with: newIdentifier)

        let removeExpectation = expectation(description: "Plugin was removed")
        pluginDataEventManager.add(pluginWasRemovedHandler: { (removedPlugin) -> Void in
            if (plugin == removedPlugin) {
                removeExpectation.fulfill()
            }
        })
        
        let pluginPath = plugin.bundle.bundlePath
        var newPlugin: Plugin?
        let createExpectation = expectation(description: "Plugin was added")
        pluginDataEventManager.add(pluginWasAddedHandler: { (addedPlugin) -> Void in
            let path = addedPlugin.bundle.bundlePath
            if (path == pluginPath) {
                newPlugin = addedPlugin
                handler(newPlugin)
                createExpectation.fulfill()
            }
        })
        
        SubprocessFileSystemModifier.writeToFile(atPath: infoDictionaryPath, contents: newInfoDictionaryContents)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
}
