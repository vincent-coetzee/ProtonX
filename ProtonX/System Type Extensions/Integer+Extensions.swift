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

extension Proton.Boolean:Value
    {
    public var taggedAddress:Proton.Address
        {
        return(taggedBoolean(self))
        }
        
//    public var valueStride:Int
//        {
//        return(MemoryLayout<Word>.stride)
//        }
//
//    public var typePointer:TypePointer?
//        {
//        return(Memory.kTypeBoolean!)
//        }
//
//    public var wordValue:Word
//        {
//        return(self == true ? 1 : 0)
//        }
        
    public init(_ word:Word)
        {
        self.init(word == 1)
        }
        
    public func asWord() -> Word
        {
        return(self ? 1 : 0)
        }
        
    public func equals(_ value:Value) -> Bool
        {
        if value is Proton.Boolean
            {
            return(self == (value as! Proton.Boolean))
            }
        return(false)
        }
        
    public func isLessThan(_ value:Value) -> Bool
        {
        return(false)
        }
        
    public func store(atAddress pointer:Proton.Address)
        {
        setAddressAtAddress(self.taggedAddress,pointer)
        }
        
    public func withTagBitsZeroed() -> Proton.Boolean
        {
        return(self)
        }
    }
    
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
        self.init(Float(bitPattern:word))
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

extension Proton.Float64:Value
    {
    public static func ==(lhs:Proton.Float64,rhs:Proton.Float64) -> Bool
        {
        return(lhs.float64 == rhs.float64)
        }
        
    public var taggedAddress:Proton.Address
        {
        return(0)
        }
//
//    public var valueStride:Int
//        {
//        return(MemoryLayout<Word>.stride)
//        }
//
//    public var typePointer:TypePointer?
//        {
//        return(Memory.kTypeFloat64!)
//        }
//
//    public var wordValue:Word
//        {
//        fatalError("Fix this Vincent")
//        }
        
    public init(_ word:Word)
        {
        self.init(Double(bitPattern:word))
        }
        
    public func asWord() -> Word
        {
        return(0)
        }
        
    public func equals(_ value:Value) -> Bool
        {
//        if value is Argon.Float64
//            {
//            return(self == (value as! Argon.Float64))
//            }
        return(false)
        }
        
    public func isLessThan(_ value:Value) -> Bool
        {
//        if value is Argon.Byte
//            {
//            return(self < (value as! Argon.Byte))
//            }
        return(false)
        }
        
    public func store(atAddress pointer:Proton.Address)
        {
        setAddressAtAddress(self.taggedAddress,pointer)
        }
        
    public func withTagBitsZeroed() -> Proton.Float64
        {
        return(self)
        }
    }

extension Proton.Byte:Value
    {
    public var taggedAddress:Proton.Address
        {
        return(taggedByte(self))
        }
        
//    public var valueStride:Int
//        {
//        return(MemoryLayout<Word>.stride)
//        }
//
//    public var typePointer:TypePointer?
//        {
//        return(Memory.kTypeByte!)
//        }
//
//    public var wordValue:Word
//        {
//        return(Word(self))
//        }
        
    public func store(atAddress pointer:Proton.Address)
        {
        setAddressAtAddress(self.taggedAddress,pointer)
        }
        
    public func equals(_ value:Value) -> Bool
        {
        if value is Proton.Byte
            {
            return(self == (value as! Proton.Byte))
            }
        return(false)
        }
        
    public func asWord() -> Word
        {
        return(unsafeBitCast(self,to:Word.self))
        }
        
    public func isLessThan(_ value:Value) -> Bool
        {
        if value is Proton.Byte
            {
            return(self < (value as! Proton.Byte))
            }
        return(false)
        }
//
//    public init(_ word:Word)
//        {
//        self.init(UInt8(word))
//        }

    public func withTagBitsZeroed() -> Proton.Byte
        {
        return(self)
        }
    }
