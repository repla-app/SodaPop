//
//  PluginsDataControllerFileSystemTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/11/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
@testable import SodaPop
import XCTest

class PluginsDataControllerFileSystemTests: TemporaryPluginsDataControllerEventTestCase {
    // MARK: File System Tests

    func testAddAndDeletePlugin() {
        var newPlugin: Plugin!
        let copyExpectation = expectation(description: "Copy")
        copyWithConfirmation(plugin,
                             destinationPluginPath: userPluginsPath) { (copiedPlugin) -> Void in
            newPlugin = copiedPlugin
            copyExpectation.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        XCTAssertNotNil(newPlugin, "The plugin should not be nil")

        XCTAssertTrue(pluginsManager.pluginsDataController.plugins.contains(newPlugin))
        removeWithConfirmation(newPlugin)
        XCTAssertFalse(pluginsManager.pluginsDataController.plugins.contains(newPlugin))
    }

    func testMovePlugin() {
        let pluginPath = plugin.resourcePath.deletingLastPathComponent.deletingLastPathComponent

        let destinationPluginFilename = DuplicatePluginController.pluginFilename(fromName: plugin.identifier)
        let destinationPluginPath = pluginPath.deletingLastPathComponent
            .appendingPathComponent(destinationPluginFilename)

        // Move the plugin
        var newPlugin: Plugin!
        moveWithConfirmation(plugin, destinationPluginPath: destinationPluginPath, handler: { (plugin) -> Void in
            newPlugin = plugin
        })
        XCTAssertNotNil(newPlugin, "The plugin should not be nil")
        XCTAssertFalse(pluginsManager.pluginsDataController.plugins.contains(plugin))
        XCTAssertTrue(pluginsManager.pluginsDataController.plugins.contains(newPlugin))

        // Move the plugin back
        var newPluginTwo: Plugin!
        moveWithConfirmation(newPlugin, destinationPluginPath: pluginPath, handler: { (movedPlugin) -> Void in
            newPluginTwo = movedPlugin
        })
        XCTAssertNotNil(newPluginTwo, "The plugin should not be nil")
        XCTAssertFalse(pluginsManager.pluginsDataController.plugins.contains(newPlugin))
        XCTAssertTrue(pluginsManager.pluginsDataController.plugins.contains(newPluginTwo))
    }

    func testEditPlugin() {
        var newPlugin: Plugin!
        modifyWithConfirmation(plugin, handler: { (modifiedPlugin) -> Void in
            newPlugin = modifiedPlugin
        })
        XCTAssertNotNil(newPlugin, "The plugin should not be nil")
        XCTAssertFalse(pluginsManager.pluginsDataController.plugins.contains(plugin))
        XCTAssertTrue(pluginsManager.pluginsDataController.plugins.contains(newPlugin))
    }

    // TODO: Test plugins made invalid are not loaded?
}
