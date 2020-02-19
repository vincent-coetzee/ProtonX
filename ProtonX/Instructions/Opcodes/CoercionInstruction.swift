//
//  CoercionInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/18.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class CoercionInstruction:Instruction
    {
    internal var operand1:Operand
    internal var operand2:Operand
    
    public override var displayString:String
        {
        return(super.displayString + self.operand1.displayString + "," + self.operand2.displayString)
        }
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(operation:Operation,register1:Register,register2:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        super.init(operation,.registerRegister)
        }
        
    public init(operation:Operation,immediate:Proton.Immediate,register1:Register)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register1)
        super.init(operation,.immediateRegister)
        }
        
    public init(operation:Operation,referenceAddress:Proton.Address,register1:Register)
        {
        self.operand1 = .referenceAddress(referenceAddress)
        self.operand2 = .register(register1)
        super.init(operation,.addressRegister)
        }
        
    public init(operation:Operation,register1:Register,referenceAddress:Proton.Address)
        {
        self.operand2 = .referenceAddress(referenceAddress)
        self.operand1 = .register(register1)
        super.init(operation,.registerAddress)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        super.encode(into: &words)
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        }
    }
