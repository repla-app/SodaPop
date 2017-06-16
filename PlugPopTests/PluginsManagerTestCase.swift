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

extension UserDefaults: DefaultsType { }

class PluginsManagerTestCase: TemporaryPluginsTestCase, CachesTestCase, DefaultsTestCase {
    var plugin: Plugin!
    var pluginsManager: PluginsManager!
    var pluginsDirectoryPaths: [String] {
        return [builtInPluginsPath, sharedTestResourcesPluginsPath]
    }
    var sharedTestResourcesPluginsPath: String {
        let sharedTestResourcesPluginURL = PotionTaster.urlForPlugin(withName: PotionTaster.testPluginNameSharedTestResources)!
        return sharedTestResourcesPluginURL
            .appendingPathComponent(pluginResourcesPathComponent)
            .appendingPathComponent(sharedTestResourcesPluginDirectory)
            .path
    }
    var builtInPluginsPath: String {
        return PotionTaster.pluginsDirectoryPath
    }
    lazy var defaults: DefaultsType = {
        UserDefaults(suiteName: testMockUserDefaultsSuiteName)!
    }()

    override func setUp() {
        super.setUp()

        // Create the plugin manager
        pluginsManager = PluginsManager(paths: pluginsDirectoryPaths,
                                        duplicatePluginDestinationDirectoryURL: duplicatePluginDestinationDirectoryURL,
                                        copyTempDirectoryURL: cachesURL,
                                        defaults: defaults,
                                        builtInPluginsPath: builtInPluginsPath,
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
        super.tearDown()
    }

    var duplicatePluginDestinationDirectoryURL: URL {
        return pluginsDirectoryURL
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
