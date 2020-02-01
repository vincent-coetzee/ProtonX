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
    public var bp:Word
    public var sp:Word
    
    public override var identifier:Identifier
        {
        return(.stack)
        }
        
    public required init()
        {
        self.bp = 0
        self.sp = 0
        super.init()
        }
        
    public override init(sizeInMegabytes:Int)
        {
        self.bp = 0
        self.sp = 0
        super.init(sizeInMegabytes: sizeInMegabytes)
        let wordSize = MemoryLayout<Word>.size
        self.sp = self.nextAddress + Word(self.sizeInBytes).aligned(to: wordSize) - Word(wordSize)
        self.bp = sp
        }
        
    public func push(_ word:Word)
        {
        setWordAtAddress(word,self.sp)
        self.sp -= Word(MemoryLayout<Word>.size)
        }
        
    public func pop() -> Word
        {
        self.sp -= Word(MemoryLayout<Word>.size)
        return(wordAtAddress(self.sp))
        }
        
    public func frameRelativeValue(at offset:Word) -> Word
        {
        return(wordAtAddress(offset + self.bp))
        }
        
    public func setFrameRelativeValue(_ word:Word,at offset:Word)
        {
        setWordAtAddress(word,offset + self.bp)
        }
    }
