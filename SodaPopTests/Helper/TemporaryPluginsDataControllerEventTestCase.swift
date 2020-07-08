//
//  PluginDataEventManagerTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/9/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
@testable import SodaPop
import SodaPopTestHarness
import XCTest

open class TemporaryPluginsDataControllerEventTestCase: TemporaryPluginTestCase {
    var pluginDataEventManager: PluginDataEventManager!

    override open func setUp() {
        super.setUp()
        pluginDataEventManager = PluginDataEventManager()
        pluginDataEventManager.delegate = pluginsManager
        pluginsManager.pluginsDataController.delegate = pluginDataEventManager
    }

    override open func tearDown() {
        pluginsManager.pluginsDataController.delegate = pluginsManager
        pluginDataEventManager.delegate = nil
        pluginDataEventManager = nil
        super.tearDown()
    }
}
