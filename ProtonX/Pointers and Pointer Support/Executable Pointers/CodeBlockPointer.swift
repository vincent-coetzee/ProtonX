//
//  CodeBlockPointer.swift
//  argon
//
//  Created by Vincent Coetzee on 31/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class CodeBlock:Collection
    {
    private var instructions:[Instruction] = []
    private var pendingLabel:Int?

    public var startIndex:Int
        {
        return(self.instructions.startIndex)
        }
        
    public var endIndex:Int
        {
        return(self.instructions.endIndex)
        }
        
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
        
    public func index(after:Int) -> Int
        {
        return(self.instructions.index(after: after))
        }
        
    public subscript(_ index:Int) -> Instruction
        {
        return(self.instructions[index])
        }
    }
    
public class CodeBlockPointer:ObjectPointer
    {
    public static let kCodeBlockInstructionCountIndex = SlotIndex.two
    public static let kCodeBlockInstructionArrayIndex = SlotIndex.three
        
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(4)
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
        
    private var _instructionArrayPointer:ArrayPointer?
    
    public var instructionArrayPointer:ArrayPointer
        {
        get
            {
            if let array = self._instructionArrayPointer
                {
                return(array)
                }
            self._instructionArrayPointer = ArrayPointer(untaggedPointerAtIndexAtPointer(Self.kCodeBlockInstructionArrayIndex,self.pointer))
            return(self._instructionArrayPointer!)
            }
        set
            {
            self._instructionArrayPointer = newValue
            tagAndSetPointerAtIndexAtPointer(newValue.pointer,Self.kCodeBlockInstructionArrayIndex,self.pointer)
            }
        }
        
    private var _cachedInstructions:Array<Instruction>?
    
    public var instructions:Array<Instruction>
        {
        if self._cachedInstructions == nil
            {
            self.cacheInstructions()
            }
        return(self._cachedInstructions!)
        }
        
    public init(instructions:InstructionVector,segment:MemorySegment = Memory.managedSegment)
        {
        super.init(segment.allocateCodeBlock(initialSizeInWords: instructions.wordCount).pointer)
        let array = self.instructionArrayPointer
        var index = 0
        for instruction in instructions
            {
            let instructionWord = instruction.encoded
            array[index] = instructionWord.instruction
            index += 1
            if instructionWord.hasAddress
                {
                array[index] = instructionWord.address
                index += 1
                }
            if instructionWord.hasImmediate
                  {
                  array[index] = instructionWord.immediate
                  index += 1
                  }
            }
        self.count = instructions.count
        }

    public var instructionAddress:Instruction.Address?
        {
        return(self.instructionArrayPointer.elementAddress)
        }
        
    required public init(_ address: UnsafeMutableRawPointer?)
        {
        super.init(address)
        }
    
    public required init(_ address: Instruction.Address)
        {
        super.init(address)
        }
        
    public func cacheInstructions()
        {
        var instructions = Array<Instruction>()
        let array = self.instructionArrayPointer
        let count = array.count
        var index = 0
        while index < count
            {
            let word = array[index]
            index += 1
            var addressWord:Word = 0
            var immediate:Word = 0
            if Instruction.instructionWordHasAddress(word)
                {
                addressWord = array[index]
                index += 1
                }
            if Instruction.instructionWordHasImmediate(word)
                {
                immediate = array[index]
                index += 1
                }
            instructions.append(Instruction.makeInstruction(from: word,with: addressWord,with: immediate))
            }
        self._cachedInstructions = instructions
        }
        
    public func appendInstructions(_ block:CodeBlock)
        {
        for instruction in block
            {
            self.appendInstruction(instruction)
            }
        }
        
    public func appendInstruction(_ instruction:Instruction)
        {
        let encoding = instruction.encoded
        self.instructionArrayPointer.append(encoding.instruction)
        if instruction.hasAddress
            {
            self.instructionArrayPointer.append(encoding.address)
            }
        if instruction.hasImmediate
            {
            self.instructionArrayPointer.append(encoding.address)
            }
        self.count += 1
        }
}
