//
//  BRInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/17.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class BRInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString + self.operand.displayString)
        }
        
    private let operand:Operand

    public override init(_ word1:Word,_ word2:Word,_ word3:Word,_ word4:Word)
        {
        self.operand = Mode.mode(of: word1).decodeOperand1(word1,word2,word3,word4)
        super.init(word1,word2,word3,word4)
        }
        
    public init(label:Label)
        {
        self.operand = .label(label)
        super.init(.MOV,.label)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand,into: &words)
        }
    }
