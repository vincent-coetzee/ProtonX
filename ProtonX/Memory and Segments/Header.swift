//
//  Header.swift
//  argon
//
//  Created by Vincent Coetzee on 31/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public protocol Headered:class
    {
    var headerWord:Word { get set }
    var tag:Argon.HeaderTag { get set }
    var totalSlotCount:Argon.SlotCount { get set }
    var hasExtraSlotsAtEnd:Bool { get set }
    var isMarked:Bool { get set }
    var isForwarded:Bool { get set }
    var valueType:Argon.ValueType { get set }
    }
    
extension Headered
    {
    public var tag:Argon.HeaderTag
        {
        get
            {
            let tagValue = (self.headerWord & (Argon.kTagBitsMask << Argon.kTagBitsShift)) >> Argon.kTagBitsShift
            return(Argon.HeaderTag(rawValue: tagValue)!)
            }
        set
            {
            let tagValue = (newValue.rawValue & Argon.kTagBitsMask ) << Argon.kTagBitsShift
            let header = self.headerWord & ~(Argon.kTagBitsMask  << Argon.kTagBitsShift)
            self.headerWord = header | tagValue
            }
        }
        
    public var totalSlotCount:Argon.SlotCount
        {
        get
            {
            return(Argon.SlotCount(((Argon.kHeaderSlotCountMask << Argon.kHeaderSlotCountShift) & self.headerWord) >> Argon.kHeaderSlotCountShift))
            }
        set
            {
            let newWord = (Word(newValue) & Argon.kHeaderSlotCountMask) << Argon.kHeaderSlotCountShift
            let header = self.headerWord & ~(Argon.kHeaderSlotCountMask  << Argon.kHeaderSlotCountShift)
            self.headerWord = header | newWord
            }
        }
        
//    public var headerSegment:MemorySegment.Identifier
//        {
//        get
//            {
//            return(MemorySegment.Identifier(rawValue: Int(((Argon.kSegmentMask << Argon.kSegmentShift) & self.headerWord) >> Argon.kSegmentShift))!)
//            }
//        set
//            {
//            let newWord = (Word(newValue.rawValue) & Argon.kSegmentMask) << Argon.kSegmentShift
//            let header = self.headerWord & ~(Argon.kSegmentMask  << Argon.kSegmentShift)
//            self.headerWord = header | newWord
//            }
//        }
        
    public var valueType:Argon.ValueType
        {
        get
            {
            return(Argon.ValueType(rawValue: (self.headerWord & Argon.kHeaderValueTypeMask)) ?? .none)
            }
        set
            {
            let newWord = (Word(newValue.rawValue) & Argon.kHeaderValueTypeMask)
            let header = self.headerWord & ~(Argon.kHeaderValueTypeMask)
            self.headerWord = header | newWord
            }
        }
        
    public var hasExtraSlotsAtEnd:Bool
        {
        get
            {
            return((((Argon.kHeaderHasExtraSlotsAtEndMask << Argon.kHeaderHasExtraSlotsAtEndShift) & self.headerWord) >> Argon.kHeaderHasExtraSlotsAtEndShift) == 1)
            }
        set
            {
            let newWord = ((newValue ? 1 : 0) & Argon.kHeaderHasExtraSlotsAtEndMask) << Argon.kHeaderHasExtraSlotsAtEndShift
            let header = self.headerWord & ~(Argon.kHeaderHasExtraSlotsAtEndMask  << Argon.kHeaderHasExtraSlotsAtEndShift)
            self.headerWord = header | newWord
            }
        }
        
    public var isMarked:Bool
        {
        get
            {
            return((((Argon.kHeaderMarkerMask << Argon.kHeaderMarkerShift) & self.headerWord) >> Argon.kHeaderMarkerShift) == 1)
            }
        set
            {
            if ValuePointer.isNullPointer(self)
                {
                return
                }
            let newWord = ((newValue ? 1 : 0) & Argon.kHeaderMarkerMask) << Argon.kHeaderMarkerShift
            let header = self.headerWord & ~(Argon.kHeaderMarkerMask  << Argon.kHeaderMarkerShift)
            self.headerWord = header | newWord
            }
        }
        
    public var isForwarded:Bool
        {
        get
            {
            return((((Argon.kHeaderIsForwardedMask << Argon.kHeaderIsForwardedShift) & self.headerWord) >> Argon.kHeaderIsForwardedShift) == 1)
            }
        set
            {
            let newWord = ((newValue ? 1 : 0) & Argon.kHeaderIsForwardedMask) << Argon.kHeaderIsForwardedShift
            let header = self.headerWord & ~(Argon.kHeaderIsForwardedMask  << Argon.kHeaderIsForwardedShift)
            self.headerWord = header | newWord
            }
        }
        
    public var isScalarType:Bool
        {
        let type = self.valueType
        return(type == .integer || type == .uinteger || type == .byte || type == .float32 || type == .boolean)
        }
        
    public var intBitPattern:Int
        {
        return(Int(bitPattern: UInt(self.headerWord)))
        }
    }

public class Header:Headered
    {
    public var word:Word = 0
    
    public init(_ word:Word)
        {
        self.word = word
        }
        
    public init(slotCount:Argon.SlotCount,valueType:Argon.ValueType,hasExtraSlotsAtEnd:Bool)
        {
        self.totalSlotCount = slotCount
        self.valueType = valueType
        self.hasExtraSlotsAtEnd = hasExtraSlotsAtEnd
        }
        
    public var headerWord:Word
        {
        get
            {
            return(self.word)
            }
        set
            {
            self.word = newValue
            }
        }
    }

public class HeaderPointer:Headered
    {
    private let address:Argon.Address
    
    public var headerWord:Word
        {
        get
            {
            return(wordAtIndexAtAddress(.zero,self.address))
            }
        set
            {
            setWordAtIndexAtAddress(newValue,.zero,self.address)
            }
        }
        
    public init(_ address:Argon.Address)
        {
        self.address = address
        }
    }
