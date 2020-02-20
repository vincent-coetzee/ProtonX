//
//  ENTERInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/17.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class ENTERInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString + self.operand1.displayString)
        }
        
    private let operand1:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word,_ word4:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3,word4)
        super.init(word1,word2,word3,word4)
        }
        
    public init(byteCount:Proton.Immediate)
        {
        self.operand1 = .immediate(byteCount)
        super.init(.ENTER,.immediate)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        }
        
    public override func execute(on thread:Thread) throws
        {
        thread.stack.enterBlock(on: thread,localsSizeInBytes: self.operand1)
        }
    }
