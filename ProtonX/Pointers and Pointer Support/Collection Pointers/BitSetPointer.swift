//
//  BitSetTypePointer.swift
//  argon
//
//  Created by Vincent Coetzee on 03/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public typealias IntRange = Range<Int>

extension IntRange
    {
    public func intersections(with ranges: [IntRange]) -> [IntRange]
        {
        let overlaps = ranges.filter{self.overlaps($0)}
        let sections = overlaps.map{self.clamped(to: $0)}
        return(sections)
        }
    }
    
public class BitSetPointer:CollectionPointer
    {
    public static func testSections()
        {
        let mask = BitFieldMask(from: 60, to: 70)
        let sections = mask.sectionsInMask(forWordCount: 8)
        for section in sections
            {
            print("SECTION FROM \(section.wordFrom) TO \(section.wordTo) MASK \(section.maskBitString)")
            }
        var pattern = BitPattern().withOnes(at: 10, length: 6),withOnes(from: 59,to:62).withOnes(from:63,to:64)
        }
        
    private static var classes:[String:BitSetClass] = [:]
    
    public class func allocateBitSetClass(bitCount:Int,forClass name:String) -> BitSetClass
        {
        let maxBitCount = bitCount * 3
        let aClass = BitSetClass(name: name,bitCount:bitCount,maximumBitCount: maxBitCount)
        Self.classes[aClass.name] = aClass
        return(aClass)
        }
        
    public class func setBitField(_ bitField:BitField,forKey:String,forClass name:String)
        {
        guard var aClass = Self.classes[name] else
            {
            return
            }
        aClass.setBitField(bitField,forKey:forKey)
        }
        
    public class func bitField(forKey:String,forClass:String) -> BitField?
        {
        guard let aClass = Self.classes[forClass] else
            {
            return(nil)
            }
        return(aClass.bitField(forKey:forKey))
        }
        
    public class func allocateBitSet(segment:MemorySegment = .managed,forClass name:String) -> BitSetPointer?
        {
        guard let aClass = Self.classes[name] else
            {
            return(nil)
            }
        let bitSet = segment.allocateBitSet(maximumBitCount: aClass.maximumBitCount)
        for (name,field) in aClass.fields
            {
            bitSet.setBitFieldStart(field.start,stop: field.stop,forKey: name)
            }
        return(bitSet)
        }
        
    public static let kBitSetCountIndex = SlotIndex.four
    public static let kBitSetWordCountIndex = SlotIndex.five
    public static let kBitSetWordsIndex = SlotIndex.six
        
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(7)
        }
        
    public var first:Word
        {
        return(self.words[0])
        }
        
    private var fields:[String:BitField] = [:]
    private var words:[UInt64] = [0]
    
    public struct BitIndex
        {
        public let wordIndex:Int
        public let bitOffsetInWord:Int
        }
        
    public struct BitField
        {
        internal let start:UInt64
        internal let stop:UInt64
        internal let shift:UInt64
        internal let name:String
        internal let mask:UInt64
        
        public init(name:String,start:UInt64,stop:UInt64,shift:UInt64)
            {
            self.name = name
            self.start = start
            self.stop = stop
            self.shift = shift
            var maskValue:Int64 = 1
            for _ in 0...(stop - start)
                {
                maskValue *= 2
                }
            maskValue -= 1
            self.mask = UInt64(bitPattern: maskValue) << shift
            }
        }
        
    public struct BitSetClass
        {
        public let name:String
        public var fields:[String:BitField] = [:]
        public let bitCount:Int
        public let maximumBitCount:Int
        
        public init(name:String,bitCount:Int,maximumBitCount:Int)
            {
            self.name = name
            self.bitCount = bitCount
            self.maximumBitCount = maximumBitCount
            }
            
        public mutating func setBitField(_ bitField:BitField,forKey:String)
            {
            self.fields[forKey] = bitField
            }
            
        public func bitField(forKey:String) -> BitField?
            {
            return(self.fields[forKey])
            }
        }
        
    public struct BitPattern
        {
        public enum BitPatternSection
            {
            case one(Int,Int,String)
            case zero(Int,Int,String)
            
            public var range:IntRange
                {
                switch(self)
                    {
                    case .one(let lower,let upper,_):
                        return(IntRange(uncheckedBounds: (lower,upper)))
                    case .zero(let lower,let upper,_):
                        return(IntRange(uncheckedBounds: (lower,upper)))
                    }
                }
                
            public init(onesFrom from:Int,to:Int)
                {
                self = .one(from,to,String.run(of:"1",length:from - to))
                }
                
            public init(zerosFrom from:Int,to:Int)
                {
                self = .zero(from,to,String.run(of:"0",length: from - to))
                }
                
            public init(onesFrom from:Int,length:Int)
                {
                self = .one(from,from + length - 1,String.run(of:"1",length:length))
                }
                
            public init(zerosFrom from:Int,length:Int)
                {
                self = .zero(from,from + length - 1,String.run(of:"0",length:length))
                }
                
            public func intersects(with pattern: BitPatternSection) -> Bool
                {
                return(self.range.overlaps(pattern.range))
                }
            }
            
        public var range:IntRange
            {
            let globalMin = self.sections.reduce(0,{min($0,$1.range.lowerBound)})
            let globalMax = self.sections.reduce(0,{max($0,$1.range.upperBound)})
            return(IntRange(uncheckedBounds: (globalMin,globalMax)))
            }
            
        public var rawString:String
            {
            var string = ""
            for _ in self.range
                {
                string += "0"
                }
            return(string)
            }
            
        public var stringView:String
            {
            var raw = self.rawString
            for section in sections
                {
                switch(section)
                    {
                    case .one(let lower,let upper,let pattern):
                        let subRange = Range<String.Index>(uncheckedBounds: (raw.index(raw.startIndex,offsetBy: lower),raw.index(raw.startIndex,offsetBy: upper)))
                        raw.replaceSubrange(subRange,with: pattern)
                    case .zero:
                        break
                    }
                }
            return(raw)
            }
            
        private var sections:[BitPatternSection] = []
        
        public mutating func withOnes(from:Int,to:Int) throws -> BitPattern
            {
            let newSection = BitPatternSection(onesFrom: from, to: to)
            for section in sections
                {
                if section.intersects(with: newSection)
                    {
                    throw(Argon.Error.bitPatternSectionsConflict(newSection, section))
                    }
                }
            sections.append(newSection)
            return(self)
            }
            
        public mutating func withOnes(at:Int,length:Int) throws -> BitPattern
            {
            let newSection = BitPatternSection(onesFrom: at, to: at + length - 1)
            for section in sections
                {
                if section.intersects(with: newSection)
                    {
                    throw(Argon.Error.bitPatternSectionsConflict(newSection, section))
                    }
                }
            sections.append(newSection)
            return(self)
            }
            
        public mutating func withZeros(from:Int,to:Int) throws -> BitPattern
            {
            let newSection = BitPatternSection(zerosFrom: from, to: to)
            for section in sections
                {
                if section.intersects(with: newSection)
                    {
                    throw(Argon.Error.bitPatternSectionsConflict(newSection, section))
                    }
                }
            sections.append(newSection)
            return(self)
            }
            
        public mutating func withZeros(at:Int,length:Int) throws -> BitPattern
            {
            let newSection = BitPatternSection(zerosFrom: at, to: at + length - 1)
            for section in sections
                {
                if section.intersects(with: newSection)
                    {
                    throw(Argon.Error.bitPatternSectionsConflict(newSection, section))
                    }
                }
            sections.append(newSection)
            return(self)
            }
        }
        
    private struct BitFieldMask
        {
        internal struct BitFieldMaskSection
            {
            private let wordIndex:Int
            public let wordFrom:Int
            public let wordTo:Int
            private var mask:Word = 0
            
            public var maskBitString:String
                {
                return(mask.bitString)
                }
                
            public init(_ range:IntRange)
                {
                self.wordIndex = range.lowerBound / Word.bitWidth
                let lower = self.wordIndex * Word.bitWidth
                self.wordFrom = range.lowerBound - lower
                self.wordTo = range.upperBound - lower - 1
                self.buildMask()
                }
                
            public init(index:Int,from:Int,to:Int)
                {
                self.wordIndex = index
                self.wordFrom = from
                self.wordTo = to - 1
                self.buildMask()
                }

            private mutating func buildMask()
                {
                var mask:Word = 0
                for bit in Word(self.wordFrom)...Word(self.wordTo)
                    {
                    mask |= (Word(1) << bit)
                    }
                self.mask = mask
                }
                
            public func intersectionBetweenMask(andPattern:Word) -> Word
                {
                return(0)
                }
            }
            
        private let from:Int
        private let to:Int
        
        public init(from:Int,to:Int)
            {
            self.from = from
            self.to = to
            }
            
        internal func sectionsInMask(forWordCount wordCount:Int) -> [BitFieldMaskSection]
            {
            let fullRange = Range<Int>(uncheckedBounds: (self.from,self.to))
            var wordRanges:[Range<Int>] = []
            var lastIndex = 0
            for index in Swift.stride(from: Word.bitWidth,to: wordCount * Word.bitWidth,by: Word.bitWidth)
                {
                wordRanges.append(Range<Int>(uncheckedBounds: (lastIndex,index)))
                lastIndex = index
                }
            let sections = fullRange.intersections(with: wordRanges)
            return(sections.map{BitFieldMaskSection($0)})
            }
        }
        
    public var bitCount:Int
        {
        get
            {
            return(Int(wordAtIndexAtPointer(Self.kBitSetCountIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),Self.kBitSetCountIndex,self.pointer)
            }
        }
        
    public var wordCount:Int
        {
        get
            {
            return(Int(wordAtIndexAtPointer(Self.kBitSetWordCountIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),Self.kBitSetCountIndex,self.pointer)
            }
        }
        
    public func setBitFieldStart(_ start:UInt64,stop:UInt64,forKey name:String)
        {
        let field = BitField(name:name,start:start,stop:stop,shift: start - 1)
        self.fields[field.name] = field
        }
        
    public func setValue(_ value:UInt64,forKey name:String)
        {
        let field = self.fields[name]!
        let newValue = (value << field.shift) & field.mask
        words[0] = (words[0] & ~field.mask) | newValue
        }
        
    public func value(forKey name:String) -> UInt64
        {
        let field = self.fields[name]!
        return((words[0] & field.mask) >> field.shift)
        }
    }
