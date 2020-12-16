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
    // MARK: Constants
    
    public let autoShowLog: Bool? // `autoShowLog` is three state, `nil` means use the user prefrence
    public let debugModeEnabled: Bool? // `debugModeEnabled` is three state, `nil` means use the user prefrence
    public let hidden: Bool
    public let kind: PluginKind
    public let path: String
    public let promptInterrupt: Bool
    public let resourcePath: String
    public let resourceURL: URL
    public let transparentBackground: Bool
    public let url: URL
    public let usesEnvironment: Bool

    // MARK: Computed

    public var commandPath: String? {
        if let command = command {
            return resourcePath.appendingPathComponent(command)
        }
        return nil
    }

    public dynamic var kindName: String {
        return kind.name()
    }

    // MARK: Variables
    
    public var editable: Bool {
        willSet {
            assert(editable, "The plugin should be editable")
        }
    }

    public var command: String? {
        willSet {
            assert(editable, "The plugin should be editable")
        }
    }

    public var identifier: String {
        willSet {
            assert(editable, "The plugin should be editable")
        }
    }
    public var name: String {
        willSet {
            assert(editable, "The plugin should be editable")
        }
    }
    public var suffixes: [String]? {
        willSet {
            assert(editable, "The plugin should be editable")
        }
    }

    init(autoShowLog: Bool?,
         debugModeEnabled: Bool?,
         hidden: Bool,
         promptInterrupt: Bool,
         transparentBackground: Bool,
         usesEnvironment: Bool,
         path: String,
         url: URL,
         resourcePath: String,
         kind: PluginKind,
         resourceURL: URL,
         // Variable
         editable: Bool,
         command: String?,
         identifier: String,
         name: String,
         suffixes: [String]?) {
        self.autoShowLog = autoShowLog
        self.debugModeEnabled = debugModeEnabled
        self.hidden = hidden
        self.promptInterrupt = promptInterrupt
        self.transparentBackground = transparentBackground
        self.usesEnvironment = usesEnvironment
        self.path = path
        self.url = url
        self.resourcePath = resourcePath
        self.kind = kind
        self.resourceURL = resourceURL
        self.editable = editable
        self.command = command
        self.identifier = identifier
        self.name = name
        self.suffixes = suffixes

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

        if resourceURL != plugin.resourceURL {
            return false
        }

        if type(of: plugin) != type(of: self) {
            return false
        }

        return true
    }
}
