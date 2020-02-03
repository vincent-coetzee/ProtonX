//
//  BasePointer.swift
//  argon
//
//  Created by Vincent Coetzee on 29/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory
    
infix operator ====

public class ValuePointer:Pointer,Equatable
    {
    public class func isNullPointer(_ pointer:AnyObject) -> Bool
        {
        return(unsafeBitCast(pointer,to: Word.self) == 0)
        }
        
    public static func ==(lhs:ValuePointer,rhs:ValuePointer) -> Bool
        {
        if unsafeBitCast(lhs,to: Word.self) == unsafeBitCast(rhs,to: Word.self)
            {
            return(true)
            }
        return(lhs.pointer == rhs.pointer)
        }
        
    public class var totalSlotCount:Argon.SlotCount
        {
        fatalError("Should have been overridden")
        }
        
    public let pointer:UnsafeMutableRawPointer?
    public let _index:Word
    private var _segment:MemorySegment?
    
    public var segment:MemorySegment
        {
        get
            {
            return(self._segment ?? MemorySegment.managed)
            }
        set
            {
            self._segment = newValue
            }
        }
    
//    public var segment:MemorySegment?
//        {
//        return(Memory.segmentContaining(address: pointerAsAddress(self.pointer)))
//        }
        
    public var hexString:String
        {
        return(self.pointer?.hexString ?? "0x00000000")
        }
        
    public var bitString:String
        {
        return(pointerAsWord(self.pointer).bitString)
        }
        
    public var taggedAddress:Instruction.Address
        {
        return(0)
        }
        
    public var untaggedAddress:Instruction.Address
        {
        return(0)
        }
        
    public var isNull:Bool
        {
        return(self.pointer == nil)
        }
        
    public var isNotNull:Bool
        {
        return(self.pointer != nil)
        }
        
    internal func initSlots()
        {
        }
        
    public init()
        {
        self.pointer = nil
        self._index = Argon.nextIndex
        self.initSlots()
        }
        
    public init(_ address:Instruction.Address)
        {
        assert(address != 7)
        self.pointer = untaggedAddressAsPointer(address)
        self._index = Argon.nextIndex
        self.initSlots()
        }
        
    required public init(_ address:UnsafeMutableRawPointer?)
        {
        self.pointer = untaggedPointer(address)
        self._index = Argon.nextIndex
        self.initSlots()
        }
        
//    public convenience init(_ slotCount:Int,segment:MemorySegment = Memory.dataSegment)
//        {
//        var totalByteSize = self.byteCountForSlotCount(slotCount)
//        self.init(segment.allocate(count: &totalByteSize))
//        self.slotCount =
//        }
        
    public class func byteCountForSlotCount(_ slotCount:Int) -> Int
        {
        // round the number of bytes up to the next wword boundary
        let wordSize = MemoryLayout<Word>.size
        let totalCount = ((slotCount + 1) * wordSize).aligned(to: MemoryLayout<Word>.alignment)
        return(totalCount)
        }
        
//    public class func layoutFor<T>(type: T.Type,count:Int,slotCount:Int) -> BufferPointer<T>.BufferLayout
//        {
//        // round the number of bytes up to the next wword boundary
//        let unitSize = MemoryLayout<T>.stride
//        let slotSize = MemoryLayout<Word>.stride
//        let sharedAlignment = Argon.lowestCommonMultiple(unitSize,slotSize)
//        let unitByteCount = (count + 1) * unitSize
//        let slotByteCount = (slotCount + 1)*slotSize
//        let totalCount = (unitByteCount + slotByteCount).aligned(to: sharedAlignment)
//        let totalSlotCount = totalCount / slotSize
//        let layout = BufferPointer<T>.BufferLayout(elementByteCount: unitByteCount, elementStride: unitSize, slotByteCount: slotByteCount, slotStride: slotSize, totalByteCount: totalCount, totalSlotCount: totalSlotCount)
//        return(layout)
//        }
        
    public class func slotCountForByteCount(_ byteCount:Int) -> Int
        {
        return(byteCount / MemoryLayout<Word>.size)
        }
        
    public class func countFor<T>(byteCount:Int,of:T.Type) -> Int
        {
        return(byteCount / MemoryLayout<T>.size)
        }
        
    public var wordValue:Word
        {
        return(pointerAsWord(self.pointer))
        }
        
    public func makeInstance(in segment:MemorySegment = Memory.managedSegment) -> Argon.Pointer?
        {
        fatalError("This should not be called here")
        }
    }
