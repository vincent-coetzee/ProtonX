//
//  NOPInstruction.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/17.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation

public class NOPInstruction:Instruction
    {
    public override init()
        {
        super.init(.NOP,.none)
        }
    }
