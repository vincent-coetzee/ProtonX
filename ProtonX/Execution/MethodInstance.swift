//
//  MethodInstance.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 03/02/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation

public class MethodInstance
    {
    private var instructions:[Instruction] = []
    
    public func append(_ instruction:Instruction)
        {
        self.instructions.append(instruction)
        }
    }
