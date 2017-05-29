//
//  WCLPluginsController+WCLDefaultNewPluginManagerDataSource.swift
//  .
//
//  Created by Roben Kleene on 5/21/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

extension WCLPluginsController: WCLDefaultNewPluginManagerDataSource {
    public func defaultNewPluginManager(_ defaultNewPluginManager: WCLDefaultNewPluginManager, pluginWithName name: String) -> Plugin? {
        return plugin(withName: name)
    }

    public func defaultNewPluginManager(_ defaultNewPluginManager: WCLDefaultNewPluginManager, pluginWithIdentifier identifier: String) -> Plugin? {
        return plugin(withIdentifier: identifier)
    }
}
