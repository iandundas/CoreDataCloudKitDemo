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


func when(@autoclosure test:  () -> Bool, action: () -> ()) {
    if test() { action() }
}

func unless(@autoclosure test:  () -> Bool, action: () -> ()) {
    if !test() { action() }
}


// MARK These almost certainly shouldn't be here - move when I've learned where to put them
// (they don't work in any other swift file :S

// https://gist.github.com/JadenGeller/2828e1f7458c8b41a7b0
when(3 == 5){
    println("three equals five")         // Will print!
}

unless(3 == 5){
    println("three does not equal five") // Will never print.
}

when(1 == 1){
    println("one equals one")            // Will print!
}

unless(1 == 1){
    println("one does not equal one")    // Will never print.
}
