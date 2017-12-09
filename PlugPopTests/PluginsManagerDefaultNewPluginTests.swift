//
//  PluginManagerDefaultNewPluginTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/17/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

@testable import PlugPop

class PluginsManagerDefaultNewPluginTests: PluginsManagerTestCase {

    func testInvalidDefaultNewPluginIdentifier() {
        // # Set a bad identifier
        let UUID = Foundation.UUID()
        let UUIDString = UUID.uuidString
        defaults.set(UUIDString, forKey: defaultNewPluginIdentifierKey)

        let defaultNewPlugin = pluginsManager.defaultNewPlugin!
        let initialDefaultNewPlugin = pluginsManager.plugin(withName: initialDefaultNewPluginName)!
        XCTAssertEqual(defaultNewPlugin, initialDefaultNewPlugin)

        let identifier = defaults.string(forKey: defaultNewPluginIdentifierKey)
        XCTAssertNil(identifier)
    }
    
    func testSettingAndDeletingDefaultNewPlugin() {
        let createdPlugin = newPluginWithConfirmation()
        pluginsManager.defaultNewPlugin = createdPlugin
        
        // Assert the WCLPlugin's isDefaultNewPlugin property
        XCTAssertTrue(createdPlugin.isDefaultNewPlugin)
        
        // Assert the default new plugin identifier in NSUserDefaults
        let defaultNewPluginIdentifier = defaults.string(forKey: defaultNewPluginIdentifierKey)
        XCTAssertEqual(createdPlugin.identifier, defaultNewPluginIdentifier)
        
        // Assert the default new plugin is returned from the WCLPluginManager
        let defaultNewPlugin = pluginsManager.defaultNewPlugin
        XCTAssertEqual(defaultNewPlugin, createdPlugin)
        
        let trashExpectation = expectation(description: "Move to trash")
        moveToTrashAndCleanUpWithConfirmation(createdPlugin) {
            trashExpectation.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)

        let defaultNewPluginTwo = pluginsManager.defaultNewPlugin!
        let initialDefaultNewPlugin = pluginsManager.plugin(withName: initialDefaultNewPluginName)!
        XCTAssertEqual(defaultNewPluginTwo, initialDefaultNewPlugin)

        let defaultNewPluginIdentifierTwo = defaults.string(forKey: defaultNewPluginIdentifierKey)
        XCTAssertEqual(defaultNewPluginIdentifierTwo, defaultNewPluginTwo.identifier)

        // # Clean Up

        try! removeTemporaryItem(at: tempCopyTempDirectoryURL)
    }

    func testDefaultNewPlugin() {
        XCTAssertNotEqual(testPluginNameNotDefault, initialDefaultNewPluginName)

        let createdPlugin = newPluginWithConfirmation()

        pluginsManager.defaultNewPlugin = createdPlugin
        
        // Seems that the problem with this test is here, renaming a plugin should move it?
        createdPlugin.name = testPluginNameNotDefault
        createdPlugin.command = testPluginCommandTwo
        createdPlugin.suffixes = testPluginSuffixesTwo
        
        let createdPluginTwo = newPluginWithConfirmation()
        
        XCTAssertEqual(createdPlugin.suffixes, createdPluginTwo.suffixes)

        let bundlePath = createdPluginTwo.bundle.bundlePath
        let pluginFolderName = bundlePath.lastPathComponent
        let createdPluginTwoName = DuplicatePluginController.pluginFilename(fromName: createdPluginTwo.name)

        XCTAssertNotEqual(createdPlugin.name, createdPluginTwo.name)
        XCTAssertTrue(createdPluginTwo.name.hasPrefix(createdPlugin.name))
        XCTAssertEqual(createdPluginTwoName, pluginFolderName, "The folder name should equal the plugin's name")

        XCTAssertEqual(createdPlugin.command!, createdPluginTwo.command!, "The new WCLPlugin's command should equal the WCLPlugin's command.")
        XCTAssertNotEqual(createdPlugin.identifier, createdPluginTwo.identifier, "The identifiers should not be equal")

        // # Clean Up

        try! removeTemporaryItem(at: tempCopyTempDirectoryURL)
    }
    
    func testSettingDefaultNewPluginToNil() {
        let createdPlugin = newPluginWithConfirmation()
        pluginsManager.defaultNewPlugin = createdPlugin
        
        let defaultNewPluginIdentifier = defaults.string(forKey: defaultNewPluginIdentifierKey)
        XCTAssertNotNil(defaultNewPluginIdentifier, "The identifier should not be nil")

        pluginsManager.defaultNewPlugin = nil

        let defaultNewPluginTwo = pluginsManager.defaultNewPlugin!
        let initialDefaultNewPlugin = pluginsManager.plugin(withName: initialDefaultNewPluginName)!
        XCTAssertEqual(defaultNewPluginTwo, initialDefaultNewPlugin)

        let defaultNewPluginIdentifierTwo = defaults.string(forKey: defaultNewPluginIdentifierKey)
        XCTAssertEqual(defaultNewPluginIdentifierTwo, defaultNewPluginTwo.identifier)

        // # Clean Up

        try! removeTemporaryItem(at: tempCopyTempDirectoryURL)
    }

    func testDefaultNewPluginKeyValueObserving() {
        let createdPlugin = newPluginWithConfirmation()
        XCTAssertFalse(createdPlugin.isDefaultNewPlugin, "The WCLPlugin should not be the default new WCLPlugin.")

        var isDefaultNewPlugin = createdPlugin.isDefaultNewPlugin
        WCLKeyValueObservingTestsHelper.observe(createdPlugin,
                                                forKeyPath: testPluginDefaultNewPluginKeyPath,
                                                options: NSKeyValueObservingOptions.new)
        { (change: [AnyHashable: Any]?) -> Void in
            isDefaultNewPlugin = createdPlugin.isDefaultNewPlugin
        }
        pluginsManager.defaultNewPlugin = createdPlugin
        XCTAssertTrue(isDefaultNewPlugin, "The key-value observing change notification for the WCLPlugin's default new WCLPlugin property should have occurred.")
        XCTAssertTrue(createdPlugin.isDefaultNewPlugin, "The WCLPlugin should be the default new WCLPlugin.")

        // Test that key-value observing notifications occur when second new plugin is set as the default new plugin
        let createdPluginTwo = newPluginWithConfirmation()
        
        XCTAssertFalse(createdPluginTwo.isDefaultNewPlugin, "The WCLPlugin should not be the default new WCLPlugin.")
        
        WCLKeyValueObservingTestsHelper.observe(createdPlugin,
                                                forKeyPath: testPluginDefaultNewPluginKeyPath,
                                                options: NSKeyValueObservingOptions.new)
        { (change: [AnyHashable: Any]?) -> Void in
                isDefaultNewPlugin = createdPlugin.isDefaultNewPlugin
        }
        var isDefaultNewPluginTwo = createdPlugin.isDefaultNewPlugin
        WCLKeyValueObservingTestsHelper.observe(createdPluginTwo,
                                                forKeyPath: testPluginDefaultNewPluginKeyPath,
                                                options: NSKeyValueObservingOptions.new)
        { (change: [AnyHashable: Any]?) -> Void in
            isDefaultNewPluginTwo = createdPluginTwo.isDefaultNewPlugin
        }
        pluginsManager.defaultNewPlugin = createdPluginTwo
        XCTAssertTrue(isDefaultNewPluginTwo, "The key-value observing change notification for the WCLPlugin's default new WCLPlugin property should have occurred.")
        XCTAssertTrue(createdPluginTwo.isDefaultNewPlugin, "The WCLPlugin should be the default new WCLPlugin.")
        XCTAssertFalse(isDefaultNewPlugin, "The key-value observing change notification for the WCLPlugin's default new WCLPlugin property should have occurred.")
        XCTAssertFalse(createdPlugin.isDefaultNewPlugin, "The WCLPlugin should not be the default new WCLPlugin.")

        // Test that key-value observing notifications occur when the default new plugin is set to nil
        WCLKeyValueObservingTestsHelper.observe(createdPluginTwo,
                                                forKeyPath: testPluginDefaultNewPluginKeyPath,
                                                options: NSKeyValueObservingOptions.new)
        { (change: [AnyHashable: Any]?) -> Void in
            isDefaultNewPluginTwo = createdPluginTwo.isDefaultNewPlugin
        }
        pluginsManager.defaultNewPlugin = nil
        XCTAssertFalse(isDefaultNewPluginTwo, "The key-value observing change notification for the second WCLPlugin's default new WCLPlugin property should have occurred.")
        XCTAssertFalse(createdPluginTwo.isDefaultNewPlugin, "The second WCLPlugin should not be the default new WCLPlugin.")

        // # Clean Up

        try! removeTemporaryItem(at: tempCopyTempDirectoryURL)
    }
    
}
