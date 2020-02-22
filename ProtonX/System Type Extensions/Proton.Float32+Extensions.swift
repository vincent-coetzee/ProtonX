//
//  Proton.Float32+Extensions.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/19.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

extension Proton.Float32:Value
    {
    public var taggedBits:Word
        {
        return(Word(self.bitPattern & 4294967295) | (Proton.kTagBitsFloat32 << Proton.kTagBitsShift))
        }
        
    public var bitString:String
        {
        var bitPattern = UInt64(1)
        var string = ""
        let count = MemoryLayout<Word>.size * 8
        let word = Word(self.bitPattern)
        for index in 1...count
            {
            string += (word & bitPattern) == bitPattern ? "1" : "0"
            string += index > 0 && index < count && index % 8 == 0 ? " " : ""
            bitPattern <<= 1
            }
        return(String(string.reversed()))
        }
        
    public var taggedAddress:Proton.Address
        {
        return((Proton.kTagBitsFloat32 << Proton.kTagBitsShift) | Word(UInt32(self.bitPattern)))
        }
        
    public init(_ word:Word)
        {
        self.init(Float(bitPattern: UInt32(word)))
        }
        
    public func asWord() -> Word
        {
        return(unsafeBitCast(self.bitPattern,to:Word.self))
        }
        
    public func equals(_ value:Value) -> Bool
        {
        if value is Proton.Float32
            {
            return(self == (value as! Proton.Float32))
            }
        return(false)
        }
        
    public func isLessThan(_ value:Value) -> Bool
        {
        if value is Proton.Float32
            {
            return(self < (value as! Proton.Float32))
            }
        return(false)
        }
        
    public func store(atAddress pointer:Proton.Address)
        {
        setAddressAtAddress(self.taggedAddress,pointer)
        }
        
    public func withTagBitsZeroed() -> Proton.Float32
        {
        return(self)
        }
        
    public init(taggedBits:Word)
        {
        self.init(bitPattern: UInt32(taggedBits & 4294967295))
        }
    }
