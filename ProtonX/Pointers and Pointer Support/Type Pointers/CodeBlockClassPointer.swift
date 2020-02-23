//
//  CodeBlockClassPointer.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/23.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation

public class CodeBlockClassPointer:ClassPointer
    {
    public func make(on thread:Thread) -> Proton.Address
        {
        let sizeInWords = thread.stack.pop()
        let pointer = CodeBlockPointer(thread.managed.allocate(slotCount: CodeBlockPointer.totalSlotCount))
        pointer.isMarked = true
        pointer.valueType = .typeType
        pointer.hasExtraSlotsAtEnd = false
        pointer.typePointer = Memory.kTypeType
        pointer.segment = thread.managed
        pointer.count = 0
        pointer.instructionArrayPointer = ArrayClassPointer(thread.memory.kArrayClass)self.allocateArray(count: initialSizeInWords * 3, elementType: Memory.kTypeInstruction!)
        Log.log("ALLOCATED CODEBLOCK AT \(pointer.hexString)")
        return(pointer)
        }
    }
