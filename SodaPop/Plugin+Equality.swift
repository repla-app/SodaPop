//
//  Plugin+Equality.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 2/7/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation

extension BasePlugin {
    func isEqual(toOther plugin: BasePlugin) -> Bool {
        if name != plugin.name {
            return false
        }

        if identifier != plugin.identifier {
            return false
        }

        if editable != plugin.editable {
            return false
        }

        if type != plugin.type {
            return false
        }

        if command != plugin.command {
            return false
        }

        if commandPath != plugin.commandPath {
            return false
        }

        if infoDictionaryURL != plugin.infoDictionaryURL {
            return false
        }

        return true
    }
}
