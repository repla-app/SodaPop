//
//  DefaultsType.swift
//  PlugPop
//
//  Created by Roben Kleene on 5/13/17.
//  Copyright (c) 2017 Roben Kleene. All rights reserved.
//

@objc public protocol DefaultsType {
    func string(forKey defaultName: String) -> String?
    func removeObject(forKey defaultName: String)
    @objc(setObject:forKey:)
    func set(_ value: Any?, forKey defaultName: String)
}
