//
//  PluginsController.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/14/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation
import Cocoa

@objc class MultiCollectionController: NSObject {
    private let nameToObjectController: WCLKeyToObjectController
    private var mutableObjects = NSMutableArray()
    
    init(objects: [AnyObject], key: String) {
        self.nameToObjectController = WCLKeyToObjectController(key: key, objects: objects)
        self.mutableObjects.addObjects(from: self.nameToObjectController.allObjects())
        super.init()
    }
    
    // MARK: Accessing Plugins
    
    func object(forKey key: String) -> AnyObject? {
        return nameToObjectController.object(forKey: key) as AnyObject?
    }

    // MARK: Convenience
    
    func addObject(_ object: AnyObject) {
        insertObject(object, inObjectsAtIndex: 0)
    }
    
    func addObjects(_ objects: [AnyObject]) {
        let range = NSMakeRange(0, objects.count)
        let indexes = IndexSet(integersIn: range.toRange() ?? 0..<0)
        insertObjects(objects, atIndexes: indexes)
    }
    
    func removeObject(_ object: AnyObject) {
        let index = indexOfObject(object)
        if index != NSNotFound {
            removeObjectFromObjectsAtIndex(index)
        }
    }
    
    func indexOfObject(_ object: AnyObject) -> Int {
         return mutableObjects.index(of: object)
    }
    
    // MARK: Required Key-Value Coding To-Many Relationship Compliance
    
    func objects() -> NSArray {
        return NSArray(array: mutableObjects)
    }
    
    func insertObject(_ object: AnyObject, inObjectsAtIndex index: Int) {
        let replacedObject: AnyObject? = nameToObjectController.add(object) as AnyObject?
        mutableObjects.insert(object, at: index)
        if let replacedObject: AnyObject = replacedObject {
            let index = mutableObjects.index(of: replacedObject)
            if index != NSNotFound {
                removeObjectFromObjectsAtIndex(index)
            }
        }
    }
    
    func insertObjects(_ objects: [AnyObject], atIndexes indexes: IndexSet) {

        let replacedObjects = nameToObjectController.addObjects(from: objects)
        mutableObjects.insert(objects, at: indexes)

        let indexes = mutableObjects.indexesOfObjects(options: [], passingTest: {
            (object, index, stop) -> Bool in
            return (replacedObjects as NSArray).contains(object)
        })
        
        removeObjectsAtIndexes(indexes)
    }

    func removeObjectFromObjectsAtIndex(_ index: Int) {
        let object: AnyObject = mutableObjects.object(at: index) as AnyObject
        nameToObjectController.remove(object)
        mutableObjects.removeObject(at: index)
    }
    
    func removeObjectsAtIndexes(_ indexes: IndexSet) {
        let objects = mutableObjects.objects(at: indexes)
        nameToObjectController.removeObjects(from: objects)
        mutableObjects.removeObjects(at: indexes)
    }

}
