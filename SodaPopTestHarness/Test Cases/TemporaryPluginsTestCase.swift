//
//  TemporaryPluginsTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/8/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation
import SodaFountain
import SodaPop
import XCTest
import XCTestTemp

open class TemporaryPluginsTestCase: TemporaryDirectoryTestCase {
    public var tempPluginsDirectoryURL: URL!
    public var tempPluginsDirectoryPath: String! {
        return tempPluginsDirectoryURL.path
    }

    public var tempPluginURL: URL!
    public var tempPluginPath: String! {
        return tempPluginURL.path
    }

    override open func setUp() {
        super.setUp()

        // Create the plugins directory
        tempPluginsDirectoryURL = temporaryDirectoryURL
            .appendingPathComponent(testPluginsDirectoryPathComponent)
        do {
            try FileManager.default
                .createDirectory(at: tempPluginsDirectoryURL,
                                 withIntermediateDirectories: false,
                                 attributes: nil)
        } catch let error as NSError {
            XCTAssertTrue(false, "Creating the directory should succeed \(error)")
        }

        tempPluginURL = makeDuplicatePlugin(fromPluginNamed: testPluginName)
    }

    override open func tearDown() {
        tempPluginsDirectoryURL = nil
        tempPluginURL = nil

        // Remove the plugins directory (containing the plugin)
        do {
            try removeTemporaryItem(withPathComponent: testPluginsDirectoryPathComponent)
        } catch let error as NSError {
            XCTAssertTrue(false, "Removing the plugins directory should have succeeded \(error)")
        }

        super.tearDown()
    }

    func makeDuplicatePlugin(fromPluginNamed pluginName: String) -> URL {
        // Copy the bundle resources plugin to the plugins directory
        let bundleResourcesPluginURL = TestPlugins.urlForPlugin(withName: pluginName)!
        let filename = pluginName.appendingPathExtension(testPluginExtension)!

        let tempPluginURL = tempPluginsDirectoryURL.appendingPathComponent(filename)
        do {
            try FileManager.default.copyItem(at: bundleResourcesPluginURL,
                                             to: tempPluginURL)
        } catch let error as NSError {
            XCTAssertTrue(false, "Moving the directory should succeed \(error)")
        }

        return tempPluginURL
    }
}
