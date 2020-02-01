//
//  ExecutionContext.swift
//  argon
//
//  Created by Vincent Coetzee on 31/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public struct EnumeratedArray<Index,Element>:ExpressibleByArrayLiteral  where Index:RawRepresentable,Index.RawValue == Int
    {
    public typealias ArrayLiteralElement = Element
    
    private var elements:[Element] = []
    
    public init(arrayLiteral elements: Element...)
        {
        self.elements = elements
        }
    
    public subscript(_ index:Index) -> Element
        {
        get
            {
            return(self.elements[Int(index.rawValue)])
            }
        set
            {
            self.elements[Int(index.rawValue)] = newValue
            }
        }
    }
    
extension Float
    {
    public init(bitPattern:Word)
        {
        self.init(bitPattern: UInt32(bitPattern & 4294967295))
        }
    }
    
public class Thread
    {
    public let memory:Memory
    public var registers:EnumeratedArray<Instruction.Register,Word> = []
    public let stack:StackSegment
    
    public init(memory:Memory)
        {
        self.memory = memory
        self.stack = StackSegment(sizeInMegabytes: 16)
        }
        
    }
