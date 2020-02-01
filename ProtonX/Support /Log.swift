//
//  Log.swift
//  argon
//
//  Created by Vincent Coetzee on 31/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation

public struct Log
    {
    private static var logger:Logger = Logger()
    
    public static func silent()
        {
        self.logger = Logger()
        }
        
    public static func console()
        {
        self.logger = ConsoleLogger()
        }
        
    public static func file(path:String)
        {
        self.logger = FileLogger(path: path)
        }
        
    public static func log(_ line:String)
        {
        self.logger.print(line)
        }
        
    public static func log(_ elements:Line.Element...)
        {
        self.logger.print(Line(elements).string)
        }
        
    private class Logger
        {
        public func print(_ line:String)
            {
            }
        }
        
    private class ConsoleLogger:Logger
        {
        public override func print(_ line:String)
            {
            Swift.print(line)
            }
        }
        
    private class FileLogger:Logger
        {
        private let path:String
        
        public init(path:String)
            {
            self.path = path
            }
            
        public override func print(_ line:String)
            {
            fatalError("Not implemented")
            }
        }
    }
