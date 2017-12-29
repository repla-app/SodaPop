//
//  PluginTestCase.swift
//  .
//
//  Created by Roben Kleene on 6/27/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

import XCTest

@testable import PlugPop

public class TemporaryPluginTestCase: TemporaryPluginsManagerTestCase, PluginOwnerType {
    var tempPlugin: Plugin!
    var plugin: Plugin {
        return tempPlugin
    }
    var pluginURL: URL {
        return plugin.bundle.bundleURL
    }
    var pluginPath: String {
        return pluginURL.path
    }

    override public func setUp() {
        super.setUp()

        // Set the plugin
        tempPlugin = tempPluginsManager.plugin(withName: testPluginName)
        XCTAssertNotNil(plugin, "The temporary plugin should not be nil")
        XCTAssertTrue(isTemporaryItem(at: plugin.resourceURL!))
        tempPlugin.editable = true
        tempPlugin.isDefaultNewPlugin = true
    }
    
    override public func tearDown() {
        tempPlugin.isDefaultNewPlugin = false
        tempPlugin = nil
        super.tearDown()
    }
}
