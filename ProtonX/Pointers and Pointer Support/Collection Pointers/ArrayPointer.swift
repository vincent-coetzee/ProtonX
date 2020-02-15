//
//  ArrayPointer.swift
//  argon
//
//  Created by Vincent Coetzee on 29/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class ArrayPointer:CollectionPointer
    {
    public static let kArrayMaximumCountIndex = SlotIndex.four
    public static let kArrayWordBufferPointerIndex = SlotIndex.five
    public static let kArrayRangeTypeIndex = SlotIndex.six
    public static let kArrayRangeLowerBoundIndex = SlotIndex.seven
    public static let kArrayRangeUpperBoundIndex = SlotIndex.eight
    public static let kArrayRangeEnumerationIndex = SlotIndex.nine
        
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(10)
        }
        
    public static let kArrayRangeTypeNone = 0
    public static let kArrayRangeTypeEnumeration = 1
    public static let kArrayRangeTypeFixed = 2
    public static let kArrayRangeTypeRange = 3
    public static let kArrayRangeTypeVector = 4
        
    public enum ArrayIndex
        {
        case none
        case enumeration(Argon.Address)
        case fixed(Word)
        case range(Int)
        case vector(Word)
        }
        
    public enum ArrayIndexType
        {
        case none
        case enumeration(Argon.Address,Word,Word)
        case fixed(Word)
        case range(Argon.Address,Int,Int)
        case vector
        
        public var rawValue:Int
            {
            switch(self)
                {
                case .none:
                    return(ArrayPointer.kArrayRangeTypeNone)
                case .enumeration:
                    return(ArrayPointer.kArrayRangeTypeEnumeration)
                case .fixed:
                    return(ArrayPointer.kArrayRangeTypeFixed)
                case .range:
                    return(ArrayPointer.kArrayRangeTypeRange)
                case .vector:
                    return(ArrayPointer.kArrayRangeTypeVector)
                }
            }
            
        public var count:Int
            {
            switch(self)
                {
                case .none:
                    return(0)
                case .enumeration(_,let lower,let upper):
                    return(Int(upper - lower + 1))
                case .fixed(let size):
                    return(Int(size))
                case .range(_,let lower,let upper):
                    return(upper - lower + 1)
                case .vector:
                    return(0)
                }
            }
            
        public func wordIndex(for index:ArrayIndex) -> Word?
            {
            switch(self,index)
                {
                case (.none,.none):
                    return(nil)
                case (.enumeration(_,_,_),.enumeration(_)):
//                    let enumPointer = EnumerationPointer(sourceEnumAddress)
//                    let stringPointer = StringPointer(elementAddress)
//                    if var wordIndex = enumPointer.index(of: stringPointer.string)
//                        {
//                        wordIndex -= Int(lower)
//                        if wordIndex > upper
//                            {
//                            return(nil)
//                            }
//                        return(Word(wordIndex))
//                        }
//                    else
//                        {
//                        return(nil)
//                        }
                    fatalError()
                case (.fixed(let size),.fixed(let fixedIndex)):
                    if fixedIndex < size
                        {
                        return(fixedIndex)
                        }
                    return(nil)
                case (.range(_,let lower,let upper),.range(let rangeIndex)):
                    if rangeIndex <= upper && rangeIndex >= lower
                        {
                        return(Word(rangeIndex - lower))
                        }
                    return(nil)
                case (.vector,.vector(let vectorIndex)):
                    return(vectorIndex)
                default:
                    fatalError("Attempt to index an array with index \(self) with an index of \(index)")
                }
            }
        }
            
    public var arrayIndexType:ArrayPointer.ArrayIndexType
        {
        get
            {
            let type = wordAtIndexAtAddress(Self.kArrayRangeTypeIndex,self.address)
            if type == ArrayPointer.kArrayRangeTypeNone
                {
                return(.none)
                }
            else if type == ArrayPointer.kArrayRangeTypeEnumeration
                {
                let enumAddress = wordAtIndexAtAddress(ArrayPointer.kArrayRangeEnumerationIndex,self.address)
                let lower = wordAtIndexAtAddress(ArrayPointer.kArrayRangeLowerBoundIndex,self.address)
                let upper = wordAtIndexAtAddress(ArrayPointer.kArrayRangeUpperBoundIndex,self.address)
                return(.enumeration(enumAddress,lower,upper))
                }
            else if type == ArrayPointer.kArrayRangeTypeFixed
                {
                let size = wordAtIndexAtAddress(ArrayPointer.kArrayRangeLowerBoundIndex,self.address)
                return(.fixed(size))
                }
            else if type == ArrayPointer.kArrayRangeTypeRange
                {
                let typeAddress = wordAtIndexAtAddress(ArrayPointer.kArrayRangeEnumerationIndex,self.address)
                let lower = wordAtIndexAtAddress(ArrayPointer.kArrayRangeLowerBoundIndex,self.address)
                let upper = wordAtIndexAtAddress(ArrayPointer.kArrayRangeUpperBoundIndex,self.address)
                return(.range(typeAddress,Int(Int64(bitPattern: lower)),Int(Int64(bitPattern: upper))))
                }
            else if type == ArrayPointer.kArrayRangeTypeVector
                {
                return(.vector)
                }
            fatalError("Invalid array index type")
            }
        set
            {
            switch(newValue)
                {
                case .none:
                    setWordAtIndexAtAddress(Word(ArrayPointer.kArrayRangeTypeNone),ArrayPointer.kArrayRangeTypeIndex,self.address)
                    break
                case .enumeration(let address,let lower,let upper):
                    setWordAtIndexAtAddress(Word(ArrayPointer.kArrayRangeTypeEnumeration),ArrayPointer.kArrayRangeTypeIndex,self.address)
                    setAddressAtIndexAtAddress(address,ArrayPointer.kArrayRangeEnumerationIndex,self.address)
                    setWordAtIndexAtAddress(lower,ArrayPointer.kArrayRangeLowerBoundIndex,self.address)
                    setWordAtIndexAtAddress(upper,ArrayPointer.kArrayRangeUpperBoundIndex,self.address)
                case .fixed(let size):
                    setWordAtIndexAtAddress(Word(ArrayPointer.kArrayRangeTypeFixed),ArrayPointer.kArrayRangeTypeIndex,self.address)
                    setWordAtIndexAtAddress(size,ArrayPointer.kArrayRangeLowerBoundIndex,self.address)
                case .range(let address,let lower,let upper):
                    setWordAtIndexAtAddress(Word(ArrayPointer.kArrayRangeTypeRange),ArrayPointer.kArrayRangeTypeIndex,self.address)
                    setAddressAtIndexAtAddress(address,ArrayPointer.kArrayRangeEnumerationIndex,self.address)
                    setIntegerAtIndexAtAddress(Int64(lower),ArrayPointer.kArrayRangeLowerBoundIndex,self.address)
                    setIntegerAtIndexAtAddress(Int64(upper),ArrayPointer.kArrayRangeUpperBoundIndex,self.address)
                case .vector:
                    setWordAtIndexAtAddress(Word(ArrayPointer.kArrayRangeTypeVector),ArrayPointer.kArrayRangeTypeIndex,self.address)
                }
            }
        }
        
    public var elementAddress:Argon.Address?
        {
        return(self.bufferPointer.wordAddress)
        }
        
    private var _bufferPointer = SlotValue<WordBlockPointer>(index: ArrayPointer.kArrayWordBufferPointerIndex)
    
    public var bufferPointer:WordBlockPointer
        {
        get
            {
            return(self._bufferPointer.value)
            }
        set
            {
            self._bufferPointer.value = newValue
            }
        }
        
    private var _maximumCount = SlotValue<Int>(index: ArrayPointer.kArrayMaximumCountIndex)
    
    public var maximumCount:Int
        {
        get
            {
            return(self._maximumCount.value)
            }
        set
            {
            self._maximumCount.value = newValue
            }
        }
        
    public override func initSlots()
        {
        super.initSlots()
        self._bufferPointer.source = self
        self._maximumCount.source = self
        }
        
    public func initializeInstance(type:TypePointer,arrayIndexType:ArrayIndexType,elementType:TypePointer,segment:MemorySegment)
        {
        self.isMarked = true
        self.arrayIndexType = arrayIndexType
        self.valueType = .array
        self.hasExtraSlotsAtEnd = false
        self.totalSlotCount = Self.totalSlotCount
        self.elementTypePointer = elementType
        self.typePointer = type
        self.count = 0
        self.maximumCount = 0
        self.initializeContents(in: segment)
        }
        
    private func initializeContents(in segment:MemorySegment)
        {
        let elementType = self.elementTypePointer!
        let count = self.arrayIndexType.count
        let allocationCount = max(count,16) * 2
        let buffer = WordBlockPointer(elementCount: allocationCount,elementType: elementType)
        self.bufferPointer = buffer
        for index in 0..<count
            {
            buffer[index] = RawMemory.taggedAddress(elementType.makeInstance(in: segment))
            }
        }
        
    public subscript(_ index:Int) -> Word
        {
        get
            {
            if index >= self.count
                {
                fatalError("Attempt to access element with index \(index) of array with count \(self.count)")
                }
            return(wordAtIndexAtAddress(WordBlockPointer.kBufferElementsIndex + index,addressAtIndexAtAddress(Self.kArrayWordBufferPointerIndex,self.address)))
            }
        set
            {
            if index >= self.count
                {
                fatalError("Attempt to set element with index \(index) of array with count \(self.count)")
                }
            setWordAtIndexAtAddress(newValue,WordBlockPointer.kBufferElementsIndex + index,addressAtIndexAtAddress(Self.kArrayWordBufferPointerIndex,self.address))
            }
        }
        
    private func grow()
        {
        let newCount = self.maximumCount * 2
        let newBuffer = WordBlockPointer(elementCount: newCount,elementType: self.elementTypePointer!,segment: .managed)
        newBuffer.copy(from: addressAtIndexAtAddress(Self.kArrayWordBufferPointerIndex,self.address),elementCount: self.maximumCount)
        setAddressAtIndexAtAddress(newBuffer.address,Self.kArrayWordBufferPointerIndex,self.address)
        self.maximumCount = newCount
        }
        
    public func append(_ word:Word)
        {
        let aCount = self.count
        if aCount >= self.maximumCount - 1
            {
            self.grow()
            }
        if aCount == self.maximumCount
            {
            fatalError("Internal error : \(#function) : Unable to grow array for some reason, may be short of memory, this should not happen")
            }
        setWordAtIndexAtAddress(word,WordBlockPointer.kBufferElementsIndex + aCount,addressAtIndexAtAddress(Self.kArrayWordBufferPointerIndex,self.address))
        self.count += 1
        }
        
    public required init(_ word:Argon.Address)
        {
        super.init(word)
        }
    }

//public class NullArrayPointer:ArrayPointer
//    {
//    public override var isNil:Bool
//        {
//        return(true)
//        }
//        
//    public init()
//        {
//        super.init(nil)
//        }
//
//    public required init(_ pointer: Argon.Pointer) {
//        fatalError("init(_:) has not been implemented")
//    }
//    
//    required public init(_ address: UnsafeMutableRawPointer?)
//        {
//        fatalError("init(_:) has not been implemented")
//        }
//    }
