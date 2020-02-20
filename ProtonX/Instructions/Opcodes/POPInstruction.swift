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
        
    public override init(_ word1:Word,_ word2:Word,_ word3:Word,_ word4:Word)
        {
        self.operand = Mode.mode(of: word1).decodeOperand1(word1,word2,word3,word4)
        super.init(word1,word2,word3,word4)
        }
        
    public init(address:Proton.Address)
        {
        self.operand = .address(address)
        super.init(.POP,.address)
        }
        
    public init(referenceAddress address:Proton.Address)
        {
        self.operand = .addressee(address,nil)
        super.init(.PUSH,.address)
        }
        
    public init(register:Register)
        {
        self.operand = .register(register)
        super.init(.PUSH,.register)
        }
        
    public init(referenceRegister register:Register)
        {
        self.operand = .registerAddressee(register,nil)
        super.init(.PUSH,.register)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand,into: &words)
        }
    }
