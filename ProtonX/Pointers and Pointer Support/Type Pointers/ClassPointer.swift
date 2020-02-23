//
//  ClassPointer.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/23.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class ClassPointer:TypePointer
    {
    public static let kClassSlotArrayIndex = SlotIndex.six
    public static let kClassParentsArrayIndex = SlotIndex.seven
    public static let kClassContractArrayIndex = SlotIndex.eight
    public static let kClassInstanceHasBytesIndex = SlotIndex.nine
    
    public override class var totalSlotCount:Proton.SlotCount
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
        
    private var _slotArrayPointer:ArrayPointer?
    
    public var slotArrayPointer:ArrayPointer
        {
        get
            {
            if self._slotArrayPointer != nil
                {
                return(self._slotArrayPointer!)
                }
            self._slotArrayPointer = ArrayPointer(addressAtIndexAtAddress(Self.kClassSlotArrayIndex,self.address))
            return(self._slotArrayPointer!)
            }
        set
            {
            self._slotArrayPointer = newValue
            setWordAtIndexAtAddress(newValue.taggedAddress,Self.kClassSlotArrayIndex,self.address)
            }
        }
        
    private var _parentsArrayPointer:ArrayPointer?
    
    public var parentsArrayPointer:ArrayPointer
        {
        get
            {
            if self._parentsArrayPointer != nil
                {
                return(self._parentsArrayPointer!)
                }
            self._parentsArrayPointer = ArrayPointer(addressAtIndexAtAddress(Self.kClassParentsArrayIndex,self.address))
            return(self._parentsArrayPointer!)
            }
        set
            {
            self._parentsArrayPointer = newValue
            setWordAtIndexAtAddress(newValue.taggedAddress,Self.kClassParentsArrayIndex,self.address)
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
            self._contractArrayPointer = ArrayPointer(addressAtIndexAtAddress(Self.kClassContractArrayIndex,self.address))
            return(self._contractArrayPointer!)
            }
        set
            {
            self._contractArrayPointer = newValue
            setWordAtIndexAtAddress(newValue.taggedAddress,Self.kClassContractArrayIndex,self.address)
            }
        }
        
    public var fitsInWord:Bool
        {
        let flag = self.instanceType
        return(flag == Proton.kTypeInteger || flag == Proton.kTypeUInteger || flag == Proton.kTypeBoolean || flag == Proton.kTypeByte || flag == Proton.kTypeFloat32)
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
//            return(Int(wordAtIndexAtAddress(Self.kTypeInstanceSlotCountIndex,self.address)))
//            }
//        set
//            {
//            setWordAtIndexAtAddress(Word(newValue),Self.kTypeInstanceSlotCountIndex,self.address)
//            }
//        }
        
    public var parentCount:Int
        {
        return(self.parentsArrayPointer.count)
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
