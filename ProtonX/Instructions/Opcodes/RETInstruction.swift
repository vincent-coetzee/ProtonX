//
//  RETInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/17.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class RETInstruction:Instruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word,_ word4:Word)
        {
        super.init(word1,word2,word3,word4)
        }
        
    public override init()
        {
        super.init(.RET,.none)
        }
    }
