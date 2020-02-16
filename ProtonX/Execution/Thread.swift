//
//  Thread.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 03/02/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation

import RawMemory

public struct EnumeratedArray<Index,Element>:ExpressibleByArrayLiteral  where Index:RawRepresentable,Index.RawValue == Int,Index:CaseIterable
    {
    public typealias ArrayLiteralElement = Element
    
    internal var elements:[Element] = []
    
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
    public let exceptionStack:StackSegment
    
    public init(memory:Memory)
        {
        self.memory = memory
        self.stack = memory.makeStackSegment(sizeInMegabytes: 4)
        self.exceptionStack = memory.makeStackSegment(sizeInMegabytes: 2)
        self.registers.elements = Array<Word>(repeating: 0, count: Instruction.Register.allCases.reduce(0,{max($0,$1.rawValue)}))
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
        
    public func execute(codeBlockAddress:Proton.Address) throws
        {
        self.stack.push(self.registers[.cp])
        self.stack.push(self.registers[.ip])
        self.registers[.cp] = codeBlockAddress
        self.registers[.ip] = wordAtAddress(wordAtAddress(codeBlockAddress + Word(3 * MemoryLayout<Word>.stride)) + Word(5 * MemoryLayout<Word>.stride)) + Word(8 * MemoryLayout<Word>.stride)
        try self.execute()
        self.registers[.ip] = self.stack.pop()
        self.registers[.cp] = self.stack.pop()
        }
        
    private func execute() throws
        {
        var address = self.registers[.ip]
        var instruction = Instruction.makeInstruction(atAddress: address)
        while instruction.operation != .RET
            {
            try instruction.execute(on: self)
            address +=  instruction.totalByteCount
            instruction = Instruction.makeInstruction(atAddress: address)
            }
        }
        
    public func call(address:Proton.Address) throws
        {
        let codeBlock = CodeBlockPointer(address)
        self.saveExecutionContext()
        self.registers[.cp] = codeBlock.address
        self.registers[.ip] = 0
        try self.execute()
        self.restoreExecutionContext()
        }
        
    public func push(_ register:Instruction.Register)
        {
        }
    }
