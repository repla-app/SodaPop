//
//  PluginsController.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/14/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation
import Cocoa

public class MultiCollectionController: NSObject {
    private let nameToObjectController: WCLKeyToObjectController
    private var mutableObjects = NSMutableArray()
    
    @objc public init(objects: [AnyObject], key: String) {
        self.nameToObjectController = WCLKeyToObjectController(key: key, objects: objects)
        self.mutableObjects.addObjects(from: self.nameToObjectController.allObjects())
        super.init()
    }
    
    // MARK: Accessing Plugins
    
    @objc public func object(forKey key: String) -> AnyObject? {
        return nameToObjectController.object(forKey: key) as AnyObject?
    }

    // MARK: Convenience
    
    @objc public func addObject(_ object: AnyObject) {
        insertObject(object, inObjectsAtIndex: 0)
    }
    
    @objc public func addObjects(_ objects: [AnyObject]) {
        let indexes = IndexSet(integersIn: 0..<objects.count)
        insertObjects(objects, atIndexes: indexes)
    }
    
    @objc public func removeObject(_ object: AnyObject) {
        let index = indexOfObject(object)
        if index != NSNotFound {
            removeObjectFromObjectsAtIndex(index)
        }
    }
    
    @objc public func indexOfObject(_ object: AnyObject) -> Int {
         return mutableObjects.index(of: object)
    }
    
    // MARK: Required Key-Value Coding To-Many Relationship Compliance
    
    @objc public func objects() -> NSArray {
        return NSArray(array: mutableObjects)
    }
    
    @objc public func insertObject(_ object: AnyObject, inObjectsAtIndex index: Int) {
        let replacedObject: AnyObject? = nameToObjectController.add(object) as AnyObject?
        mutableObjects.insert(object, at: index)
        if let replacedObject: AnyObject = replacedObject {
            let index = mutableObjects.index(of: replacedObject)
            if index != NSNotFound {
                removeObjectFromObjectsAtIndex(index)
            }
        }
    }
    
    @objc public func insertObjects(_ objects: [AnyObject], atIndexes indexes: IndexSet) {

        let replacedObjects = nameToObjectController.addObjects(from: objects)
        mutableObjects.insert(objects, at: indexes)

        let indexes = mutableObjects.indexesOfObjects(options: [], passingTest: {
            (object, index, stop) -> Bool in
            return (replacedObjects as NSArray).contains(object)
        })
        
        removeObjectsAtIndexes(indexes)
    }

    @objc public func removeObjectFromObjectsAtIndex(_ index: Int) {
        let object: AnyObject = mutableObjects.object(at: index) as AnyObject
        nameToObjectController.remove(object)
        mutableObjects.removeObject(at: index)
    }
    
    @objc public func removeObjectsAtIndexes(_ indexes: IndexSet) {
        let objects = mutableObjects.objects(at: indexes)
        nameToObjectController.removeObjects(from: objects)
        mutableObjects.removeObjects(at: indexes)
    }

}
