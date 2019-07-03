//
//  FileSystemTests.swift
//  FileSystemTests
//
//  Created by Roben Kleene on 9/29/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import XCTest

@testable import SodaPop
import SodaPopTestHarness

class TemporaryPluginValidationTests: TemporaryPluginTestCase {
    func testNameValidation() {
        plugin.name = testPluginName

        // Test that the name is valid for this plugin
        var name: AnyObject? = testPluginName as AnyObject?
        do {
            try plugin.validateName(&name)
        } catch {
            XCTAssertTrue(false, "Validation should succeed")
        }

        // Test an invalid object
        name = NSDictionary()
        var error: NSError?
        do {
            try plugin.validateName(&name)
        } catch let nameError as NSError {
            error = nameError
        }
        XCTAssertNotNil(error, "The error should not be nil.")

        // Create a new plugin
        let createdPlugin = newPluginWithConfirmation()

        // Test that the name is not valid for another plugin
        error = nil
        name = testPluginName as AnyObject?
        do {
            try createdPlugin.validateName(&name)
        } catch let nameError as NSError {
            error = nameError
        }
        XCTAssertNotNil(error, "The error should not be nil.")

        // Test that the new plugins name is invalid
        error = nil
        name = createdPlugin.name as AnyObject?
        do {
            try plugin.validateName(&name)
        } catch let nameError as NSError {
            error = nameError
        }
        XCTAssertNotNil(error, "The error should not be nil.")
        // Inverse
        error = nil
        name = plugin.name as AnyObject?
        do {
            try createdPlugin.validateName(&name)
        } catch let nameError as NSError {
            error = nameError
        }
        XCTAssertNotNil(error, "The error should not be nil.")

        // Test that the name is now valid for the second plugin
        name = plugin.name as AnyObject?
        plugin.name = testPluginNameNonexistent
        error = nil
        do {
            try createdPlugin.validateName(&name)
        } catch {
            XCTAssertTrue(false, "Validation should succeed")
        }

        // Test that the new name is now invalid
        error = nil
        name = plugin.name as AnyObject?
        do {
            try createdPlugin.validateName(&name)
        } catch let nameError as NSError {
            error = nameError
        }
        XCTAssertNotNil(error, "The error should not be nil.")

        // Test that the created plugins name is valid after deleting
        error = nil
        name = createdPlugin.name as AnyObject?
        do {
            try plugin.validateName(&name)
        } catch let nameError as NSError {
            error = nameError
        }
        XCTAssertNotNil(error, "The error should not be nil.")
        // Delete
        let trashExpectation = expectation(description: "Move to trash")
        moveToTrashAndCleanUpWithConfirmation(createdPlugin) {
            trashExpectation.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)

        // Test that the new name is now valid
        do {
            try plugin.validateName(&name)
        } catch {
            XCTAssertTrue(false, "Validation should succeed")
        }

        // Clean Up
        let duplicatePluginURL = temporaryDirectoryURL.appendingPathComponent(testCopyTempDirectoryName)
        do {
            try removeTemporaryItem(at: duplicatePluginURL)
        } catch {
            XCTFail()
        }
    }
}

class PluginValidationTests: PluginTestCase {
    func testSuffixValidation() {
        // Test Valid Extensions
        var suffixes: AnyObject? = testPluginSuffixesTwo as AnyObject?
        do {
            try plugin.validateExtensions(&suffixes)
        } catch {
            XCTAssertFalse(true, "Validation should succeed.")
        }

        // Test Invalid Duplicate Extensions
        var error: NSError?
        suffixes = [testPluginSuffix, testPluginSuffix] as AnyObject?
        do {
            try plugin.validateExtensions(&suffixes)
        } catch let nameError as NSError {
            error = nameError
        }
        XCTAssertNotNil(error, "The error should not be nil.")

        // Test Invalid Length Extensions
        error = nil
        suffixes = [testPluginSuffix, ""] as AnyObject?
        do {
            try plugin.validateExtensions(&suffixes)
        } catch let validationError as NSError {
            error = validationError
        }
        XCTAssertNotNil(error, "The error should not be nil.")

        // Test Invalid Object Extensions
        error = nil
        suffixes = [testPluginSuffix, []] as AnyObject?
        do {
            try plugin.validateExtensions(&suffixes)
        } catch let validationError as NSError {
            error = validationError
        }
        XCTAssertNotNil(error, "The error should not be nil.")

        // Test Invalid Character Extensions
        error = nil
        suffixes = [testPluginSuffix, "jkl;"] as AnyObject?
        do {
            try plugin.validateExtensions(&suffixes)
        } catch let validationError as NSError {
            error = validationError
        }
        XCTAssertNotNil(error, "The error should not be nil.")
    }
}
