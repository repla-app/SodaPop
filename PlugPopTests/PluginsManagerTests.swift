//
//  PluginManagerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/6/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

@testable import PlugPop

class PluginsManagerTests: PluginsManagerTestCase {

    func testTestPlugins() {
        let plugins = pluginsManager.plugins
        for plugin in plugins {
            XCTAssertEqual(plugin.pluginType, Plugin.PluginType.other, "The plugin type should be built-in")
            XCTAssertEqual(plugin.type, Plugin.PluginType.other.name(), "The type should equal the name")
        }
    }
    
    func testDuplicateAndTrashPlugin() {
        let newPlugin = newPluginWithConfirmation()
        
        XCTAssertEqual(pluginsManager.plugins().count, 2, "The plugins count should be two")
        let plugins = pluginsManager.plugins() as NSArray
        XCTAssertTrue(plugins.contains(newPlugin), "The plugins should contain the plugin")

        // Edit the new plugin
        newPlugin.command = testPluginCommandTwo

        // Create another plugin from this plugin
        let newPluginTwo = duplicateWithConfirmation(newPlugin)
        
        // Test Properties

        XCTAssertEqual(newPluginTwo.command!, newPlugin.command!, "The commands should be equal")
        XCTAssertNotEqual(plugin.command!, newPlugin.command!, "The names should not be equal")
        
        // Trash the duplicated plugin
        moveToTrashAndCleanUpWithConfirmation(newPlugin)
        moveToTrashAndCleanUpWithConfirmation(newPluginTwo)
    }

    func testRenamePlugin() {
        let newPluginName = plugin.identifier
        plugin.name = newPluginName
        XCTAssertNotNil(pluginsManager.plugin(withName: newPluginName), "The plugin should not be nil")
        XCTAssertNil(pluginsManager.plugin(withName: testPluginName), "The plugin should be nil")
    }
}

class PluginsManagerBuiltInPluginsTests: XCTestCase {

    override func setUp() {
        super.setUp()
        let pluginsManager = PluginsManager(paths: testPluginsPaths,
           duplicatePluginDestinationDirectoryURL: testTrashDirectoryPath)
        PluginsManager.setOverrideSharedInstance(pluginsManager)
    }
    
    override func tearDown() {
        PluginsManager.setOverrideSharedInstance(nil)
        super.tearDown()
    }
    
    func testBuiltInPlugins() {
        let plugins = pluginsManager.plugins() as! [Plugin]

        for plugin in plugins {
            XCTAssertEqual(plugin.pluginType, Plugin.PluginType.builtIn, "The plugin type should be built-in")
            XCTAssertEqual(plugin.type, Plugin.PluginType.builtIn.name(), "The type should equal the name")
        }

        let count = pluginsManager.plugins().count
        var pluginsPathsCount = 0

        for pluginsPath in testPluginsPaths {

            do {
                let contents = try FileManager.default.contentsOfDirectory(atPath: pluginsPath)
                let paths = contents
                let pluginFileExtensionMatch = ".\(pluginFileExtension)"
                let pluginFileExtensionPredicate: NSPredicate! = NSPredicate(format: "self ENDSWITH %@", pluginFileExtensionMatch)
                let pluginPaths = paths.filter {
                    pluginFileExtensionPredicate.evaluate(with: $0)

                }
                pluginsPathsCount += pluginPaths.count
            } catch {
                XCTAssertTrue(false, "Getting the contents should succeed")
            }
        }
        XCTAssert(count == pluginsPathsCount, "The counts should be equal")
    }
}
