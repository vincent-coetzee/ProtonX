//
//  InstancePointer.swift
//  argon
//
//  Created by Vincent Coetzee on 02/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class ObjectPointer:ValuePointer,Headered,Value,Key
    {
    public var valueStride: Int
        {
        return(MemoryLayout<Word>.stride)
        }
        
    public var hashedValue:Int
        {
        return(unsafeBitCast(self.taggedAddress,to: Int.self))
        }
    
    public var hashedValueIndex: SlotIndex
        {
        fatalError()
        }
    
    public class var stride:Int
        {
        return(Word.stride * 2)
        }
        
    public static let kObjectHeaderIndex = SlotIndex.zero
    public static let kObjectTypeIndex = SlotIndex.one
        
    public class var slotSizeInBytes:Argon.ByteCount
        {
        return(Argon.ByteCount(MemoryLayout<Word>.stride))
        }
        
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(2)
        }
        
    public override var taggedAddress:Instruction.Address
        {
        return(taggedObject(self.pointer))
        }
        
    public override var untaggedAddress:Instruction.Address
        {
        return(untaggedPointerAsAddress(self.pointer))
        }
        
    public var typePointer:TypePointer?
        {
        get
            {
            return(TypePointer(untaggedPointerAtIndexAtPointer(Self.kObjectTypeIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(taggedObject(newValue?.pointer),Self.kObjectTypeIndex,self.pointer)
            }
        }
        
    public var headerWord:Word
        {
        get
            {
            return(wordAtIndexAtPointer(Self.kObjectHeaderIndex,self.pointer))
            }
        set
            {
            setWordAtIndexAtPointer(newValue,Self.kObjectHeaderIndex,self.pointer)
            }
        }
    
    public var objectStrideInBytes:Argon.ByteCount
        {
        return(Argon.ByteCount(2*MemoryLayout<Word>.stride))
        }
        
    public override init(_ address:Instruction.Address)
        {
        super.init(address)
        self.isMarked = true
        }
    
    required public init(_ address: UnsafeMutableRawPointer?)
        {
        super.init(address)
        self.isMarked = true
        }
        
    public func asWord() -> Word
        {
        return(self.taggedAddress)
        }
        
    private func dumpHeader()
        {
        guard let pointer = self.pointer else
            {
            return
            }
        Log.log(.natural("0x\(pointer.hexString):"),.space(1),.natural("\(self.headerWord.bitString)"),.space(1),.natural("HEADER(TYPE=\(self.valueType),SLOTS=\(self.totalSlotCount),EXTRA=\(self.hasExtraSlotsAtEnd),FORWARD=\(self.isForwarded))"))
        }
        
    private func dumpWord(_ slotWord:Word,at address:Instruction.Address)
        {
        switch(slotWord.tag)
            {
            case Argon.kTagBitsObject:
                let objectHeader = HeaderPointer(RawMemory.untaggedAddress(slotWord))
                let type = objectHeader.valueType
                let stringValue = type == .string ? "\"" + ImmutableStringPointer(RawMemory.untaggedAddress(slotWord)).string + "\"" : ""
                Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(objectHeader.headerWord.bitString)"),.space(1),.natural("POINTER TO \(type) \(stringValue)"))
            case Argon.kTagBitsInteger:
                Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("INTEGER(\(Int64(bitPattern: slotWord)))"))
            case Argon.kTagBitsUInteger:
                Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("UINTEGER(\(Int64(bitPattern: slotWord)))"))
//                        case Argon.kTagBitsUnsigned:
//                            Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("UNSIGNED(\(slotWord))"))
//            case Argon.kTagBitsCharacter:
//                let character = Unicode.Scalar(UInt16(untaggedWord(slotWord)))
//                let string = String(character!)
//                Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("CHARACTER(\(string))"))
            case Argon.kTagBitsByte:
                let byte = UInt8(slotWord)
                Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("BYTE(\(byte))"))
            case Argon.kTagBitsBoolean:
                let boolean = slotWord == 1
                Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("BOOLEAN(\(boolean))"))
            case Argon.kTagBitsFloat32:
                let float = Float(bitPattern: slotWord)
                Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("FLOAT32(\(float))"))
            default:
                Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"))
            }
        }
        
    public func dump()
        {
        self.dumpHeader()
        for index in 1..<Self.totalSlotCount.count
            {
            let slotIndex = SlotIndex(index: index)
            let word = wordAtIndexAtPointer(slotIndex,self.pointer)
            self.dumpWord(word,at: Instruction.Address(bitPattern: self.pointer! + slotIndex))
            }
        }
        
    public func equals(_ value:Value) -> Bool
        {
        if value is ObjectPointer
            {
            return(self == (value as! ObjectPointer))
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
        
    public func store(contentsOf holder:inout ValueHolder,atIndex index:SlotIndex)
        {
        guard let pointer = self.pointer else
            {
            Log.log("Null pointer in \(#function), unable to write valueHolder contents")
            return
            }
        holder.store(atIndex: index, atPointer: pointer)
        }
        
    public func store<K>(key:K,atIndex index:SlotIndex) where K:Key
        {
        guard let pointer = self.pointer else
            {
            Log.log("Null pointer in \(#function), unable to write key contents")
            return
            }
        key.store(atPointer: pointer + index)
        }
        
    public func store(value:Value,atIndex index:SlotIndex)
        {
        guard let pointer = self.pointer else
            {
            Log.log("Null pointer in \(#function), unable to write key contents")
            return
            }
        value.store(atPointer: pointer + index)
        }
    }
