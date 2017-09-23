//
//  FileSystemTests.swift
//  FileSystemTests
//
//  Created by Roben Kleene on 9/29/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import XCTest

@testable import PlugPop
import PotionTaster
import XCTestTemp
import StringPlusPath

class PluginTests: PluginTestCase {

    func testSharedResources() {
        let testSharedResourcesPath = pluginsManager.sharedResourcesPath!.appendingPathComponent(testSharedResourcePathComponent)
        var isDir: ObjCBool = false
        var fileExists = FileManager.default.fileExists(atPath: testSharedResourcesPath, isDirectory: &isDir)
        XCTAssertTrue(fileExists)
        XCTAssertFalse(isDir.boolValue)

        let testSharedResourcesURL = pluginsManager.sharedResourcesURL!.appendingPathComponent(testSharedResourcePathComponent)
        fileExists = FileManager.default.fileExists(atPath: testSharedResourcesURL.path, isDirectory: &isDir)
        XCTAssertTrue(fileExists)
        XCTAssertFalse(isDir.boolValue)
    }

    func testPlugin() {
        guard let plugin = pluginsManager.plugin(withName: PotionTaster.testPluginNamePrint) else {
            XCTFail()
            return
        }
        var isDir: ObjCBool = false
        let fileExists = FileManager.default.fileExists(atPath: plugin.resourcePath!, isDirectory: &isDir)
        XCTAssertTrue(fileExists)
        XCTAssertTrue(isDir.boolValue)
        XCTAssertEqual(plugin.resourcePath, plugin.resourceURL!.path)
    }

    func testEditPluginProperties() {
        let contents = contentsOfInfoDictionaryWithConfirmation(for: plugin)

        plugin.name = PotionTaster.testPluginNameTwo
        let contentsTwo = contentsOfInfoDictionaryWithConfirmation(for: plugin)
        XCTAssertNotEqual(contents, contentsTwo, "The contents should not be equal")

        plugin.command = PotionTaster.testPluginCommandTwo
        let contentsThree = contentsOfInfoDictionaryWithConfirmation(for: plugin)
        XCTAssertNotEqual(contentsTwo, contentsThree, "The contents should not be equal")

        let uuid = UUID()
        let uuidString = uuid.uuidString
        plugin.identifier = uuidString
        let contentsFour = contentsOfInfoDictionaryWithConfirmation(for: plugin)
        XCTAssertNotEqual(contentsThree, contentsFour, "The contents should not be equal")

        plugin.suffixes = testPluginSuffixesTwo
        let contentsFive = contentsOfInfoDictionaryWithConfirmation(for: plugin)
        XCTAssertNotEqual(contentsFour, contentsFive, "The contents should not be equal")
        let newPlugin: Plugin! = Plugin.makePlugin(url: pluginURL)

        XCTAssertEqual(plugin.name, newPlugin.name, "The names should be equal")
        XCTAssertEqual(plugin.command!, newPlugin.command!, "The commands should be equal")
        XCTAssertEqual(plugin.identifier, newPlugin.identifier, "The identifiers should be equal")
        XCTAssertEqual(plugin.suffixes, newPlugin.suffixes, "The file extensions should be equal")
    }

    func testEquality() {
        let samePlugin: Plugin = Plugin.makePlugin(url: pluginURL)!
        XCTAssertNotEqual(plugin, samePlugin, "The plugins should not be equal")
        XCTAssertTrue(plugin.isEqual(toOther: samePlugin), "The plugins should be equal")
        
        // Duplicate the plugins folder, this should not cause a second plugin to be added to the plugin manager since the copy originated from the same process
        let destinationPluginFilename = DuplicatePluginController.pluginFilename(fromName: plugin.identifier)
        let destinationPluginURL: URL! = pluginURL.deletingLastPathComponent().appendingPathComponent(destinationPluginFilename)
        do {
            try FileManager.default.copyItem(at: pluginURL as URL, to: destinationPluginURL)
        } catch {
            XCTAssertTrue(false, "The copy should succeed")
        }

        let newPlugin: Plugin! = Plugin.makePlugin(url: destinationPluginURL)
        XCTAssertNotEqual(plugin, newPlugin, "The plugins should not be equal")
        // This fails because the bundle URL and commandPath are different
        XCTAssertFalse(plugin.isEqual(to: newPlugin), "The plugins should be equal")

        // TODO: It would be nice to test modifying properties, but there isn't a way to do that because with two separate plugin directories the command paths and info dictionary URLs will be different
    }

    // MARK: Helper

    func contentsOfInfoDictionaryWithConfirmation(for plugin: Plugin) -> String {
        let pluginInfoDictionaryPath = Plugin.urlForInfoDictionary(for: plugin).path
        var infoDictionaryContents: String!
        do {
            infoDictionaryContents = try String(contentsOfFile: pluginInfoDictionaryPath, encoding: String.Encoding.utf8)
        } catch {
            XCTAssertTrue(false, "Getting the info dictionary contents should succeed")
        }
        
        return infoDictionaryContents
    }
}

class DuplicatePluginNameValidationTests: PluginTestCase {

    var mockPluginsManager: MockPluginsManager {
        return pluginsManager as! MockPluginsManager
    }

    class NameBlocker: NSObject {
        @objc let name: String
        init(name: String) {
            self.name = name
        }
    }

    override func setUp() {
        pluginsManagerType = MockPluginsManager.self
        super.setUp()
    }

    func testPluginNames() {

        // Setup
        let fromName = PotionTaster.testPluginNameNonexistent
        XCTAssert(fromName != plugin.name)

        for index in 0...105 {

            // Calculate the current suffixed name
            let suffix = index + 1
            let suffixedName = "\(fromName) \(suffix)"
            var testName: String!
            switch index {
            case 0:
                testName = fromName
            case let x where x > 98:
                testName = plugin.identifier
            default:
                testName = suffixedName
            }

            let name = pluginsManager.pluginsController.uniquePluginName(fromName: fromName,
                                                                         for: plugin)
            XCTAssertEqual(name, testName)

            // Block more names for the next iteration
            if index == 0 {
                mockPluginsManager.mockPluginsController.override(name: fromName, with: plugin)
            } else {
                mockPluginsManager.mockPluginsController.override(name: suffixedName, with: plugin)
            }
        }

    }
}

// TODO: Test trying to run a plugin that has been unloaded? After deleting it's resources
// TODO: Add tests for invalid plugin info dictionaries, e.g., file extensions and commands can be nil

