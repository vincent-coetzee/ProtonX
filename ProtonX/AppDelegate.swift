//
//  AppDelegate.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 01/02/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {



    func applicationDidFinishLaunching(_ aNotification: Notification)
        {
        MemorySegment.test()
        }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }


}

