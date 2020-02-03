//
//  SeamPointer.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 03/02/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class SeamPointer:TypePointer
    {
    public static let kSeamSlotArrayIndex = SlotIndex.five
    public static let kSeamParentSeamArrayIndex = SlotIndex.six
    public static let kSeamContractArrayIndex = SlotIndex.seven
    public static let kSeamInstanceHasBytesIndex = SlotIndex.eight
    
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(9)
        }
        
    public var slotCount:Int
        {
        get
            {
            return(self.slotArrayPointer.count)
            }
        }
        
    public var parentSeamCount:Int
        {
        get
            {
            return(self.parentSeamArrayPointer.count)
            }
        }
        
    private var _slotArrayPointer:ArrayPointer?
    
    public var slotArrayPointer:ArrayPointer
        {
        get
            {
            if self._slotArrayPointer != nil
                {
                return(self._slotArrayPointer!)
                }
            self._slotArrayPointer = ArrayPointer(untaggedAddressAtIndexAtPointer(Self.kSeamSlotArrayIndex,self.pointer))
            return(self._slotArrayPointer!)
            }
        set
            {
            self._slotArrayPointer = newValue
            setWordAtIndexAtPointer(newValue.taggedAddress,Self.kSeamSlotArrayIndex,self.pointer)
            }
        }
        
    private var _parentSeamArrayPointer:ArrayPointer?
    
    public var parentSeamArrayPointer:ArrayPointer
        {
        get
            {
            if self._parentSeamArrayPointer != nil
                {
                return(self._parentSeamArrayPointer!)
                }
            self._parentSeamArrayPointer = ArrayPointer(untaggedAddressAtIndexAtPointer(Self.kSeamParentSeamArrayIndex,self.pointer))
            return(self._parentSeamArrayPointer!)
            }
        set
            {
            self._parentSeamArrayPointer = newValue
            setWordAtIndexAtPointer(newValue.taggedAddress,Self.kSeamParentSeamArrayIndex,self.pointer)
            }
        }
        
    private var _contractArrayPointer:ArrayPointer?
    
    public var contractArrayPointer:ArrayPointer
        {
        get
            {
            if self._contractArrayPointer != nil
                {
                return(self._contractArrayPointer!)
                }
            self._contractArrayPointer = ArrayPointer(untaggedAddressAtIndexAtPointer(Self.kSeamContractArrayIndex,self.pointer))
            return(self._contractArrayPointer!)
            }
        set
            {
            self._contractArrayPointer = newValue
            setWordAtIndexAtPointer(newValue.taggedAddress,Self.kSeamContractArrayIndex,self.pointer)
            }
        }
        
    public var fitsInWord:Bool
        {
        let flag = self.instanceType
        return(flag == Argon.kTypeInteger || flag == Argon.kTypeUInteger || flag == Argon.kTypeBoolean || flag == Argon.kTypeByte || flag == Argon.kTypeFloat32)
        }
        
    public var instanceHasBytes:Bool
        {
        get
            {
            return(self.flag(TypePointer.kFlagInstanceContainsBits))
            }
        set
            {
            self.setFlag(TypePointer.kFlagInstanceContainsBits,to: newValue)
            }
        }
//
//    public var instanceSlotCount:Int
//        {
//        get
//            {
//            return(Int(untaggedWordAtIndexAtPointer(Self.kTypeInstanceSlotCountIndex,self.pointer)))
//            }
//        set
//            {
//            setWordAtIndexAtPointer(Word(newValue),Self.kTypeInstanceSlotCountIndex,self.pointer)
//            }
//        }
        
    public var parentCount:Int
        {
        return(self.parentSeamArrayPointer.count)
        }
        
    public func appendSlot(name:String,type:TypePointer?,flags:Word,index:SlotIndex,segment: MemorySegment)
        {
        self.appendSlot(SlotPointer(name: name,type: type,flags: flags,index: index,segment: segment))
        }
        
    public func appendSlot(_ slot:SlotPointer)
        {
        if self.slotArrayPointer.isNull
            {
            self.slotArrayPointer = self.segment.allocateArray(count: 16, elementType: Memory.kTypeSlot!)
            if self.slotArrayPointer.isNull
                {
                fatalError("SlotArray not allocating correctly")
                }
            }
        self.slotArrayPointer.append(slot.taggedAddress)
        }
    }
