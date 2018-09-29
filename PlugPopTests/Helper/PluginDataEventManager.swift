//
//  PluginsDataControllerEventManager.swift
//  PlugPopTests
//
//  Created by Roben Kleene on 12/9/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
@testable import PlugPop

class PluginDataEventManager: PluginsDataControllerDelegate {
    var pluginWasAddedHandlers: [(Plugin) -> Void]
    var pluginWasRemovedHandlers: [(Plugin) -> Void]
    weak var delegate: PluginsDataControllerDelegate?

    init() {
        pluginWasAddedHandlers = [(Plugin) -> Void]()
        pluginWasRemovedHandlers = [(Plugin) -> Void]()
    }

    // MARK: `PluginsDataControllerDelegate`

    public func pluginsDataController(_ pluginsDataController: PluginsDataController,
                                      didAddPlugin plugin: Plugin) {
        delegate?.pluginsDataController(pluginsDataController, didAddPlugin: plugin)

        assert(pluginWasAddedHandlers.count > 0, "There should be at least one handler")

        if pluginWasAddedHandlers.count > 0 {
            let handler = pluginWasAddedHandlers.remove(at: 0)
            handler(plugin)
        }
    }

    func pluginsDataController(_ pluginsDataController: PluginsDataController,
                               didRemovePlugin plugin: Plugin) {
        delegate?.pluginsDataController(pluginsDataController,
                                        didRemovePlugin: plugin)

        assert(pluginWasRemovedHandlers.count > 0, "There should be at least one handler")

        if pluginWasRemovedHandlers.count > 0 {
            let handler = pluginWasRemovedHandlers.remove(at: 0)
            handler(plugin)
        }
    }

    func pluginsDataController(_ pluginsDataController: PluginsDataController,
                               uniquePluginNameFromName name: String,
                               for plugin: Plugin) -> String? {
        return delegate?.pluginsDataController(pluginsDataController,
                                               uniquePluginNameFromName: name,
                                               for: plugin)
    }

    // MARK: Handlers

    func add(pluginWasAddedHandler handler: @escaping (_ plugin: Plugin) -> Void) {
        pluginWasAddedHandlers.append(handler)
    }

    func add(pluginWasRemovedHandler handler: @escaping (_ plugin: Plugin) -> Void) {
        pluginWasRemovedHandlers.append(handler)
    }
}
