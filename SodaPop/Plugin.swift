//
//  Plugin.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

@objcMembers
public class Plugin: POPPlugin {
    public let autoShowLog: Bool? // `autoShowLog` is three state, `nil` means use the user prefrence
    public let debugModeEnabled: Bool? // `debugModeEnabled` is three state, `nil` means use the user prefrence
    public let hidden: Bool
    public let promptInterrupt: Bool
    public let transparentBackground: Bool
    public let usesEnvironment: Bool
    public let directoryPath: String
    public let directoryURL: URL
    public let kind: PluginKind

    public var path: String
    public var url: URL
    
    public var command: String? {
        get {
            assertionFailure("Subclasses must override")
            return nil
        }
        set {
            assertionFailure("Subclasses must override")
        }
    }
    public var commandPath: String? {
        get {
            assertionFailure("Subclasses must override")
            return nil
        }
    }
    public var editable: Bool {
        get {
            assertionFailure("Subclasses must override")
            return false
        }
        set {
            assertionFailure("Subclasses must override")
        }
    }
    public var identifier: String {
        get {
            assertionFailure("Subclasses must override")
            return ""
        }
        set {
            assertionFailure("Subclasses must override")
        }
    }
    public var name: String {
        get {
            assertionFailure("Subclasses must override")
            return ""
        }
        set {
            assertionFailure("Subclasses must override")
        }
    }
    public var suffixes: [String]? {
        get {
            assertionFailure("Subclasses must override")
            return [String]()
        }
        set {
            assertionFailure("Subclasses must override")
        }
    }

    init(autoShowLog: Bool?,
         debugModeEnabled: Bool?,
         hidden: Bool,
         promptInterrupt: Bool,
         transparentBackground: Bool,
         usesEnvironment: Bool,
         directoryPath: String,
         directoryURL: URL,
         path: String,
         kind: PluginKind,
         url: URL) {
        self.autoShowLog = autoShowLog
        self.debugModeEnabled = debugModeEnabled
        self.hidden = hidden
        self.promptInterrupt = promptInterrupt
        self.transparentBackground = transparentBackground
        self.usesEnvironment = usesEnvironment
        self.directoryPath = directoryPath
        self.directoryURL = directoryURL
        self.path = path
        self.kind = kind
        self.url = url
    }

    func isEqual(toOther plugin: Plugin) -> Bool {
        if name != plugin.name {
            return false
        }

        if identifier != plugin.identifier {
            return false
        }

        if editable != plugin.editable {
            return false
        }

        if kind != plugin.kind {
            return false
        }

        if command != plugin.command {
            return false
        }

        if commandPath != plugin.commandPath {
            return false
        }

        if url != plugin.url {
            return false
        }

        if type(of: plugin) != type(of: self) {
            return false
        }

        return true
    }
}
