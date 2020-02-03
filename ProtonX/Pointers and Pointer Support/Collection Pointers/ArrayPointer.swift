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
        case enumeration(Instruction.Address)
        case fixed(Word)
        case range(Int)
        case vector(Word)
        }
        
    public enum ArrayIndexType
        {
        case none
        case enumeration(Instruction.Address,Word,Word)
        case fixed(Word)
        case range(Instruction.Address,Int,Int)
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
            let type = wordAtIndexAtPointer(Self.kArrayRangeTypeIndex,self.pointer)
            if type == ArrayPointer.kArrayRangeTypeNone
                {
                return(.none)
                }
            else if type == ArrayPointer.kArrayRangeTypeEnumeration
                {
                let enumAddress = untaggedWordAtIndexAtPointer(ArrayPointer.kArrayRangeEnumerationIndex,self.pointer)
                let lower = wordAtIndexAtPointer(ArrayPointer.kArrayRangeLowerBoundIndex,self.pointer)
                let upper = wordAtIndexAtPointer(ArrayPointer.kArrayRangeUpperBoundIndex,self.pointer)
                return(.enumeration(enumAddress,lower,upper))
                }
            else if type == ArrayPointer.kArrayRangeTypeFixed
                {
                let size = wordAtIndexAtPointer(ArrayPointer.kArrayRangeLowerBoundIndex,self.pointer)
                return(.fixed(size))
                }
            else if type == ArrayPointer.kArrayRangeTypeRange
                {
                let typeAddress = untaggedWordAtIndexAtPointer(ArrayPointer.kArrayRangeEnumerationIndex,self.pointer)
                let lower = wordAtIndexAtPointer(ArrayPointer.kArrayRangeLowerBoundIndex,self.pointer)
                let upper = wordAtIndexAtPointer(ArrayPointer.kArrayRangeUpperBoundIndex,self.pointer)
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
                    setWordAtIndexAtPointer(Word(ArrayPointer.kArrayRangeTypeNone),ArrayPointer.kArrayRangeTypeIndex,self.pointer)
                    break
                case .enumeration(let address,let lower,let upper):
                    setWordAtIndexAtPointer(Word(ArrayPointer.kArrayRangeTypeEnumeration),ArrayPointer.kArrayRangeTypeIndex,self.pointer)
                    tagAndSetAddressAtIndexAtPointer(address,ArrayPointer.kArrayRangeEnumerationIndex,self.pointer)
                    setWordAtIndexAtPointer(lower,ArrayPointer.kArrayRangeLowerBoundIndex,self.pointer)
                    setWordAtIndexAtPointer(upper,ArrayPointer.kArrayRangeUpperBoundIndex,self.pointer)
                case .fixed(let size):
                    setWordAtIndexAtPointer(Word(ArrayPointer.kArrayRangeTypeFixed),ArrayPointer.kArrayRangeTypeIndex,self.pointer)
                    setWordAtIndexAtPointer(size,ArrayPointer.kArrayRangeLowerBoundIndex,self.pointer)
                case .range(let address,let lower,let upper):
                    setWordAtIndexAtPointer(Word(ArrayPointer.kArrayRangeTypeRange),ArrayPointer.kArrayRangeTypeIndex,self.pointer)
                    tagAndSetAddressAtIndexAtPointer(address,ArrayPointer.kArrayRangeEnumerationIndex,self.pointer)
                    setInt64AtIndexAtPointer(Int64(lower),ArrayPointer.kArrayRangeLowerBoundIndex,self.pointer)
                    setInt64AtIndexAtPointer(Int64(upper),ArrayPointer.kArrayRangeUpperBoundIndex,self.pointer)
                case .vector:
                    setWordAtIndexAtPointer(Word(ArrayPointer.kArrayRangeTypeVector),ArrayPointer.kArrayRangeTypeIndex,self.pointer)
                }
            }
        }
        
    public var bufferPointer:WordBlockPointer
        {
        get
            {
            return(WordBlockPointer(untaggedPointerAtIndexAtPointer(Self.kArrayWordBufferPointerIndex,self.pointer)))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue.pointer,Self.kArrayWordBufferPointerIndex,self.pointer)
            }
        }
        
    public var maximumCount:Int
        {
        get
            {
            Log.log("GET Array Maximum Count Index = \(Self.kArrayMaximumCountIndex)")
            return(Int(wordAtIndexAtPointer(Self.kArrayMaximumCountIndex,self.pointer)))
            }
        set
            {
            Log.log("SET Array Maximum Count Index = \(Self.kArrayMaximumCountIndex)")
            setWordAtIndexAtPointer(Word(newValue),Self.kArrayMaximumCountIndex,self.pointer)
            }
        }
        
    public required init(_ address:UnsafeMutableRawPointer)
        {
        super.init(address)
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
            buffer[index] = taggedObject(elementType.makeInstance(in: segment))
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
            return(wordAtIndexAtPointer(WordBlockPointer.kBufferElementsIndex + index,untaggedPointerAtIndexAtPointer(Self.kArrayWordBufferPointerIndex,self.pointer)))
            }
        set
            {
            if index >= self.count
                {
                fatalError("Attempt to set element with index \(index) of array with count \(self.count)")
                }
            setWordAtIndexAtPointer(newValue,WordBlockPointer.kBufferElementsIndex + index,untaggedPointerAtIndexAtPointer(Self.kArrayWordBufferPointerIndex,self.pointer))
            }
        }
        
    private func grow()
        {
        let newCount = self.maximumCount * 2
        let newBuffer = WordBlockPointer(elementCount: newCount,elementType: self.elementTypePointer!,segment: .managed)
        newBuffer.copy(from: untaggedPointerAtIndexAtPointer(Self.kArrayWordBufferPointerIndex,self.pointer),elementCount: self.maximumCount)
        setPointerAtIndexAtPointer(newBuffer.pointer,Self.kArrayWordBufferPointerIndex,self.pointer)
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
        setWordAtIndexAtPointer(word,WordBlockPointer.kBufferElementsIndex + aCount,untaggedPointerAtIndexAtPointer(Self.kArrayWordBufferPointerIndex,self.pointer))
        self.count += 1
        }
        
    public func append(_ pointer:Argon.Pointer)
        {
        self.append(pointerAsWord(pointer))
        }
        
    public required init(_ word:Instruction.Address)
        {
        super.init(word)
        }
        
    required public init(_ address: UnsafeMutableRawPointer?)
        {
        super.init(address)
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
