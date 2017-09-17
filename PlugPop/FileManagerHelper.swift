//
//  FileManagerHelper.swift
//  PlugPop
//
//  Created by Roben Kleene on 9/17/17.
//  Copyright © 2017 Roben Kleene. All rights reserved.
//

import Foundation

class FileManagerHelper {
    class func createDirectoryIfMissing(atPath path: String) throws {
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

    class func createDirectoryIfMissing(at URL: URL) throws {
        do {
            try createDirectoryIfMissing(atPath: URL.path)
        } catch let error as NSError {
            throw error
        }
    }
}
