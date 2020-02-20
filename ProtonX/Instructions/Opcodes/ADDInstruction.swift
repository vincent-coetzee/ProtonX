//
//  ADDInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/17.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory
    
public class ADDInstruction:ArithmeticInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word,_ word4:Word)
        {
        super.init(word1,word2,word3,word4)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        super.init(operation:.ADD,register1:register1,register2:register2,register3:register3)
        }
        
    public init(register1:Register,immediate:Proton.Immediate,register3:Register)
        {
        super.init(operation:.ADD,register1:register1,immediate:immediate,register3:register3)
        }
        
    public init(immediate:Proton.Immediate,register2:Register,register3:Register)
        {
        super.init(operation:.ADD,immediate:immediate,register2:register2,register3:register3)
        }
    
    public override func execute(on thread:Thread) throws
        {
        switch(self.operand1,self.operand2,self.operand3)
            {
            case let(.register(r1),.register(r2),.register(r3)):
                let taggedValue1 = thread.registers[r1.rawValue]
                let taggedValue2 = thread.registers[r2.rawValue]
                let tag1 = taggedValue1.tag
                if tag1.tag != taggedValue2.tag
                    {
                    throw(Proton.Error.integerTypeMismatch)
                    }
                if tag1 == Proton.kTagBitsInteger
                    {
                    thread.registers[r3.rawValue] = Word(bitPattern: Proton.Integer(bitPattern: thread.registers[r1.rawValue]) + Proton.Integer(bitPattern: thread.registers[r2.rawValue]))
                    }
                throw(Proton.Error.registerValueInvalid(r1))
            case let(.register(r1),.immediate(immediate),.register(r3)):
                let taggedValue1 = thread.registers[r1.rawValue]
                let tag1 = taggedValue1.tag
                if tag1 == Proton.kTagBitsInteger
                    {
                    thread.registers[r3.rawValue] = Word(bitPattern: Proton.Integer(bitPattern: thread.registers[r1.rawValue]) + immediate)
                    }
                throw(Proton.Error.registerValueInvalid(r1))
            case let(.immediate(immediate),.register(r1),.register(r3)):
                let taggedValue1 = thread.registers[r1.rawValue]
                let tag1 = taggedValue1.tag
                if tag1 == Proton.kTagBitsInteger
                    {
                    thread.registers[r3.rawValue] = Word(bitPattern: Proton.Integer(bitPattern: thread.registers[r1.rawValue]) + immediate)
                    }
                throw(Proton.Error.registerValueInvalid(r1))
            default:
                throw(Proton.Error.invalidOperands)
            }
        }
    }
