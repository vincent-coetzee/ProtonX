//
//  Thread.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 03/02/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class Thread
    {    
    public let memory:Memory
    public var registers:Array<Word>
    public let stack:StackSegment
    public let exceptionStack:StackSegment
    
    public init(memory:Memory)
        {
        self.memory = memory
        self.stack = memory.makeStackSegment(sizeInMegabytes: 4)
        self.exceptionStack = memory.makeStackSegment(sizeInMegabytes: 2)
        self.registers = Array<Word>(repeating: 0, count: Instruction.Register.allCases.reduce(0,{max($0,$1.rawValue)}))
        }
        
    private func saveExecutionContext()
        {
        self.stack.push(self.registers[Instruction.Register.cbp.rawValue])
        self.stack.push(self.registers[Instruction.Register.ip.rawValue])
        }
        
    private func restoreExecutionContext()
        {
        self.registers[Instruction.Register.ip.rawValue] = self.stack.pop()
        self.registers[Instruction.Register.cbp.rawValue] = self.stack.pop()
        }
        
    public func execute(codeBlockAddress:Proton.Address) throws
        {
        self.stack.push(self.registers[Instruction.Register.cbp.rawValue])
        self.stack.push(self.registers[Instruction.Register.ip.rawValue])
        self.registers[Instruction.Register.cbp.rawValue] = codeBlockAddress
        self.registers[Instruction.Register.ip.rawValue] = CodeBlockPointer.instructionAddress(of: codeBlockAddress)
        try self.execute()
        self.registers[Instruction.Register.ip.rawValue] = self.stack.pop()
        self.registers[Instruction.Register.cbp.rawValue] = self.stack.pop()
        }
        
    private func execute() throws
        {
        var instruction = Instruction.makeInstruction(atAddress: self.registers[Instruction.Register.ip.rawValue])
        while instruction.operation != .RET
            {
            self.registers[Instruction.Register.ip.rawValue] += instruction.totalByteCount
            try instruction.execute(on: self)
            instruction = Instruction.makeInstruction(atAddress: self.registers[Instruction.Register.ip.rawValue])
            }
        }
        
    public func call(codeBlockAddress address:Proton.Address) throws
        {
        self.saveExecutionContext()
        self.registers[Instruction.Register.cbp.rawValue] = address
        self.registers[Instruction.Register.ip.rawValue] = CodeBlockPointer.instructionAddress(of: address)
        try self.execute()
        self.restoreExecutionContext()
        }
        
    public func push(_ register:Instruction.Register)
        {
        }
    }
