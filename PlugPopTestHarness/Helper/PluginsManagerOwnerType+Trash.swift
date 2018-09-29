//
//  PluginsManagerOwnerType+Trash.swift
//  PlugPopTests
//
//  Created by Roben Kleene on 12/30/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation
import PlugPop

extension PluginsManagerOwnerType {
    public func moveToTrashAndCleanUpWithConfirmation(_ plugin: Plugin,
                                                      handler: (() -> Void)?) {
        // Trash the plugin
        pluginsManager.moveToTrash(plugin) { url, error in
            assert(error == nil)
            assert(url != nil)
            let trashedPluginPath = url!.path

            // Confirm that the directory does exist in the trash now
            var isDir: ObjCBool = false
            let afterExists = FileManager.default.fileExists(atPath: trashedPluginPath, isDirectory: &isDir)
            assert(afterExists)
            assert(isDir.boolValue)

            // Clean up trash
            do {
                try FileManager.default.removeItem(atPath: trashedPluginPath)
            } catch {
                assert(false)
            }
            handler?()
        }
    }
}
