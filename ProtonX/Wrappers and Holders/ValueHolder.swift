//
//  ValueHolder.swift
//  argon
//
//  Created by Vincent Coetzee on 30/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public enum ValueHolder:Comparable
    {
    private static func objectValue(for word:Word) -> ValueHolder
        {
        let pointer = untaggedWordAsPointer(word)
        let headerWord = wordAtPointer(pointer)
        switch(headerWord.valueType)
            {
        case .none:
            return(.none)
        case .methodInstance:
            break
        case .string:
            return(.stringReference(StringPointer(pointer)))
        case .dictionary:
            return(.none)
        case .set:
            return(.none)
        case .bitSet:
            return(.none)
        case .array:
            return(.none)
        case .list:
            return(.none)
        case .custom:
            return(.none)
        case .enumeration:
            return(.none)
        case .type:
            return(.type(TypePointer(pointer)))
        case .wordBuffer:
            return(.none)
        case .byteArray:
            return(.none)
        case .slot:
            return(.slot(SlotPointer(pointer)))
        case .virtualSlot:
            return(.none)
        case .systemSlot:
            return(.none)
        case .codeBlock:
            return(.none)
        case .closure:
            return(.none)
        case .typeType:
            return(.none)
        case .metaType:
            return(.none)
        case .contract:
            return(.none)
        case .method:
            return(.none)
        case .enumerationCase:
            return(.enumerationCase(EnumerationCasePointer(pointer)))
        case .package:
            return(.package(PackagePointer(pointer)))
        case .contractMethod:
            return(.none)
        case .contractSlot:
            return(.none)
        case .packageImportElement:
            return(.none)
        default:
            break
            }
        return(.none)
        }
        
    public static func !=(lhs:ValueHolder,rhs:ValueHolder) -> Bool
        {
        return(!(lhs == rhs))
        }
        
    public static func ==(lhs:ValueHolder,rhs:ValueHolder) -> Bool
        {
        switch(lhs,rhs)
            {
            case (.null,.null):
                return(true)
            case (.none,.none):
                return(true)
            case let (.integer(int1),.integer(int2)):
                return(int1 == int2)
            case let (.uinteger(int1),.uinteger(int2)):
                return(int1 == int2)
            case let (.float32(int1),.float32(int2)):
                return(int1 == int2)
            case let (.float64(int1),.float64(int2)):
                return(int1 == int2)
            case let (.boolean(int1),.boolean(int2)):
                return(int1 == int2)
            case let (.byte(int1),.byte(int2)):
                return(int1 == int2)
            case let (.string(int1),.string(int2)):
                return(int1 == int2)
            case let (.string(int1),.stringReference(int2)):
                return(int1 == int2)
            case let (.stringReference(int1),.stringReference(int2)):
                return(int1 == int2)
            case let (.stringReference(int2),.string(int1)):
                return(int1 == int2)
            case let (.type(int1),.type(int2)):
                return(int1 == int2)
            case let(.key(value1),.key(value2)):
                return(value1.equals(value2))
            case let(.value(value1),.value(value2)):
                return(value1.equals(value2))
            default:
                return(false)
            }
        }
        
    public static func <(lhs:ValueHolder,rhs:ValueHolder) -> Bool
        {
        switch(lhs,rhs)
            {
            case (.null,.null):
                return(false)
            case (.none,.none):
                return(false)
            case let (.integer(int1),.integer(int2)):
                return(int1 < int2)
            case let (.uinteger(int1),.uinteger(int2)):
                return(int1 < int2)
            case let (.float32(int1),.float32(int2)):
                return(int1 < int2)
            case let (.float64(int1),.float64(int2)):
                return(int1 < int2)
            case (.boolean,.boolean):
                return(false)
            case let (.byte(int1),.byte(int2)):
                return(int1 < int2)
            case let (.string(int1),.string(int2)):
                return(int1 < int2)
            case let (.string(int1),.stringReference(int2)):
                return(int1 < int2)
            case let (.stringReference(int1),.stringReference(int2)):
                return(int1 < int2)
            case let (.stringReference(int2),.string(int1)):
                return(int1 < int2)
            case let (.type(int1),.type(int2)):
                return(int1 < int2)
            case let(.key(value1),.key(value2)):
                return(value1.isLessThan(value2))
            case let(.value(value1),.value(value2)):
                return(value1.isLessThan(value2))
            default:
                return(false)
            }
        }
        
    public func asWord() -> Word
        {
        switch(self)
            {
            case .key(let value):
                return(value.asWord())
            case .value(let value):
                return(value.asWord())
            case .null:
                return(0)
            case .none:
                return(0)
            case .integer(let int):
                return(int.asWord())
            case .uinteger(let uint):
                return(uint)
            case .float32(let value):
                return(value.asWord())
            case .float64:
               return(0)
            case .boolean(let value):
                return(value.asWord())
            case .byte(let value):
                return(value.asWord())
            case .string(let value):
                return(value.asWord())
            case .stringReference(let value):
                return(value.asWord())
            case .slot(let value):
                return(value.asWord())
            case .enumerationCase(let value):
                return(value.asWord())
            case .enumeration(let value):
                return(value.asWord())
            case .bits(let value):
                return(value.asWord())
            case .type(let value):
                return(value.asWord())
            case .package(let value):
               return(value.asWord())
            }
        }
        
    public var bitString:String
        {
        var bitPattern = UInt64(1)
        var string = ""
        let count = MemoryLayout<Word>.size * 8
        let word = self.asWord()
        for index in 1...count
            {
            string += (word & bitPattern) == bitPattern ? "1" : "0"
            string += index > 0 && index < count && index % 8 == 0 ? " " : ""
            bitPattern <<= 1
            }
        return(String(string.reversed()))
        }
        
    public var debugString:String
        {
        switch(self)
            {
            case .key(let value):
                return("Key(\(value))")
            case .value(let value):
                return("Value(\(value))")
            case .null:
                return("null")
            case .none:
                return("none")
            case .integer(let int):
                return("Integer(\(int))")
            case .uinteger(let uint):
                return("UInteger(\(uint))")
            case .float32(let value):
                return("Float32(\(value))")
            case .float64(let value):
                return("Float64(\(value))")
            case .boolean(let value):
                return("Boolean(\(value))")
            case .byte(let value):
                return("Byte(\(value))")
            case .string(let value):
                return("String(\(value))")
            case .stringReference(let value):
                return("StringPointer(\(value.string))")
            case .slot(let value):
                return("Slot(\(value.name),\(value.slotTypePointer!.name),\(value.index.index))")
            case .enumerationCase(let value):
                return("EnumerationCase(\(value.name))")
            case .enumeration(let value):
                return("Enumeration(\(value.name))")
            case .bits(let value):
                return("Bits(\(value))")
            case .type(let value):
                return("TypePointer(\(value.name))")
            case .package(let value):
                return("Package(\(value.fullName))")
            }
        }
        
    case none
    case integer(Int64)
    case uinteger(UInt64)
    case float32(Float)
    case float64(Double)
    case boolean(Bool)
    case byte(UInt8)
    case string(String)
    case stringReference(StringPointer)
    case slot(SlotPointer)
    case enumerationCase(EnumerationCasePointer)
    case enumeration(EnumerationPointer)
    case bits(UInt64)
    case type(TypePointer)
    case package(PackagePointer)
    case null
    case value(Value)
    case key(Value)
    
    public init(string:String?)
        {
        if string == nil
            {
            self = .null
            }
        else
            {
            self = .string(string!)
            }
        }
        
    public init(value:Value)
        {
        self = .value(value)
        }
        
    public init(object:ObjectPointer)
        {
        self.init(word: object.taggedAddress)
        }
        
    public init(stringReference:StringPointer)
        {
        self.init(word: stringReference.taggedAddress)
        }
        
    public init<K>(key:K) where K:Key
        {
        if key is String
            {
            self = .string((key as! String))
            }
        else
            {
            self = .key(key)
            }
        }
        
    public init(integer:Argon.Integer)
        {
        self = .integer(integer & ~(Argon.Integer(Argon.kTagBitsMask) << Argon.Integer(Argon.kTagBitsShift)))
        }
        
    public init(uinteger:Argon.UInteger)
        {
        self = .uinteger(uinteger)
        }
        
    public init(float64:Double)
        {
        self = .float64(float64)
        }
        
    public init(float32:Float)
        {
        self = .float32(float32)
        }
        
    public init(byte:Argon.Byte)
        {
        self = .byte(byte)
        }
        
    public init(bits:Word)
        {
        self = .bits(bits)
        }
        
    public init(boolean:Bool)
        {
        self = .boolean(boolean)
        }
        
    public init(word incoming:Word?)
        {
        if incoming == nil
            {
            self = .null
            }
        else
            {
            let word = incoming! & ~(Argon.kTagBitsMask << Argon.kTagBitsShift)
            switch(Argon.HeaderTag(rawValue: (incoming ?? 0).tag)!)
                {
                case .integer:
                    self = .integer(Int64(bitPattern: word))
                case .uinteger:
                    self = .uinteger(word)
                case .float32:
                    let u32 = UInt32(word &  4294967295)
                    self = .float32(Float(bitPattern: u32))
                case .float64:
    //                return(lhs.word == rhs.word)
                    self = .float64(0)
                case .boolean:
                    self = .boolean(word == 1)
                case .byte:
                    self = .byte(UInt8(word & 255))
                case .object:
                    self = ValueHolder.objectValue(for: word)
                case .bits:
                    self = .bits(word & ~Argon.kTagBitsMask)
                }
            }
        }
        
    public func copyAddress() -> Instruction.Address
        {
        switch(self)
            {
            case .string(let value):
                return(ImmutableStringPointer(value).taggedAddress)
            case .stringReference(let value):
                if value.isNull
                    {
                    return(taggedObjectAddress(0))
                    }
                return(ImmutableStringPointer(value.string).taggedAddress)
            default:
                return(taggedObjectAddress(0))
            }
        }
        
    @inline(__always)
    public mutating func store(atIndex index:SlotIndex,atPointer:Argon.Pointer)
        {
        self.store(atPointer: atPointer + index)
        }
        
    @inline(__always)
    public mutating func store(atIndex index:Int,atPointer:Argon.Pointer)
        {
        self.store(atPointer: atPointer + SlotIndex(index: index))
        }
        
    @inline(__always)
    public mutating func store(atPointer pointer:Argon.Pointer)
        {
        switch(self)
            {
            case .key(let key):
                key.store(atPointer: pointer)
            case .value(let value):
                value.store(atPointer: pointer)
            case .null:
                setWordAtPointer(0,pointer)
            case .none:
                setWordAtPointer(0,pointer)
            case .integer(let int):
                setWordAtPointer(taggedInteger(int),pointer)
            case .uinteger(let uint):
                setWordAtPointer(taggedUInteger(uint),pointer)
            case .float32(let value):
                setWordAtPointer(taggedFloat32(value),pointer)
            case .float64:
//                let header = Header(slotCount: 2, valueType: .float64, hasExtraSlotsAtEnd: false)
//                header.tag = .float64
//                header.valueType = .float64
//                let float64 = taggedFloat64(header.headerWord,value)
                setWordAtPointer(0,pointer)
            case .boolean(let value):
                setWordAtPointer(taggedBoolean(value),pointer)
            case .byte(let value):
                setWordAtPointer(taggedByte(value),pointer)
            case .string(let value):
                let immutableString = ImmutableStringPointer(value)
                self = .stringReference(immutableString)
                setWordAtPointer(immutableString.taggedAddress,pointer)
            case .stringReference(let value):
                setWordAtPointer(value.taggedAddress,pointer)
            case .slot(let value):
                setWordAtPointer(value.taggedAddress,pointer)
            case .enumerationCase(let value):
                setWordAtPointer(value.taggedAddress,pointer)
            case .enumeration(let value):
                setWordAtPointer(value.taggedAddress,pointer)
            case .bits(let value):
                setWordAtPointer(taggedBits(value),pointer)
            case .type(let value):
                setWordAtPointer(value.taggedAddress,pointer)
            case .package(let value):
                setWordAtPointer(value.taggedAddress,pointer)
            }
        }
    }
