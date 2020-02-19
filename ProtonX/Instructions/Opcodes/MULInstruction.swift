//
//  MULInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/17.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class MULInstruction:ArithmeticInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        super.init(operation:.MUL,register1:register1,register2:register2,register3:register3)
        }
        
    public init(register1:Register,immediate:Proton.Immediate,register3:Register)
        {
        super.init(operation:.MUL,register1:register1,immediate:immediate,register3:register3)
        }
        
    public init(immediate:Proton.Immediate,register2:Register,register3:Register)
        {
        super.init(operation:.MUL,immediate:immediate,register2:register2,register3:register3)
        }
    }
