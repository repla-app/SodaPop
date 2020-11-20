//
//  PluginsDataControllerEventManager.swift
//  SodaPopTests
//
//  Created by Roben Kleene on 12/9/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
@testable import SodaPop

class PluginDataEventManager: PluginsDataControllerDelegate {
    var pluginWasAddedHandlers: [(BasePlugin) -> Void]
    var pluginWasRemovedHandlers: [(BasePlugin) -> Void]
    weak var delegate: PluginsDataControllerDelegate?

    init() {
        pluginWasAddedHandlers = [(BasePlugin) -> Void]()
        pluginWasRemovedHandlers = [(BasePlugin) -> Void]()
    }

    // MARK: `PluginsDataControllerDelegate`

    public func pluginsDataController(_ pluginsDataController: PluginsDataController,
                                      didAddPlugin plugin: BasePlugin) {
        delegate?.pluginsDataController(pluginsDataController, didAddPlugin: plugin)

        assert(pluginWasAddedHandlers.count > 0, "There should be at least one handler")

        if pluginWasAddedHandlers.count > 0 {
            let handler = pluginWasAddedHandlers.remove(at: 0)
            handler(plugin)
        }
    }

    func pluginsDataController(_ pluginsDataController: PluginsDataController,
                               didRemovePlugin plugin: BasePlugin) {
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
                               for plugin: BasePlugin) -> String? {
        return delegate?.pluginsDataController(pluginsDataController,
                                               uniquePluginNameFromName: name,
                                               for: plugin)
    }

    // MARK: Handlers

    func add(pluginWasAddedHandler handler: @escaping (_ plugin: BasePlugin) -> Void) {
        pluginWasAddedHandlers.append(handler)
    }

    func add(pluginWasRemovedHandler handler: @escaping (_ plugin: BasePlugin) -> Void) {
        pluginWasRemovedHandlers.append(handler)
    }
}
