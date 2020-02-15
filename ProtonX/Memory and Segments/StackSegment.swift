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
        
    public func stackValue(on thread:Thread,at offset:Int) -> Word
        {
        return(wordAtAddress(Word(UInt(bitPattern: offset + Int(thread.registers[.bp])))))
        }
        
    public func setStackValue(_ word:Word,on thread:Thread,at offset:Int)
        {
        setWordAtAddress(word,Word(UInt(bitPattern: offset + Int(thread.registers[.bp]))))
        }
        
    public func push(_ operand:Instruction.Operand,on thread:Thread)
        {
        switch(operand)
            {
        case .immediate(let value):
            setWordAtAddress(Word(bitPattern: value),self.top)
            self.top -= Word(MemoryLayout<Word>.size)
        case .address(let address):
            setWordAtAddress(address,self.top)
            self.top -= Word(MemoryLayout<Word>.size)
        case .referenceAddress(let value):
            setWordAtAddress(value,self.top)
            self.top -= Word(MemoryLayout<Word>.size)
        case .register(let register):
            setWordAtAddress(thread.registers[register],self.top)
            self.top -= Word(MemoryLayout<Word>.size)
        case .referenceRegister(let register):
            let address = thread.registers[register]
            setWordAtAddress(wordAtAddress(address),self.top)
            self.top -= Word(MemoryLayout<Word>.size)
        case .stack(let offset):
            let stackOffset = thread.registers[.bp] + Word(UInt(bitPattern: offset))
            setWordAtAddress(wordAtAddress(stackOffset),self.top)
        default:
            break
            }
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
