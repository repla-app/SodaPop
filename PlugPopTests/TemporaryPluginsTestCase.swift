//
//  TemporaryPluginsTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/8/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation
import XCTest

@testable import Web_Console

class TemporaryPluginsTestCase: TemporaryDirectoryTestCase {
    var pluginsDirectoryURL: URL!
    var pluginsDirectoryPath: String! {
        get {
            return pluginsDirectoryURL.path
        }
    }
    var pluginURL: URL!
    var pluginPath: String! {
        get {
            return pluginURL.path
        }
    }
    
    override func setUp() {
        super.setUp()
        
        // Create the plugins directory
        pluginsDirectoryURL = temporaryDirectoryURL
            .appendingPathComponent(pluginsDirectoryPathComponent)

        do {
            try FileManager.default
                .createDirectory(at: pluginsDirectoryURL,
                    withIntermediateDirectories: false,
                    attributes: nil)
        } catch let error as NSError {
            XCTAssertTrue(false, "Creating the directory should succeed \(error)")
        }
       
        // Copy the bundle resources plugin to the plugins directory
        let bundleResourcesPluginURL: URL! = url(forResource: testPluginName, withExtension:pluginFileExtension)
        let filename = testPluginName.appendingPathExtension(pluginFileExtension)!
        
        pluginURL = pluginsDirectoryURL.appendingPathComponent(filename)
        do {
            try FileManager.default
                .copyItem(at: bundleResourcesPluginURL,
                    to: pluginURL)
        } catch let error as NSError {
            XCTAssertTrue(false, "Moving the directory should succeed \(error)")
        }
    }
    
    override func tearDown() {
        pluginsDirectoryURL = nil
        pluginURL = nil
        
        // Remove the plugins directory (containing the plugin)
        do {
            try removeTemporaryItem(atPathComponent: pluginsDirectoryPathComponent)
        } catch let error as NSError {
            XCTAssertTrue(false, "Removing the plugins directory should have succeeded \(error)")
        }
        
        super.tearDown()
    }
    
}
