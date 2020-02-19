//
//  ArithmeticInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/17.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class ArithmeticInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString + self.operand1.displayString + "," + self.operand2.displayString + "," + self.operand3.displayString)
        }
        
    internal var operand1:Operand
    internal var operand2:Operand
    internal var operand3:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(operation:Operation,register1:Register,register2:Register,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init()
        self.operation = operation
        self.mode = .registerRegisterRegister
        }
        
    public init(operation:Operation,register1:Register,immediate:Proton.Immediate,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .immediate(immediate)
        self.operand3 = .register(register3)
        super.init()
        self.operation = operation
        self.mode = .registerImmediateRegister
        }
        
    public init(operation:Operation,immediate:Proton.Immediate,register2:Register,register3:Register)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init()
        self.operation = operation
        self.mode = .immediateRegisterRegister
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }
