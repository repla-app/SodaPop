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
            XCTAssertEqual(plugin.pluginType, PluginType.other, "The plugin type should be built-in")
            XCTAssertEqual(plugin.type, PluginType.other.name(), "The type should equal the name")
        }
    }
    
    func testDuplicateAndTrashPlugin() {
        let startingPluginsCount = pluginsManager.plugins.count

        let newPlugin = newPluginWithConfirmation()
        
        XCTAssertEqual(pluginsManager.plugins.count, startingPluginsCount + 1)
        let plugins = pluginsManager.plugins
        XCTAssertTrue(plugins.contains(newPlugin))

        // Edit the new plugin
        newPlugin.command = testPluginCommandNotDefault

        // Create another plugin from this plugin
        let newPluginTwo = duplicateWithConfirmation(newPlugin)
        
        // Test Properties

        XCTAssertEqual(newPluginTwo.command!, newPlugin.command!, "The commands should be equal")
        XCTAssertNotEqual(pluginsManager.defaultNewPlugin!.command!, newPlugin.command!, "The commands should not be equal")
        
        // Trash the duplicated plugin
        let trashExpectation = expectation(description: "Move to trash")
        moveToTrashAndCleanUpWithConfirmation(newPlugin) {
            trashExpectation.fulfill()
        }
        let trashExpectationTwo = expectation(description: "Move to trash")
        moveToTrashAndCleanUpWithConfirmation(newPluginTwo) {
            trashExpectationTwo.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)

        // # Clean Up
        try! removeTemporaryItem(at: tempCopyTempDirectoryURL)
    }

    func testRenamePlugin() {
        let newPlugin = newPluginWithConfirmation()
        let newPluginName = pluginsManager.defaultNewPlugin!.identifier
        newPlugin.name = newPluginName
        XCTAssertNotNil(pluginsManager.plugin(withName: newPluginName), "The plugin should not be nil")
        XCTAssertNil(pluginsManager.plugin(withName: testPluginName), "The plugin should be nil")
    }

    func testBuiltInPlugins() {
        let plugins = pluginsManager.plugins
        var builtInPluginsTested = 0

        for plugin in plugins {
            let testPluginPath = builtInPluginsPath.appendingPathComponent(plugin.bundle.bundlePath.lastPathComponent)
            guard plugin.bundle.bundlePath == testPluginPath else {
                continue
            }
            XCTAssertEqual(plugin.pluginType, PluginType.builtIn)
            XCTAssertEqual(plugin.type, PluginType.builtIn.name())
            builtInPluginsTested += 1
        }

        XCTAssert(builtInPluginsTested > 0)

        var pluginsPathsCount = 0

        let contents = try! FileManager.default.contentsOfDirectory(atPath: builtInPluginsPath)
        let paths = contents
        let pluginFileExtensionMatch = ".\(testPluginExtension)"
        let pluginFileExtensionPredicate: NSPredicate! = NSPredicate(format: "self ENDSWITH %@", pluginFileExtensionMatch)
        let pluginPaths = paths.filter {
            pluginFileExtensionPredicate.evaluate(with: $0)
        }
        pluginsPathsCount += pluginPaths.count
        XCTAssert(builtInPluginsTested == pluginsPathsCount)
    }
}
