//
//  PluginType.swift
//  SodaPop
//
//  Created by Roben Kleene on 11/19/20.
//  Copyright © 2020 Roben Kleene. All rights reserved.
//

import Foundation

public protocol Plugin: Equatable {
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

    dynamic var name: String { get set }
    dynamic var identifier: String { get set }

    dynamic var command: String? { get set }

    var commandPath: String? { get set }

    dynamic var suffixes: [String] { get set }

    dynamic var type: String { get }

    dynamic var editable: Bool { get set }

    var description: String { get }
}
