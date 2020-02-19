//
//  MAKEInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/17.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory
     
public class MAKEInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString)
        }
        
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public override init()
        {
        super.init(.MAKE,.none)
        }
    }
