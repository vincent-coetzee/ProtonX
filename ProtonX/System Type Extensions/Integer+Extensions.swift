//
//  Signed+Extensions.swift
//  argon
//
//  Created by Vincent Coetzee on 20/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

extension Argon.Integer:Value
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
        
    public var taggedAddress:Instruction.Address
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
        if value is Argon.Integer
            {
            return(self == (value as! Argon.Integer))
            }
        return(false)
        }
        
    public func isLessThan(_ value:Value) -> Bool
        {
        if value is Argon.Integer
            {
            return(self < (value as! Argon.Integer))
            }
        return(false)
        }
        
    public func asWord() -> Word
        {
        return(Word(bitPattern: self))
        }
        
    public func store(atPointer pointer:Argon.Pointer)
        {
        setAddressAtPointer(self.taggedAddress,pointer)
        }
        
    public func withTagBitsZeroed() -> Argon.Integer
        {
        return(self & ~(Self(Argon.kTagBitsMask) << Self(Argon.kTagBitsShift)))
        }
        
        
    public func withTagAndSignBitsCleared() -> Argon.Integer
        {
        let mask:Argon.Integer = 1152921504606846975
        return(self & mask)
        }
    }
    
extension Argon.UInteger
    {
    public var taggedAddress:Instruction.Address
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
        if value is Argon.UInteger
            {
            return(self == (value as! Argon.UInteger))
            }
        return(false)
        }
        
    public func isLessThan(_ value:Value) -> Bool
        {
        if value is Argon.UInteger
            {
            return(self < (value as! Argon.UInteger))
            }
        return(false)
        }
        
    public func store(atPointer pointer:Argon.Pointer)
        {
        setAddressAtPointer(self.taggedAddress,pointer)
        }
        
    public func withTagBitsZeroed() -> Argon.UInteger
        {
        return(self & ~(Self(Argon.kTagBitsMask) << Self(Argon.kTagBitsShift)))
        }
    }

extension Argon.Boolean:Value
    {
    public var taggedAddress:Instruction.Address
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
        if value is Argon.Boolean
            {
            return(self == (value as! Argon.Boolean))
            }
        return(false)
        }
        
    public func isLessThan(_ value:Value) -> Bool
        {
        return(false)
        }
        
    public func store(atPointer pointer:Argon.Pointer)
        {
        setAddressAtPointer(self.taggedAddress,pointer)
        }
        
    public func withTagBitsZeroed() -> Argon.Boolean
        {
        return(self)
        }
    }
    
extension Argon.Float32:Value
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
        
    public var taggedAddress:Instruction.Address
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
        if value is Argon.Float32
            {
            return(self == (value as! Argon.Float32))
            }
        return(false)
        }
        
    public func isLessThan(_ value:Value) -> Bool
        {
        if value is Argon.Float32
            {
            return(self < (value as! Argon.Float32))
            }
        return(false)
        }
        
    public func store(atPointer pointer:Argon.Pointer)
        {
        setAddressAtPointer(self.taggedAddress,pointer)
        }
        
    public func withTagBitsZeroed() -> Argon.Float32
        {
        return(self)
        }
    }

extension Argon.Float64:Value
    {
    public static func ==(lhs:Argon.Float64,rhs:Argon.Float64) -> Bool
        {
        return(lhs.float64 == rhs.float64)
        }
        
    public var taggedAddress:Instruction.Address
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
        
    public func store(atPointer pointer:Argon.Pointer)
        {
        setAddressAtPointer(self.taggedAddress,pointer)
        }
        
    public func withTagBitsZeroed() -> Argon.Float64
        {
        return(self)
        }
    }

extension Argon.Byte:Value
    {
    public var taggedAddress:Instruction.Address
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
        
    public func store(atPointer pointer:Argon.Pointer)
        {
        setAddressAtPointer(self.taggedAddress,pointer)
        }
        
    public func equals(_ value:Value) -> Bool
        {
        if value is Argon.Byte
            {
            return(self == (value as! Argon.Byte))
            }
        return(false)
        }
        
    public func asWord() -> Word
        {
        return(unsafeBitCast(self,to:Word.self))
        }
        
    public func isLessThan(_ value:Value) -> Bool
        {
        if value is Argon.Byte
            {
            return(self < (value as! Argon.Byte))
            }
        return(false)
        }
//
//    public init(_ word:Word)
//        {
//        self.init(UInt8(word))
//        }

    public func withTagBitsZeroed() -> Argon.Byte
        {
        return(self)
        }
    }
