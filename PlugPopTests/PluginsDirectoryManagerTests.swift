//
//  PluginsDirectoryManagerPluginsTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 12/14/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

@testable import Web_Console

class PluginsDirectoryEventManager: PluginsDirectoryManagerDelegate {
    var pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers: Array<(_ path: String) -> Void>
    var pluginInfoDictionaryWasRemovedAtPluginPathHandlers: Array<(_ path: String) -> Void>
    
    
    init () {
        self.pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers = Array<(_ path: String) -> Void>()
        self.pluginInfoDictionaryWasRemovedAtPluginPathHandlers = Array<(_ path: String) -> Void>()
    }
    

    // MARK: PluginsDirectoryManagerDelegate
    
    func pluginsDirectoryManager(_ pluginsDirectoryManager: PluginsDirectoryManager, pluginInfoDictionaryWasCreatedOrModifiedAtPluginPath pluginPath: String) {
        assert(pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers.count > 0, "There should be at least one handler")
        
        if (pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers.count > 0) {
            let handler = pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers.remove(at: 0)
            handler(pluginPath)
        }
    }
    
    func pluginsDirectoryManager(_ pluginsDirectoryManager: PluginsDirectoryManager, pluginInfoDictionaryWasRemovedAtPluginPath pluginPath: String) {
        assert(pluginInfoDictionaryWasRemovedAtPluginPathHandlers.count > 0, "There should be at least one handler")
        
        if (pluginInfoDictionaryWasRemovedAtPluginPathHandlers.count > 0) {
            let handler = pluginInfoDictionaryWasRemovedAtPluginPathHandlers.remove(at: 0)
            handler(pluginPath)
        }
    }

    
    // MARK: Handlers
    
    func add(pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler handler: @escaping (_ path: String) -> Void) {
        pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandlers.append(handler)
    }
    
    func add(pluginInfoDictionaryWasRemovedAtPluginPathHandler handler: @escaping (_ path: String) -> Void) {
        pluginInfoDictionaryWasRemovedAtPluginPathHandlers.append(handler)
    }
    
}

extension PluginsDirectoryManagerTests {
    
    // MARK: Move Helpers
    
    func movePluginWithConfirmation(atPluginPath pluginPath: String, destinationPluginPath: String) {
        let removeExpectation = expectation(description: "Info dictionary was removed")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasRemovedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path as NSString) == pluginPath) {
                removeExpectation.fulfill()
            }
        })
        
        let createExpectation = expectation(description: "Info dictionary was created")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path as NSString) == destinationPluginPath) {
                createExpectation.fulfill()
            }
        })
        
        SubprocessFileSystemModifier.moveItem(atPath: pluginPath, toPath: destinationPluginPath)
        
        // Wait for expectations
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func movePluginWithConfirmation(atPluginPath pluginPath: String, toUnwatchedDestinationPluginPath destinationPluginPath: String) {
        let removeExpectation = expectation(description: "Info dictionary was removed")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasRemovedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path as NSString) == pluginPath) {
                removeExpectation.fulfill()
            }
        })
        
        let moveExpectation = expectation(description: "Move finished")
        SubprocessFileSystemModifier.moveItem(atPath: pluginPath, toPath: destinationPluginPath, handler: {
            moveExpectation.fulfill()
        })
        
        // Wait for expectations
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    

    // MARK: Copy Helpers
    
    func copyPluginWithConfirmation(atPluginPath pluginPath: String, destinationPluginPath: String) {
        let createExpectation = expectation(description: "Info dictionary was created or modified")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path as NSString) == destinationPluginPath) {
                createExpectation.fulfill()
            }
        })

        let copyExpectation = expectation(description: "Copy finished")
        SubprocessFileSystemModifier.copyDirectory(atPath: pluginPath, toPath: destinationPluginPath, handler: {
            copyExpectation.fulfill()
        })
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    func copyPlugin(atPluginPath pluginPath: String, toPluginPath destinationPluginPath: String) {
        let copyExpectation = expectation(description: "Copy finished")
        SubprocessFileSystemModifier.copyDirectory(atPath: pluginPath, toPath: destinationPluginPath, handler: {
            copyExpectation.fulfill()
        })
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    

    // MARK: Remove Helpers
    
    func removePluginWithConfirmation(atPluginPath pluginPath: String) {
        let removeExpectation = expectation(description: "Info dictionary was removed")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasRemovedAtPluginPathHandler: { (path) -> Void in
            self.pluginsDirectoryManager.delegate = nil // Ignore subsequent remove events
            if (type(of: self).resolve(temporaryDirectoryPath: path as NSString) == pluginPath) {
                removeExpectation.fulfill()
            }
        })

        let deleteExpectation = expectation(description: "Delete finished")
        SubprocessFileSystemModifier.removeDirectory(atPath: pluginPath, handler: {
            deleteExpectation.fulfill()
        })
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
}

class PluginsDirectoryManagerTests: TemporaryPluginsTestCase {
    var pluginsDirectoryManager: PluginsDirectoryManager!
    var pluginsDirectoryEventManager: PluginsDirectoryEventManager!
    var pluginInfoDictionaryPath: String!
    
    override func setUp() {
        super.setUp()
        pluginsDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: pluginsDirectoryURL)
        pluginsDirectoryEventManager = PluginsDirectoryEventManager()
        pluginsDirectoryManager.delegate = pluginsDirectoryEventManager
        pluginInfoDictionaryPath = Plugin.urlForInfoDictionary(forPluginAt: pluginURL).path
    }
    
    override func tearDown() {
        pluginsDirectoryManager.delegate = nil
        pluginsDirectoryEventManager = nil
        pluginsDirectoryManager = nil // Make sure this happens after setting its delegate to nil
        pluginInfoDictionaryPath = nil
        super.tearDown()
    }
    
    // MARK: Plugin Directory Tests
    
    func testMovePlugin() {
        // Move the plugin
        let movedPluginFilename = testPluginDirectoryName
        let movedPluginPath = pluginPath.deletingLastPathComponent.appendingPathComponent(movedPluginFilename)
        movePluginWithConfirmation(atPluginPath: pluginPath, destinationPluginPath: movedPluginPath)
        
        // Clean up
        // Copy the plugin back to it's original path so the tearDown delete of the temporary plugin succeeds
        movePluginWithConfirmation(atPluginPath: movedPluginPath, destinationPluginPath: pluginPath)
    }
    
    func testCopyAndRemovePlugin() {
        let copiedPluginFilename = testPluginDirectoryName
        let copiedPluginPath = pluginPath.deletingLastPathComponent.appendingPathComponent(copiedPluginFilename)
        copyPluginWithConfirmation(atPluginPath: pluginPath, destinationPluginPath: copiedPluginPath)
        
        // Clean up
        removePluginWithConfirmation(atPluginPath: copiedPluginPath)
    }

    func testCopyToUnwatchedDirectory() {
        let pluginFilename = pluginPath.lastPathComponent
        let copiedPluginPath = temporaryDirectoryPath.appendingPathComponent(pluginFilename)
        copyPlugin(atPluginPath: pluginPath, toPluginPath: copiedPluginPath)
        
        do {
            try removeTemporaryItem(atPath: copiedPluginPath)
        } catch {
            XCTAssertTrue(false, "The remove should suceed")
        }
    }
    
    func testCopyFromUnwatchedDirectory() {
        // Move the plugin to unwatched directory
        let pluginFilename = pluginPath.lastPathComponent
        let movedPluginPath = temporaryDirectoryPath.appendingPathComponent(pluginFilename)
        movePluginWithConfirmation(atPluginPath: pluginPath, toUnwatchedDestinationPluginPath: movedPluginPath)

        // Copy back to original location
        copyPluginWithConfirmation(atPluginPath: movedPluginPath, destinationPluginPath: pluginPath)

        // Cleanup
        do {
            try removeTemporaryItem(atPath: movedPluginPath)
        } catch {
            XCTAssertTrue(false, "The remove should suceed")
        }
    }
    
    
    // MARK: Info Dictionary Tests
    
    func testMoveInfoDictionary() {

        let infoDictionaryDirectory: String! = pluginInfoDictionaryPath.deletingLastPathComponent
        let renamedInfoDictionaryFilename = testDirectoryName
        let renamedInfoDictionaryPath = infoDictionaryDirectory.appendingPathComponent(renamedInfoDictionaryFilename)
        
        // Move
        let expectation = self.expectation(description: "Info dictionary was removed")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasRemovedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path as NSString) == self.pluginPath) {
                expectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.moveItem(atPath: pluginInfoDictionaryPath, toPath: renamedInfoDictionaryPath)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        
        // Move back
        let expectationTwo = self.expectation(description: "Info dictionary was created or modified")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path as NSString) == self.pluginPath) {
                expectationTwo.fulfill()
            }
        })
        SubprocessFileSystemModifier.moveItem(atPath: renamedInfoDictionaryPath, toPath: pluginInfoDictionaryPath)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    
    func testRemoveAndAddInfoDictionary() {
        // Read in the contents of the info dictionary

        var infoDictionaryContents: String!
        do {
            infoDictionaryContents = try String(contentsOfFile: pluginInfoDictionaryPath, encoding: String.Encoding.utf8)
        } catch {
            XCTAssertTrue(false, "Getting the info dictionary contents should succeed")
        }
        
        // Remove the info dictionary
        let expectation = self.expectation(description: "Info dictionary was removed")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasRemovedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path as NSString) == self.pluginPath) {
                expectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.removeFile(atPath: pluginInfoDictionaryPath)
        waitForExpectations(timeout: defaultTimeout, handler: nil)

        // Add back the info dictionary
        let expectationTwo = self.expectation(description: "Info dictionary was created or modified")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path as NSString) == self.pluginPath) {
                expectationTwo.fulfill()
            }
        })
        SubprocessFileSystemModifier.writeToFile(atPath: pluginInfoDictionaryPath, contents: infoDictionaryContents)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func testModifyInfoDictionary() {
        // Read in the contents of the info dictionary
        var infoDictionaryContents: String!
        do {
            infoDictionaryContents = try String(contentsOfFile: pluginInfoDictionaryPath, encoding: String.Encoding.utf8)
        } catch {
            XCTAssertTrue(false, "Getting the info dictionary contents should succeed")
        }

    
        
        // Remove the info dictionary
        let expectation = self.expectation(description: "Info dictionary was created or modified")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path as NSString) == self.pluginPath) {
                expectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.writeToFile(atPath: pluginInfoDictionaryPath, contents: testFileContents)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        
        // Remove the info dictionary
        let expectationTwo = self.expectation(description: "Info dictionary was created or modified")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path as NSString) == self.pluginPath) {
                expectationTwo.fulfill()
            }
        })
        SubprocessFileSystemModifier.writeToFile(atPath: pluginInfoDictionaryPath, contents: infoDictionaryContents)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
}
