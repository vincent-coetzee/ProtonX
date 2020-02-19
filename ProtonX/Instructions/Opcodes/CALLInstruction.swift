//
//  CALLInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/17.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class CALLInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString + self.operand1.displayString)
        }
        
    private let operand1:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(label:Label)
        {
        self.operand1 = .label(label)
        super.init(.CALL,.label)
        }
        
    public init(address:Proton.Address)
        {
        self.operand1 = .address(address)
        super.init(.CALL,.address)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        }
    }
