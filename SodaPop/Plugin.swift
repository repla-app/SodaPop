//
//  PluginType.swift
//  SodaPop
//
//  Created by Roben Kleene on 11/19/20.
//  Copyright © 2020 Roben Kleene. All rights reserved.
//

import Foundation

public protocol Plugin {
    var hidden: Bool { get }
    var promptInterrupt: Bool { get }
    var usesEnvironment: Bool { get }
    // `debugModeEnabled` is three state, `nil` means use the user prefrence
    var debugModeEnabled: Bool? { get }
    // `autoShowLog` is three state, `nil` means use the user prefrence
    var autoShowLog: Bool? { get }
    var transparentBackground: Bool { get }
    var pluginKind: PluginKind { get }

    var resourcePath: String? { get }
    var resourceURL: URL? { get }
    var directoryURL: URL? { get }

    // MARK: Properties

    dynamic var name: String { get }
    dynamic var identifier: String { get }

    dynamic var command: String? { get }

    var commandPath: String? { get }

    dynamic var suffixes: [String] { get }

    dynamic var type: String { get }

    dynamic var editable: Bool { get }

    var description: String { get }
}
