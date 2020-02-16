//
//  AllocationBlockPointer.swift
//  argon
//
//  Created by Vincent Coetzee on 29/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

    
public class WordBlockPointer:CollectionPointer
    {
    public struct BufferLayout
        {
        public let elementByteCount:Int
        public let elementStride:Int
        public let slotByteCount:Int
        public let slotStride:Int
        public let totalByteCount:Int
        public let totalSlotCount:Int
        }
    
    public class var kBufferElementStrideIndex:SlotIndex
        {
        return(SlotIndex.four)
        }
        
    public class var kBufferTotalByteCountIndex:SlotIndex
        {
        return(SlotIndex.five)
        }
        
    public class var kBufferTotalElementByteCountIndex:SlotIndex
        {
        return(SlotIndex.six)
        }
        
    public class var kBufferMaximumElementCountIndex:SlotIndex
        {
        return(SlotIndex.seven)
        }
        
    public class var kBufferElementsIndex:SlotIndex
        {
        return(SlotIndex.eight)
        }
        
    public override class var totalSlotCount:Proton.SlotCount
        {
        return(9)
        }
        
    public var totalByteCount:Proton.ByteCount
        {
        get
            {
            return(Proton.ByteCount(wordAtIndexAtAddress(Self.kBufferTotalByteCountIndex,self.address)))
            }
        set
            {
            setWordAtIndexAtAddress(Word(newValue),Self.kBufferTotalByteCountIndex,self.address)
            }
        }
        
    public var maximumElementCount:Int
        {
        get
            {
            return(Int(wordAtIndexAtAddress(Self.kBufferMaximumElementCountIndex,self.address)))
            }
        set
            {
            setWordAtIndexAtAddress(Word(newValue),Self.kBufferMaximumElementCountIndex,self.address)
            }
        }
        
    public var elementStrideInBytes:Int
        {
        get
            {
            return(Int(wordAtIndexAtAddress(Self.kBufferElementStrideIndex,self.address)))
            }
        set
            {
            setWordAtIndexAtAddress(Word(newValue),Self.kBufferElementStrideIndex,self.address)
            }
        }
        
    public var totalElementByteCount:Proton.ByteCount
        {
        get
            {
            return(Proton.ByteCount(wordAtIndexAtAddress(Self.kBufferTotalElementByteCountIndex,self.address)))
            }
        set
            {
            setWordAtIndexAtAddress(Word(newValue.count),Self.kBufferTotalElementByteCountIndex,self.address)
            }
        }
        
    public required init(_ address:Word)
        {
        super.init(address)
        }
        
    public init(elementCount:Int,elementType:TypePointer,segment:MemorySegment = Memory.managedSegment)
        {
        let theElementStride = elementType.objectStrideInBytes
        let theSlotStride = MemoryLayout<Word>.stride
        let overallAlignment = Proton.lowestCommonMultiple(theElementStride.count,theSlotStride)
        let theElementByteCount = Proton.ByteCount(theElementStride.count * elementCount).aligned(to: overallAlignment)
        let theSlotByteCount = Proton.ByteCount(theSlotStride * WordBlockPointer.totalSlotCount.count).aligned(to: overallAlignment)
        let theTotalByteCount = theSlotByteCount + theElementByteCount
        var newSlotCount = Proton.SlotCount(0)
        super.init(segment.allocate(byteCount: theTotalByteCount,slotCount: &newSlotCount))
        self.elementTypePointer = elementType
        self.maximumElementCount = elementCount
        self.totalElementByteCount = theElementByteCount
        self.elementStrideInBytes = theElementStride.count
        self.totalByteCount = theTotalByteCount
        self.isMarked = true
        self.valueType = .wordBuffer
        self.hasExtraSlotsAtEnd = true
        self.totalSlotCount = newSlotCount
        self.typePointer = Memory.kTypeWordBuffer
        self.count = 0
        Log.log("ALLOCATED WORDBUFFER AT \(self.hexString)")
        }
        
    @inline(__always)
    public func addressOfElement(atIndex:SlotIndex) -> Proton.Address
        {
        return(self.address + SlotOffset(stride: self.elementStrideInBytes,index: atIndex))
        }
        
    public var wordAddress:Proton.Address
        {
        return(self.address + Self.kBufferElementsIndex)
        }
        
    public subscript(_ index:Int) -> Word
        {
        get
            {
            return(wordAtAddress(self.addressOfElement(atIndex: SlotIndex(index: index))))
            }
        set
            {
            setWordAtAddress(newValue,self.addressOfElement(atIndex: SlotIndex(index: index)))
            }
        }
        
    public func copy(from buffer: Proton.Address,elementCount:Int)
        {
        let totalBytes = (elementCount + WordBlockPointer.totalSlotCount.count) * MemoryLayout<Word>.stride
        memcpy(UnsafeMutableRawPointer(bitPattern: UInt(self.address)),UnsafeMutableRawPointer(bitPattern: UInt(self.address)),totalBytes)
        self.count = elementCount
        }
    }


