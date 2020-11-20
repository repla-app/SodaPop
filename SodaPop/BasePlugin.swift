//
//  Plugin.swift
//  PluginManagerPrototype
//
//  Created by Roben Kleene on 9/13/14.
//  Copyright (c) 2014 Roben Kleene. All rights reserved.
//

import Cocoa

@objcMembers
public class BasePlugin: POPPlugin {
    let hidden: Bool
    public let promptInterrupt: Bool
    public let usesEnvironment: Bool
    // `debugModeEnabled` is three state, `nil` means use the user prefrence
    public let debugModeEnabled: Bool?
    // `autoShowLog` is three state, `nil` means use the user prefrence
    public let autoShowLog: Bool?
    public let transparentBackground: Bool
    let pluginKind: PluginKind

    init(hidden: Bool,
         promptInterrupt: Bool,
         usesEnvironment: Bool,
         debugModeEnabled: Bool,
         autoShowLog: Bool,
         transparentBackground: Bool,
         pluginKind: PluginKind) {
        self.hidden = hidden
        self.promptInterrupt = promptInterrupt
        self.usesEnvironment = usesEnvironment
        self.debugModeEnabled = debugModeEnabled
        self.autoShowLog = autoShowLog
        self.transparentBackground = transparentBackground
        self.pluginKind = pluginKind
    }
}
