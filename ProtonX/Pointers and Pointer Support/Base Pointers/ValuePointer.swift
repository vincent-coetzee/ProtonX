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
        return(lhs.address == rhs.address)
        }
        
    public class var totalSlotCount:Proton.SlotCount
        {
        fatalError("Should have been overridden")
        }
        
    public let address:Proton.Address
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
        return(self.address.hexString)
        }
        
    public var bitString:String
        {
        return(self.address.bitString)
        }
        
    public var taggedAddress:Proton.Address
        {
        return((Proton.kTagBitsAddress << Proton.kTagBitsShift) | self.address)
        }
        
    public var untaggedAddress:Proton.Address
        {
        return(self.address)
        }
        
    public var isNull:Bool
        {
        return(self.address == 0)
        }
        
    public var isNotNull:Bool
        {
        return(self.address != 0)
        }
        
    internal func initSlots()
        {
        }
        
    public init()
        {
        self.address = 0
        self._index = Proton.nextIndex
        self.initSlots()
        }
        
    required public init(_ address:Proton.Address)
        {
        self.address = address & ~(Proton.kTagBitsMask << Proton.kTagBitsShift)
        self._index = Proton.nextIndex
        self.initSlots()
        }
        
    public class func byteCountForSlotCount(_ slotCount:Int) -> Int
        {
        // round the number of bytes up to the next wword boundary
        let wordSize = MemoryLayout<Word>.size
        let totalCount = ((slotCount + 1) * wordSize).aligned(to: MemoryLayout<Word>.alignment)
        return(totalCount)
        }
        
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
        return(Word(self.address))
        }
        
    public func makeInstance(in segment:MemorySegment = Memory.managedSegment) -> Proton.Address
        {
        fatalError("This should not be called here")
        }
    }
