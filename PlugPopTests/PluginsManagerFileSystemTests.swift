//
//  PluginManagerFileSystemTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/11/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
@testable import PlugPop
import PlugPopTestHarness
import XCTest

class PluginsManagerFileSystemTests: TemporaryPluginsDataControllerEventTestCase {
    func plugins() -> NSArray {
        return pluginsManager.plugins as NSArray
    }

    // MARK: File System Tests

    func testAddAndDeletePlugin() {
        let startingPluginsCount = pluginsManager.plugins.count
        var newPlugin: Plugin!
        let copyExpectation = expectation(description: "Copy")
        copyWithConfirmation(plugin,
                             destinationPluginPath: userPluginsPath) { plugin in
            newPlugin = plugin
            copyExpectation.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        XCTAssertNotNil(newPlugin)

        XCTAssertTrue(plugins().contains(newPlugin!))
        XCTAssertEqual(pluginsManager.plugin(withName: plugin.name)!, newPlugin)
        XCTAssertEqual(pluginsManager.plugins.count, startingPluginsCount, "The plugins count should match the `startingPluginsCount`, because the `newPlugin` has the same name as an existing plugin, so it should have replaced that plugin.")

        // # Clean Up

        // Remove the `newPlugin`
        removeWithConfirmation(newPlugin)
        XCTAssertFalse(plugins().contains(newPlugin))
        XCTAssertEqual(pluginsManager.plugins.count, startingPluginsCount - 1, "Interesting here is that the plugin manager has no plugins loaded, even though the original plugin is still there. This is because when multiple plugins are loaded with the same name, only the most recent plugin with the name is loaded. So the count is `- 1` from the `startingPluginsCount` even though the original plugin is still there.")

        // Test that the original plugin can be reloaded by modifying it
        var originalPlugin: Plugin!
        modifyWithConfirmation(plugin) { (plugin) -> Void in
            originalPlugin = plugin
        }
        XCTAssertNotNil(originalPlugin, "The plugin should not be nil")
        XCTAssertTrue(plugins().contains(originalPlugin), "The plugins should contain the plugin")
        XCTAssertEqual(pluginsManager.plugin(withName: plugin.name)!, originalPlugin, "The plugins should be equal")
        XCTAssertEqual(pluginsManager.plugins.count, startingPluginsCount)
    }

    func testMovePlugin() {
        let startingPluginsCount = pluginsManager.plugins.count

        // # Move One
        // Move the plugin to a filename based on its identifier

        let pluginPath = plugin.bundle.bundlePath
        let destinationPluginFilename = DuplicatePluginController.pluginFilename(fromName: plugin.identifier)
        let pluginParentDirectory = pluginPath.deletingLastPathComponent
        let destinationPluginPath = pluginParentDirectory.appendingPathComponent(destinationPluginFilename)
        var newPlugin: Plugin!

        moveWithConfirmation(plugin, destinationPluginPath: destinationPluginPath, handler: { (plugin) -> Void in
            newPlugin = plugin
        })
        XCTAssertNotNil(newPlugin, "The plugin should not be nil")
        XCTAssertTrue(plugins().contains(newPlugin), "The plugins should contain the plugin")
        XCTAssertEqual(pluginsManager.plugin(withName: testPluginName)!, newPlugin, "The plugins should be equal")
        XCTAssertEqual(pluginsManager.plugins.count, startingPluginsCount)

        // Move the plugin back
        var originalPlugin: Plugin!
        moveWithConfirmation(newPlugin, destinationPluginPath: pluginPath, handler: { (plugin) -> Void in
            originalPlugin = plugin
        })
        XCTAssertNotNil(originalPlugin, "The plugin should not be nil")
        XCTAssertTrue(plugins().contains(originalPlugin), "The plugins should contain the plugin")
        XCTAssertEqual(pluginsManager.plugin(withName: testPluginName)!, originalPlugin, "The plugins should be equal")
        XCTAssertEqual(pluginsManager.plugins.count, startingPluginsCount, "The plugins count should be one")
    }

    func testEditPlugin() {
        // Move the plugin
        var newPlugin: Plugin!
        modifyWithConfirmation(plugin) { (plugin) -> Void in
            newPlugin = plugin
        }
        XCTAssertNotNil(newPlugin, "The plugin should not be nil")
        XCTAssertFalse(plugins().contains(plugin), "The plugins should not contain the plugin")
        XCTAssertTrue(plugins().contains(newPlugin), "The plugins should contain the plugin")
    }

    // TODO: Test making the plugin info dictionary invalid removes it
    // TODO: Test that touching the plugin info dictionary does not cause it to reload (because the resulting plugin will still be equal) No way to test this now since there aren't any callbacks to wait for here
}
