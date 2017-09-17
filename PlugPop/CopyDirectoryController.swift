
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
    typealias CleanUpCompletion = ((Error?) -> ())?
    let copyTempDirectoryURL: URL
    var tempDirectoryName: String
    var trashDirectoryName: String {
        return tempDirectoryName + " Recovered"
    }
    
    // Creates a directory with `tempDirectoryName` in `tempDirectoryURL`
    init(tempDirectoryURL: URL,
         tempDirectoryName: String)
    {
        self.tempDirectoryName = tempDirectoryName
        self.copyTempDirectoryURL = tempDirectoryURL.appendingPathComponent(tempDirectoryName)
    }

    // MARK: Public
    
    func cleanUp(completion: CleanUpCompletion) {
            move(contentsOf: copyTempDirectoryURL,
                 toDirectoryInTrashWithName: trashDirectoryName,
                 completion: completion)
    }
    
    func copyItem(at URL: URL,
                  completionHandler handler: @escaping (_ URL: Foundation.URL?, _ error: NSError?) -> Void)
    {
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

    func move(contentsOf URL: URL,
              toDirectoryInTrashWithName directoryInTrashName: String,
              completion: CleanUpCompletion)
    {
        var validCachesURL = false
        let hasPrefix = URL.path.hasPrefix(copyTempDirectoryURL.path)
        validCachesURL = hasPrefix

        if !validCachesURL {
            assert(false, "The URL should be a valid caches URL")
            completion?(nil)
            return
        }

        let directoryToTrashURL = URL.appendingPathComponent(directoryInTrashName)

        var foundFilesToRecover = false
        if let enumerator = FileManager.default.enumerator(at: URL,
                                                           includingPropertiesForKeys: [URLResourceKey.nameKey],
                                                           options: [.skipsHiddenFiles, .skipsSubdirectoryDescendants],
                                                           errorHandler: nil)
        {
            while let fileURL = enumerator.nextObject() as? URL {
                var resourceName: AnyObject?
                do {
                    try (fileURL as NSURL).getResourceValue(&resourceName, forKey: .nameKey)
                } catch let error as NSError {
                    completion?(error)
                    return
                }

                guard let filename = resourceName as? String else {
                    assert(false)
                    continue
                }

                if filename == directoryInTrashName {
                    continue
                }

                if !foundFilesToRecover {
                    do {
                        try FileManagerHelper.createDirectoryIfMissing(at: directoryToTrashURL)
                    } catch let error as NSError {
                        completion?(error)
                        return
                    }
                    
                    foundFilesToRecover = true
                }
                
                let UUID = Foundation.UUID()
                let UUIDString = UUID.uuidString
                let destinationFileURL = directoryToTrashURL.appendingPathComponent(UUIDString)

                do {
                    try FileManager.default.moveItem(at: fileURL,
                                                     to: destinationFileURL)
                } catch let error as NSError {
                    completion?(error)
                    return
                }
            }
        }

        if !foundFilesToRecover {
            completion?(nil)
            return
        }

        NSWorkspace.shared().recycle([directoryToTrashURL]) { (_, error) in
            return completion?(error)
        }
    }

    // MARK: Private Duplicate Helpers
    
    private class func copyItem(at URL: URL, to directoryURL: URL) throws -> Foundation.URL? {
        do {
            // Setup the destination directory
            try FileManagerHelper.createDirectoryIfMissing(at: directoryURL)
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

}
