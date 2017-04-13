//
//  PluginsDataController+Paths.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/2/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

extension PluginsDataController {
    class func pathsForPlugins(atPath path: String) -> [String] {
        var pluginPaths = [String]()
        if let pathContents = try? FileManager.default.contentsOfDirectory(atPath: path) {
            let fileExtension = ".\(pluginFileExtension)"
            let pluginPredicate = NSPredicate(format: "self ENDSWITH %@", fileExtension)
            let pluginPathComponents = pathContents.filter {
                pluginPredicate.evaluate(with: $0)
            }
            for pluginPathComponent in pluginPathComponents {
                let pluginPath = path.appendingPathComponent(pluginPathComponent)
                pluginPaths.append(pluginPath)
            }
        }
        
        return pluginPaths
    }
    
    class func plugins(atPluginPaths pluginPaths: [String]) -> [Plugin] {
        var plugins = [Plugin]()
        for pluginPath in pluginPaths {
            if let plugin = Plugin.makePlugin(path: pluginPath) {
                plugins.append(plugin)
            }
        }
        return plugins
    }
    
    func plugins(atPath path: String) -> [Plugin] {
        let pluginPaths = type(of: self).pathsForPlugins(atPath: path)
        let plugins = type(of: self).plugins(atPluginPaths: pluginPaths)
        return plugins
    }

}
