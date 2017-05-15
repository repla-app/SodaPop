//
//  PluginDataEventManagerTestCase.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/9/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import XCTest

@testable import Web_Console

class PluginDataEventManager: PluginsDataControllerDelegate {
    var pluginWasAddedHandlers: Array<(_ plugin: Plugin) -> Void>
    var pluginWasRemovedHandlers: Array<(_ plugin: Plugin) -> Void>
    var delegate: PluginsDataControllerDelegate?
    
    init () {
        self.pluginWasAddedHandlers = Array<(_ plugin: Plugin) -> Void>()
        self.pluginWasRemovedHandlers = Array<(_ plugin: Plugin) -> Void>()
    }
    
    
    // MARK: PluginsDataControllerDelegate
    
    func pluginsDataController(_ pluginsDataController: PluginsDataController, didAddPlugin plugin: Plugin) {
        delegate?.pluginsDataController(pluginsDataController, didAddPlugin: plugin)
        
        assert(pluginWasAddedHandlers.count > 0, "There should be at least one handler")
        
        if (pluginWasAddedHandlers.count > 0) {
            let handler = pluginWasAddedHandlers.remove(at: 0)
            handler(plugin)
        }
    }
    
    func pluginsDataController(_ pluginsDataController: PluginsDataController, didRemovePlugin plugin: Plugin) {
        delegate?.pluginsDataController(pluginsDataController, didRemovePlugin: plugin)
        
        assert(pluginWasRemovedHandlers.count > 0, "There should be at least one handler")
        
        if (pluginWasRemovedHandlers.count > 0) {
            let handler = pluginWasRemovedHandlers.remove(at: 0)
            handler(plugin)
        }
    }
    
    // MARK: Handlers
    
    func add(pluginWasAddedHandler handler: @escaping (_ plugin: Plugin) -> Void) {
        pluginWasAddedHandlers.append(handler)
    }
    
    func add(pluginWasRemovedHandler handler: @escaping (_ plugin: Plugin) -> Void) {
        pluginWasRemovedHandlers.append(handler)
    }
    
}


class PluginsDataControllerEventTestCase: PluginsManagerTestCase {
    var pluginDataEventManager: PluginDataEventManager!
    
    override func setUp() {
        super.setUp()
        pluginDataEventManager = PluginDataEventManager()
        pluginDataEventManager.delegate = PluginsManager.sharedInstance
        PluginsManager.sharedInstance.pluginsDataController.delegate = pluginDataEventManager
    }
    
    override func tearDown() {
        PluginsManager.sharedInstance.pluginsDataController.delegate = PluginsManager.sharedInstance
        pluginDataEventManager.delegate = nil
        pluginDataEventManager = nil
        super.tearDown()
    }
}
