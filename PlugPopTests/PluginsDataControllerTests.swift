//
//  PluginManagerTests.swift
//  PluginManagerTests
//
//  Created by Roben Kleene on 9/15/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

@testable import Web_Console

class PluginsDataControllerClassTests: XCTestCase {
    
    func testPluginPaths() {
        let pluginsPath = Bundle.main.builtInPlugInsPath!
        let pluginPaths = PluginsDataController.pathsForPlugins(atPath: pluginsPath)

        // Test plugin path counts
        do {
            let directoryContents = try FileManager.default.contentsOfDirectory(atPath: pluginsPath)
            let testPluginPaths = directoryContents.filter { ($0 as NSString).pathExtension == kPlugInExtension }
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
        let pluginsDataController = PluginsDataController(paths: testPluginsPaths, duplicatePluginDestinationDirectoryURL: Directory.trash.URL())
        let plugins = pluginsDataController.plugins()
        
        var pluginPaths = [String]()
        for pluginsPath in testPluginsPaths {
            let paths = PluginsDataController.pathsForPlugins(atPath: pluginsPath)
            pluginPaths += paths
        }
        
        XCTAssert(!plugins.isEmpty, "The plugins should not be empty")
        XCTAssert(plugins.count == pluginPaths.count, "The plugins count should match the plugin paths count")
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

    var duplicatePluginRootDirectoryURL: URL {
        return temporaryDirectoryURL
                .appendingPathComponent(testApplicationSupportDirectoryName)
    }
    
    override var duplicatePluginDestinationDirectoryURL: URL {
        return duplicatePluginRootDirectoryURL
            .appendingPathComponent(applicationName)
            .appendingPathComponent(pluginsDirectoryPathComponent)
    }

    func cleanUpDuplicatedPlugins() {
        do {
            try removeTemporaryItem(at: duplicatePluginRootDirectoryURL)
        } catch {
            XCTAssertTrue(false, "The remove should succeed")
        }        
    }
    
    func testDuplicateAndTrashPlugin() {
        XCTAssertEqual(PluginsManager.sharedInstance.pluginsDataController.plugins().count, 1, "The plugins count should be one")
        
        var newPlugin: Plugin!
        
        let addedExpectation = expectation(description: "Plugin was added")
        pluginDataEventManager.add(pluginWasAddedHandler: { (addedPlugin) -> Void in
            addedExpectation.fulfill()
        })

        let duplicateExpectation = expectation(description: "Plugin was duplicated")
        PluginsManager.sharedInstance.pluginsDataController.duplicate(plugin, handler: { (duplicatePlugin, error) -> Void in
            XCTAssertNil(error, "The error should be nil")
            newPlugin = duplicatePlugin
            duplicateExpectation.fulfill()
        })

        waitForExpectations(timeout: defaultTimeout, handler: nil)

        XCTAssertEqual(PluginsManager.sharedInstance.pluginsDataController.plugins().count, 2, "The plugins count should be two")
        XCTAssertTrue(PluginsManager.sharedInstance.pluginsDataController.plugins().contains(newPlugin!), "The plugins should contain the plugin")
        
        // Trash the duplicated plugin
        let removeExpectation = expectation(description: "Plugin was removed")
        pluginDataEventManager.add(pluginWasRemovedHandler: { (removedPlugin) -> Void in
            XCTAssertEqual(newPlugin!, removedPlugin, "The plugins should be equal")
            removeExpectation.fulfill()
        })

        moveToTrashAndCleanUpWithConfirmation(newPlugin!)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        cleanUpDuplicatedPlugins()
    }

    func testDuplicatePluginWithBlockingFile() {
        let createSuccess = FileManager.default.createFile(atPath: duplicatePluginRootDirectoryURL.path,
            contents: nil,
            attributes: nil)
        XCTAssertTrue(createSuccess, "Creating the file should succeed.")
        
        let duplicateExpectation = expectation(description: "Plugin was duplicated")
        PluginsManager.sharedInstance.pluginsDataController.duplicate(plugin, handler: { (duplicatePlugin, error) -> Void in
            XCTAssertNil(duplicatePlugin, "The duplicate plugin should be nil")
            XCTAssertNotNil(error, "The error should not be nil")
            duplicateExpectation.fulfill()
        })
        
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        cleanUpDuplicatedPlugins()
    }

    func testDuplicatePluginWithEarlyBlockingFile() {
        do {
            try PluginsDataController.createDirectoryIfMissing(at: duplicatePluginRootDirectoryURL.deletingLastPathComponent())

        } catch {
            XCTAssertTrue(false, "Creating the directory should succeed")
        }

        // Block the destination directory with a file
        let createSuccess = FileManager.default.createFile(atPath: duplicatePluginRootDirectoryURL.path,
            contents: nil,
            attributes: nil)
        XCTAssertTrue(createSuccess, "Creating the file should succeed.")
        
        let duplicateExpectation = expectation(description: "Plugin was duplicated")
        PluginsManager.sharedInstance.pluginsDataController.duplicate(plugin, handler: { (duplicatePlugin, error) -> Void in
            XCTAssertNil(duplicatePlugin, "The duplicate plugin should be nil")
            XCTAssertNotNil(error, "The error should not be nil")
            duplicateExpectation.fulfill()
        })
        
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        cleanUpDuplicatedPlugins()
    }

}
