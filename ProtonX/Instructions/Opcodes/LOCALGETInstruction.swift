//
//  LOCALGETInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/21.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class LOCALGETInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString + self.operand1.displayString + "," + self.operand2.displayString)
        }
        
    private let operand1:Operand
    private let operand2:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word,_ word4:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3,word4)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3,word4)
        super.init(word1,word2,word3,word4)
        }
        
    public init(frame:Int,index:Int,register:Register)
        {
        self.operand2 = .register(register)
        self.operand1 = .immediate(Proton.Immediate(frame: frame,index: index))
        super.init(.LOCALGET,.immediateRegister)
        }
        
    public init(frame:Int,index:Int,addressee:Proton.Address)
        {
        self.operand2 = .addressee(addressee,nil)
        self.operand1 = .immediate(Proton.Immediate(frame: frame,index: index))
        super.init(.LOCALGET,.immediateAddress)
        }
        
    public init(frame:Int,index:Int,registerAddressee:Register)
        {
        self.operand2 = .registerAddressee(registerAddressee,nil)
        self.operand1 = .immediate(Proton.Immediate(frame: frame,index: index))
        super.init(.LOCALGET,.immediateRegister)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        }
    }
