//
//  MOVInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/17.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class MOVInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString + self.operand1.displayString + "," + self.operand2.displayString)
        }
        
    private var operand1:Operand = .none
    private var operand2:Operand = .none
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word,_ word4:Word)
        {
        super.init(word1,word2,word3,word4)
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3,word4)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3,word4)
        }
        
    public init(register1:Register,register2:Register)
        {
        super.init(.MOV,.registerRegister)
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        }
        
    public init(immediate:Proton.Immediate,register2:Register)
        {
        super.init(.MOV,.immediateRegister)
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register2)
        }
        
    public init(referenceAddress:Proton.Address,register2:Register)
        {
        super.init(.MOV,.addressRegister)
        self.operand1 = .addressee(referenceAddress,nil)
        self.operand2 = .register(register2)
        }
        
    public init(register1:Register,referenceAddress:Proton.Address)
        {
        super.init(.MOV,.registerAddress)
        self.operand2 = .addressee(referenceAddress,nil)
        self.operand1 = .register(register1)
        }
        
    public init(offsetInStack:Int,register2:Register)
        {
        super.init(.MOV,.stackRegister)
        self.operand2 = .register(register2)
        self.operand1 = .stack(offsetInStack)
        }
         
    public init(register1:Register,offsetInStack:Int)
         {
         super.init(.MOV,.registerStack)
         self.operand1 = .register(register1)
         self.operand2 = .stack(offsetInStack)
         }
         
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        }
        
    public override func execute(on thread:Thread) throws
        {
        switch(self.operand1,self.operand2)
            {
            case let(.address(address1),.address(address2)):
                setWordAtAddress(wordAtAddress(address1),address2)
            case let(.address(address1),.register(register)):
                thread.registers[register.rawValue] = address1
            case let(.address(address1),.registerAddressee(register,nil)):
                setWordAtAddress(address1,thread.registers[register.rawValue])
            case let(.address(address1),.addressee(address2,offset)):
                setWordAtAddress(address1,address2 + (offset ?? 0))
            case let(.address(address1),.stack(offset)):
                thread.stack.setStackValue(address1,on: thread,at: offset)
            case let (.immediate(value),.register(register)):
                thread.registers[register.rawValue] = Word(bitPattern: value)
            case let (.immediate(value),.registerAddressee(register,nil)):
                setWordAtAddress(Word(bitPattern: value),thread.registers[register.rawValue])
            case let (.immediate(value),.addressee(address,nil)):
                setWordAtAddress(Word(bitPattern: value),address)
            case let (.immediate(value),.stack(offset)):
                thread.stack.setStackValue(Word(bitPattern: value),on: thread,at: offset)
            case let (.register(register1),.register(register2)):
                thread.registers[register2.rawValue] = thread.registers[register1.rawValue]
            case let (.register(register1),.addressee(address,offset)):
                setWordAtAddress(thread.registers[register1.rawValue],address + (offset ?? 0))
            case let (.register(register1),.registerAddressee(register2,offset)):
                setWordAtAddress(thread.registers[register1.rawValue],thread.registers[register2.rawValue] + (offset ?? 0))
            case let (.register(register1),.stack(offset)):
                thread.stack.setStackValue(thread.registers[register1.rawValue],on: thread,at: offset)
            case let (.stack(offset1),.stack(offset2)):
                thread.stack.setStackValue(thread.stack.stackValue(on: thread,at: offset1),on: thread,at: offset2)
            case let (.stack(offset1),.register(register)):
                 thread.registers[register.rawValue] = thread.stack.stackValue(on: thread,at: offset1)
            case let (.stack(offset1),.registerAddressee(register,nil)):
                 setWordAtAddress(thread.stack.stackValue(on: thread,at: offset1),thread.registers[register.rawValue])
            case let (.stack(offset1),.addressee(address,nil)):
                 setWordAtAddress(thread.stack.stackValue(on: thread,at: offset1),address)
            case let (.addressee(address1,offset1),.addressee(address2,offset2)):
                 setWordAtAddress(wordAtAddress(address1 + (offset1 ?? 0)),address2 + (offset2 ?? 0))
            case let (.addressee(address1,offset1),.register(register)):
                 thread.registers[register.rawValue] = wordAtAddress(address1 + (offset1 ?? 0))
            case let (.addressee(address1,offset1),.registerAddressee(register,offset2)):
                 setWordAtAddress(wordAtAddress(address1 + (offset1 ?? 0)),thread.registers[register.rawValue] + (offset2 ?? 0))
            case let (.addressee(address1,offset1),.stack(offset)):
                 thread.stack.setStackValue(wordAtAddress(address1 + (offset1 ?? 0)),on: thread,at: offset)
            case let (.registerAddressee(register1,offset1),.addressee(address2,offset2)):
                 setWordAtAddress(wordAtAddress(thread.registers[register1.rawValue] + (offset1 ?? 0)),address2 + (offset2 ?? 0))
            case let (.registerAddressee(register1,offset1),.register(register)):
                 thread.registers[register.rawValue] = wordAtAddress(thread.registers[register1.rawValue] + (offset1 ?? 0))
            case let (.registerAddressee(register1,offset1),.registerAddressee(register,offset2)):
                 setWordAtAddress(wordAtAddress(thread.registers[register1.rawValue] + (offset1 ?? 0)),thread.registers[register.rawValue] + (offset2 ?? 0))
            case let (.registerAddressee(register1,offset1),.stack(offset)):
                 thread.stack.setStackValue(wordAtAddress(thread.registers[register1.rawValue] + (offset1 ?? 0)),on: thread,at: offset)
            default:
                fatalError("Invalid MOV operand pairing")
            }
        }
    }
