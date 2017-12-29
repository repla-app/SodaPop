//
//  PluginTestCase.swift
//  .
//
//  Created by Roben Kleene on 6/28/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

import XCTest

@testable import PlugPop

class PluginTestCase: PluginsManagerTestCase, PluginOwnerType {
    private var privatePlugin: Plugin!
    var plugin: Plugin {
        return privatePlugin
    }
    var pluginURL: URL {
        return plugin.bundle.bundleURL
    }
    var pluginPath: String {
        return pluginURL.path
    }

    override func setUp() {
        super.setUp()

        // Set the plugin
        privatePlugin = pluginsManager.plugin(withName: testPluginName)
        XCTAssertNotNil(plugin, "The temporary plugin should not be nil")
        privatePlugin.isDefaultNewPlugin = true
    }
    
    override func tearDown() {
        privatePlugin.isDefaultNewPlugin = false
        privatePlugin = nil
        super.tearDown()
    }

}
