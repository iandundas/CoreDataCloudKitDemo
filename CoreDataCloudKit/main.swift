//
//  File.swift
//  CoreDataCloudKit
//
//  Created by Ian Dundas on 31/07/2015.
//  Copyright (c) 2015 Ian Dundas. All rights reserved.
//

import Foundation
import UIKit

let isRunningTests = NSClassFromString("XCTestCase") != nil

if isRunningTests {
   UIApplicationMain(Process.argc, Process.unsafeArgv, nil, NSStringFromClass(TestingAppDelegate))
} else {
   UIApplicationMain(Process.argc, Process.unsafeArgv, nil, NSStringFromClass(AppDelegate))
}
