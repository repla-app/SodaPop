//
//  WCLFileExtensionTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/25/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

@testable import Web_Console

let fileExtensionToPluginKey = "WCLFileExtensionToPlugin"

class WCLFileExtensionTests: FileExtensionsTestCase {
    var fileExtension: WCLFileExtension!
    var fileExtensionPluginDictionary: NSDictionary {
        get {
            var fileExtensionToPluginDictionary = WCLFileExtension.fileExtensionToPluginDictionary()
            return fileExtensionToPluginDictionary[fileExtension.suffix] as! NSDictionary
        }
    }

    // MARK: Helper
    
    func matches(_ plugin: Plugin, for fileExtension: WCLFileExtension) -> Bool {
        let suffix = fileExtension.suffix
        
        let plugins = fileExtension.plugins() as NSArray
        let containsPlugin = plugins.contains(plugin)
        
        let suffixes = plugin.suffixes as NSArray
        let containsSuffix = suffixes.contains(suffix)
        
        return containsPlugin == containsSuffix
    }
    
    func confirmPluginIdentifierInFileExtensionPluginDictionary() {
        let pluginIdentifierInDictionary = fileExtensionPluginDictionary.value(forKey: testFileExtensionPluginIdentifierKey) as! String
        XCTAssertEqual(pluginIdentifierInDictionary, fileExtension.selectedPlugin?.identifier, "The WCLPlugin's identifier value in the dictionary should match the WCLFileExtension's selected WCLPlugin's identifier.")
    }

    // MARK: Tests
    
    override func setUp() {
        super.setUp()
        plugin.suffixes = testPluginSuffixes
        XCTAssertEqual(FileExtensionsController.sharedInstance.suffixes().count, 1, "The file extensions count should equal one.")
        fileExtension = FileExtensionsController.sharedInstance.fileExtension(forSuffix: testPluginSuffix)
        mockUserDefaultsSetUp()
        UserDefaultsManager.standardUserDefaults().setValue(nil, forKey: fileExtensionToPluginKey)
    }

    override func tearDown() {
        UserDefaultsManager.standardUserDefaults().setValue(nil, forKey: fileExtensionToPluginKey)
        mockUserDefaultsTearDown()
        super.tearDown()
    }
    
    func testNewFileExtensionProperties() {
        XCTAssertEqual(fileExtension.suffix, testPluginSuffix, "The WCLFileExtension's extension should equal the test extension.")
        XCTAssertEqual(fileExtension.isEnabled, defaultFileExtensionEnabled, "The WCLFileExtension's enabled should equal the default enabled.")
        XCTAssertEqual(fileExtension.selectedPlugin, fileExtension.plugins()[0], "The WCLFileExtension's selected WCLPlugin should be the first WCLPlugin.")

        let plugins = PluginsManager.sharedInstance.plugins() as! [Plugin]
        for plugin in plugins {
            let matches = self.matches(plugin, for: fileExtension)
            XCTAssertTrue(matches, "The WCLPlugin should match the WCLFileExtension.")
        }
    }
    
    func testSettingEnabled() {
        var isEnabled = fileExtension.isEnabled
        WCLKeyValueObservingTestsHelper.observe(fileExtension,
            forKeyPath: testFileExtensionEnabledKeyPath,
            options: NSKeyValueObservingOptions.new)
        {
            (_) -> Void in
            isEnabled = self.fileExtension.isEnabled
        }

        var inverseEnabled = !fileExtension.isEnabled
        fileExtension.isEnabled = inverseEnabled
        XCTAssertEqual(isEnabled, inverseEnabled, "The key-value observing change notification for the WCLFileExtensions's enabled property should have occurred.")
        XCTAssertEqual(fileExtension.isEnabled, inverseEnabled, "The WCLFileExtension's isEnabled should equal the inverse enabled.")

        // Test UserDefaults
        var enabledInDictionary = fileExtensionPluginDictionary.value(forKey: testFileExtensionEnabledKeyPath) as! Bool
        XCTAssertEqual(enabledInDictionary, fileExtension.isEnabled, "The enabled value in the dictionary should match the WCLFileExtension's enabled property")

        // Test key-value observing for the enabled property
        isEnabled = fileExtension.isEnabled
        WCLKeyValueObservingTestsHelper.observe(fileExtension,
            forKeyPath: testFileExtensionEnabledKeyPath,
            options: NSKeyValueObservingOptions.new)
        {
            (_) -> Void in
            isEnabled = self.fileExtension.isEnabled
        }

        inverseEnabled = !fileExtension.isEnabled
        fileExtension.isEnabled = inverseEnabled
        XCTAssertEqual(isEnabled, inverseEnabled, "The key-value observing change notification for the WCLFileExtensions's enabled property should have occurred.")
        XCTAssertEqual(fileExtension.isEnabled, inverseEnabled, "The WCLFileExtension's isEnabled should equal the inverse enabled.")

        // Test UserDefaults
        enabledInDictionary = fileExtensionPluginDictionary.value(forKey: testFileExtensionEnabledKeyPath) as! Bool
        XCTAssertEqual(enabledInDictionary, fileExtension.isEnabled, "The enabled value in the dictionary should match the WCLFileExtension's enabled property")
    }

    func testSettingSelectedPlugin() {
        var observedChange = false
        WCLKeyValueObservingTestsHelper.observe(fileExtension,
            forKeyPath: testFileExtensionSelectedPluginKeyPath,
            options: NSKeyValueObservingOptions.new)
        {
            (_) -> Void in
            observedChange = true
        }

        XCTAssertFalse(observedChange, "The change should not have been observed.")
        fileExtension.selectedPlugin = plugin
        XCTAssertTrue(observedChange, "The key-value observing change should have occurred.")
        XCTAssertEqual(fileExtension.selectedPlugin, plugin, "The WCLFileExtension's selected WCLPlugin should equal the WCLPlugin.")
        confirmPluginIdentifierInFileExtensionPluginDictionary()

        // Test changing the selected plugin
        
        let createdPlugin = newPluginWithConfirmation()
        createdPlugin.suffixes = testPluginSuffixes

        observedChange = false
        WCLKeyValueObservingTestsHelper.observe(fileExtension,
            forKeyPath: testFileExtensionSelectedPluginKeyPath,
            options: NSKeyValueObservingOptions.new)
        {
                (_) -> Void in
                observedChange = true
        }
        XCTAssertFalse(observedChange, "The change should not have been observed.")
        fileExtension.selectedPlugin = createdPlugin
        XCTAssertTrue(observedChange, "The key-value observing change should have occurred.")
        XCTAssertEqual(fileExtension.selectedPlugin, createdPlugin, "The WCLFileExtension's selected WCLPlugin should equal the WCLPlugin.")
        confirmPluginIdentifierInFileExtensionPluginDictionary()
        
        // Test setting the selected plugin to nil

        observedChange = false
        WCLKeyValueObservingTestsHelper.observe(fileExtension,
            forKeyPath: testFileExtensionSelectedPluginKeyPath,
            options: NSKeyValueObservingOptions.new)
        {
            (_) -> Void in
            observedChange = true
        }
        XCTAssertFalse(observedChange, "The change should not have been observed.")
        fileExtension.selectedPlugin = nil
        XCTAssertTrue(observedChange, "The key-value observing change should have occurred.")
        XCTAssertEqual(fileExtension.selectedPlugin, fileExtension.plugins()[0], "The WCLFileExtension's selected WCLPlugin should be the first WCLPlugin.")
        confirmPluginIdentifierInFileExtensionPluginDictionary()
    }

    func testChangingPluginsFileExtensions() {
        let createdPlugin = newPluginWithConfirmation()
        createdPlugin.suffixes = testPluginSuffixesEmpty

        XCTAssertFalse(fileExtension.plugins().contains(createdPlugin), "The WCLFileExtension's WCLPlugins should not contain the new WCLPlugin.")

        var plugins = fileExtension.plugins()
        WCLKeyValueObservingTestsHelper.observe(fileExtension,
            forKeyPath: testFileExtensionPluginsKey,
            options: NSKeyValueObservingOptions.new)
        {
            (_) -> Void in
            plugins = self.fileExtension.plugins()
        }
        XCTAssertFalse(plugins.contains(createdPlugin), "The WCLPlugins should not contain the new WCLPlugin.")
        createdPlugin.suffixes = testPluginSuffixes
        XCTAssertTrue(plugins.contains(createdPlugin), "The key-value observing change notification for the WCLFileExtensions's WCLPlugins property should have occurred.")
        XCTAssertTrue(fileExtension.plugins().contains(createdPlugin), "The WCLFileExtension's WCLPlugins should contain the new WCLPlugin.")

        fileExtension.selectedPlugin = createdPlugin
        
        // Test removing the file extension

        // Test key-value observing for the plugins property
        WCLKeyValueObservingTestsHelper.observe(fileExtension,
            forKeyPath: testFileExtensionPluginsKey,
            options: NSKeyValueObservingOptions.new)
        {
            (_) -> Void in
            plugins = self.fileExtension.plugins()
        }

        // Test key-value observing for the selected plugin property
        var observedChange = false
        WCLKeyValueObservingTestsHelper.observe(fileExtension,
            forKeyPath: testFileExtensionSelectedPluginKeyPath,
            options: NSKeyValueObservingOptions.new)
        {
            (_) -> Void in
            observedChange = true
        }
        XCTAssertFalse(observedChange, "The change should not have been observed.")

        createdPlugin.suffixes = testPluginSuffixesEmpty

        // Test the file extensions plugins property changed
        XCTAssertFalse(plugins.contains(createdPlugin), "The key-value observing change notification for the WCLFileExtensions's WCLPlugins property should have occurred.")
        XCTAssertFalse(fileExtension.plugins().contains(createdPlugin), "The WCLFileExtension's WCLPlugins should not contain the new WCLPlugin.")

        // Test the file extensions selected plugin property changed
        XCTAssertTrue(observedChange, "The key-value observing change should have occurred.")
        XCTAssertNotEqual(fileExtension.selectedPlugin, createdPlugin, "The WCLFileExtension's selected WCLPlugin should not be the new WCLPlugin.")
        XCTAssertEqual(fileExtension.selectedPlugin, fileExtension.plugins()[0], "The WCLFileExtension's selected WCLPlugin should be the first WCLPlugin.")

        confirmPluginIdentifierInFileExtensionPluginDictionary()
    }

    func testDeletingSelectedPlugin() {
        let createdPlugin = newPluginWithConfirmation()
        createdPlugin.suffixes = testPluginSuffixes
        fileExtension.selectedPlugin = createdPlugin

        // Test key-value observing for the plugins property
        var plugins = fileExtension.plugins()
        WCLKeyValueObservingTestsHelper.observe(fileExtension,
            forKeyPath: testFileExtensionPluginsKey,
            options: NSKeyValueObservingOptions.new)
        {
            (_) -> Void in
            plugins = self.fileExtension.plugins()
        }
        
        // Test key-value observing for the selected plugin property
        var observedChange = false
        WCLKeyValueObservingTestsHelper.observe(fileExtension,
            forKeyPath: testFileExtensionSelectedPluginKeyPath,
            options: NSKeyValueObservingOptions.new)
            {
                (_) -> Void in
                observedChange = true
        }
        XCTAssertFalse(observedChange, "The change should not have been observed.")

        // Move plugin to trash
        moveToTrashAndCleanUpWithConfirmation(createdPlugin)

        // Test the file extensions plugins property changed
        XCTAssertFalse(plugins.contains(createdPlugin), "The key-value observing change notification for the WCLFileExtensions's WCLPlugins property should have occurred.")
        XCTAssertFalse(fileExtension.plugins().contains(createdPlugin), "The WCLFileExtension's WCLPlugins should not contain the new WCLPlugin.")

        // Test the file extensions selected plugin property changed
        XCTAssertTrue(observedChange, "The key-value observing change should have occurred.")
        XCTAssertNotEqual(fileExtension.selectedPlugin, createdPlugin, "The WCLFileExtension's selected WCLPlugin should not be the new WCLPlugin.")
        XCTAssertEqual(fileExtension.selectedPlugin, fileExtension.plugins()[0], "The WCLFileExtension's selected WCLPlugin should be the first WCLPlugin.")
        
        confirmPluginIdentifierInFileExtensionPluginDictionary()
    }

}
