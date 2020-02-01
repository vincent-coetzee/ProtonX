//
//  ScalarPointer.swift
//  argon
//
//  Created by Vincent Coetzee on 29/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class ScalarPointer:ValuePointer,Key
    {
    public static func ==(lhs:ScalarPointer,rhs:ScalarPointer) -> Bool
        {
        return(ValueHolder(word: wordAtIndexAtPointer(.zero,lhs.pointer)) == ValueHolder(word: wordAtIndexAtPointer(.zero,rhs.pointer)))
        }
        
    public static func <(lhs:ScalarPointer,rhs:ScalarPointer) -> Bool
        {
        return(ValueHolder(word: wordAtIndexAtPointer(.zero,lhs.pointer)) < ValueHolder(word: wordAtIndexAtPointer(.zero,rhs.pointer)))
        }
        
    public var hashedValue:Int
        {
        return(Int(bitPattern: self.pointer!))
        }
        
    public var hashedValueIndex: SlotIndex
        {
        return(SlotIndex(index: Int(self.hashedValue)))
        }
    
//    public var typePointer: TypePointer?
//        {
//        switch(self.scalarType)
//            {
//            case .bits:
//                return(Memory.kTypeNone)
//            case .none:
//                return(Memory.kTypeNone)
//            case .integer:
//                return(Memory.kTypeInteger)
//            case .uinteger:
//                return(Memory.kTypeUInteger)
//            case .boolean:
//                return(Memory.kTypeBoolean)
//            case .byte:
//                return(Memory.kTypeByte)
//            case .float32:
//                return(Memory.kTypeFloat32)
//            case .float64:
//                break
//            }
//        fatalError("You need to think this through")
//        }
    
//    public var valueStride: Int
//        {
//        return(MemoryLayout<Word>.stride)
//        }
    
    public var scalarType:Argon.ScalarType

    public var integerValue:Int64
        {
        get
            {
            return(untaggedIntegerAtIndexAtPointer(SlotIndex(index: 0),self.pointer))
            }
        set
            {
            setTaggedIntegerAtIndexAtPointer(newValue,SlotIndex(index: 0),self.pointer)
            }
        }

    public var uintegerValue:UInt64
        {
        get
            {
            untaggedUIntegerAtIndexAtPointer(SlotIndex(index: 0),self.pointer)
            }
        set
            {
            setTaggedUIntegerAtIndexAtPointer(newValue,SlotIndex(index: 0),self.pointer)
            }
        }
        
    public var booleanValue:Bool
        {
        get
            {
            untaggedBooleanAtIndexAtPointer(SlotIndex.zero,self.pointer)
            }
        set
            {
            setTaggedBooleanAtIndexAtPointer(newValue,.zero,self.pointer)
            }
        }
        
    public var doubleValue:Float
        {
        get
            {
            fatalError()
            }
        set
            {
            fatalError()
            }
        }
        
    public var float32Value:Argon.Float32
        {
        get
            {
            untaggedFloat32AtIndexAtPointer(.zero,self.pointer)
            }
        set
            {
            setTaggedFloat32AtIndexAtPointer(newValue,.zero,self.pointer)
            }
        }
        
    public var float64Value:Argon.Float64
        {
        get
            {
            Argon.Float64(untaggedFloat64AtIndexAtPointer(.zero,self.pointer))
            }
        set
            {
            setTaggedFloat64AtIndexAtPointer(newValue.float64,.zero,self.pointer)
            }
        }
        
    public var byteValue:UInt8
        {
        get
            {
            untaggedByteAtIndexAtPointer(.zero,self.pointer)
            }
        set
            {
            setTaggedByteAtIndexAtPointer(newValue,.zero,self.pointer)
            }
        }
        
    public var bitsValue:Word
        {
        get
            {
            untaggedBitsAtIndexAtPointer(.zero,self.pointer)
            }
        set
            {
            setTaggedBitsAtIndexAtPointer(newValue,.zero,self.pointer)
            }
        }
        
    public override var taggedAddress:Instruction.Address
        {
        switch(self.scalarType)
            {
            case .none:
                break
            case .integer:
                return(taggedInteger(self.integerValue))
            case .uinteger:
                return(taggedUInteger(self.uintegerValue))
            case .boolean:
                return(taggedBoolean(self.booleanValue))
            case .byte:
                return(taggedByte(self.byteValue))
            case .bits:
                return(taggedBits(self.bitsValue))
            case .float32:
                return(taggedFloat32(self.float32Value))
            case .float64:
//                return(taggedFloat64(self.float64Value))
                fatalError("You need to think this through")
            }
        return(0)
        }
        
    public init(type:Argon.ScalarType)
        {
        fatalError()
        }
    
    public init(float:Argon.Float32)
        {
        self.scalarType = Argon.ScalarType.float32
        super.init(UnsafeMutableRawPointer(bitPattern: Int(float.bitPattern)))
        }
        
    public init(int:Int)
        {
        self.scalarType = Argon.ScalarType.integer
        super.init(UnsafeMutableRawPointer(bitPattern: int))
        }
        
    public init(word:Word)
        {
        self.scalarType = Argon.ScalarType.uinteger
        super.init(UnsafeMutableRawPointer(bitPattern: Int(Int64(bitPattern: word))))
        }
        
    public init(type:TypePointer)
        {
        Header(wordAtIndexAtPointer(.zero,type.pointer)).valueType = .float32
        self.scalarType = Argon.ScalarType.float32
        super.init(taggedObject(type.pointer))
        }
        
    public override init(_ address:Instruction.Address)
        {
        let type = Header(wordAtIndexAtPointer(.zero,UnsafeMutableRawPointer(bitPattern: UInt(address)))).valueType
        self.scalarType = Argon.ScalarType(type)
        super.init(address)
        }
        
    required public init(_ rawPointer: UnsafeMutableRawPointer?)
        {
        let tag = Header(wordAtIndexAtPointer(.zero,rawPointer)).valueType
        self.scalarType = Argon.ScalarType(tag)
        super.init(rawPointer)
        }
    
    public required init(_ pointer: Argon.Pointer) {
        fatalError("init(_:) has not been implemented")
    }
    
    public func asWord() -> Word
        {
        switch(self.scalarType)
            {
            case .none:
                return(0)
            case .integer:
                return(Word(bitPattern: self.integerValue))
            case .uinteger:
                return(self.uintegerValue)
            case .boolean:
                return(self.booleanValue ? 1 : 0)
            case .byte:
                return(unsafeBitCast(self.byteValue,to: Word.self))
            case .bits:
                return(self.bitsValue)
            case .float32:
                return(unsafeBitCast(self.float32Value.bitPattern,to: Word.self))
            case .float64:
//                return(taggedFloat64(self.float64Value))
                fatalError("You need to think this through")
            }
        }
        
    public func equals(_ value:Value) -> Bool
        {
        if value is ScalarPointer
            {
            return(self == (value as! ScalarPointer))
            }
        return(false)
        }
        
    public func isLessThan(_ value:Value) -> Bool
        {
        if value is ScalarPointer
            {
            return(self < (value as! ScalarPointer))
            }
        return(false)
        }
        
    public func store(atPointer pointer:Argon.Pointer)
        {
        setAddressAtPointer(self.taggedAddress,pointer)
        }
    }
