//
//  SlotPointer.swift
//  argon
//
//  Created by Vincent Coetzee on 30/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class SlotTypePointer:TypePointer
    {
    }
    
public class SlotPointer:ObjectPointer
    {
    public static let kSlotFirstOffset = SlotOffset(stride: MemoryLayout<Word>.stride,index: SlotIndex(index: 2))
    
    public static let kSlotNameIndex = SlotIndex.ten                // the name of the slot - eg "dateOfBirth"
    public static let kSlotTypeIndex = SlotIndex.ten + .one         // the type of the slot, a TypePointer
    public static let kSlotFlagsIndex = SlotIndex.ten + .two        // flags describing the slot
    public static let kSlotIndexIndex = SlotIndex.ten + .three      // the index of the slot in the object, the header index is 0, the type is 1, so this should be t least 2
    public static let kSlotBaseSlotCount = SlotIndex.ten + .four    // dunno

    public override class var totalSlotCount:Argon.SlotCount
        {
        return(15)
        }
        
    public var flags:Word
        {
        get
            {
            return(wordAtIndexAtPointer(Self.kSlotFlagsIndex,self.pointer))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),Self.kSlotFlagsIndex,self.pointer)
            }
        }
        
    public var index:SlotIndex
        {
        get
            {
            return(SlotIndex(index: Int(wordAtIndexAtPointer(Self.kSlotIndexIndex,self.pointer))))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue.index),Self.kSlotIndexIndex,self.pointer)
            }
        }
        
    public var namePointer:ImmutableStringPointer
        {
        get
            {
            return(ImmutableStringPointer(untaggedPointerAtIndexAtPointer(Self.kSlotNameIndex,self.pointer)))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue.pointer,Self.kSlotNameIndex,self.pointer)
            }
        }
        
    public var name:String
        {
        get
            {
            return(self.namePointer.string)
            }
        }
        
    public var slotTypePointer:TypePointer?
        {
        get
            {
            return(TypePointer(untaggedPointerAtIndexAtPointer(Self.kSlotTypeIndex,self.pointer)))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue?.pointer,Self.kSlotTypeIndex,self.pointer)
            }
        }
        
    public init(name:String,type:TypePointer?,flags:Word = 0,index:SlotIndex,segment:MemorySegment = Memory.managedSegment)
        {
        let namePointer = ImmutableStringPointer(name)
        let byteCount = Argon.ByteCount(Self.totalSlotCount)
        var newSlotCount = Argon.SlotCount(0)
        let address = segment.allocate(byteCount: byteCount,slotCount: &newSlotCount)
        super.init(address)
        self.isMarked = true
        self.totalSlotCount = newSlotCount
        self.valueType = .slot
        self.typePointer = Memory.kTypeSlot
        self.flags = flags
        self.namePointer = namePointer
        self.index = index
        self.slotTypePointer = type
        }
    
    required public init(_ address: UnsafeMutableRawPointer?)
        {
        super.init(address)
        }
}
