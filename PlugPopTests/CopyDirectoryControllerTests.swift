//
//  CopyDirectoryControllerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/4/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

@testable import PlugPop
import XCTestTemp

class CopyDirectoryControllerTests: TemporaryPluginsTestCase, TempCopyTempURLType {
    var copyDirectoryController: CopyDirectoryController!

    enum ClassConstants {
        static let tempDirectoryName = "Copy Directory Test"
    }
    
    override func setUp() {
        super.setUp()
        copyDirectoryController = CopyDirectoryController(tempDirectoryURL: tempCopyTempDirectoryURL,
                                                          tempDirectoryName: ClassConstants.tempDirectoryName)
        let cleanUpExpectation = expectation(description: "Cleanup")
        copyDirectoryController.cleanUp() { error in
            XCTAssertNil(error)
            cleanUpExpectation.fulfill()
        }
    }
    
    override func tearDown() {
        copyDirectoryController = nil
        super.tearDown()
    }

    // MARK: Helper

    func cleanUpCopyDirectoryControllerDirectoriesWithConfirmation() {
        let tempURL = tempCopyTempDirectoryURL.appendingPathComponent(ClassConstants.tempDirectoryName)
        // The order of these is important the inner URL must be deleted first.
        let directoryURLs = [tempURL, tempCopyTempDirectoryURL]
        for directoryURL in directoryURLs {
            var isDir: ObjCBool = false
            let exists = FileManager.default.fileExists(atPath: directoryURL.path,
                                                        isDirectory: &isDir)
            XCTAssertTrue(exists, "The item should exist")
            XCTAssertTrue(isDir.boolValue, "The item should be a directory")
            try! removeTemporaryItem(at: directoryURL)
        }
    }

    // MARK: Tests

    func testCopy() {
        let copyExpectation = expectation(description: "Copy")
        
        var copiedPluginURL: URL!
        copyDirectoryController.copyItem(at: tempPluginURL, completionHandler: { (URL, error) -> Void in
            XCTAssertNotNil(URL, "The URL should not be nil")
            XCTAssertNil(error, "The error should be nil")
            
            if let URL = URL {
                let movedFilename = testDirectoryName
                let movedDestinationURL = self.tempPluginsDirectoryURL.appendingPathComponent(movedFilename)

                do {
                    try FileManager.default.moveItem(at: URL,
                                                     to: movedDestinationURL)
                } catch {
                    XCTAssertTrue(false, "The move should succeed")
                }

                copiedPluginURL = movedDestinationURL
                copyExpectation.fulfill()
            }
        })
        waitForExpectations(timeout: defaultTimeout, handler: nil)

        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: copiedPluginURL.path,
                                                    isDirectory: &isDir)
        XCTAssertTrue(exists, "The item should exist")
        XCTAssertTrue(isDir.boolValue, "The item should be a directory")

        let pluginInfoDictionaryURL = Plugin.urlForInfoDictionary(forPluginAt: tempPluginURL)
        let copiedPluginInfoDictionaryURL = Plugin.urlForInfoDictionary(forPluginAt: copiedPluginURL)
        
        do {
            let pluginInfoDictionaryContents: String! = try String(contentsOf: pluginInfoDictionaryURL,
                                                                   encoding: String.Encoding.utf8)
            let copiedPluginInfoDictionaryContents: String! = try String(contentsOf: copiedPluginInfoDictionaryURL,
                                                                         encoding: String.Encoding.utf8)
            XCTAssertEqual(copiedPluginInfoDictionaryContents, pluginInfoDictionaryContents, "The contents should be equal")
        } catch {
            XCTAssertTrue(false, "Getting the info dictionary contents should succeed")
        }
        
        // Cleanup
        do {
            try removeTemporaryItem(at: copiedPluginURL)
        } catch {
            XCTAssertTrue(false, "The remove should succeed")
        }
        cleanUpCopyDirectoryControllerDirectoriesWithConfirmation()
    }

    func testCleanUpOnInit() {
        let copyExpectation = expectation(description: "Copy")
        copyDirectoryController.copyItem(at: tempPluginURL, completionHandler: { (URL, error) -> Void in
            XCTAssertNotNil(URL, "The URL should not be nil")
            XCTAssertNil(error, "The error should be nil")

            if let URL = URL {
                let movedFilename = testDirectoryName
                let movedDirectoryURL = URL.deletingLastPathComponent()
                let movedDestinationURL = movedDirectoryURL.appendingPathComponent(movedFilename)

                do {
                    try FileManager.default.moveItem(at: URL,
                        to: movedDestinationURL)
                } catch {
                    XCTAssertTrue(false, "The move should succeed")
                }

                copyExpectation.fulfill()
            }
        })
        waitForExpectations(timeout: defaultTimeout, handler: nil)

        // Assert the contents is empty
        do {
            let contents = try FileManager.default.contentsOfDirectory(at: copyDirectoryController.copyTempDirectoryURL,
                                                                       includingPropertiesForKeys: [URLResourceKey.nameKey],
                                                                       options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            XCTAssertFalse(contents.isEmpty, "The contents should not be empty")
        } catch {
            XCTAssertTrue(false, "Getting the contents should succeed")
        }

        // Init a new CopyDirectoryController

        let copyDirectoryControllerTwo = CopyDirectoryController(tempDirectoryURL: tempCopyTempDirectoryURL,
                                                                 tempDirectoryName: ClassConstants.tempDirectoryName)

        let cleanUpExpectation = expectation(description: "Cleanup")
        copyDirectoryController.cleanUp() { error in
            XCTAssertNil(error)

            // Assert the directory is empty
            do {
                let contentsTwo = try FileManager.default.contentsOfDirectory(at: self.copyDirectoryController.copyTempDirectoryURL,
                                                                              includingPropertiesForKeys: [URLResourceKey.nameKey],
                                                                              options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
                XCTAssertTrue(contentsTwo.isEmpty, "The contents should be empty")
            } catch {
                XCTAssertTrue(false, "Getting the contents should succeed")
            }

            cleanUpExpectation.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)

        // Clean Up
        let recoveredFilesPath = testTrashDirectoryPath.appendingPathComponent(copyDirectoryControllerTwo.trashDirectoryName)
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: recoveredFilesPath, isDirectory: &isDir)
        XCTAssertTrue(exists, "The item should exist")
        XCTAssertTrue(isDir.boolValue, "The item should be a directory")

        // Clean up trash
        do {
            try FileManager.default.removeItem(atPath: recoveredFilesPath)
        } catch {
            XCTAssertTrue(false, "The remove should succeed")
        }

        // Clean up `CopyDirectoryController` temporary directories
        try! removeTemporaryItem(at: tempCopyTempDirectoryURL)
    }
}
