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
        return(ValueHolder(word: wordAtIndexAtAddress(.zero,lhs.address)) == ValueHolder(word: wordAtIndexAtAddress(.zero,rhs.address)))
        }
        
    public static func <(lhs:ScalarPointer,rhs:ScalarPointer) -> Bool
        {
        return(ValueHolder(word: wordAtIndexAtAddress(.zero,lhs.address)) < ValueHolder(word: wordAtIndexAtAddress(.zero,rhs.address)))
        }
        
    public var hashedValue:Int
        {
        return(Int(Int64(self.address)))
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
            return(integerAtIndexAtAddress(SlotIndex(index: 0),self.address))
            }
        set
            {
            setIntegerAtIndexAtAddress(newValue,SlotIndex(index: 0),self.address)
            }
        }

    public var uintegerValue:UInt64
        {
        get
            {
            return(uintegerAtIndexAtAddress(SlotIndex(index: 0),self.address))
            }
        set
            {
            setUIntegerAtIndexAtAddress(newValue,SlotIndex(index: 0),self.address)
            }
        }
        
    public var booleanValue:Bool
        {
        get
            {
            return(booleanAtIndexAtAddress(SlotIndex.zero,self.address))
            }
        set
            {
            setBooleanAtIndexAtAddress(newValue,.zero,self.address)
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
            float32AtIndexAtAddress(.zero,self.address)
            }
        set
            {
            setFloat32AtIndexAtAddress(newValue,.zero,self.address)
            }
        }
        
//    public var float64Value:Argon.Float64
//        {
//        get
//            {
//            Argon.Float64(untaggedFloat64AtIndexAtPointer(.zero,self.address))
//            }
//        set
//            {
//            setTaggedFloat64AtIndexAtPointer(newValue.float64,.zero,self.address)
//            }
//        }
        
    public var byteValue:UInt8
        {
        get
            {
            return(byteAtIndexAtAddress(.zero,self.address))
            }
        set
            {
            setByteAtIndexAtAddress(newValue,.zero,self.address)
            }
        }
        
    public var bitsValue:Word
        {
        get
            {
            return(bitsAtIndexAtAddress(.zero,self.address))
            }
        set
            {
            setBitsAtIndexAtAddress(newValue,.zero,self.address)
            }
        }
        
//    public override var taggedAddress:Argon.Address
//        {
//        switch(self.scalarType)
//            {
//            case .none:
//                break
//            case .integer:
//                return(taggedInteger(self.integerValue))
//            case .uinteger:
//                return(taggedUInteger(self.uintegerValue))
//            case .boolean:
//                return(taggedBoolean(self.booleanValue))
//            case .byte:
//                return(taggedByte(self.byteValue))
//            case .bits:
//                return(taggedBits(self.bitsValue))
//            case .float32:
//                return(taggedFloat32(self.float32Value))
//            case .float64:
////                return(taggedFloat64(self.float64Value))
//                fatalError("You need to think this through")
//            }
//        return(0)
//        }
        
    public init(type:Argon.ScalarType)
        {
        fatalError()
        }
    
    public init(float:Argon.Float32)
        {
        self.scalarType = Argon.ScalarType.float32
        super.init(Argon.Address(bitPattern: Int64(float.bitPattern)))
        }
        
    public init(int:Int)
        {
        self.scalarType = Argon.ScalarType.integer
        super.init(Argon.Address(bitPattern: Int64(int)))
        }
        
    public init(word:Word)
        {
        self.scalarType = Argon.ScalarType.uinteger
        super.init(word)
        }
        
    public init(type:TypePointer)
        {
        Header(wordAtIndexAtAddress(.zero,type.address)).valueType = .float32
        self.scalarType = Argon.ScalarType.float32
        super.init(type.address)
        }
        
    public required init(_ address:Argon.Address)
        {
        let type = Header(wordAtIndexAtAddress(.zero,address)).valueType
        self.scalarType = Argon.ScalarType(type)
        super.init(address)
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
        
    public func store(atAddress pointer:Argon.Address)
        {
        setAddressAtAddress(self.taggedAddress,pointer)
        }
    }
