//
//  PluginsDirectoryManagerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/8/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation
import XCTest

@testable import Web_Console

protocol FilesAndPluginsDirectoryManagerFileDelegate {
    func testPluginsDirectoryManager(_ filesAndPluginsDirectoryManager: FilesAndPluginsDirectoryManager, fileWasCreatedOrModifiedAtPath path: String)
    func testPluginsDirectoryManager(_ filesAndPluginsDirectoryManager: FilesAndPluginsDirectoryManager, directoryWasCreatedOrModifiedAtPath path: String)
    func testPluginsDirectoryManager(_ filesAndPluginsDirectoryManager: FilesAndPluginsDirectoryManager, itemWasRemovedAtPath path: String)
}

class FilesAndPluginsDirectoryManager: PluginsDirectoryManager {
    var fileDelegate: FilesAndPluginsDirectoryManagerFileDelegate?
    
    override func directoryWatcher(_ directoryWatcher: WCLDirectoryWatcher, directoryWasCreatedOrModifiedAtPath path: String) {
        fileDelegate?.testPluginsDirectoryManager(self, directoryWasCreatedOrModifiedAtPath: path)
        super.directoryWatcher(directoryWatcher, directoryWasCreatedOrModifiedAtPath: path)
    }
    
    override func directoryWatcher(_ directoryWatcher: WCLDirectoryWatcher, fileWasCreatedOrModifiedAtPath path: String) {
        fileDelegate?.testPluginsDirectoryManager(self, fileWasCreatedOrModifiedAtPath: path)
        super.directoryWatcher(directoryWatcher, fileWasCreatedOrModifiedAtPath: path)
    }
    
    override func directoryWatcher(_ directoryWatcher: WCLDirectoryWatcher, itemWasRemovedAtPath path: String) {
        fileDelegate?.testPluginsDirectoryManager(self, itemWasRemovedAtPath: path)
        super.directoryWatcher(directoryWatcher, itemWasRemovedAtPath: path)
    }
}

class FilesAndPluginsDirectoryEventManager: PluginsDirectoryEventManager, FilesAndPluginsDirectoryManagerFileDelegate {
    var fileWasCreatedOrModifiedAtPathHandlers: Array<(_ path: String) -> Void>
    var directoryWasCreatedOrModifiedAtPathHandlers: Array<(_ path: String) -> Void>
    var itemWasRemovedAtPathHandlers: Array<(_ path: String) -> Void>

    override init() {
        self.fileWasCreatedOrModifiedAtPathHandlers = Array<(_ path: String) -> Void>()
        self.directoryWasCreatedOrModifiedAtPathHandlers = Array<(_ path: String) -> Void>()
        self.itemWasRemovedAtPathHandlers = Array<(_ path: String) -> Void>()
        super.init()
    }

    func testPluginsDirectoryManager(_ filesAndPluginsDirectoryManager: FilesAndPluginsDirectoryManager, fileWasCreatedOrModifiedAtPath path: String) {
        assert(fileWasCreatedOrModifiedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (fileWasCreatedOrModifiedAtPathHandlers.count > 0) {
            let handler = fileWasCreatedOrModifiedAtPathHandlers.remove(at: 0)
            handler(path)
        }
    }
    
    func testPluginsDirectoryManager(_ filesAndPluginsDirectoryManager: FilesAndPluginsDirectoryManager, directoryWasCreatedOrModifiedAtPath path: String) {
        assert(directoryWasCreatedOrModifiedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (directoryWasCreatedOrModifiedAtPathHandlers.count > 0) {
            let handler = directoryWasCreatedOrModifiedAtPathHandlers.remove(at: 0)
            handler(path)
        }
    }
    
    func testPluginsDirectoryManager(_ filesAndPluginsDirectoryManager: FilesAndPluginsDirectoryManager, itemWasRemovedAtPath path: String) {
        assert(itemWasRemovedAtPathHandlers.count > 0, "There should be at least one handler")
        
        if (itemWasRemovedAtPathHandlers.count > 0) {
            let handler = itemWasRemovedAtPathHandlers.remove(at: 0)
            handler(path)
        }
    }


    func add(fileWasCreatedOrModifiedAtPathHandler handler: @escaping (_ path: String) -> Void) {
        fileWasCreatedOrModifiedAtPathHandlers.append(handler)
    }
    
    func add(directoryWasCreatedOrModifiedAtPathHandler handler: @escaping (_ path: String) -> Void) {
        directoryWasCreatedOrModifiedAtPathHandlers.append(handler)
    }
    
    func add(itemWasRemovedAtPathHandler handler: @escaping (_ path: String) -> Void) {
        itemWasRemovedAtPathHandlers.append(handler)
    }
}

extension FilesAndPluginsDirectoryManagerTests {

    // MARK: Expectation Helpers
    
    func createPluginInfoDictionaryWasRemovedExpectation(forPluginPath path: String) {
        let pluginInfoDictionaryWasRemovedExpectation = expectation(description: "Plugin info dictionary was removed")
        fileAndPluginsDirectoryEventManager.add(pluginInfoDictionaryWasRemovedAtPluginPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == path) {
                pluginInfoDictionaryWasRemovedExpectation.fulfill()
            }
        })
    }
    
    func createPluginInfoDictionaryWasCreatedOrModifiedExpectation(forPluginPath path: String) {
        let pluginInfoDictionaryWasCreatedOrModifiedExpectation = expectation(description: "Plugin info dictionary was created or modified")
        fileAndPluginsDirectoryEventManager.add(pluginInfoDictionaryWasCreatedOrModifiedAtPluginPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == path) {
                pluginInfoDictionaryWasCreatedOrModifiedExpectation.fulfill()
            }
        })
    }
    
    
    // MARK: Create With Confirmation Helpers
    
    func createFileWithConfirmation(atPath path: String) {
        let fileWasCreatedOrModifiedExpectation = expectation(description: "File was created")
        fileAndPluginsDirectoryEventManager.add(fileWasCreatedOrModifiedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == path) {
                fileWasCreatedOrModifiedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.createFile(atPath: path)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    
    func createDirectoryWithConfirmation(atPath path: String) {
        let directoryWasCreatedOrModifiedExpectation = expectation(description: "Directory was created")
        fileAndPluginsDirectoryEventManager.add(directoryWasCreatedOrModifiedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == path) {
                directoryWasCreatedOrModifiedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.createDirectory(atPath: path)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    
    
    // MARK: Remove With Confirmation Helpers
    
    func removeFileWithConfirmation(atPath path: String) {
        let fileWasRemovedExpectation = expectation(description: "File was removed")
        fileAndPluginsDirectoryEventManager.add(itemWasRemovedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == path) {
                fileWasRemovedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.removeFile(atPath: path)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    
    func removeDirectoryWithConfirmation(atPath path: String) {
        let directoryWasRemovedExpectation = expectation(description: "Directory was removed")
        fileAndPluginsDirectoryEventManager.add(itemWasRemovedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == path) {
                directoryWasRemovedExpectation.fulfill()
            }
        })
        SubprocessFileSystemModifier.removeDirectory(atPath: path)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
    
    
    // MARK: Move With Confirmation Helpers
    
    func moveDirectoryWithConfirmation(atPath path: String, destinationPath: String) {
        // Remove original
        let directoryWasRemovedExpectation = expectation(description: "Directory was removed with move")
        fileAndPluginsDirectoryEventManager.add(itemWasRemovedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == path) {
                directoryWasRemovedExpectation.fulfill()
            }
        })
        // Create new
        let directoryWasCreatedExpectation = expectation(description: "Directory was created with move")
        fileAndPluginsDirectoryEventManager.add(directoryWasCreatedOrModifiedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == destinationPath) {
                directoryWasCreatedExpectation.fulfill()
            }
        })
        // Move
        SubprocessFileSystemModifier.moveItem(atPath: path, toPath: destinationPath)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func moveDirectoryWithConfirmation(atUnwatchedPath path: String, destinationPath: String) {
        // Create new
        let directoryWasCreatedExpectation = expectation(description: "Directory was created with move")
        fileAndPluginsDirectoryEventManager.add(directoryWasCreatedOrModifiedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == destinationPath) {
                directoryWasCreatedExpectation.fulfill()
            }
        })
        // Move
        let moveExpectation = expectation(description: "Move finished")
        SubprocessFileSystemModifier.moveItem(atPath: path, toPath: destinationPath, handler: {
            moveExpectation.fulfill()
        })
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    func moveDirectoryWithConfirmation(atPath path: String, toUnwatchedDestinationPath destinationPath: String) {
        // Remove original
        let directoryWasRemovedExpectation = expectation(description: "Directory was removed with move")
        fileAndPluginsDirectoryEventManager.add(itemWasRemovedAtPathHandler: { returnedPath -> Void in
            if (type(of: self).resolve(temporaryDirectoryPath: returnedPath as NSString) == path) {
                directoryWasRemovedExpectation.fulfill()
            }
        })
        // Move
        let moveExpectation = expectation(description: "Move finished")
        SubprocessFileSystemModifier.moveItem(atPath: path, toPath: destinationPath, handler: {
            moveExpectation.fulfill()
        })
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }


    // MARK: Plugin File Hierarchy Helpers

    func createDirectory(atPath path: String) {
        do {
            try FileManager.default
                .createDirectory(atPath: path,
                    withIntermediateDirectories: false,
                    attributes: nil)
        } catch let error as NSError {
            XCTAssertTrue(false, "Creating the directory should succeed. \(error)")
        }
    }
    
    func createFile(atPath path: String) {
        let success = FileManager.default.createFile(atPath: path,
            contents: nil,
            attributes: nil)
        XCTAssertTrue(success, "Creating the file should succeed.")
    }
    
    func createValidPluginHierarchy(atPath path: String) {
        performValidPluginHierarchyOperation(atPath: path, isRemove: false, requireConfirmation: false)
    }

    func createValidPluginHierarchyWithConfirmation(atPath path: String) {
        performValidPluginHierarchyOperation(atPath: path, isRemove: false, requireConfirmation: true)
    }
    
    func removeValidPluginHierarchy(atPath path: String) {
        performValidPluginHierarchyOperation(atPath: path, isRemove: true, requireConfirmation: false)
    }

    func removeValidPluginHierarchyWithConfirmation(atPath path: String) {
        performValidPluginHierarchyOperation(atPath: path, isRemove: true, requireConfirmation: true)
    }

    
    func performValidPluginHierarchyOperation(atPath path: String, isRemove: Bool, requireConfirmation: Bool) {
        let testPluginDirectoryPath = path.appendingPathComponent(testPluginDirectoryName)
        let testPluginContentsDirectoryPath = testPluginDirectoryPath.appendingPathComponent(testPluginContentsDirectoryName)
        let testPluginResourcesDirectoryPath = testPluginContentsDirectoryPath.appendingPathComponent(testPluginResourcesDirectoryName)
        let testPluginResourcesFilePath = testPluginResourcesDirectoryPath.appendingPathComponent(testFilename)
        let testPluginContentsFilePath = testPluginContentsDirectoryPath.appendingPathComponent(testFilename)
        let testInfoDictionaryFilePath = testPluginContentsDirectoryPath.appendingPathComponent(testPluginInfoDictionaryFilename)

        if !isRemove {
            if !requireConfirmation {
                createDirectory(atPath: testPluginDirectoryPath)
                createDirectory(atPath: testPluginContentsDirectoryPath)
                createDirectory(atPath: testPluginResourcesDirectoryPath)
                createFile(atPath: testPluginResourcesFilePath)
                createFile(atPath: testPluginContentsFilePath)
                createFile(atPath: testInfoDictionaryFilePath)
            } else {
                createDirectoryWithConfirmation(atPath: testPluginDirectoryPath)
                createDirectoryWithConfirmation(atPath: testPluginContentsDirectoryPath)
                createDirectoryWithConfirmation(atPath: testPluginResourcesDirectoryPath)
                createFileWithConfirmation(atPath: testPluginResourcesFilePath)
                createFileWithConfirmation(atPath: testPluginContentsFilePath)
                createPluginInfoDictionaryWasCreatedOrModifiedExpectation(forPluginPath: testPluginDirectoryPath)
                createFileWithConfirmation(atPath: testInfoDictionaryFilePath)
            }
        } else {
            if !requireConfirmation {
                let testPluginDirectoryPath = path.appendingPathComponent(testPluginDirectoryName)
                do {
                    try removeTemporaryItem(atPath: testPluginDirectoryPath)
                } catch let error as NSError {
                    XCTAssertTrue(false, "Removing the directory should succeed. \(error)")
                }
            } else {
                createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testPluginDirectoryPath)
                removeFileWithConfirmation(atPath: testInfoDictionaryFilePath)

                removeFileWithConfirmation(atPath: testPluginResourcesFilePath)
                removeDirectoryWithConfirmation(atPath: testPluginResourcesDirectoryPath)
                removeFileWithConfirmation(atPath: testPluginContentsFilePath)

                createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testPluginDirectoryPath)
                removeDirectoryWithConfirmation(atPath: testPluginContentsDirectoryPath)
                
                createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testPluginDirectoryPath)
                removeDirectoryWithConfirmation(atPath: testPluginDirectoryPath)
            }
        }
    }
}


class FilesAndPluginsDirectoryManagerTests: TemporaryPluginsTestCase {
    var fileAndPluginsDirectoryManager: FilesAndPluginsDirectoryManager!
    var fileAndPluginsDirectoryEventManager: FilesAndPluginsDirectoryEventManager!

    // MARK: setUp & tearDown

    override func setUp() {
        super.setUp()
        fileAndPluginsDirectoryManager = FilesAndPluginsDirectoryManager(pluginsDirectoryURL: pluginsDirectoryURL)
        fileAndPluginsDirectoryEventManager = FilesAndPluginsDirectoryEventManager()
        fileAndPluginsDirectoryManager.delegate = fileAndPluginsDirectoryEventManager
        fileAndPluginsDirectoryManager.fileDelegate = fileAndPluginsDirectoryEventManager
    }
    
    override func tearDown() {
        fileAndPluginsDirectoryManager.fileDelegate = nil
        fileAndPluginsDirectoryManager.delegate = nil
        fileAndPluginsDirectoryEventManager = nil
        fileAndPluginsDirectoryManager = nil // Make sure this happens after setting its delegate to nil
        super.tearDown()
    }
    
    func testValidPluginFileHierarchy() {

        // Create a directory in the plugins directory, this should not cause a callback
        let testPluginDirectoryPath = pluginsDirectoryPath.appendingPathComponent(testPluginDirectoryName)
        createDirectoryWithConfirmation(atPath: testPluginDirectoryPath)
        
        // Create a file in the plugins directory, this should not cause a callback
        let testFilePath = pluginsDirectoryPath.appendingPathComponent(testFilename)
        createFileWithConfirmation(atPath: testFilePath)
        
        // Create the contents directory, this should not cause a callback
        let testPluginContentsDirectoryPath = testPluginDirectoryPath.appendingPathComponent(testPluginContentsDirectoryName)
        createDirectoryWithConfirmation(atPath: testPluginContentsDirectoryPath)
        
        // Create a file in the contents directory, this should not cause a callback
        let testPluginContentsFilePath = testPluginContentsDirectoryPath.appendingPathComponent(testFilename)
        createFileWithConfirmation(atPath: testPluginContentsFilePath)
        
        // Create the resource directory, this should not cause a callback
        let testPluginResourcesDirectoryPath = testPluginContentsDirectoryPath.appendingPathComponent(testPluginResourcesDirectoryName)
        createDirectoryWithConfirmation(atPath: testPluginResourcesDirectoryPath)
        
        // Create a file in the resource directory, this should not cause a callback
        let testPluginResourcesFilePath = testPluginResourcesDirectoryPath.appendingPathComponent(testFilename)
        createFileWithConfirmation(atPath: testPluginResourcesFilePath)

        // Create an info dictionary in the contents directory, this should cause a callback
        let testInfoDictionaryFilePath = testPluginContentsDirectoryPath.appendingPathComponent(testPluginInfoDictionaryFilename)
        createPluginInfoDictionaryWasCreatedOrModifiedExpectation(forPluginPath: testPluginDirectoryPath)
        createFileWithConfirmation(atPath: testInfoDictionaryFilePath)
        
        // Clean up
        
        // Remove the info dictionary in the contents directory, this should cause a callback
        createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testPluginDirectoryPath)
        removeFileWithConfirmation(atPath: testInfoDictionaryFilePath)

        // Remove the file in the resource directory, this should not cause a callback
        removeFileWithConfirmation(atPath: testPluginResourcesFilePath)

        // Remove the resource directory, this should not cause a callback
        removeDirectoryWithConfirmation(atPath: testPluginResourcesDirectoryPath)
        
        // Remove the file in the contents directory, this should not cause a callback
        removeFileWithConfirmation(atPath: testPluginContentsFilePath)

        // Remove the contents directory, this should cause a callback
        // because this could be the delete after move of a valid plugin's contents directory
        createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testPluginDirectoryPath)
        removeDirectoryWithConfirmation(atPath: testPluginContentsDirectoryPath)
        
        // Remove the file in the plugins directory, this should not cause a callback
        // because the file doesn't have the plugin file extension
        removeFileWithConfirmation(atPath: testFilePath)
        
        // Remove the directory in the plugins directory, this should cause a callback
        // because this could be the delete after move of a valid plugin
        createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testPluginDirectoryPath)
        removeDirectoryWithConfirmation(atPath: testPluginDirectoryPath)
    }

    func testInvalidPluginFileHierarchy() {
        // Create an invalid contents directory in the plugins path, this should not cause a callback
        let testInvalidPluginContentsDirectoryPath = pluginsDirectoryPath.appendingPathComponent(testPluginDirectoryName)
        createDirectoryWithConfirmation(atPath: testInvalidPluginContentsDirectoryPath)

        // Create a info dictionary in the invalid contents directory, this should not cause a callback
        let testInvalidInfoDictionaryPath = testInvalidPluginContentsDirectoryPath.appendingPathComponent(testPluginInfoDictionaryFilename)
        createFileWithConfirmation(atPath: testInvalidInfoDictionaryPath)
        

        // Clean up
        
        // Remove the info dictionary in the invalid contents directory, this should not cause a callback
        removeFileWithConfirmation(atPath: testInvalidInfoDictionaryPath)
        
        // Remove the invalid contents directory in the plugins path, this should cause a callback
        // because this could be the delete after move of a valid plugin
        createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testInvalidPluginContentsDirectoryPath)
        removeDirectoryWithConfirmation(atPath: testInvalidPluginContentsDirectoryPath)
    }

    func testFileForContentsDirectory() {
        // Create a directory in the plugins directory, this should not cause a callback
        let testPluginDirectoryPath = pluginsDirectoryPath.appendingPathComponent(testPluginDirectoryName)
        createDirectoryWithConfirmation(atPath: testPluginDirectoryPath)

        // Create the contents directory, this should not cause a callback
        let testPluginContentsFilePath = testPluginDirectoryPath.appendingPathComponent(testPluginContentsDirectoryName)
        createFileWithConfirmation(atPath: testPluginContentsFilePath)


        // Clean up
        
        // Remove the contents directory, this should cause a callback
        // because this could be the delete after move of a valid plugin's contents directory
        createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testPluginDirectoryPath)
        removeFileWithConfirmation(atPath: testPluginContentsFilePath)
    
        // Remove the directory in the plugins directory, this should cause a callback
        // because this could be the delete after move of a valid plugin
        createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testPluginDirectoryPath)
        removeDirectoryWithConfirmation(atPath: testPluginDirectoryPath)
    }

    func testDirectoryForInfoDictionary() {
        // Create a directory in the plugins directory, this should not cause a callback
        let testPluginDirectoryPath = pluginsDirectoryPath.appendingPathComponent(testPluginDirectoryName)
        createDirectoryWithConfirmation(atPath: testPluginDirectoryPath)
        
        // Create the contents directory, this should not cause a callback
        let testPluginContentsDirectoryPath = testPluginDirectoryPath.appendingPathComponent(testPluginContentsDirectoryName)
        createDirectoryWithConfirmation(atPath: testPluginContentsDirectoryPath)
        
        // Create a directory for the info dictionary, this should not cause a callback
        let testPluginInfoDictionaryDirectoryPath = testPluginContentsDirectoryPath.appendingPathComponent(testPluginInfoDictionaryFilename)
        createDirectoryWithConfirmation(atPath: testPluginInfoDictionaryDirectoryPath)
        
        // Clean up

        // Create a directory for the info dictionary, this should cause a callback
        createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testPluginDirectoryPath)
        removeDirectoryWithConfirmation(atPath: testPluginInfoDictionaryDirectoryPath)
        
        // Remove the contents directory, this should cause a callback
        // because this could be the delete after move of a valid plugin's contents directory
        createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testPluginDirectoryPath)
        removeDirectoryWithConfirmation(atPath: testPluginContentsDirectoryPath)
        
        // Remove the directory in the plugins directory, this should cause a callback
        // because this could be the delete after move of a valid plugin
        createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testPluginDirectoryPath)
        removeDirectoryWithConfirmation(atPath: testPluginDirectoryPath)
    }

    func testMoveResourcesDirectory() {
        createValidPluginHierarchyWithConfirmation(atPath: pluginsDirectoryPath)

        let testPluginDirectoryPath = pluginsDirectoryPath.appendingPathComponent(testPluginDirectoryName)
        let testPluginContentsDirectoryPath = testPluginDirectoryPath.appendingPathComponent(testPluginContentsDirectoryName)
        let testPluginResourcesDirectoryPath = testPluginContentsDirectoryPath.appendingPathComponent(testPluginResourcesDirectoryName)
        let testRenamedPluginResourcesDirectoryPath = testPluginContentsDirectoryPath.appendingPathComponent(testDirectoryName)
        moveDirectoryWithConfirmation(atPath: testPluginResourcesDirectoryPath, destinationPath: testRenamedPluginResourcesDirectoryPath)

        // Clean up
        moveDirectoryWithConfirmation(atPath: testRenamedPluginResourcesDirectoryPath, destinationPath: testPluginResourcesDirectoryPath)

        removeValidPluginHierarchyWithConfirmation(atPath: pluginsDirectoryPath)
    }

    func testMoveContentsDirectory() {
        createValidPluginHierarchyWithConfirmation(atPath: pluginsDirectoryPath)

        let testPluginDirectoryPath = pluginsDirectoryPath.appendingPathComponent(testPluginDirectoryName)
        let testPluginContentsDirectoryPath = testPluginDirectoryPath.appendingPathComponent(testPluginContentsDirectoryName)
        let testRenamedPluginContentsDirectoryPath = testPluginDirectoryPath.appendingPathComponent(testDirectoryName)
        createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testPluginDirectoryPath)
        moveDirectoryWithConfirmation(atPath: testPluginContentsDirectoryPath, destinationPath: testRenamedPluginContentsDirectoryPath)
        
        // Clean up
        createPluginInfoDictionaryWasCreatedOrModifiedExpectation(forPluginPath: testPluginDirectoryPath)
        moveDirectoryWithConfirmation(atPath: testRenamedPluginContentsDirectoryPath, destinationPath: testPluginContentsDirectoryPath)

        removeValidPluginHierarchyWithConfirmation(atPath: pluginsDirectoryPath)
    }

    func testMovePluginDirectory() {
        createValidPluginHierarchyWithConfirmation(atPath: pluginsDirectoryPath)

        let testPluginDirectoryPath = pluginsDirectoryPath.appendingPathComponent(testPluginDirectoryName)
        let testRenamedPluginDirectoryPath = pluginsDirectoryPath.appendingPathComponent(testPluginDirectoryNameTwo)
        createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testPluginDirectoryPath)
        createPluginInfoDictionaryWasCreatedOrModifiedExpectation(forPluginPath: testRenamedPluginDirectoryPath)
        moveDirectoryWithConfirmation(atPath: testPluginDirectoryPath, destinationPath: testRenamedPluginDirectoryPath)
        
        // Clean up
        createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testRenamedPluginDirectoryPath)
        createPluginInfoDictionaryWasCreatedOrModifiedExpectation(forPluginPath: testPluginDirectoryPath)
        moveDirectoryWithConfirmation(atPath: testRenamedPluginDirectoryPath, destinationPath: testPluginDirectoryPath)

        removeValidPluginHierarchyWithConfirmation(atPath: pluginsDirectoryPath)
    }

    func testMovePluginFromAndToUnwatchedDirectory() {
        createValidPluginHierarchy(atPath: temporaryDirectoryPath)
        
        // Move from unwatched directory
        let testPluginDirectoryPath = temporaryDirectoryPath.appendingPathComponent(testPluginDirectoryName)
        let testMovedPluginDirectoryPath = pluginsDirectoryPath.appendingPathComponent(testPluginDirectoryName)
        createPluginInfoDictionaryWasCreatedOrModifiedExpectation(forPluginPath: testMovedPluginDirectoryPath)
        moveDirectoryWithConfirmation(atUnwatchedPath: testPluginDirectoryPath, destinationPath: testMovedPluginDirectoryPath)

        // Move to unwatched directory
        createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testMovedPluginDirectoryPath)
        moveDirectoryWithConfirmation(atPath: testMovedPluginDirectoryPath, toUnwatchedDestinationPath: testPluginDirectoryPath)

        // Clean up
        removeValidPluginHierarchy(atPath: temporaryDirectoryPath)
    }

    func testFileExtensionAsName() {
        createValidPluginHierarchyWithConfirmation(atPath: pluginsDirectoryPath)
        
        // Create a file named with just the file extension
        let testFilePath = pluginsDirectoryPath.appendingPathComponent(pluginFileExtension)
        createFileWithConfirmation(atPath: testFilePath)
        removeFileWithConfirmation(atPath: testFilePath)

        // Clean up
        removeValidPluginHierarchyWithConfirmation(atPath: pluginsDirectoryPath)
    }

    func testOnlyFileExtension() {
        createValidPluginHierarchyWithConfirmation(atPath: pluginsDirectoryPath)
        
        // Create a file named with just the file extension
        let testFilePath = pluginsDirectoryPath.appendingPathComponent(".\(pluginFileExtension)")
        createFileWithConfirmation(atPath: testFilePath)
        removeFileWithConfirmation(atPath: testFilePath)
        
        // Clean up
        removeValidPluginHierarchyWithConfirmation(atPath: pluginsDirectoryPath)
    }

    
    func testHiddenFile() {
        createValidPluginHierarchyWithConfirmation(atPath: pluginsDirectoryPath)
        
        // Create a hidden file
        let testFilePath = pluginsDirectoryPath.appendingPathComponent(testHiddenDirectoryName)
        createFileWithConfirmation(atPath: testFilePath)
        removeFileWithConfirmation(atPath: testFilePath)

        // Clean up
        removeValidPluginHierarchyWithConfirmation(atPath: pluginsDirectoryPath)
    }

    func testHiddenFileInPluginDirectory() {
        createValidPluginHierarchyWithConfirmation(atPath: pluginsDirectoryPath)
        // Create a hidden file
        let testPluginDirectoryPath = pluginsDirectoryPath.appendingPathComponent(testPluginDirectoryName)
        let testFilePath = testPluginDirectoryPath.appendingPathComponent(testHiddenDirectoryName)
        createFileWithConfirmation(atPath: testFilePath)
        removeFileWithConfirmation(atPath: testFilePath)

        // Clean up
        removeValidPluginHierarchyWithConfirmation(atPath: pluginsDirectoryPath)
    }

    func testRemoveAndAddPluginFileExtension() {
        createValidPluginHierarchyWithConfirmation(atPath: pluginsDirectoryPath)

        // Move the directory, removing the plugin extension, this should cause a callback
        let testPluginDirectoryPath = pluginsDirectoryPath.appendingPathComponent(testPluginDirectoryName)
        let movedPluginDirectoryFilename = testPluginDirectoryName.deletingPathExtension
        let movedPluginDirectoryPath = pluginsDirectoryPath.appendingPathComponent(movedPluginDirectoryFilename)
        createPluginInfoDictionaryWasRemovedExpectation(forPluginPath: testPluginDirectoryPath)
        moveDirectoryWithConfirmation(atPath: testPluginDirectoryPath, destinationPath: movedPluginDirectoryPath)

        // Move the directory back, re-adding the file extension, this should cause a callback
        createPluginInfoDictionaryWasCreatedOrModifiedExpectation(forPluginPath: testPluginDirectoryPath)
        moveDirectoryWithConfirmation(atPath: movedPluginDirectoryPath, destinationPath: testPluginDirectoryPath)

        // Clean up
        removeValidPluginHierarchyWithConfirmation(atPath: pluginsDirectoryPath)
    }
}
