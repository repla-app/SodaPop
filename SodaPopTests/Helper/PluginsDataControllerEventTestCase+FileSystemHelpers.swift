//
//  PluginsDataControllerEventTestCase+FileSystemHelpers.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/19/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation
import OutOfTouch
@testable import SodaPop
import XCTest

extension TemporaryPluginsDataControllerEventTestCase {
    // MARK: Move Helpers

    func moveWithConfirmation(_ plugin: Plugin,
                              destinationPluginPath: String,
                              handler: @escaping (_ plugin: Plugin?) -> Void) {
        let pluginPath = plugin.path
        guard isTemporaryItem(atPath: pluginPath) else {
            XCTFail("Tried to move a plugin that is not in a temporary directory.")
            return
        }

        let removeExpectation = expectation(description: "Plugin was removed")
        pluginDataEventManager.add(pluginWasRemovedHandler: { (removedPlugin) -> Void in
            if plugin == removedPlugin {
                removeExpectation.fulfill()
            }
        })

        var newPlugin: Plugin?
        let createExpectation = expectation(description: "Plugin was added")
        pluginDataEventManager.add(pluginWasAddedHandler: { (addedPlugin) -> Void in
            let path = addedPlugin.path
            if path == destinationPluginPath {
                newPlugin = addedPlugin
                handler(newPlugin)
                createExpectation.fulfill()
            }
        })

        let moveExpectation = expectation(description: "Move finished")
        OutOfTouch.moveItem(atPath: pluginPath,
                            toPath: destinationPluginPath) { standardOutput, standardError, exitStatus in
            XCTAssertNil(standardOutput)
            XCTAssertNil(standardError)
            XCTAssert(exitStatus == 0)
            moveExpectation.fulfill()
        }

        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    // MARK: Copy Helpers

    func copyWithConfirmation(_ plugin: Plugin,
                              destinationPluginPath: String,
                              handler: @escaping (_ plugin: Plugin?) -> Void) {
        var pluginWasAdded = false
        var pluginWasCopied = false

        var newPlugin: Plugin?
        pluginDataEventManager.add(pluginWasAddedHandler: { (addedPlugin) -> Void in
            let path = addedPlugin.path
            if path.hasPrefix(destinationPluginPath) {
                newPlugin = addedPlugin
                pluginWasAdded = true
                guard pluginWasAdded, pluginWasCopied else {
                    return
                }

                // TODO: Once the requirement that no two plugins have the same
                // identifier is enforced, we'll also have to change the new plugin's
                // identifier here.
                handler(newPlugin)
            }
        })

        let pluginPath = plugin.path
        OutOfTouch.copyDirectory(atPath: pluginPath,
                                 toPath: destinationPluginPath) { standardOutput, standardError, exitStatus in
            XCTAssertNil(standardOutput)
            XCTAssertNil(standardError)
            XCTAssert(exitStatus == 0)
            pluginWasCopied = true
            guard pluginWasAdded, pluginWasCopied else {
                return
            }
            XCTAssertNotNil(newPlugin)
            handler(newPlugin)
        }
    }

    // MARK: Remove Helpers

    func removeWithConfirmation(_ plugin: Plugin) {
        let removeExpectation = expectation(description: "Plugin was removed")
        pluginDataEventManager.add(pluginWasRemovedHandler: { (removedPlugin) -> Void in
            if plugin == removedPlugin {
                removeExpectation.fulfill()
            }
        })

        let pluginPath = plugin.path
        let deleteExpectation = expectation(description: "Remove finished")
        OutOfTouch.removeDirectory(atPath: pluginPath) { standardOutput, standardError, exitStatus in
            XCTAssertNil(standardOutput)
            XCTAssertNil(standardError)
            XCTAssert(exitStatus == 0)
            deleteExpectation.fulfill()
        }
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }

    // MARK: Modify Helpers

    func modifyWithConfirmation(_ plugin: Plugin, handler: @escaping (_ plugin: Plugin?) -> Void) {
        // Get the old identifier
        guard let xmlPlugin = plugin as? XMLPlugin else {
            XCTFail()
            return
        }
        let infoDictionary = NSDictionary(contentsOf: xmlPlugin.infoDictionaryURL)! as Dictionary
        let identifier: String = infoDictionary[XMLPlugin.InfoDictionaryKeys.identifier as NSString] as? String ?? ""
        // Get the info dictionary contents
        let infoDictionaryPath = xmlPlugin.infoDictionaryURL.path

        // Make a new identifier
        let UUID = Foundation.UUID()
        let newIdentifier = UUID.uuidString

        var infoDictionaryContents: String!
        do {
            infoDictionaryContents = try String(contentsOfFile: infoDictionaryPath, encoding: String.Encoding.utf8)
        } catch {
            XCTAssertNil(false, "Getting the info dictionary contents shoudld succeed.")
        }

        // Replace the old identifier with the new identifier
        let newInfoDictionaryContents = infoDictionaryContents.replacingOccurrences(of: identifier, with: newIdentifier)

        let removeExpectation = expectation(description: "Plugin was removed")
        pluginDataEventManager.add(pluginWasRemovedHandler: { (removedPlugin) -> Void in
            if plugin == removedPlugin {
                removeExpectation.fulfill()
            }
        })

        let pluginPath = plugin.path
        var newPlugin: Plugin?
        let createExpectation = expectation(description: "Plugin was added")
        pluginDataEventManager.add(pluginWasAddedHandler: { (addedPlugin) -> Void in
            let path = addedPlugin.path
            if path == pluginPath {
                newPlugin = addedPlugin
                handler(newPlugin)
                createExpectation.fulfill()
            }
        })

        OutOfTouch.writeToFile(atPath: infoDictionaryPath,
                               contents: newInfoDictionaryContents,
                               handler: nil)
        waitForExpectations(timeout: defaultTimeout, handler: nil)
    }
}
