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
        return(taggedFloat32(self))
        }
        
//    public var valueStride:Int
//        {
//        return(MemoryLayout<Word>.stride)
//        }
//
//    public var typePointer:TypePointer?
//        {
//        return(Memory.kTypeFloat32!)
//        }
//
//    public var wordValue:Word
//        {
//        return(Word(self.bitPattern))
//        }
        
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
    }
