//
//  Signed+Extensions.swift
//  argon
//
//  Created by Vincent Coetzee on 20/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

extension Proton.Integer:Value
    {
    public var bitString:String
        {
        var bitPattern = Int64(1)
        var string = ""
        let count = MemoryLayout<Word>.size * 8
        for index in 1...count
            {
            string += (self & bitPattern) == bitPattern ? "1" : "0"
            string += index > 0 && index < count && index % 8 == 0 ? " " : ""
            bitPattern <<= 1
            }
        return(String(string.reversed()))
        }
        
    public var taggedBits:Word
        {
        return(Word(bitPattern:self) & 9223372036854775807)
        }
        
    public var taggedAddress:Proton.Address
        {
        return(taggedInteger(self))
        }
//        
//    public var valueStride:Int
//        {
//        return(MemoryLayout<Word>.stride)
//        }
//        
//    public var typePointer:TypePointer?
//        {
//        return(Memory.kTypeInteger!)
//        }
//        
//    public var wordValue:Word
//        {
//        return(Word(bitPattern: self))
//        }
        
    public func equals(_ value:Value) -> Bool
        {
        if value is Proton.Integer
            {
            return(self == (value as! Proton.Integer))
            }
        return(false)
        }
        
    public func isLessThan(_ value:Value) -> Bool
        {
        if value is Proton.Integer
            {
            return(self < (value as! Proton.Integer))
            }
        return(false)
        }
        
    public func asWord() -> Word
        {
        return(Word(bitPattern: self))
        }
        
    public func store(atAddress pointer:Proton.Address)
        {
        setIntegerAtAddress(self,pointer)
        }
        
    public func withTagBitsZeroed() -> Proton.Integer
        {
        return(self & ~(Self(Proton.kTagBitsMask) << Self(Proton.kTagBitsShift)))
        }
        
    public init(taggedBits:Word)
        {
        self = Int64(bitPattern: taggedBits)
        }
        
    public func withTagAndSignBitsCleared() -> Proton.Integer
        {
        let mask:Proton.Integer = 1152921504606846975
        return(self & mask)
        }
    }
    
extension Proton.UInteger
    {
    public var taggedAddress:Proton.Address
        {
        return(taggedUInteger(self))
        }
        
//    public var valueStride:Int
//        {
//        return(MemoryLayout<Word>.stride)
//        }
//
//    public var typePointer:TypePointer?
//        {
//        return(Memory.kTypeUInteger!)
//        }
        
    public func equals(_ value:Value) -> Bool
        {
        if value is Proton.UInteger
            {
            return(self == (value as! Proton.UInteger))
            }
        return(false)
        }
        
    public func isLessThan(_ value:Value) -> Bool
        {
        if value is Proton.UInteger
            {
            return(self < (value as! Proton.UInteger))
            }
        return(false)
        }
        
    public func store(atAddress pointer:Proton.Address)
        {
        setAddressAtAddress(self.taggedAddress,pointer)
        }
        
    public func withTagBitsZeroed() -> Proton.UInteger
        {
        return(self & ~(Self(Proton.kTagBitsMask) << Self(Proton.kTagBitsShift)))
        }
    }

