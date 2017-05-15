//
//  PluginManagerTestCase_new.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/18/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

@testable import Web_Console

class PluginsManagerTestCase: TemporaryPluginsTestCase {
    var plugin: Plugin!
    
    override func setUp() {
        super.setUp()
        
        // Create the plugin manager
        let pluginsManager = PluginsManager(paths: [pluginsDirectoryPath],
            duplicatePluginDestinationDirectoryURL: duplicatePluginDestinationDirectoryURL)
        PluginsManager.setOverrideSharedInstance(pluginsManager)

        // Set the plugin
        plugin = pluginsManager.plugin(forName: testPluginName)
        plugin.editable = true
        XCTAssertNotNil(plugin, "The temporary plugin should not be nil")

        PluginsManager.sharedInstance.defaultNewPlugin = plugin
    }
    
    override func tearDown() {
        PluginsManager.sharedInstance.defaultNewPlugin = nil
        plugin = nil
        PluginsManager.setOverrideSharedInstance(nil)
        super.tearDown()
    }

    var duplicatePluginDestinationDirectoryURL: URL {
        return pluginsDirectoryURL as URL
    }
    
    func newPluginWithConfirmation() -> Plugin {
        var createdPlugin: Plugin!
        let createdPluginExpectation = expectation(description: "Create new plugin")
        PluginsManager.sharedInstance.newPlugin { (newPlugin, error) -> Void in
            XCTAssertNil(error, "The error should be nil")
            createdPlugin = newPlugin
            createdPluginExpectation.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        return createdPlugin
    }
 
    func duplicateWithConfirmation(_ plugin: Plugin) -> Plugin {
        var createdPlugin: Plugin!
        let createdPluginExpectation = expectation(description: "Create new plugin")
        PluginsManager.sharedInstance.duplicate(plugin) { (newPlugin, error) -> Void in
            XCTAssertNil(error, "The error should be nil")
            createdPlugin = newPlugin
            createdPluginExpectation.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        return createdPlugin
    }
    
    func moveToTrashAndCleanUpWithConfirmation(_ plugin: Plugin) {
        // Confirm that a matching directory does not exist in the trash
        let trashedPluginDirectoryName = plugin.bundle.bundlePath.lastPathComponent
        let trashedPluginPath = Directory.trash.path().appendingPathComponent(trashedPluginDirectoryName)
        let beforeExists = FileManager.default.fileExists(atPath: trashedPluginPath)
        XCTAssertTrue(!beforeExists, "The item should exist")
        
        // Trash the plugin
        PluginsManager.sharedInstance.moveToTrash(plugin)
        
        // Confirm that the directory does exist in the trash now
        var isDir: ObjCBool = false
        let afterExists = FileManager.default.fileExists(atPath: trashedPluginPath, isDirectory: &isDir)
        XCTAssertTrue(afterExists, "The item should exist")
        XCTAssertTrue(isDir.boolValue, "The item should be a directory")
        
        // Clean up trash
        do {
            try FileManager.default.removeItem(atPath: trashedPluginPath)
        } catch {
            XCTAssertTrue(false, "The remove should succeed")
        }
    }
}
