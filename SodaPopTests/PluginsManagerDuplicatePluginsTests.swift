//
//  PluginManagerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/6/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
@testable import SodaPop
import SodaPopTestHarness
import XCTest

class PluginsManagerDuplicatePluginsTests: ArrayControllerTestCase {
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
        XCTAssertNotEqual(pluginsManager.defaultNewPlugin!.command!, newPlugin.command!)

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
        do {
            try removeTemporaryItem(at: tempCopyTempDirectoryURL)
        } catch {
            XCTFail()
        }
    }

    func testRenamePlugin() {
        let newPlugin = newPluginWithConfirmation()
        let newPluginName = pluginsManager.defaultNewPlugin!.identifier
        let oldPluginName = newPlugin.name
        newPlugin.name = newPluginName
        XCTAssertNotNil(pluginsManager.plugin(withName: newPluginName))
        XCTAssertNil(pluginsManager.plugin(withName: oldPluginName))

        // # Clean Up
        do {
            try removeTemporaryItem(at: tempCopyTempDirectoryURL)
        } catch {
            XCTFail()
        }
    }

    func testBuiltInPlugins() {
        let plugins = pluginsManager.plugins
        var builtInPluginsTested = 0

        for plugin in plugins {
            let testPluginPath = builtInPluginsPath.appendingPathComponent(plugin.bundle.bundlePath.lastPathComponent)
            let resolvedTestPluginPath = (testPluginPath as NSString).resolvingSymlinksInPath
            let resolvedPluginPath = (plugin.bundle.bundlePath as NSString).resolvingSymlinksInPath
            guard resolvedPluginPath == resolvedTestPluginPath else {
                XCTAssertEqual(plugin.pluginType, .other)
                continue
            }
            XCTAssertEqual(plugin.pluginType, .builtIn)
            XCTAssertEqual(plugin.type, PluginKind.builtIn.name())
            builtInPluginsTested += 1
        }

        XCTAssert(builtInPluginsTested > 0)

        var pluginsPathsCount = 0

        let pluginFileExtensionMatch = ".\(testPluginExtension)"
        let pluginFileExtensionPredicate: NSPredicate! = NSPredicate(format: "self ENDSWITH %@",
                                                                     pluginFileExtensionMatch)
        do {
            let paths = try FileManager.default.contentsOfDirectory(atPath: builtInPluginsPath)
            let pluginPaths = paths.filter {
                pluginFileExtensionPredicate.evaluate(with: $0)
            }
            pluginsPathsCount += pluginPaths.count
            XCTAssert(builtInPluginsTested == pluginsPathsCount)
        } catch {
            XCTFail()
        }
    }

    func testUnwatchedSameURL() {
        guard let plugin = Plugin.makePlugin(url: testPluginOutsideURL) else {
            XCTFail()
            return
        }
        guard let pluginTwo = Plugin.makePlugin(url: testPluginOutsideURL) else {
            XCTFail()
            return
        }
        pluginsManager.addUnwatched(plugin)
        pluginsManager.addUnwatched(pluginTwo)
        XCTAssertNotNil(pluginsManager.plugin(withName: testPluginOutsideName))
        pluginsManager.removeUnwatched(pluginTwo)
        XCTAssertNil(pluginsManager.plugin(withName: testPluginOutsideName))
    }

    func testUnwatched() {
        guard let plugin = Plugin.makePlugin(url: testPluginOutsideURL) else {
            XCTFail()
            return
        }
        XCTAssertNil(pluginsManager.plugin(withName: testPluginOutsideName))
        pluginsManager.addUnwatched(plugin)
        XCTAssertNotNil(pluginsManager.plugin(withName: testPluginOutsideName))
        pluginsManager.removeUnwatched(plugin)
        XCTAssertNil(pluginsManager.plugin(withName: testPluginOutsideName))
        pluginsManager.addUnwatched(plugin)
        pluginsManager.addUnwatched(plugin)
        XCTAssertNotNil(pluginsManager.plugin(withName: testPluginOutsideName))
        pluginsManager.removeUnwatched(plugin)
        XCTAssertNil(pluginsManager.plugin(withName: testPluginOutsideName))
        pluginsManager.removeUnwatched(plugin)
    }
}
