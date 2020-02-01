//
//  CodeBlockPointer.swift
//  argon
//
//  Created by Vincent Coetzee on 31/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class CodeBlockPointer:ObjectPointer
    {
    public static let kCodeBlockCodeBufferIndex = SlotIndex.two
    public static let kCodeBlockInstructionCountIndex = SlotIndex.three
    public static let kCodeBlockInstructionsIndex = SlotIndex.four
    public static let kCodeBlockBaseSlotCount = SlotIndex.five
        
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
    }
