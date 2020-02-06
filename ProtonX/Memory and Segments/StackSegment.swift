//
//  StackMemorySegment.swift
//  argon
//
//  Created by Vincent Coetzee on 26/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class StackSegment:MemorySegment
    {
    public var top:Word
    
    public override var identifier:Identifier
        {
        return(.stack)
        }
        
    public required init()
        {
        self.top = 0
        super.init()
        }
        
    public override init(sizeInMegabytes:Int)
        {
        self.top = 0
        super.init(sizeInMegabytes: sizeInMegabytes)
        let wordSize = MemoryLayout<Word>.size
        self.top = self.nextAddress + Word(self.sizeInBytes).aligned(to: wordSize) - Word(wordSize)
        }
        
    public func push(_ word:Word)
        {
        setWordAtAddress(word,self.top)
        self.top -= Word(MemoryLayout<Word>.size)
        }
        
    public func pop() -> Word
        {
        self.top -= Word(MemoryLayout<Word>.size)
        return(wordAtAddress(self.top))
        }
        
    public func frameRelativeValue(on thread:Thread,at offset:Word) -> Word
        {
        return(wordAtAddress(offset + thread.registers[.bp]))
        }
        
    public func setFrameRelativeValue(on thread:Thread,_ word:Word,at offset:Word)
        {
        setWordAtAddress(word,offset + thread.registers[.bp])
        }
        
    public func enterBlock(on thread: Thread,localsSizeInBytes size: Instruction.Operand)
        {
        self.push(thread.registers[.bp])
        thread.registers[.bp] = thread.registers[.sp]
        switch(size)
            {
            case .immediate(let value):
                self.top -= Word(value)
            default:
                fatalError("Invalid operand sent to \(#function)")
            }
        }
    }
