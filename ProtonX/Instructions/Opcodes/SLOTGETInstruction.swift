//
//  SLOTGETInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/17.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class SLOTGETInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString + self.operand1.displayString + "," + self.operand2.displayString)
        }
        
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,immediate:Proton.Immediate,register2:Register)
        {
        self.operand1 = .register(register1)
        self.operand3 = .register(register2)
        self.operand2 = .immediate(immediate)
        super.init(.SLOTGET,.registerImmediateRegister)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        self.operand2 = .register(register2)
        self.operand1 = .register(register1)
        self.operand3 = .register(register3)
        super.init(.SLOTGET,.registerRegisterRegister)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }
