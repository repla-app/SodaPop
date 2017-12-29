//
//  DuplicatePluginController.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 9/25/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Foundation

protocol DuplicatePluginControllerDelegate {
    func duplicatePluginController(_  duplicatePluginController: DuplicatePluginController,
                                   uniquePluginNameFromName name: String,
                                   for plugin: Plugin) -> String?
}

class DuplicatePluginController {
    lazy var copyDirectoryController: CopyDirectoryController = {
        let copyDirectoryController = CopyDirectoryController(tempDirectoryURL: self.copyTempDirectoryURL, 
                                                              tempDirectoryName: ClassConstants.tempDirectoryName)
        copyDirectoryController.cleanUp() { error in
            assert(error == nil)
        }
        return copyDirectoryController
    }()
    let pluginMaker: PluginMaker
    var delegate: DuplicatePluginControllerDelegate?
    let copyTempDirectoryURL: URL
    
    enum ClassConstants {
        static let tempDirectoryName = "Duplicate Plugin"
    }
    
    init(pluginMaker: PluginMaker, 
         copyTempDirectoryURL: URL)
    {
        self.copyTempDirectoryURL = copyTempDirectoryURL
        self.pluginMaker = pluginMaker
    }
    
    class func pluginFilename(fromName name: String) -> String {
        return name.appendingPathExtension(pluginFileExtension)!
    }

    func duplicate(_ plugin: Plugin,
                   to destinationDirectoryURL: URL,
                   completionHandler handler: @escaping (_ plugin: Plugin?, _ error: NSError?) -> Void)
    {
        let pluginFileURL = plugin.bundle.bundleURL
        copyDirectoryController.copyItem(at: pluginFileURL,
                                         completionHandler: { [weak self] (URL, error) -> Void in
            guard let `self` = self else { return }

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
                    try FileManagerHelper.createDirectoryIfMissing(at: destinationDirectoryURL)
                    try FileManager.default.moveItem(at: URL, to: movedDestinationURL)
                } catch let error as NSError {
                    handler(nil, error)
                    return
                }
                
                if let movedPlugin = self.pluginMaker.makePlugin(url: movedDestinationURL) {
                    movedPlugin.editable = true
                    movedPlugin.identifier = UUID.uuidString
                    if let uniqueName = self.delegate?.duplicatePluginController(self, 
                                                                                 uniquePluginNameFromName: movedPlugin.name, 
                                                                                 for: movedPlugin)
                    {
                        movedPlugin.name = uniqueName
                    } else {
                        movedPlugin.name = movedPlugin.identifier
                    }
                    plugin = movedPlugin
                    
                    // Attempt to move the plugin to a directory based on its name (this can safely fail)
                    let renamedPluginFilename = type(of: self).pluginFilename(fromName: movedPlugin.name)
                    let renamedDestinationURL = movedDestinationURL.deletingLastPathComponent().appendingPathComponent(renamedPluginFilename)
                    do {
                        try FileManager.default.moveItem(at: movedDestinationURL, to: renamedDestinationURL)
                        if let renamedPlugin = self.pluginMaker.makePlugin(url: renamedDestinationURL) {
                            plugin = renamedPlugin
                        }
                    } catch {
//                    } catch let error as NSError {
                        // TODO: This is a useful log message, but it's confusing
                        // for tests. Eventually a better solution for this type
                        // of log message would be useful.
//                        print("Failed to move a plugin directory to \(renamedDestinationURL) \(error)")
                    }
                }
            }

            handler(plugin, error)
        })
    }
}
