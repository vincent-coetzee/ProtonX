//
//  InstancePointer.swift
//  argon
//
//  Created by Vincent Coetzee on 02/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class ObjectPointer:ValuePointer,Headered,Value,Key,CachedPointer
    {
    public var valueStride: Int
        {
        return(MemoryLayout<Word>.stride)
        }
        
    public var hashedValue:Int
        {
        return(Int(Int64(bitPattern: self.taggedAddress)))
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
        
    public class var slotSizeInBytes:Proton.ByteCount
        {
        return(Proton.ByteCount(MemoryLayout<Word>.stride))
        }
        
    public override class var totalSlotCount:Proton.SlotCount
        {
        return(2)
        }
        
    public override var taggedAddress:Proton.Address
        {
        return((self.address & ~(Proton.kTagBitsMask << Proton.kTagBitsShift)) | (Proton.kTagBitsAddress << Proton.kTagBitsShift))
        }
        
    public override var untaggedAddress:Proton.Address
        {
        return(self.address & ~(Proton.kTagBitsMask << Proton.kTagBitsShift))
        }
        
    public var typePointer:TypePointer?
        {
        get
            {
            return(TypePointer(addressAtIndexAtAddress(Self.kObjectTypeIndex,self.address)))
            }
        set
            {
            setAddressAtIndexAtAddress(newValue?.address ?? 0,Self.kObjectTypeIndex,self.address)
            }
        }
        
    public var headerWord:Word
        {
        get
            {
            return(wordAtIndexAtAddress(Self.kObjectHeaderIndex,self.address))
            }
        set
            {
            setWordAtIndexAtAddress(newValue,Self.kObjectHeaderIndex,self.address)
            }
        }
    
    public var objectStrideInBytes:Proton.ByteCount
        {
        return(Proton.ByteCount(2*MemoryLayout<Word>.stride))
        }
        
    private var pointerSlotCache:[SlotIndex:ObjectPointer] = [:]

    public required init(_ address:Proton.Address)
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
        Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(self.headerWord.bitString)"),.space(1),.natural("HEADER(TYPE=\(self.valueType),SLOTS=\(self.totalSlotCount),EXTRA=\(self.hasExtraSlotsAtEnd),FORWARD=\(self.isForwarded))"))
        }
        
    private func dumpWord(_ slotWord:Word,at address:Proton.Address)
        {
        switch(slotWord.tag)
            {
            case Proton.kTagBitsAddress:
                let objectHeader = HeaderPointer(RawMemory.untaggedAddress(slotWord))
                let type = objectHeader.valueType
                let stringValue = type == .string ? "\"" + ImmutableStringPointer(RawMemory.untaggedAddress(slotWord)).string + "\"" : ""
                Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(objectHeader.headerWord.bitString)"),.space(1),.natural("POINTER TO \(type) \(stringValue)"))
            case Proton.kTagBitsInteger:
                Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("INTEGER(\(Int64(bitPattern: slotWord)))"))
            case Proton.kTagBitsByte:
                let byte = UInt8(slotWord)
                Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("BYTE(\(byte))"))
            case Proton.kTagBitsBoolean:
                let boolean = slotWord == 1
                Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("BOOLEAN(\(boolean))"))
            case Proton.kTagBitsFloat32:
                let float = Float(taggedBits: slotWord)
                Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("FLOAT32(\(float))"))
            case Proton.kTagBitsFloat64:
                let float = Double(taggedBits: slotWord)
                Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("FLOAT64(\(float))"))
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
            let word = wordAtIndexAtAddress(slotIndex,self.address)
            self.dumpWord(word,at: self.address + slotIndex)
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
        
    public func store(atAddress address:Proton.Address)
        {
        setAddressAtAddress(self.address,address)
        }
        
    public func store(contentsOf holder:inout ValueHolder,atIndex index:SlotIndex)
        {
        holder.store(atIndex: index, atAddress: self.address)
        }
        
    public func store<K>(key:K,atIndex index:SlotIndex) where K:Key
        {
        key.store(atAddress: self.address + index)
        }
        
    public func store(value:Value,atIndex index:SlotIndex)
        {
        value.store(atAddress: self.address + index)
        }
        
    public func value<T>(of index: SlotIndex,as:T.Type) -> T  where T:CachedPointer
        {
        if let pointer = self.pointerSlotCache[index]
            {
            return(pointer as! T)
            }
        let pointer = T(addressAtIndexAtAddress(index,self.address))
        self.pointerSlotCache[index] = (pointer as! ObjectPointer)
        return(pointer)
        }
        
    public func setValue<T>(of index:SlotIndex,to:T) where T:CachedPointer
        {
        let objectPointer = (to as! ObjectPointer)
        self.pointerSlotCache[index] = objectPointer
        setAddressAtIndexAtAddress(objectPointer.address,index,self.address)
        }
    }
