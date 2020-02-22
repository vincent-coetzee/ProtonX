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
        
    public var taggedBits:Word
        {
        return(Word(bitPattern: Int64(self)) & 9223372036854775807)
        }
        
    public var bitString:String
        {
        return(Word(self).bitString)
        }
        
    public init(taggedBits:Word)
        {
        self = Int(bitPattern: UInt(taggedBits))
        }
        
    public func aligned(to alignment:Int) -> Int
        {
        return((self + ((Int(alignment) - 1))) & (~Int(alignment - 1)))
        }
        
    public func withTagBitsZeroed() -> Int
        {
        return(self & ~(Self(Proton.kTagBitsMask) << Self(Proton.kTagBitsShift)))
        }
        
    public func withTagAndSignBitsCleared() -> Int
        {
        return(Int(bitPattern: UInt((Word(UInt(bitPattern: self)) & ~Proton.kTagBitsTop5Mask))))
        }
    }

extension Int:CachedPointer
    {
    public var taggedAddress: Proton.Address
        {
        return(Proton.Address(self))
        }
    }
