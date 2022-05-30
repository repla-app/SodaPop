//
//  PluginsDirectoryManager.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 11/8/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import BubbleUp
import Foundation

protocol PluginsDirectoryManagerDelegate: AnyObject {
    func pluginsDirectoryManager(_ pluginsDirectoryManager: PluginsDirectoryManager,
                                 pluginInfoDictionaryWasCreatedOrModifiedAtPluginPath pluginPath: String)
    func pluginsDirectoryManager(_ pluginsDirectoryManager: PluginsDirectoryManager,
                                 pluginInfoDictionaryWasRemovedAtPluginPath pluginPath: String)
}

class PluginsPathHelper {
    class func subpathRange(inPath path: String, untilSubpath subpath: String) -> NSRange {
        // Normalize the subpath so the same range is always returned
        // regardless of the format of the subpath (e.g., number of slashes)
        let normalizedSubpath = subpath.standardizingPath
        let pathAsNSString: NSString = path as NSString
        let subpathRange = pathAsNSString.range(of: normalizedSubpath)
        if subpathRange.location == NSNotFound {
            return subpathRange
        }
        let untilSubpathLength = subpathRange.location + subpathRange.length
        let untilSubpathRange = NSRange(location: 0, length: untilSubpathLength)
        return untilSubpathRange
    }

    class func subpath(fromPath path: String, untilSubpath subpath: String) -> String? {
        let range = subpathRange(inPath: path, untilSubpath: subpath)
        if range.location == NSNotFound {
            return nil
        }
        let pathAsNSString: NSString = path as NSString
        let pathUntilSubpath = pathAsNSString.substring(with: range)
        return pathUntilSubpath
    }

    class func pathComponents(ofPath path: String, afterSubpath subpath: String) -> [String]? {
        let normalizedPath = path.standardizingPath
        let range = subpathRange(inPath: normalizedPath, untilSubpath: subpath)
        if range.location == NSNotFound {
            return nil
        }

        let normalizedPathAsNSString: NSString = normalizedPath as NSString
        let pathComponent = normalizedPathAsNSString.substring(from: range.length)
        let pathComponents = pathComponent.pathComponents

        if pathComponents.count == 0 {
            return pathComponents
        }

        // Remove slashes (path components are sometimes slashes for the first and last component)
        let mutablePathComponents = NSMutableArray(array: pathComponents)
        mutablePathComponents.remove("/")
        return mutablePathComponents as NSArray as? [String]
    }

    class func contains(_ pathComponent: String, subpathComponent: String) -> Bool {
        let pathComponents = pathComponent.pathComponents
        let subpathComponents = subpathComponent.pathComponents
        for index in 0 ..< subpathComponents.count {
            let pathComponent = pathComponents[index] as NSString
            let subpathComponent = subpathComponents[index]
            if !pathComponent.isEqual(to: subpathComponent) {
                return false
            }
        }
        return true
    }

    class func does(pathComponent: String, matchPathComponent: String) -> Bool {
        // Breaking the path components up into an array removes path
        // separators like slashes from being part of the comparison.
        // E.g., `Contents/` is equal to `Contents`
        let pathComponents = pathComponent.pathComponents
        let matchPathComponents = matchPathComponent.pathComponents
        if pathComponents.count != matchPathComponents.count {
            return false
        }
        for index in 0 ..< pathComponents.count {
            let pathComponent = pathComponents[index] as NSString
            let matchPathComponent = matchPathComponents[index]
            if !pathComponent.isEqual(to: matchPathComponent) {
                return false
            }
        }
        return true
    }

    class func contains(_ path: String, subpath: String) -> Bool {
        if let pathUntilSubpath = self.subpath(fromPath: path, untilSubpath: subpath) {
            return pathUntilSubpath.standardizingPath == subpath.standardizingPath
        }
        return false
    }
}

class PluginsDirectoryManager: NSObject, BBUDirectoryWatcherDelegate, PluginsDirectoryEventHandlerDelegate {
    weak var delegate: PluginsDirectoryManagerDelegate?
    let pluginsDirectoryEventHandler: PluginsDirectoryEventHandler
    let directoryWatcher: BBUDirectoryWatcher
    let pluginsDirectoryURL: URL
    init(pluginsDirectoryURL: URL) {
        self.pluginsDirectoryURL = pluginsDirectoryURL
        directoryWatcher = BBUDirectoryWatcher(url: pluginsDirectoryURL)
        pluginsDirectoryEventHandler = PluginsDirectoryEventHandler()
        super.init()

        directoryWatcher.delegate = self
        pluginsDirectoryEventHandler.delegate = self
    }

    // MARK: BBUDirectoryWatcherDelegate

    func directoryWatcher(_: BBUDirectoryWatcher, directoryWasCreatedOrModifiedAtPath path: String) {
        assert(isSubpathOfPluginsDirectory(path), "The path should be a subpath of the plugins directory")

        if let pluginPath = pluginPath(fromPath: path) {
            pluginsDirectoryEventHandler.addDirectoryWasCreatedOrModifiedEvent(atPluginPaths: pluginPath, forPath: path)
        }
    }

    func directoryWatcher(_: BBUDirectoryWatcher, fileWasCreatedOrModifiedAtPath path: String) {
        assert(isSubpathOfPluginsDirectory(path), "The path should be a subpath of the plugins directory")

        if let pluginPath = pluginPath(fromPath: path) {
            pluginsDirectoryEventHandler.addFileWasCreatedOrModifiedEvent(atPluginPath: pluginPath, path: path)
        }
    }

    func directoryWatcher(_: BBUDirectoryWatcher, itemWasRemovedAtPath path: String) {
        assert(isSubpathOfPluginsDirectory(path), "The path should be a subpath of the plugins directory")

        if let pluginPath = pluginPath(fromPath: path) {
            pluginsDirectoryEventHandler.addItemWasRemovedEvent(atPluginPath: pluginPath, path: path)
        }
    }

    // MARK: PluginsDirectoryEventHandlerDelegate

    func pluginsDirectoryEventHandler(_: PluginsDirectoryEventHandler,
                                      handleCreatedOrModifiedEventsAtPluginPath pluginPath: String,
                                      createdOrModifiedDirectoryPaths directoryPaths: [String]?,
                                      createdOrModifiedFilePaths filePaths: [String]?) {
        if let filePaths = filePaths {
            for path in filePaths {
                if shouldFireInfoDictionaryWasCreatedOrModified(atPluginPath: pluginPath,
                                                                forFileCreatedOrModifiedAtPath: path) {
                    delegate?.pluginsDirectoryManager(self,
                                                      pluginInfoDictionaryWasCreatedOrModifiedAtPluginPath: pluginPath)
                    return
                }
            }
        }

        if let directoryPaths = directoryPaths {
            for path in directoryPaths {
                if shouldFireInfoDictionaryWasCreatedOrModified(atPluginPath: pluginPath,
                                                                forDirectoryCreatedOrModifiedAtPath: path) {
                    delegate?.pluginsDirectoryManager(self,
                                                      pluginInfoDictionaryWasCreatedOrModifiedAtPluginPath: pluginPath)
                    return
                }
            }
        }
    }

    func pluginsDirectoryEventHandler(_: PluginsDirectoryEventHandler,
                                      handleRemovedEventsAtPluginPath pluginPath: String,
                                      removedItemPaths itemPaths: [String]?) {
        if let itemPaths = itemPaths {
            for path in itemPaths {
                if shouldFireInfoDictionaryWasRemoved(atPluginPath: pluginPath,
                                                      forItemRemovedAtPath: path) {
                    delegate?.pluginsDirectoryManager(self, pluginInfoDictionaryWasRemovedAtPluginPath: pluginPath)
                    return
                }
            }
        }
    }

    // MARK: Evaluating Events

    func shouldFireInfoDictionaryWasCreatedOrModified(atPluginPath pluginPath: String,
                                                      forDirectoryCreatedOrModifiedAtPath path: String) -> Bool {
        for pathComponent in infoPathComponents {
            if containsValidInfoDictionarySubpath(path, atPathComponent: pathComponent),
               doesInfoDictionaryExist(atPluginPath: pluginPath, atPathComponent: pathComponent) {
                return true
            }
        }
        return false
    }

    func shouldFireInfoDictionaryWasCreatedOrModified(atPluginPath pluginPath: String,
                                                      forFileCreatedOrModifiedAtPath path: String) -> Bool {
        for pathComponent in infoPathComponents {
            if isValidInfoDictionary(atPath: path, atPathComponent: pathComponent),
               doesInfoDictionaryExist(atPluginPath: pluginPath, atPathComponent: pathComponent) {
                return true
            }
        }
        return false
    }

    func shouldFireInfoDictionaryWasRemoved(atPluginPath pluginPath: String,
                                            forItemRemovedAtPath path: String) -> Bool {
        for pathComponent in infoPathComponents {
            if containsValidInfoDictionarySubpath(path, atPathComponent: pathComponent),
               !doesInfoDictionaryExist(atPluginPath: pluginPath, atPathComponent: pathComponent) {
                return true
            }
        }
        return false
    }

    // MARK: Helpers

    func isValidInfoDictionary(atPath path: String, atPathComponent pathComponent: String) -> Bool {
        return hasValidInfoDictionarySubpath(path,
                                             requireExactInfoDictionaryMatch: true,
                                             atPathComponent: pathComponent)
    }

    func containsValidInfoDictionarySubpath(_ path: String, atPathComponent pathComponent: String) -> Bool {
        return hasValidInfoDictionarySubpath(path,
                                             requireExactInfoDictionaryMatch: false,
                                             atPathComponent: pathComponent)
    }

    func hasValidInfoDictionarySubpath(_ path: String,
                                       requireExactInfoDictionaryMatch: Bool,
                                       atPathComponent pathComponent: String) -> Bool {
        if let pluginPathComponents = pluginPathComponents(fromPath: path) {
            var pluginSubpathComponents = pluginPathComponents as? [String]
            if let firstPathComponent = pluginSubpathComponents?.remove(at: 0) {
                if firstPathComponent.pathExtension != pluginFileExtension {
                    return false
                }

                if let pluginSubpathComponents = pluginSubpathComponents {
                    let pluginSubpath = NSString.path(withComponents: pluginSubpathComponents)

                    if requireExactInfoDictionaryMatch {
                        return PluginsPathHelper.does(pathComponent: pathComponent,
                                                      matchPathComponent: pluginSubpath)
                    } else {
                        return PluginsPathHelper.contains(pathComponent,
                                                          subpathComponent: pluginSubpath)
                    }
                }
            }
        }
        return false
    }

    func doesInfoDictionaryExist(atPluginPath pluginPath: String, atPathComponent pathComponent: String) -> Bool {
        let infoDictionaryPath = pluginPath.appendingPathComponent(pathComponent)
        var isDir: ObjCBool = false
        let fileExists = FileManager.default.fileExists(atPath: infoDictionaryPath, isDirectory: &isDir)
        return fileExists && !isDir.boolValue
    }

    func isInfoDictionarySubdirectory(ofPath _: String) -> Bool {
        return false
    }

    func pluginPath(fromPath path: String) -> String? {
        if let pluginPathComponent = pluginPathComponent(fromPath: path) {
            let pluginPath = pluginsDirectoryURL.path.appendingPathComponent(pluginPathComponent)
            return pluginPath
        }
        return nil
    }

    func pluginPathComponent(fromPath path: String) -> String? {
        if let pathComponents = PluginsPathHelper.pathComponents(ofPath: path,
                                                                 afterSubpath: pluginsDirectoryURL.path),
            pathComponents.count > 0 {
            let pluginSubpathComponents = pathComponents as Array
            let pathComponent = pluginSubpathComponents[0]
            return pathComponent
        }
        return nil
    }

    func pluginPathComponents(fromPath path: String) -> NSArray? {
        let pathComponents = PluginsPathHelper.pathComponents(ofPath: path, afterSubpath: pluginsDirectoryURL.path)
        return pathComponents as NSArray?
    }

    func isSubpathOfPluginsDirectory(_ path: String) -> Bool {
        return PluginsPathHelper.contains(path, subpath: pluginsDirectoryURL.path)
    }

    override var description: String {
        return "pluginsDirectoryURL.path = \(pluginsDirectoryURL.path)"
    }
}
