//
//  BRNZInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/17.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class BRNZInstruction:ConditionalBranchInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        super.init(operation:.BRNZ,register1:register1,register2:register2,label:label)
        }
        
    public init(register1:Register,immediate:Proton.Immediate,label:Label)
        {
        super.init(operation:.BRNZ,register1:register1,immediate:immediate,label:label)
        }
        
    public init(register1:Register,referenceAddress:Proton.Address,label:Label)
        {
        super.init(operation:.BRNZ,register1:register1,referenceAddress:referenceAddress,label:label)
        }
    }
