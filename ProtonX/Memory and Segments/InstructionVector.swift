//
//  InstructionBuffer.swift
//  argon
//
//  Created by Vincent Coetzee on 31/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory
    
public class InstructionVector:Collection
    {
    public static func +(lhs:InstructionVector,rhs:Instruction) -> InstructionVector
        {
        lhs.append(rhs)
        return(lhs)
        }
        
    public var startIndex:Int
        {
        return(self.instructions.startIndex)
        }
        
    public var endIndex:Int
        {
        return(self.instructions.endIndex)
        }

    public var count:Int
        {
        return(self.instructions.count)
        }
        
    private var instructions:[Instruction] = []
    
    public func index(after:Int) -> Int
        {
        return(self.instructions.index(after: after))
        }
        
    public subscript(_ index:Int) -> Instruction
        {
        return(self.instructions[index])
        }
        
    public func append(_ rhs:Instruction)
        {
        self.instructions.append(rhs)
        }
    }
