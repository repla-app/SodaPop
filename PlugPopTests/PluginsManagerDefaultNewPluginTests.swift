//
//  PluginManagerDefaultNewPluginTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/17/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

@testable import Web_Console

class PluginsManagerDefaultNewPluginTests: PluginsManagerTestCase {

    override func setUp() {
        mockUserDefaultsSetUp()
        super.setUp()
    }
    
    override func tearDown() {
        mockUserDefaultsTearDown()
        super.tearDown()
    }
    
    func testInvalidDefaultNewPluginIdentifier() {
        PluginsManager.sharedInstance.defaultNewPlugin = nil
        let UUID = Foundation.UUID()
        let UUIDString = UUID.uuidString
        UserDefaultsManager.standardUserDefaults().set(UUIDString, forKey: defaultNewPluginIdentifierKey)

        let defaultNewPlugin = PluginsManager.sharedInstance.defaultNewPlugin
        let initialDefaultNewPlugin: Plugin! = PluginsManager.sharedInstance.plugin(forName: initialDefaultNewPluginName)
        XCTAssertEqual(defaultNewPlugin, initialDefaultNewPlugin, "The plugins should be equal")
        
        let identifier = UserDefaultsManager.standardUserDefaults().string(forKey: defaultNewPluginIdentifierKey)
        XCTAssertNil(identifier, "The default new WCLPlugin identifier should be nil.")
    }
    
    func testSettingAndDeletingDefaultNewPlugin() {
        let createdPlugin = newPluginWithConfirmation()
        PluginsManager.sharedInstance.defaultNewPlugin = createdPlugin
        
        // Assert the WCLPlugin's isDefaultNewPlugin property
        XCTAssertTrue(createdPlugin.isDefaultNewPlugin, "The WCLPlugin should be the default new WCLPlugin.")
        
        // Assert the default new plugin identifier in NSUserDefaults
        let defaultNewPluginIdentifier: String! = UserDefaultsManager.standardUserDefaults().string(forKey: defaultNewPluginIdentifierKey)
        XCTAssertEqual(createdPlugin.identifier, defaultNewPluginIdentifier, "The default WCLPlugin's identifier should equal the WCLPlugin's identifier.")
        
        // Assert the default new plugin is returned from the WCLPluginManager
        let defaultNewPlugin = PluginsManager.sharedInstance.defaultNewPlugin
        XCTAssertEqual(defaultNewPlugin, createdPlugin, "The default new WCLPlugin should be the WCLPlugin.")
        
        moveToTrashAndCleanUpWithConfirmation(createdPlugin)
        
        let defaultNewPluginTwo = PluginsManager.sharedInstance.defaultNewPlugin
        let initialDefaultNewPlugin: Plugin! = PluginsManager.sharedInstance.plugin(forName: initialDefaultNewPluginName)
        XCTAssertEqual(defaultNewPluginTwo, initialDefaultNewPlugin, "The plugins should be equal")

        let defaultNewPluginIdentifierTwo = UserDefaultsManager.standardUserDefaults().string(forKey: defaultNewPluginIdentifierKey)
        XCTAssertNil(defaultNewPluginIdentifierTwo, "The default new WCLPlugin identifier should be nil.")
    }
    

    func testDefaultNewPlugin() {
        let createdPlugin = newPluginWithConfirmation()

        PluginsManager.sharedInstance.defaultNewPlugin = createdPlugin
        
        createdPlugin.name = testPluginNameTwo
        createdPlugin.command = testPluginCommandTwo
        createdPlugin.suffixes = testPluginSuffixesTwo
        
        let createdPluginTwo = newPluginWithConfirmation()
        
        XCTAssertEqual(createdPlugin.suffixes, createdPluginTwo.suffixes, "The new WCLPlugin's file extensions should equal the WCLPlugin's file extensions.")

        let bundlePath = createdPluginTwo.bundle.bundlePath
        let pluginFolderName = bundlePath.lastPathComponent
        XCTAssertEqual(DuplicatePluginController.pluginFilename(fromName: createdPluginTwo.name), pluginFolderName, "The folder name should equal the plugin's name")
        
        let longName: String = createdPlugin.name
        XCTAssertTrue(longName.hasPrefix(createdPlugin.name), "The new WCLPlugin's name should start with the WCLPlugin's name.")
        XCTAssertNotEqual(createdPlugin.name, createdPluginTwo.name, "The new WCLPlugin's name should not equal the WCLPlugin's name.")

        XCTAssertEqual(createdPlugin.command!, createdPluginTwo.command!, "The new WCLPlugin's command should equal the WCLPlugin's command.")
        XCTAssertNotEqual(createdPlugin.identifier, createdPluginTwo.identifier, "The identifiers should not be equal")
    }
    
    func testSettingDefaultNewPluginToNil() {
        let createdPlugin = newPluginWithConfirmation()
        PluginsManager.sharedInstance.defaultNewPlugin = createdPlugin
        
        let defaultNewPluginIdentifier: String? = UserDefaultsManager.standardUserDefaults().string(forKey: defaultNewPluginIdentifierKey)
        XCTAssertNotNil(defaultNewPluginIdentifier, "The identifier should not be nil")

        PluginsManager.sharedInstance.defaultNewPlugin = nil

        let defaultNewPluginIdentifierTwo: String? = UserDefaultsManager.standardUserDefaults().string(forKey: defaultNewPluginIdentifierKey)
        XCTAssertNil(defaultNewPluginIdentifierTwo, "The identifier should be nil")
    }

    func testDefaultNewPluginKeyValueObserving() {
        let createdPlugin = newPluginWithConfirmation()
        XCTAssertFalse(createdPlugin.isDefaultNewPlugin, "The WCLPlugin should not be the default new WCLPlugin.")

        var isDefaultNewPlugin = createdPlugin.isDefaultNewPlugin
        WCLKeyValueObservingTestsHelper.observe(createdPlugin,
            forKeyPath: testPluginDefaultNewPluginKeyPath,
            options: NSKeyValueObservingOptions.new )
        {
            (change: [AnyHashable: Any]?) -> Void in
            isDefaultNewPlugin = createdPlugin.isDefaultNewPlugin
        }
        PluginsManager.sharedInstance.defaultNewPlugin = createdPlugin
        XCTAssertTrue(isDefaultNewPlugin, "The key-value observing change notification for the WCLPlugin's default new WCLPlugin property should have occurred.")
        XCTAssertTrue(createdPlugin.isDefaultNewPlugin, "The WCLPlugin should be the default new WCLPlugin.")

        // Test that key-value observing notifications occur when second new plugin is set as the default new plugin
        let createdPluginTwo = newPluginWithConfirmation()
        
        XCTAssertFalse(createdPluginTwo.isDefaultNewPlugin, "The WCLPlugin should not be the default new WCLPlugin.")
        
        WCLKeyValueObservingTestsHelper.observe(createdPlugin,
            forKeyPath: testPluginDefaultNewPluginKeyPath,
            options: NSKeyValueObservingOptions.new )
            {
                (change: [AnyHashable: Any]?) -> Void in
                isDefaultNewPlugin = createdPlugin.isDefaultNewPlugin
        }
        var isDefaultNewPluginTwo = createdPlugin.isDefaultNewPlugin
        WCLKeyValueObservingTestsHelper.observe(createdPluginTwo,
            forKeyPath: testPluginDefaultNewPluginKeyPath,
            options: NSKeyValueObservingOptions.new )
            {
                (change: [AnyHashable: Any]?) -> Void in
                isDefaultNewPluginTwo = createdPluginTwo.isDefaultNewPlugin
        }
        PluginsManager.sharedInstance.defaultNewPlugin = createdPluginTwo
        XCTAssertTrue(isDefaultNewPluginTwo, "The key-value observing change notification for the WCLPlugin's default new WCLPlugin property should have occurred.")
        XCTAssertTrue(createdPluginTwo.isDefaultNewPlugin, "The WCLPlugin should be the default new WCLPlugin.")
        XCTAssertFalse(isDefaultNewPlugin, "The key-value observing change notification for the WCLPlugin's default new WCLPlugin property should have occurred.")
        XCTAssertFalse(createdPlugin.isDefaultNewPlugin, "The WCLPlugin should not be the default new WCLPlugin.")

        // Test that key-value observing notifications occur when the default new plugin is set to nil
        WCLKeyValueObservingTestsHelper.observe(createdPluginTwo,
            forKeyPath: testPluginDefaultNewPluginKeyPath,
            options: NSKeyValueObservingOptions.new )
            {
                (change: [AnyHashable: Any]?) -> Void in
                isDefaultNewPluginTwo = createdPluginTwo.isDefaultNewPlugin
        }
        PluginsManager.sharedInstance.defaultNewPlugin = nil
        XCTAssertFalse(isDefaultNewPluginTwo, "The key-value observing change notification for the second WCLPlugin's default new WCLPlugin property should have occurred.")
        XCTAssertFalse(createdPluginTwo.isDefaultNewPlugin, "The second WCLPlugin should not be the default new WCLPlugin.")
    }
    
}
