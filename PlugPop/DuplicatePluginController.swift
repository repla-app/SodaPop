//
//  DuplicatePluginController.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/25/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation

class DuplicatePluginController {
    lazy var copyDirectoryController = CopyDirectoryController(tempDirectoryName: ClassConstants.tempDirectoryName)

    struct ClassConstants {
        static let tempDirectoryName = "Duplicate Plugin"
    }
    class func pluginFilename(fromName name: String) -> String {
        return name.appendingPathExtension(pluginFileExtension)!
    }
    func duplicate(_ plugin: Plugin, to destinationDirectoryURL: URL, completionHandler handler: @escaping (_ plugin: Plugin?, _ error: NSError?) -> Void) {
        let pluginFileURL = plugin.bundle.bundleURL
        copyDirectoryController.copyItem(at: pluginFileURL, completionHandler: { (URL, error) -> Void in
            
            guard error == nil else {
                handler(nil, error)
                return
            }
            
            var plugin: Plugin?
            if let URL = URL {
                let UUID = Foundation.UUID()
                let movedFilename = type(of: self).pluginFilename(fromName: UUID.uuidString)
                let movedDestinationURL = destinationDirectoryURL.appendingPathComponent(movedFilename)

                do {
                    try FileManager.default.moveItem(at: URL, to: movedDestinationURL)
                } catch let error as NSError {
                    handler(nil, error)
                    return
                }
                
                if let movedPlugin = Plugin.makePlugin(url: movedDestinationURL) {
                    movedPlugin.editable = true
                    movedPlugin.renameWithUniqueName()
                    movedPlugin.identifier = UUID.uuidString
                    plugin = movedPlugin
                    
                    // Attempt to move the plugin to a directory based on its name (this can safely fail)
                    let renamedPluginFilename = type(of: self).pluginFilename(fromName: movedPlugin.name)
                    let renamedDestinationURL = movedDestinationURL.deletingLastPathComponent().appendingPathComponent(renamedPluginFilename)
                    do {
                        try FileManager.default.moveItem(at: movedDestinationURL, to: renamedDestinationURL)
                        if let renamedPlugin = Plugin.makePlugin(url: renamedDestinationURL) {
                            plugin = renamedPlugin
                        }
                    } catch let error as NSError {
                        print("Failed to move a plugin directory to \(renamedDestinationURL) \(error)")
                    }
                }
            }

            handler(plugin, error)
        })
    }
}
