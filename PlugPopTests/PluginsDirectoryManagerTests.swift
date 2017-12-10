//
//  PluginsDirectoryManagerPluginsTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 12/14/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

@testable import PlugPop
import OutOfTouch

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
    
    func movePluginWithConfirmation(atPluginPath tempPluginPath: String, destinationPluginPath: String) {
        let removeExpectation = expectation(description: "Info dictionary was removed")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasRemovedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path) == tempPluginPath) {
                removeExpectation.fulfill()
            }
        })
        
        let createExpectation = expectation(description: "Info dictionary was created")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path) == destinationPluginPath) {
                createExpectation.fulfill()
            }
        })
        
        OutOfTouch.moveItem(atPath: tempPluginPath,
                            toPath: destinationPluginPath,
                            handler: nil)
        
        // Wait for expectations
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func movePluginWithConfirmation(atPluginPath tempPluginPath: String, toUnwatchedDestinationPluginPath destinationPluginPath: String) {
        let removeExpectation = expectation(description: "Info dictionary was removed")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasRemovedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path) == tempPluginPath) {
                removeExpectation.fulfill()
            }
        })
        
        let moveExpectation = expectation(description: "Move finished")
        OutOfTouch.moveItem(atPath: tempPluginPath,
                            toPath: destinationPluginPath)
        { standardOutput, standardError, exitStatus in
            XCTAssertNil(standardOutput)
            XCTAssertNil(standardError)
            XCTAssert(exitStatus == 0)
            moveExpectation.fulfill()
        }
        
        // Wait for expectations
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    

    // MARK: Copy Helpers
    
    func copyPluginWithConfirmation(atPluginPath pluginPath: String, destinationPluginPath: String) {
        let createExpectation = expectation(description: "Info dictionary was created or modified")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path) == destinationPluginPath) {
                createExpectation.fulfill()
            }
        })

        let copyExpectation = expectation(description: "Copy finished")
        OutOfTouch.copyDirectory(atPath: pluginPath, toPath: destinationPluginPath)
        { standardOutput, standardError, exitStatus in
            XCTAssertNil(standardOutput)
            XCTAssertNil(standardError)
            XCTAssert(exitStatus == 0)
            copyExpectation.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    func copyPlugin(atPluginPath pluginPath: String, toPluginPath destinationPluginPath: String) {
        let copyExpectation = expectation(description: "Copy finished")
        OutOfTouch.copyDirectory(atPath: pluginPath,
                                 toPath: destinationPluginPath)
        { standardOutput, standardError, exitStatus in
            XCTAssertNil(standardOutput)
            XCTAssertNil(standardError)
            XCTAssert(exitStatus == 0)
            copyExpectation.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    

    // MARK: Remove Helpers
    
    func removePluginWithConfirmation(atPluginPath pluginPath: String) {
        let removeExpectation = expectation(description: "Info dictionary was removed")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasRemovedAtPluginPathHandler: { (path) -> Void in
            self.pluginsDirectoryManager.delegate = nil // Ignore subsequent remove events
            if (type(of: self).resolve(temporaryDirectoryPath: path) == pluginPath) {
                removeExpectation.fulfill()
            }
        })

        let deleteExpectation = expectation(description: "Delete finished")
        OutOfTouch.removeDirectory(atPath: pluginPath)
        { standardOutput, standardError, exitStatus in
            XCTAssertNil(standardOutput)
            XCTAssertNil(standardError)
            XCTAssert(exitStatus == 0)
            deleteExpectation.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
}

class PluginsDirectoryManagerTests: TemporaryPluginsTestCase {
    var pluginsDirectoryManager: PluginsDirectoryManager!
    var pluginsDirectoryEventManager: PluginsDirectoryEventManager!
    var pluginInfoDictionaryPath: String!
    
    override func setUp() {
        super.setUp()
        pluginsDirectoryManager = PluginsDirectoryManager(pluginsDirectoryURL: tempPluginsDirectoryURL)
        pluginsDirectoryEventManager = PluginsDirectoryEventManager()
        pluginsDirectoryManager.delegate = pluginsDirectoryEventManager
        pluginInfoDictionaryPath = Plugin.urlForInfoDictionary(forPluginAt: tempPluginURL).path
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
        let movedPluginFilename = testPluginDirectoryNoPluginName
        let movedPluginPath = tempPluginPath.deletingLastPathComponent.appendingPathComponent(movedPluginFilename)
        movePluginWithConfirmation(atPluginPath: tempPluginPath, destinationPluginPath: movedPluginPath)
        
        // Clean up
        // Copy the plugin back to it's original path so the tearDown delete of the temporary plugin succeeds
        movePluginWithConfirmation(atPluginPath: movedPluginPath, destinationPluginPath: tempPluginPath)
    }
    
    func testCopyAndRemovePlugin() {
        let copiedPluginFilename = testPluginDirectoryNoPluginName
        let copiedPluginPath = tempPluginPath.deletingLastPathComponent.appendingPathComponent(copiedPluginFilename)
        copyPluginWithConfirmation(atPluginPath: tempPluginPath, destinationPluginPath: copiedPluginPath)
        
        // Clean up
        removePluginWithConfirmation(atPluginPath: copiedPluginPath)
    }

    func testCopyToUnwatchedDirectory() {
        let pluginFilename = tempPluginPath.lastPathComponent
        let copiedPluginPath = temporaryDirectoryPath.appendingPathComponent(pluginFilename)
        copyPlugin(atPluginPath: tempPluginPath, toPluginPath: copiedPluginPath)
        
        do {
            try removeTemporaryItem(atPath: copiedPluginPath)
        } catch {
            XCTAssertTrue(false, "The remove should suceed")
        }
    }
    
    func testCopyFromUnwatchedDirectory() {
        // Move the plugin to unwatched directory
        let pluginFilename = tempPluginPath.lastPathComponent
        let movedPluginPath = temporaryDirectoryPath.appendingPathComponent(pluginFilename)
        movePluginWithConfirmation(atPluginPath: tempPluginPath, toUnwatchedDestinationPluginPath: movedPluginPath)

        // Copy back to original location
        copyPluginWithConfirmation(atPluginPath: movedPluginPath, destinationPluginPath: tempPluginPath)

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
            if (type(of: self).resolve(temporaryDirectoryPath: path) == self.tempPluginPath) {
                expectation.fulfill()
            }
        })
        OutOfTouch.moveItem(atPath: pluginInfoDictionaryPath,
                            toPath: renamedInfoDictionaryPath,
                            handler: nil)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        
        // Move back
        let expectationTwo = self.expectation(description: "Info dictionary was created or modified")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path) == self.tempPluginPath) {
                expectationTwo.fulfill()
            }
        })
        OutOfTouch.moveItem(atPath: renamedInfoDictionaryPath,
                            toPath: pluginInfoDictionaryPath,
                            handler: nil)
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
            if (type(of: self).resolve(temporaryDirectoryPath: path) == self.tempPluginPath) {
                expectation.fulfill()
            }
        })
        OutOfTouch.removeFile(atPath: pluginInfoDictionaryPath,
                              handler: nil)
        waitForExpectations(timeout: defaultTimeout, handler: nil)

        // Add back the info dictionary
        let expectationTwo = self.expectation(description: "Info dictionary was created or modified")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path) == self.tempPluginPath) {
                expectationTwo.fulfill()
            }
        })
        OutOfTouch.writeToFile(atPath: pluginInfoDictionaryPath,
                               contents: infoDictionaryContents,
                               handler: nil)
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
            if (type(of: self).resolve(temporaryDirectoryPath: path) == self.tempPluginPath) {
                expectation.fulfill()
            }
        })
        OutOfTouch.writeToFile(atPath: pluginInfoDictionaryPath,
                               contents: testFileContents,
                               handler: nil)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
        
        // Remove the info dictionary
        let expectationTwo = self.expectation(description: "Info dictionary was created or modified")
        pluginsDirectoryEventManager.add(pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler: { (path) -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: path) == self.tempPluginPath) {
                expectationTwo.fulfill()
            }
        })
        OutOfTouch.writeToFile(atPath: pluginInfoDictionaryPath,
                               contents: infoDictionaryContents,
                               handler: nil)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
}
