//
//  CodeBlockPointer.swift
//  argon
//
//  Created by Vincent Coetzee on 31/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class CodeBlock
    {
    private var instructions:[Instruction] = []
    private var pendingLabel:Int?
    
    public func decorateNextInstruction(withLabel:Int)
        {
        self.pendingLabel = withLabel
        }
        
    public func appendInstruction(_ instruction:Instruction)
        {
        if self.pendingLabel != nil
            {
            instruction.set(incomingLabel: pendingLabel!)
            self.pendingLabel = nil
            }
        self.instructions.append(instruction)
        }
    }
    
public class CodeBlockPointer:ObjectPointer
    {
    public static let kCodeBlockCodeBufferIndex = SlotIndex.two
    public static let kCodeBlockInstructionCountIndex = SlotIndex.three
    public static let kCodeBlockBaseSlotCount = SlotIndex.four
    public static let kCodeBlockInstructionsIndex = SlotIndex.five
        
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(6)
        }
        
    public var count:Int
        {
        get
            {
            return(Int(untaggedWordAtIndexAtPointer(Self.kCodeBlockInstructionCountIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),Self.kCodeBlockInstructionCountIndex,self.pointer)
            }
        }
        
    public subscript(_ index:Int) -> Instruction
        {
        get
            {
            return(unsafeBitCast(wordAtIndexAtPointer(SlotIndex(index: index + Self.kCodeBlockInstructionsIndex.index),self.pointer),to: Instruction.self))
            }
        set
            {
            setWordAtIndexAtPointer(unsafeBitCast(newValue,to: Word.self),SlotIndex(index: index + Self.kCodeBlockInstructionsIndex.index),self.pointer)
            }
        }
        
    public var instructionsAddress:Instruction.Address
        {
        return(addressOfIndexAtPointer(Self.kCodeBlockInstructionsIndex,self.pointer))
        }

    public init(instructions:InstructionVector,segment:MemorySegment = Memory.managedSegment)
        {
        let wordSize = MemoryLayout<Word>.size
        let bytesRequired = Argon.ByteCount((instructions.count + 20 + Self.kCodeBlockBaseSlotCount.index) * wordSize)
        var newSlotCount = Argon.SlotCount(0)
        super.init(segment.allocate(byteCount: bytesRequired,slotCount: &newSlotCount))
        self.totalSlotCount = newSlotCount
        self.valueType = .codeBlock
        self.hasExtraSlotsAtEnd = false
        self.isMarked = true
        self.typePointer = Memory.kTypeCodeBlock
        var index = Self.kCodeBlockInstructionsIndex
        for instruction in instructions
            {
            self[index.index] = instruction
            index += 1
            }
        self.count = index.index
        }

    required public init(_ address: UnsafeMutableRawPointer?)
        {
        super.init(address)
        }
    
    public required init(_ address: Instruction.Address)
        {
        super.init(address)
        }
}
