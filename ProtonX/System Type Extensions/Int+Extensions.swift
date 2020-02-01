//
//  Int+Extensions.swift
//  argon
//
//  Created by Vincent Coetzee on 15/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

extension Int
    {
    @discardableResult
    public static postfix func ++(lhs:inout Int) -> Int
        {
        let oldValue = lhs
        lhs += 1
        return(oldValue)
        }
        
    public func byteCountRoundedUpToSlotCount() -> Int
        {
        let wordSize = MemoryLayout<Word>.size
        let byteCount = self.aligned(to: wordSize)
        return((byteCount / wordSize) + 1)
        }
        
    public var bitString:String
        {
        return(Word(self).bitString)
        }
        
    public func aligned(to alignment:Int) -> Int
        {
        return((self + ((Int(alignment) - 1))) & (~Int(alignment - 1)))
        }
        
    public func withTagBitsZeroed() -> Int
        {
        return(self & ~(Self(Argon.kTagBitsMask) << Self(Argon.kTagBitsShift)))
        }
        
    public func withTagAndSignBitsCleared() -> Int
        {
        let mask:Int = 1152921504606846975
        return(self & mask)
        }
    }
