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
    var tag:Proton.HeaderTag { get set }
    var totalSlotCount:Proton.SlotCount { get set }
    var hasExtraSlotsAtEnd:Bool { get set }
    var isMarked:Bool { get set }
    var isForwarded:Bool { get set }
    var valueType:Proton.ValueType { get set }
    }
    
extension Headered
    {
    public var tag:Proton.HeaderTag
        {
        get
            {
            let tagValue = (self.headerWord & (Proton.kTagBitsMask << Proton.kTagBitsShift)) >> Proton.kTagBitsShift
            return(Proton.HeaderTag(rawValue: tagValue)!)
            }
        set
            {
            let tagValue = (newValue.rawValue & Proton.kTagBitsMask ) << Proton.kTagBitsShift
            let header = self.headerWord & ~(Proton.kTagBitsMask  << Proton.kTagBitsShift)
            self.headerWord = header | tagValue
            }
        }
        
    public var totalSlotCount:Proton.SlotCount
        {
        get
            {
            return(Proton.SlotCount(((Proton.kHeaderSlotCountMask << Proton.kHeaderSlotCountShift) & self.headerWord) >> Proton.kHeaderSlotCountShift))
            }
        set
            {
            let newWord = (Word(newValue) & Proton.kHeaderSlotCountMask) << Proton.kHeaderSlotCountShift
            let header = self.headerWord & ~(Proton.kHeaderSlotCountMask  << Proton.kHeaderSlotCountShift)
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
        
    public var valueType:Proton.ValueType
        {
        get
            {
            return(Proton.ValueType(rawValue: (self.headerWord & Proton.kHeaderValueTypeMask)) ?? .none)
            }
        set
            {
            let newWord = (Word(newValue.rawValue) & Proton.kHeaderValueTypeMask)
            let header = self.headerWord & ~(Proton.kHeaderValueTypeMask)
            self.headerWord = header | newWord
            }
        }
        
    public var hasExtraSlotsAtEnd:Bool
        {
        get
            {
            return((((Proton.kHeaderHasExtraSlotsAtEndMask << Proton.kHeaderHasExtraSlotsAtEndShift) & self.headerWord) >> Proton.kHeaderHasExtraSlotsAtEndShift) == 1)
            }
        set
            {
            let newWord = ((newValue ? 1 : 0) & Proton.kHeaderHasExtraSlotsAtEndMask) << Proton.kHeaderHasExtraSlotsAtEndShift
            let header = self.headerWord & ~(Proton.kHeaderHasExtraSlotsAtEndMask  << Proton.kHeaderHasExtraSlotsAtEndShift)
            self.headerWord = header | newWord
            }
        }
        
    public var isMarked:Bool
        {
        get
            {
            return((((Proton.kHeaderMarkerMask << Proton.kHeaderMarkerShift) & self.headerWord) >> Proton.kHeaderMarkerShift) == 1)
            }
        set
            {
            if ValuePointer.isNullPointer(self)
                {
                return
                }
            let newWord = ((newValue ? 1 : 0) & Proton.kHeaderMarkerMask) << Proton.kHeaderMarkerShift
            let header = self.headerWord & ~(Proton.kHeaderMarkerMask  << Proton.kHeaderMarkerShift)
            self.headerWord = header | newWord
            }
        }
        
    public var isForwarded:Bool
        {
        get
            {
            return((((Proton.kHeaderIsForwardedMask << Proton.kHeaderIsForwardedShift) & self.headerWord) >> Proton.kHeaderIsForwardedShift) == 1)
            }
        set
            {
            let newWord = ((newValue ? 1 : 0) & Proton.kHeaderIsForwardedMask) << Proton.kHeaderIsForwardedShift
            let header = self.headerWord & ~(Proton.kHeaderIsForwardedMask  << Proton.kHeaderIsForwardedShift)
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
        
    public init(slotCount:Proton.SlotCount,valueType:Proton.ValueType,hasExtraSlotsAtEnd:Bool)
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
    private let address:Proton.Address
    
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
        
    public init(_ address:Proton.Address)
        {
        self.address = address
        }
    }
