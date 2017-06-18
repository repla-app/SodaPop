//
//  TemporaryPluginsManagerTestCase.swift
//  .
//
//  Created by Roben Kleene on 6/18/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

class TemporaryPluginsManagerTestCase: TemporaryPluginsTestCase, PluginsManagerFactoryType {
    var builtInPluginsPath: String = nil 
    var userPluginsPath: String {
        return tempPluginsDirectoryPath
    }
    var pluginsDirectoryPaths: [String] {
        return [userPluginsPath]
    }
    var plugin: Plugin!
    var pluginsManager: PluginsManager!
    lazy var defaults: DefaultsType = {
        UserDefaults(suiteName: testMockUserDefaultsSuiteName)!
    }()

    override func setUp() {
        super.setUp()

        // Create the plugin manager
        pluginsManager = makePluginsManager()
        // Set the plugin
        plugin = pluginsManager.plugin(withName: PotionTaster.testPluginName)
        plugin.editable = true
        XCTAssertNotNil(plugin, "The temporary plugin should not be nil")
        plugin.isDefaultNewPlugin = true
    }
    
    override func tearDown() {
        plugin.isDefaultNewPlugin = false
        plugin = nil
        super.tearDown()
    }

}
