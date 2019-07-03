//
//  POPPluginsController+POPDefaultNewPluginManagerDataSource.swift
//  .
//
//  Created by Roben Kleene on 5/21/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

extension POPPluginsController: POPDefaultNewPluginManagerDataSource {
    public func defaultNewPluginManager(_: POPDefaultNewPluginManager,
                                        pluginWithName name: String) -> Plugin? {
        return plugin(withName: name)
    }

    public func defaultNewPluginManager(_: POPDefaultNewPluginManager,
                                        pluginWithIdentifier identifier: String) -> Plugin? {
        return plugin(withIdentifier: identifier)
    }
}
