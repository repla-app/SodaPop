//
//  PluginManagerTests.swift
//  PluginManagerTests
//
//  Created by Roben Kleene on 9/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

@testable import PlugPop
import XCTestTemp

class PluginsDataControllerClassTests: PluginsManagerDependenciesTestCase {

    func testPluginPaths() {
        let pluginPaths = PluginsDataController.pathsForPlugins(atPath: builtInPluginsPath)

        // Test plugin path counts
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(atPath: builtInPluginsPath)
            let testPluginPaths = directoryContents.filter { ($0 as NSString).pathExtension == pluginFileExtension }
            XCTAssert(!testPluginPaths.isEmpty, "The test plugin paths count should be greater than zero")
            XCTAssert(testPluginPaths.count == pluginPaths.count, "The plugin paths count should equal the test plugin paths count")
        } catch {
            XCTAssertTrue(false, "Getting the contents should succeed")
        }
        
        // Test plugins can be created from all paths
        var plugins = [Plugin]()
        for pluginPath in pluginPaths {
            if let plugin = Plugin.makePlugin(path: pluginPath) {
                plugins.append(plugin)
            } else {
                XCTAssert(false, "The plugin should exist")
            }
        }

        let testPluginsCount = PluginsDataController.plugins(atPluginPaths: pluginPaths).count
        XCTAssert(plugins.count == testPluginsCount, "The plugins count should equal the test plugins count")
    }

    func testExistingPlugins() {
        let pluginsDataController = PluginsDataController(pluginsPaths: pluginsDirectoryPaths,
                                                          copyTempDirectoryURL: tempCopyTempDirectoryURL,
                                                          defaultNewPluginManager: WCLDefaultNewPluginManager(defaults: defaults),
                                                          userPluginsPath: userPluginsPath,
                                                          builtInPluginsPath: builtInPluginsPath)
        let plugins = pluginsDataController.plugins
        
        var pluginPaths = [String]()
        for pluginsPath in pluginsDirectoryPaths {
            let paths = PluginsDataController.pathsForPlugins(atPath: pluginsPath)
            pluginPaths += paths
        }
        
        XCTAssert(!plugins.isEmpty, "The plugins should not be empty")
        XCTAssert(plugins.count == pluginPaths.count, "The plugins count should match the plugin paths count")

        // # Clean Up

        // Creating a `PluginsDataController` implicitly creates the
        // `userPluginsPath` (which starts from "Application Support").
        try! removeTemporaryItem(at: temporaryApplicationSupportDirectoryURL)
    }

}

extension TemporaryDirectoryTestCase {
    // MARK: Helpers
    
    func createFileWithConfirmation(at URL: Foundation.URL, withContents: String) {
        let path = URL.path
        let createSuccess = FileManager.default.createFile(atPath: path,
            contents: testFileContents.data(using: String.Encoding.utf8),
            attributes: nil)
        XCTAssertTrue(createSuccess, "Creating the file should succeed.")
    }
    
    func contentsOfFileWithConfirmation(at URL: Foundation.URL) throws -> String {
        do {
            let contents = try String(contentsOf: URL,
                encoding: String.Encoding.utf8)
            return contents
        } catch let error as NSError {
            throw error
        }
    }
    
    func confirmFileExists(at URL: Foundation.URL) {
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: URL.path, isDirectory: &isDir)
        XCTAssertTrue(exists, "The file should exist")
        XCTAssertTrue(!isDir.boolValue, "The file should not be a directory")
    }
}

class PluginsDataControllerTemporaryDirectoryTests: TemporaryDirectoryTestCase {
    
    func testCreateDirectoryIfMissing() {
        let directoryURL = temporaryDirectoryURL
            .appendingPathComponent(testDirectoryName)
            .appendingPathComponent(testDirectoryNameTwo)

        do {
            try PluginsDataController.createDirectoryIfMissing(at: directoryURL)
        } catch {
            XCTAssert(false, "Creating the directory should succeed")
        }
        
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: directoryURL.path, isDirectory: &isDir)
        XCTAssertTrue(exists, "The file should exist")
        XCTAssertTrue(isDir.boolValue, "The file should be a directory")
        
        // Clean Up
        let rootDirectoryURL: URL = directoryURL.deletingLastPathComponent()
        do {
            try removeTemporaryItem(at: rootDirectoryURL)
        } catch {
            XCTAssertTrue(false, "The remove should succeed")
        }
    }
    
    func testCreateDirectoryWithPathBlocked() {
        let directoryURL = temporaryDirectoryURL
            .appendingPathComponent(testDirectoryName)

        // Create the blocking file
        createFileWithConfirmation(at: directoryURL, withContents: testFileContents)
        
        // Attempt
        var error: NSError?
        do {
            try PluginsDataController.createDirectoryIfMissing(at: directoryURL)
        } catch let createError as NSError {
            error = createError
        }
        XCTAssertNotNil(error, "The error should not be nil")
        
        // Confirm the File Still Exists
        confirmFileExists(at: directoryURL)
        
        // Confirm the Contents

        do {
            let contents = try contentsOfFileWithConfirmation(at: directoryURL)
            XCTAssertEqual(testFileContents, contents, "The contents should be equal")
        } catch {
            XCTAssertTrue(false, "Getting the contents should succeed")
        }
        
        // Clean Up
        do {
            try removeTemporaryItem(at: directoryURL)
        } catch {
            XCTAssertTrue(false, "The remove should succeed")
        }
    }

    func testCreateDirectoryWithFirstPathComponentBlocked() {
        let directoryURL = temporaryDirectoryURL
            .appendingPathComponent(testDirectoryName)
            .appendingPathComponent(testDirectoryNameTwo)
        let blockingFileURL = directoryURL.deletingLastPathComponent()
        
        // Create the blocking file
        createFileWithConfirmation(at: blockingFileURL, withContents: testFileContents)
        
        // Attempt
        var didThrow = false
        do {
            try PluginsDataController.createDirectoryIfMissing(at: directoryURL)
        } catch {
            didThrow = true
        }
        XCTAssertTrue(didThrow, "The error should have been thrown")
        
        // Confirm the File Still Exists
        confirmFileExists(at: blockingFileURL)
        
        // Confirm the Contents
        do {
            let contents = try contentsOfFileWithConfirmation(at: blockingFileURL)
            XCTAssertEqual(testFileContents, contents, "The contents should be equal")
        } catch {
            XCTAssertTrue(false, "Getting the contents should succeed")
        }

        // Clean Up
        do {
            try removeTemporaryItem(at: blockingFileURL)
        } catch {
            XCTAssertTrue(false, "The remove should succeed")
        }
    }

    func testCreateDirectoryWithSecondPathComponentBlocked() {
        let directoryURL = temporaryDirectoryURL
            .appendingPathComponent(testDirectoryName)
            .appendingPathComponent(testDirectoryNameTwo)
        
        // Create the first path so creating the blocking file doesn't fail
        let containerDirectoryURL = directoryURL.deletingLastPathComponent()
        do {
            try PluginsDataController.createDirectoryIfMissing(at: containerDirectoryURL)
        } catch {
            XCTAssertTrue(false, "Creating the directory should succeed")
        }
        
        // Create the blocking file
        createFileWithConfirmation(at: directoryURL, withContents: testFileContents)
        
        // Attempt
        var didThrow = false
        do {
            try PluginsDataController.createDirectoryIfMissing(at: directoryURL)
        } catch {
            didThrow = true
        }
        XCTAssertTrue(didThrow, "The error should have been thrown")
        
        // Confirm the File Still Exists
        confirmFileExists(at: directoryURL)
        
        // Confirm the Contents
        do {
            let contents = try contentsOfFileWithConfirmation(at: directoryURL)
            XCTAssertEqual(testFileContents, contents, "The contents should be equal")
        } catch {
            XCTAssertTrue(false, "Getting the contents should succeed")
        }
        
        // Clean Up
        do {
            try removeTemporaryItem(at: containerDirectoryURL)
        } catch {
            XCTAssertTrue(false, "The remove should succeed")
        }

    }

}

class PluginsDataControllerTests: PluginsDataControllerEventTestCase {
    
    func cleanUpDuplicatedPlugins() {
        do {
            try removeTemporaryItem(at: temporaryUserPluginsDirectoryURL)
        } catch {
            XCTAssertTrue(false, "The remove should succeed")
        }        
    }
    
    func testDuplicateAndTrashPlugin() {
        let startingPluginsCount = pluginsManager.plugins.count

        var newPlugin: Plugin!
        
        let addedExpectation = expectation(description: "Plugin was added")
        pluginDataEventManager.add(pluginWasAddedHandler: { (addedPlugin) -> Void in
            addedExpectation.fulfill()
        })

        let duplicateExpectation = expectation(description: "Plugin was duplicated")
        pluginsManager.pluginsDataController.duplicate(plugin, handler: { (duplicatePlugin, error) -> Void in
            XCTAssertNil(error, "The error should be nil")
            newPlugin = duplicatePlugin
            duplicateExpectation.fulfill()
        })

        waitForExpectations(timeout: defaultTimeout, handler: nil)

        XCTAssertEqual(pluginsManager.pluginsDataController.plugins.count, startingPluginsCount + 1, "The plugins count should be two")
        XCTAssertTrue(pluginsManager.pluginsDataController.plugins.contains(newPlugin!), "The plugins should contain the plugin")
        
        // Trash the duplicated plugin
        let removeExpectation = expectation(description: "Plugin was removed")
        pluginDataEventManager.add(pluginWasRemovedHandler: { (removedPlugin) -> Void in
            XCTAssertEqual(newPlugin!, removedPlugin, "The plugins should be equal")
            removeExpectation.fulfill()
        })

        let trashExpectation = expectation(description: "Move to trash")
        moveToTrashAndCleanUpWithConfirmation(newPlugin!) {
            trashExpectation.fulfill()
        }

        waitForExpectations(timeout: defaultTimeout, handler: nil)
        cleanUpDuplicatedPlugins()

        // # Clean Up

        let duplicatePluginURL = temporaryDirectoryURL.appendingPathComponent(testCopyTempDirectoryName)
        try! removeTemporaryItem(at: duplicatePluginURL)
    }

    func testDuplicatePluginWithBlockingFile() {
        let createSuccess = FileManager.default.createFile(atPath: temporaryUserPluginsDirectoryPath,
            contents: nil,
            attributes: nil)
        XCTAssertTrue(createSuccess, "Creating the file should succeed.")
        
        let duplicateExpectation = expectation(description: "Plugin was duplicated")
        pluginsManager.pluginsDataController.duplicate(plugin, handler: { (duplicatePlugin, error) -> Void in
            XCTAssertNil(duplicatePlugin, "The duplicate plugin should be nil")
            XCTAssertNotNil(error, "The error should not be nil")
            duplicateExpectation.fulfill()
        })
        
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        cleanUpDuplicatedPlugins()
    }

    // This tests that an error is generated if the entire
    // `temporaryUserPluginsDirectoryURL` is blocked.
    // TODO: This test test that if the `temporaryUserPluginsDirectoryURL`
    // (e.g., the "Application Support" directory) is blocked by a file, that
    // an error is returned. But we don't current support that configuration
    // in the app (the app will fail during this case). Long term, an
    // alternative solution will be found and this test should be re-enabled at
    // that time.
    func testDuplicatePluginWithEarlyBlockingFile() {
        // This snippet should disable this test, while indicating it can be
        // re-enabled when the `temporaryUserPluginsDirectoryURL` is no longer
        // automatically created by the `PluginsDataController`
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: temporaryUserPluginsDirectoryURL.path,
                                                    isDirectory: &isDir)
        XCTAssertTrue(exists)
        guard !exists else {
            return
        }

        // # Real Tests Follow

        try! PluginsDataController.createDirectoryIfMissing(at: temporaryUserPluginsDirectoryURL.deletingLastPathComponent())

        // Block the destination directory with a file
        let createSuccess = FileManager.default.createFile(atPath: temporaryUserPluginsDirectoryPath,
            contents: nil,
            attributes: nil)
        XCTAssertTrue(createSuccess, "Creating the file should succeed.")

        let duplicateExpectation = expectation(description: "Plugin was duplicated")
        pluginsManager.pluginsDataController.duplicate(plugin, handler: { (duplicatePlugin, error) -> Void in
            XCTAssertNil(duplicatePlugin, "The duplicate plugin should be nil")
            XCTAssertNotNil(error, "The error should not be nil")
            duplicateExpectation.fulfill()
        })

        waitForExpectations(timeout: defaultTimeout, handler: nil)
        cleanUpDuplicatedPlugins()
    }

}
