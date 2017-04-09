//
//  CopyDirectoryControllerTests.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/4/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

@testable import Web_Console

class CopyDirectoryControllerTests: TemporaryPluginsTestCase {
    var copyDirectoryController: CopyDirectoryController!
    struct ClassConstants {
        static let tempDirectoryName = "Copy Directory Test"
    }
    
    override func setUp() {
        super.setUp()
        copyDirectoryController = CopyDirectoryController(tempDirectoryName: ClassConstants.tempDirectoryName)
    }
    
    override func tearDown() {
        copyDirectoryController = nil
        super.tearDown()
    }

    
    func testCopy() {
        let copyExpectation = expectation(description: "Copy")
        
        var copiedPluginURL: URL!
        copyDirectoryController.copyItem(at: pluginURL, completionHandler: { (URL, error) -> Void in
            XCTAssertNotNil(URL, "The URL should not be nil")
            XCTAssertNil(error, "The error should be nil")
            
            if let URL = URL {
                let movedFilename = testDirectoryName
                let movedDestinationURL = self.pluginsDirectoryURL.appendingPathComponent(movedFilename)

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

        let pluginInfoDictionaryURL = Plugin.urlForInfoDictionary(forPluginAt: pluginURL)
        let copiedPluginInfoDictionaryURL = Plugin.urlForInfoDictionary(forPluginAt: copiedPluginURL)
        
        do {
            let pluginInfoDictionaryContents: String! = try String(contentsOf: pluginInfoDictionaryURL, encoding: String.Encoding.utf8)
            let copiedPluginInfoDictionaryContents: String! = try String(contentsOf: copiedPluginInfoDictionaryURL, encoding: String.Encoding.utf8)
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
    }

    func testCleanUpOnInit() {
        let copyExpectation = expectation(description: "Copy")
        copyDirectoryController.copyItem(at: pluginURL, completionHandler: { (URL, error) -> Void in
            XCTAssertNotNil(URL, "The URL should not be nil")
            XCTAssertNil(error, "The error should be nil")

            if let URL = URL {
                let movedFilename = testDirectoryName
                let movedDirectoryURL: Foundation.URL! = URL.deletingLastPathComponent()
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
        let copyDirectoryControllerTwo = CopyDirectoryController(tempDirectoryName: ClassConstants.tempDirectoryName)
        
        // Assert directory is empty

        do {
            let contentsTwo = try FileManager.default.contentsOfDirectory(at: copyDirectoryController.copyTempDirectoryURL,
                includingPropertiesForKeys: [URLResourceKey.nameKey],
                options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants])
            XCTAssertTrue(contentsTwo.isEmpty, "The contents should be empty")
        } catch {
            XCTAssertTrue(false, "Getting the contents should succeed")
        }

        // Clean Up
        let recoveredFilesPath = Directory.trash.path().appendingPathComponent(copyDirectoryControllerTwo.trashDirectoryName)
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
    }
}
