
//
//  DirectoryDuplicateController.swift
//  PluginEditorPrototype
//
//  Created by Roben Kleene on 1/4/15.
//  Copyright (c) 2015 Roben Kleene. All rights reserved.
//

import Foundation
import Cocoa

class CopyDirectoryController {
    let copyTempDirectoryURL: URL
    let tempDirectoryName: String
    var trashDirectoryName: String {
        get {
            return tempDirectoryName + " Recovered"
        }
    }
    
    init(tempDirectoryName: String) {
        self.tempDirectoryName = tempDirectoryName
        self.copyTempDirectoryURL = Directory.caches.URL().appendingPathComponent(tempDirectoryName)
        do {
            try self.cleanUp()
        } catch let error as NSError {
            assert(false, "Failed to clean up \(error)")
        }
    }
    

    // MARK: Public
    
    func cleanUp() throws {
        do {
            try type(of: self).move(contentsOf: copyTempDirectoryURL, toDirectoryInTrashWithName: trashDirectoryName)
        } catch let error as NSError {
            throw error
        }
    }
    
    func copyItem(at URL: Foundation.URL, completionHandler handler: @escaping (_ URL: Foundation.URL?, _ error: NSError?) -> Void) {
        DispatchQueue.global(qos: DispatchQoS.QoSClass.default).async {
            do {
                let copiedURL = try type(of: self).copyItem(at: URL, to: self.copyTempDirectoryURL)
                DispatchQueue.main.async {
                    handler(copiedURL, nil)
                    if let path = copiedURL?.path {
                        let fileExists = FileManager.default.fileExists(atPath: path)
                        assert(!fileExists, "The file should not exist")
                    } else {
                        assert(false, "Getting the path should succeed")
                    }
                }
            } catch let error as NSError {
                handler(nil, error)
            }
        }
    }
    

    // MARK: Private Clean Up Helpers

    class func move(contentsOf URL: Foundation.URL, toDirectoryInTrashWithName trashDirectoryName: String) throws {
        var validCachesURL = false
        let hasPrefix = URL.path.hasPrefix(Directory.caches.path())
        validCachesURL = hasPrefix

        if !validCachesURL {
            assert(false, "The URL should be a valid caches URL")
            return
        }

        var foundFilesToRecover = false
        if let enumerator = FileManager.default.enumerator(at: URL,
            includingPropertiesForKeys: [URLResourceKey.nameKey],
            options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants],
            errorHandler: nil)
        {
            while let fileURL = enumerator.nextObject() as? Foundation.URL {
                
                var filename: AnyObject?
                do {
                    try (fileURL as NSURL).getResourceValue(&filename, forKey: URLResourceKey.nameKey)
                } catch let error as NSError {
                    throw error
                }
                
                if let filename = filename as? String {
                    if filename == trashDirectoryName {
                        continue
                    }

                    let trashDirectoryURL = URL.appendingPathComponent(trashDirectoryName)
                    if !foundFilesToRecover {
                        do {
                            try createDirectoryIfMissing(at: trashDirectoryURL)
                        } catch let error as NSError {
                            throw error
                        }
                        
                        foundFilesToRecover = true
                    }
                    
                    let UUID = Foundation.UUID()
                    let UUIDString = UUID.uuidString
                    let destinationFileURL = trashDirectoryURL.appendingPathComponent(UUIDString)
                    do {
                        try FileManager.default.moveItem(at: fileURL, to: destinationFileURL)
                    } catch let error as NSError {
                        throw error
                    }
                }
            }
        }

        if !foundFilesToRecover {
            return
        }

        NSWorkspace.shared().performFileOperation(NSWorkspaceRecycleOperation,
            source: URL.path,
            destination: "",
            files: [trashDirectoryName],
            tag: nil)
    }
    

    // MARK: Private Duplicate Helpers
    
    private class func copyItem(at URL: URL, to directoryURL: URL) throws -> Foundation.URL? {
        do {
            // Setup the destination directory
            try createDirectoryIfMissing(at: directoryURL)
        } catch let error as NSError {
            throw error
        }
        
        let uuid = UUID()
        let uuidString = uuid.uuidString
        let destinationURL = directoryURL.appendingPathComponent(uuidString)

        do {
            try FileManager.default.copyItem(at: URL, to: destinationURL)
            return destinationURL
        } catch let error as NSError {
            throw error
        }
    }


    // MARK: Private Create Directory Helpers
    
    private class func createDirectoryIfMissing(atPath path: String) throws {
        // TODO: Should set error instead of assert
        var isDir: ObjCBool = false
        let exists = FileManager.default.fileExists(atPath: path, isDirectory: &isDir)

        if exists {
            if !isDir.boolValue {
                throw FileSystemError.fileExistsForDirectoryError
            }
            return
        }
        
        do {
            try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
        } catch let error as NSError {
            throw error
        }
    }
    
    private class func createDirectoryIfMissing(at URL: URL) throws {
        do {
            try createDirectoryIfMissing(atPath: URL.path)
        } catch let error as NSError {
            throw error
        }
    }
}
