//
//  PluginManagerTestCase_new.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/18/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

@testable import PlugPop
import PotionTaster

class PluginsManagerTestCase: TemporaryPluginsTestCase {
    var plugin: Plugin!
    var pluginsManager: PluginsManager!
    lazy var cachesPath: String = {
        let cachesDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true)[0]
        return cachesDirectory.appendingPathComponent(String(describing: self))
    }()
    lazy var cachesURL: URL = {
        URL(fileURLWithPath: self.cachesPath)
    }()
    lazy var defaults: DefaultsType = {
        let userDefaults = UserDefaults(suiteName: testMockUserDefaultsSuiteName)!
    }()

    override func setUp() {
        super.setUp()

        // Create the plugin manager
        pluginsManager = PluginsManager(paths: [pluginsDirectoryPath],
                                        duplicatePluginDestinationDirectoryURL: duplicatePluginDestinationDirectoryURL,
                                        copyTempDirectoryURL: cachesURL,
                                        defaults: defaults,
                                        builtInPluginsPath: pluginsDirectoryPath,
                                        applicationSupportPluginsPath: nil)

        // Set the plugin
        plugin = pluginsManager.plugin(withName: PotionTaster.testPluginName)
        plugin.editable = true
        XCTAssertNotNil(plugin, "The temporary plugin should not be nil")
        plugin.isDefaultNewPlugin = true
    }
    
    override func tearDown() {
        plugin.isDefaultNewPlugin = false
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
        pluginsManager.newPlugin { (newPlugin, error) -> Void in
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
        pluginsManager.duplicate(plugin) { (newPlugin, error) -> Void in
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
        let trashedPluginPath = testTrashDirectoryPath.appendingPathComponent(trashedPluginDirectoryName)
        let beforeExists = FileManager.default.fileExists(atPath: trashedPluginPath)
        XCTAssertTrue(!beforeExists, "The item should exist")
        
        // Trash the plugin
        pluginsManager.moveToTrash(plugin)
        
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
