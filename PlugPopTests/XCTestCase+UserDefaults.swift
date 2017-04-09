//
//  XCTestCase+UserDefaults.swift
//  Web Console
//
//  Created by Roben Kleene on 10/1/15.
//  Copyright © 2015 Roben Kleene. All rights reserved.
//

import Foundation

@testable import Web_Console

let testMockUserDefaultsSuiteName = "com.1percenter.WebConsoleTests"

extension XCTestCase {
    
    func mockUserDefaultsSetUp() {
        let userDefaultsURL = Bundle.main.url(forResource: userDefaultsFilename, withExtension: userDefaultsFileExtension)!
        let userDefaultsDictionary = NSDictionary(contentsOf: userDefaultsURL) as! [String: AnyObject]
        let userDefaults = UserDefaults(suiteName: testMockUserDefaultsSuiteName)!
        userDefaults.register(defaults: userDefaultsDictionary)
        let userDefaultsController = NSUserDefaultsController(defaults: userDefaults, initialValues: userDefaultsDictionary)
        UserDefaultsManager.setOverrideStandardUserDefaults(userDefaults)
        UserDefaultsManager.setOverrideSharedUserDefaultsController(userDefaultsController)
    }
    
    func mockUserDefaultsTearDown() {
        UserDefaultsManager.setOverrideStandardUserDefaults(nil)
        UserDefaultsManager.setOverrideSharedUserDefaultsController(nil)
    }

}
