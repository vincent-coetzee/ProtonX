//
//  PUSHPARMInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/17.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class PUSHPARMInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString + self.operand1.displayString + "," + self.operand2.displayString)
        }
        
    private let operand1:Operand
    private let operand2:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(immediate:Proton.Immediate,register:Register)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register)
        super.init(.PUSHPARM,.immediateRegister)
        }
        
    public init(immediate:Proton.Immediate,address:Proton.Address)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .address(address)
        super.init(.PUSHPARM,.immediateAddress)
        }
        
    public init(immediate:Proton.Immediate,referenceAddress address:Proton.Address)
        {
        self.operand2 = .referenceAddress(address)
        self.operand1 = .immediate(immediate)
        super.init(.PUSHPARM,.immediateAddress)
        }
        
    public init(register1:Register,register2:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        super.init(.PUSHPARM,.registerRegister)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        }
    }
