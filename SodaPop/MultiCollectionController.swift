//
//  PluginsController.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/14/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Cocoa
import Foundation

@objcMembers
public class MultiCollectionController: NSObject {
    private let nameToObjectController: POPKeyToObjectController
    private var mutableObjects = NSMutableArray()

    public init(objects: [AnyObject], key: String) {
        nameToObjectController = POPKeyToObjectController(key: key, objects: objects)
        mutableObjects.addObjects(from: nameToObjectController.allObjects())
        super.init()
    }

    // MARK: Accessing Plugins

    public func object(forKey key: String) -> AnyObject? {
        return nameToObjectController.object(forKey: key) as AnyObject?
    }

    // MARK: Convenience

    public func addObject(_ object: AnyObject) {
        insertObject(object, inObjectsAtIndex: 0)
    }

    public func addObjects(_ objects: [AnyObject]) {
        let indexes = IndexSet(integersIn: 0 ..< objects.count)
        insertObjects(objects, atIndexes: indexes)
    }

    public func removeObject(_ object: AnyObject) {
        let index = indexOfObject(object)
        if index != NSNotFound {
            removeObjectFromObjectsAtIndex(index)
        }
    }

    public func indexOfObject(_ object: AnyObject) -> Int {
        return mutableObjects.index(of: object)
    }

    // MARK: Required Key-Value Coding To-Many Relationship Compliance

    public func objects() -> NSArray {
        return NSArray(array: mutableObjects)
    }

    public func insertObject(_ object: AnyObject, inObjectsAtIndex index: Int) {
        let replacedObject = nameToObjectController.add(object) as AnyObject
        mutableObjects.insert(object, at: index)
        let index = mutableObjects.index(of: replacedObject)
        guard index != NSNotFound else {
            return
        }

        removeObjectFromObjectsAtIndex(index)
    }

    public func insertObjects(_ objects: [AnyObject], atIndexes indexes: IndexSet) {
        let replacedObjects = nameToObjectController.addObjects(from: objects)
        mutableObjects.insert(objects, at: indexes)

        let indexes = mutableObjects.indexesOfObjects(options: [], passingTest: {
            (object, _, _) -> Bool in
            (replacedObjects as NSArray).contains(object)
        })

        removeObjectsAtIndexes(indexes)
    }

    public func removeObjectFromObjectsAtIndex(_ index: Int) {
        let object: AnyObject = mutableObjects.object(at: index) as AnyObject
        nameToObjectController.remove(object)
        mutableObjects.removeObject(at: index)
    }

    public func removeObjectsAtIndexes(_ indexes: IndexSet) {
        let objects = mutableObjects.objects(at: indexes)
        nameToObjectController.removeObjects(from: objects)
        mutableObjects.removeObjects(at: indexes)
    }
}
