//
//  PluginsDirectoryEventHandler.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 12/10/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

// What needs to be unique are created events 

// The reason events are coalesced by sending the events after the delay period,
// as opposed to sending an event right away then preventing events from being
// sent for the delay period, is that only former works in the following case:
// 1. The plugin is edited
// 2. The plugin is loaded
// 3. The plugin is edited again
// In this case, the plugin should be loaded again for the second edit. The
// plugin would not be reloaded for the second edit if events are prevented
// from firing during the delay period.

protocol PluginsDirectoryEventHandlerDelegate {
    func pluginsDirectoryEventHandler(_ pluginsDirectoryEventHandler: PluginsDirectoryEventHandler,
        handleCreatedOrModifiedEventsAtPluginPath pluginPath: String,
        createdOrModifiedDirectoryPaths directoryPaths: [String]?,
        createdOrModifiedFilePaths filePaths: [String]?)
    func pluginsDirectoryEventHandler(_ pluginsDirectoryEventHandler: PluginsDirectoryEventHandler,
        handleRemovedEventsAtPluginPath pluginPath: String,
        removedItemPaths itemPaths: [String]?)
}

class PluginsDirectoryEventHandler {
    var pluginPathToCreatedOrModifiedFilePaths: [String : [String]]
    var pluginPathToCreatedOrModifiedDirectoryPaths: [String : [String]]
    var pluginPathToRemovedItemPaths: [String : [String]]
    var delegate: PluginsDirectoryEventHandlerDelegate?
    
    struct ClassConstants {
        static let fileEventDelay = 0.3
    }
    
    init() {
        self.pluginPathToCreatedOrModifiedFilePaths = [String : [String]]()
        self.pluginPathToCreatedOrModifiedDirectoryPaths = [String : [String]]()
        self.pluginPathToRemovedItemPaths = [String : [String]]()
    }
    
    // MARK: Collecting Handlers
    
    func addDirectoryWasCreatedOrModifiedEvent(atPluginPaths pluginPath: String, forPath path: String) {
        if var paths = pluginPathToCreatedOrModifiedDirectoryPaths[pluginPath] {
            paths.append(path)
            pluginPathToCreatedOrModifiedDirectoryPaths[pluginPath] = paths
        } else {
            pluginPathToCreatedOrModifiedDirectoryPaths[pluginPath] = [path]

            fireCreatedOrModifiedEventsAfterDelay(for: pluginPath)
        }
    }

    func addFileWasCreatedOrModifiedEvent(atPluginPath pluginPath: String, path: String) {
        if var paths = pluginPathToCreatedOrModifiedFilePaths[pluginPath] {
            paths.append(path)
            pluginPathToCreatedOrModifiedFilePaths[pluginPath] = paths
        } else {
            pluginPathToCreatedOrModifiedFilePaths[pluginPath] = [path]

            fireCreatedOrModifiedEventsAfterDelay(for: pluginPath)
        }
    }

    func addItemWasRemovedEvent(atPluginPath pluginPath: String, path: String) {
        if var paths = pluginPathToRemovedItemPaths[pluginPath] {
            paths.append(path)
            pluginPathToRemovedItemPaths[pluginPath] = paths
        } else {
            pluginPathToRemovedItemPaths[pluginPath] = [path]

            fireRemovedEventsAfterDelay(for: pluginPath)
        }
    }

    func fireCreatedOrModifiedEventsAfterDelay(for pluginPath: String) {
        let delay = ClassConstants.fileEventDelay * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            self.fireCreatedOrModifiedEvents(atPluginPath: pluginPath)
        })
    }
    
    func fireRemovedEventsAfterDelay(for pluginPath: String) {
        let delay = ClassConstants.fileEventDelay * Double(NSEC_PER_SEC)
        let time = DispatchTime.now() + Double(Int64(delay)) / Double(NSEC_PER_SEC)
        DispatchQueue.main.asyncAfter(deadline: time, execute: {
            self.fireRemovedEvents(for: pluginPath)
        })
    }
    
    // MARK: Firing Handlers
    
    func fireCreatedOrModifiedEvents(atPluginPath pluginPath: String) {
        let filePaths = pluginPathToCreatedOrModifiedFilePaths[pluginPath]
        let directoryPaths = pluginPathToCreatedOrModifiedDirectoryPaths[pluginPath]
        
        if filePaths == nil && directoryPaths == nil {
            return
        }
        
        delegate?.pluginsDirectoryEventHandler(self,
            handleCreatedOrModifiedEventsAtPluginPath: pluginPath,
            createdOrModifiedDirectoryPaths: directoryPaths,
            createdOrModifiedFilePaths: filePaths)

        pluginPathToCreatedOrModifiedFilePaths[pluginPath] = nil
        pluginPathToCreatedOrModifiedDirectoryPaths[pluginPath] = nil
    }

    func fireRemovedEvents(for pluginPath: String) {
        if let itemPaths = pluginPathToRemovedItemPaths[pluginPath] {
            delegate?.pluginsDirectoryEventHandler(self,
                handleRemovedEventsAtPluginPath: pluginPath,
                removedItemPaths: itemPaths)
            pluginPathToRemovedItemPaths[pluginPath] = nil
        }
    }
    
}
