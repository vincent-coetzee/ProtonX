//
//  Word+Extensions.swift
//  argon
//
//  Created by Vincent Coetzee on 15/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public typealias WordArray = Array<Word>
public typealias DoubleWordTuple = (Word,Word)
public typealias DoubleWordTupleArray = Array<DoubleWordTuple>

extension Word:HashableValue,Value
    {
    public static let allOnes:Word = 18446744073709551615
    public static let allZeros:Word = 0
        
    public static func twoToPower(of n:Word) -> Word
        {
        if n == 0
            {
            return(1)
            }
        return(2 << (n-1))
        }
        
    public var hashedValue:Int
        {
        return(Int(Int64(bitPattern: self)))
        }
    
    public var wordValue: Word
        {
        return(self)
        }
    
    public static let stride = MemoryLayout<Word>.stride
    
    public var linkingHash:Int
        {
        return(Int(self))
        }
        
    public static var objectStrideInBytes: Argon.ByteCount
        {
        return(Argon.ByteCount(MemoryLayout<Self>.stride))
        }
    
    public static func +=(lhs:inout Word,rhs:Argon.ByteCount)
        {
        lhs = lhs + Word(rhs)
        }
        
    public func store(atPointer:Argon.Pointer?)
        {
        setWordAtPointer(self,atPointer)
        }
        
    public var isHeader:Bool
        {
        let mask = Argon.kHeaderMarkerMask << Argon.kHeaderMarkerShift
        return((self & mask) == mask)
        }
        
    public var isNull:Bool
        {
        return((self & ~(Argon.kTagBitsMask << Argon.kTagBitsShift)) == 0)
        }
        
    public var isNotNull:Bool
        {
        return((self & ~(Argon.kTagBitsMask << Argon.kTagBitsShift)) != 0)
        }
        
    public var valueType:Argon.ValueType
        {
        let mask = Argon.kHeaderValueTypeMask << Argon.kHeaderValueTypeShift
        let bits = Word((self & mask) >> Argon.kHeaderValueTypeShift)
        return(Argon.ValueType(rawValue: bits)!)
        }
        
//    public var tagPointerType:ValuePointer.Type
//        {
//        switch(self.tag)
//            {
//            case Argon.kTypeObject:
//                return(ObjectPointer.self)
//            case Argon.kTypeSigned:
//                return(SignedPointer.self)
//            case Argon.kTypeUnsigned:
//                return(UnsignedPointer.self)
//            case Argon.kTypeBoolean:
//                return(BooleanPointer.self)
//            case Argon.kTypeCharacter:
//                return(CharacterPointer.self)
//            case Argon.kTypeByte:
//                return(BytePointer.self)
//            case Argon.kTypeFloat32:
//                return(Float32Pointer.self)
//            case Argon.kTypeFloat64:
//                return(Float64Pointer.self)
//            default:
//                fatalError("Invalid tag \(self.tag)")
//            }
//        }
        
    public var tag:Word
        {
        return((self & (Argon.kTagBitsMask << Argon.kTagBitsShift)) >> Argon.kTagBitsShift)
        }
        
    public var objectType:Word
        {
        return((self & (Argon.kHeaderValueTypeMask << Argon.kHeaderValueTypeShift)) >> Argon.kHeaderValueTypeShift)
        }
        
    public func asWord() -> Word
        {
        return(self)
        }
        
    public func byteCountRoundedUpToSlotCount() -> Word
        {
        let wordSize = MemoryLayout<Word>.size
        let byteCount = self.aligned(to: wordSize)
        return((byteCount / UInt64(wordSize)) + 1)
        }
        
    public func aligned(to alignment:Int) -> Word
        {
        return((self + ((Word(alignment) - 1))) & (~Word(alignment - 1)))
        }
        
    public var hexString:String
        {
        return(String(format: "%016lX",UInt64(self)))
        }
        
    public var bitString:String
        {
        var bitPattern = UInt64(1)
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
        
    public init(_ count:Argon.ByteCount)
        {
        self.init(count.count)
        }
        
    public init(_ count:Argon.SlotCount)
        {
        self.init(count.count)
        }
        
    public init(atPointer:Argon.Pointer?)
        {
        self.init(untaggedWordAtPointer(atPointer))
        }
        
    public init(bitPattern pointer:Argon.Pointer)
        {
        self.init(pointerAsWord(pointer))
        }
        
    public init(bitPattern float:Float)
        {
        self.init(bitPattern: Int64(Int32(bitPattern: float.bitPattern)))
        }
        
    public init(bits:String)
        {
        self.init(BitSetPointer.bitsAsWord(bits))
        }
    }
