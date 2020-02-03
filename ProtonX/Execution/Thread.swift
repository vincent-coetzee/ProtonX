//
//  Thread.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 03/02/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
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
        self.stack = memory.makeStackSegment(sizeInMegabytes: 16)
        for register in Instruction.Register.allCases
            {
            self.registers[register] = 0
            }
        }
        
    private func saveExecutionContext()
        {
        self.stack.push(self.registers[.cp])
        self.stack.push(self.registers[.ip])
        }
        
    private func restoreExecutionContext()
        {
        self.registers[.ip] = self.stack.pop()
        self.registers[.cp] = self.stack.pop()
        }
        
    private func run()
        {
        let instruction = Instruction(at: 
        }
        
    public func call(codeBlock:CodeBlockPointer)
        {
        self.saveExecutionContext()
        self.registers[.cp] = pointerAsAddress(codeBlock.pointer)
        self.registers[.ip] = codeBlock.instructionsAddress
        self.run()
        self.restoreExecutionContext()
        }
        
    public func push(_ register:Instruction.Register)
        {
        }
    }
