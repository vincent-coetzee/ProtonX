//
//  AllocationBlockPointer.swift
//  argon
//
//  Created by Vincent Coetzee on 29/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public protocol WordStorable
    {
    static var instanceStrideInBytes:Int { get }
    func store(atPointer:Argon.Pointer?)
    init?(atPointer:Argon.Pointer?)
    }
    
//public struct StringWordAssociation:WordVectorConvertible
//    {
//    public let stringPointer:StringPointer
//    public let word:Word
//
//    public var stride:Int
//        {
//        return(MemoryLayout<Self>.stride)
//        }
//
//    public static var wordCount:Int
//        {
//        return(2)
//        }
//
//    public var wordVector:WordVector
//        {
//        return(WordVector(self.stringPointer.taggedAddress,self.word))
//        }
//
//    public init(_ string:String,_ word:Word)
//        {
//        self.stringPointer = StringPointer(string)
//        self.word = word
//        }
//
//    public init(_ vector:WordVector)
//        {
//        self.stringPointer = StringPointer(untaggedAddress(vector[0]))
//        self.word = vector[1]
//        }
//    }
    
//public struct WordVector:Collection
//    {
//    private var words:[Word] = []
//
//    public var startIndex:Int
//        {
//        return(self.words.startIndex)
//        }
//
//    public var endIndex:Int
//        {
//        return(self.words.endIndex)
//        }
//
//    public var count:Int
//        {
//        return(self.words.count)
//        }
//
//    public init(_ words:Word...)
//        {
//        self.words = words
//        }
//
//    public init(_ count:Int)
//        {
//        self.words = Array<Word>(repeating: 0, count: count)
//        }
//
//    public init(at pointer:Argon.Pointer?)
//        {
//        self.words = []
//        if pointer != nil
//            {
//            var index = 0
//            let count = Int(wordAtIndexAtPointer(index++,pointer))
//            self.words = []
//            for _ in 0..<count
//                {
//                self.words.append(wordAtIndexAtPointer(index++,pointer))
//                }
//            }
//        }
//
//    public init(at address:Instruction.Address)
//        {
//        self.words = []
//        if address != 0
//            {
//            var index = 0
//            let count = Int(wordAtIndexAtAddress(index++,address))
//            for _ in 0..<count
//                {
//                self.words.append(wordAtIndexAtAddress(index++,address))
//                }
//            }
//        }
//
//    public func index(after:Int) -> Int
//        {
//        return(self.words.index(after: after))
//        }
//
//    public subscript(_ index:Int) -> Word
//        {
//        get
//            {
//            return(self.words[index])
//            }
//        set
//            {
//            self.words[index] = newValue
//            }
//        }
//
//    public func setAtAddress(_ inAddress:Instruction.Address)
//        {
//        var address = inAddress
//        setWordAtAddress(Word(self.words.count),address++)
//        for word in self.words
//            {
//            setWordAtAddress(word,address++)
//            }
//        }
//    }
    
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
        
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(9)
        }
        
//    public subscript<T:Value>(_ index:SlotIndex) -> T? where T:Equatable
//        {
//        get
//            {
//            guard let pointer = self.pointer else
//                {
//                return(nil)
//                }
//            return(self.elementTypePointer?.typedValue(of: wordAtIndexAtPointer(index,pointer)) as? T)
//            }
//        set
//            {
//            guard let pointer = self.pointer else
//                {
//                return
//                }
//            setWordAtIndexAtPointer(newValue?.taggedAddress ?? 0,index,pointer)
//            }
//        }
        
    public var totalByteCount:Argon.ByteCount
        {
        get
            {
            return(Argon.ByteCount(wordAtIndexAtPointer(Self.kBufferTotalByteCountIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),Self.kBufferTotalByteCountIndex,self.pointer)
            }
        }
        
    public var maximumElementCount:Int
        {
        get
            {
            return(Int(wordAtIndexAtPointer(Self.kBufferMaximumElementCountIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),Self.kBufferMaximumElementCountIndex,self.pointer)
            }
        }
        
    public var elementStrideInBytes:Int
        {
        get
            {
            return(Int(wordAtIndexAtPointer(Self.kBufferElementStrideIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),Self.kBufferElementStrideIndex,self.pointer)
            }
        }
        
    public var totalElementByteCount:Argon.ByteCount
        {
        get
            {
            return(Argon.ByteCount(wordAtIndexAtPointer(Self.kBufferTotalElementByteCountIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue.count),Self.kBufferTotalElementByteCountIndex,self.pointer)
            }
        }
        
    private var elementsPointer:Argon.Pointer?
        {
        guard let pointer = self.pointer else
            {
            return(nil)
            }
        return(Argon.Pointer(bitPattern: Instruction.Address(bitPattern: pointer) + Word(MemoryLayout<Word>.stride * WordBlockPointer.kBufferElementsIndex.index)))
        }
        
    public override init(_ address:Word)
        {
        super.init(address)
        }
        
    public init(elementCount:Int,elementType:TypePointer,segment:MemorySegment = Memory.managedSegment)
        {
        let theElementStride = elementType.objectStrideInBytes
        let theSlotStride = MemoryLayout<Word>.stride
        let overallAlignment = Argon.lowestCommonMultiple(theElementStride.count,theSlotStride)
        let theElementByteCount = Argon.ByteCount(theElementStride.count * elementCount).aligned(to: overallAlignment)
        let theSlotByteCount = Argon.ByteCount(theSlotStride * WordBlockPointer.totalSlotCount.count).aligned(to: overallAlignment)
        let theTotalByteCount = theSlotByteCount + theElementByteCount
        var newSlotCount = Argon.SlotCount(0)
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
        
    required public init(_ somePointer: Argon.Pointer?)
        {
        super.init(somePointer)
        }
        
    @inline(__always)
    public func pointerToElement(atIndex:SlotIndex) -> Argon.Pointer?
        {
        guard let pointer = self.pointer else
            {
            return(nil)
            }
        return(pointer + SlotOffset(stride: self.elementStrideInBytes,index: atIndex))
        }
        
    public subscript(_ index:Int) -> Word
        {
        get
            {
            return(wordAtPointer(self.pointerToElement(atIndex: SlotIndex(index: index))))
            }
        set
            {
            setWordAtPointer(newValue,self.pointerToElement(atIndex: SlotIndex(index: index)))
            }
        }
        
    public func copy(from buffer: Argon.Pointer?,elementCount:Int)
        {
        let totalBytes = (elementCount + WordBlockPointer.totalSlotCount.count) * MemoryLayout<Word>.stride
        memcpy(self.pointer,buffer,totalBytes)
        self.count = elementCount
        }
    }


