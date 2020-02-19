//
//  POPInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/17.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class POPInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString + self.operand.displayString)
        }
        
    private let operand:Operand
        
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(address:Proton.Address)
        {
        self.operand = .address(address)
        super.init(.POP,.address)
        }
        
    public init(referenceAddress address:Proton.Address)
        {
        self.operand = .referenceAddress(address)
        super.init(.PUSH,.address)
        }
        
    public init(register:Register)
        {
        self.operand = .register(register)
        super.init(.PUSH,.register)
        }
        
    public init(referenceRegister register:Register)
        {
        self.operand = .referenceRegister(register)
        super.init(.PUSH,.register)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand,into: &words)
        }
    }
