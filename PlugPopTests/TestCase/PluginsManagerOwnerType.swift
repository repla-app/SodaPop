//
//  PluginsManagerTestCaseType.swift
//  PlugPopTests
//
//  Created by Roben Kleene on 12/9/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation

@testable import PlugPop

protocol PluginsManagerOwnerType {
    var pluginsManager: PluginsManager { get }
}

extension PluginsManagerOwnerType {

    func moveToTrashAndCleanUpWithConfirmation(_ plugin: Plugin,
                                               handler: (() -> Void)?)
    {
        // Confirm that a matching directory does not exist in the trash
        let trashedPluginDirectoryName = plugin.bundle.bundlePath.lastPathComponent
        let trashedPluginPath = testTrashDirectoryPath.appendingPathComponent(trashedPluginDirectoryName)
        let beforeExists = FileManager.default.fileExists(atPath: trashedPluginPath)
        assert(!beforeExists)

        // Trash the plugin
        pluginsManager.moveToTrash(plugin) { error in
            assert(error == nil)

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
