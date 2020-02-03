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
    public static func bitsAsWord(_ bits:String) -> Word
        {
        let reversed = String(bits.reversed())
        let count = reversed.count
        guard count % Word.bitWidth == 0 else
            {
            return(0)
            }
        let lower = String.Index.init(utf16Offset: 0, in: reversed)
        let upper = String.Index.init(utf16Offset: 64, in: reversed)
        let range = Range<String.Index>(uncheckedBounds: (lower,upper))
        let wordString = reversed[range]
        var shift = 0
        var word:Word = 0
        for character in wordString
            {
            word |= ((character == "0") ? 0 : 1) << shift
            shift += 1
            }
        return(word)
        }
        
    public static func testSections() throws
        {
        let mask = BitFieldMask(from: 60, to: 70,wordCount:4)
        let layout = mask.layout
        print(layout)
        let maskBits = mask.bits
        print(maskBits.bitString)
        let bitSet = Memory.staticSegment.allocateBitSet(maximumBitCount: 192)
        bitSet.bits = "000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000"
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
            bitSet.setBitField(field,forKey: name)
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
        
    public struct BitArray
        {
        public static func &(lhs:BitArray,rhs:BitArray) -> BitArray
            {
            var newBits = BitArray(bitCount: lhs.bitCount)
            for index in 0..<lhs.bitCount
                {
                newBits.bits[index] = lhs.bits[index] == rhs.bits[index] ? lhs.bits[index] : 0
                }
            return(newBits)
            }
            
        public static func |(lhs:BitArray,rhs:BitArray) -> BitArray
            {
            var newBits = BitArray(bitCount: lhs.bitCount)
            for index in 0..<lhs.bitCount
                {
                newBits.bits[index] = lhs.bits[index] == 1 || rhs.bits[index] == 1 ? 1 : 0
                }
            return(newBits)
            }
            
        public static prefix func ~(lhs:BitArray) -> BitArray
            {
            var newBits = BitArray(bitCount: lhs.bitCount)
            for index in 0..<lhs.bitCount
                {
                newBits.bits[index] = lhs.bits[index] == 0 ? 1 : 0
                }
            return(newBits)
            }
            
        public static func ^(lhs:BitArray,rhs:BitArray) -> BitArray
            {
            var newBits = BitArray(bitCount: lhs.bitCount)
            for index in 0..<lhs.bitCount
                {
                newBits.bits[index] = (lhs.bits[index] == 1 || rhs.bits[index] == 1) && !(lhs.bits[index] == 1 && rhs.bits[index] == 1) ? 1 : 0
                }
            return(newBits)
            }
            
        public var wordArray:[Word]
            {
            var mask:Word = 1
            var words:[Word] = []
            var word:Word = 0
            for index in 0..<self.bitCount
                {
                if index % 8 == 0 && index != 0
                    {
                    words.append(word)
                    word = 0
                    }
                word |= self.bits[index] == 1 ? mask : 0
                mask <<= 1
                }
            return(words)
            }
            
        private var bits:Array<UInt8>
        private let bitCount:Int
        
        public init(bitCount:Int)
            {
            self.bits = Array<UInt8>(repeating: 0, count: bitCount)
            self.bitCount = bitCount
            }
        }
        
    public struct BitIndex
        {
        @discardableResult
        public static postfix func ++(lhs:inout BitIndex) -> BitIndex
            {
            let old = lhs
            lhs.wordOffset += 1
            if lhs.wordOffset >= Word.bitWidth
                {
                lhs.wordIndex += 1
                lhs.wordOffset -= Word.bitWidth
                }
            return(old)
            }
            
        public var wordMask:Word
            {
            return(Word.twoToPower(of: Word(self.wordOffset)))
            }
            
        public private(set) var wordIndex:Int = 0
        public private(set) var wordOffset:Int = 0
        
        public init(position:Int)
            {
            self.wordIndex = position / Word.bitWidth
            self.wordOffset = position - (self.wordIndex * Word.bitWidth) - 1
            }
            
        public func orValue(of source:Bits,into target:Bits)
            {
//            let sourceValue = source[self]
            }
        }
        
    public struct BitField
        {
        public let name:String
        public let sections:[BitFieldSection]
        public let wordCount:Int
        
        public init(name:String,from:Int,to:Int,wordCount:Int)
            {
            self.name = name
            let fullRange = Range<Int>(uncheckedBounds: (from,to))
            var wordRanges:[Range<Int>] = []
            var lastIndex = 0
            for index in Swift.stride(from: Word.bitWidth,to: wordCount * Word.bitWidth,by: Word.bitWidth)
                {
                wordRanges.append(Range<Int>(uncheckedBounds: (lastIndex,index)))
                lastIndex = index
                }
            let intersections = fullRange.intersections(with: wordRanges)
            self.sections = intersections.map{BitFieldSection($0)}
            self.wordCount = wordCount
            }
            
        public func bits(of bitSet:BitSetPointer) -> Word
            {
            var word:Word = 0
            let firstIndex = self.sections.reduce(0,{min($0,$1.wordFrom)})
            var offset = firstIndex
            for section in self.sections
                {
                word = section.bits(of: bitSet) >> offset | word
                offset = section.absoluteFrom - self.nearestWordBoundaryBitIndex(to: section.absoluteFrom)
                }
            return(word)
            }
            
        public func nearestWordBoundaryBitIndex(to bitOffset:Int) -> Int
            {
            let factor = bitOffset / Word.bitWidth
            return(factor * Word.bitWidth)
            }
            
        public func setBits(of bitSet:BitSetPointer,to value:Word)
            {
//            var word:Word = 0
//            let firstIndex = self.sections.reduce(0,{min($0,$1.wordFrom)})
//            for section in self.sections
//                {
//                word = word | 0
//                }
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
        
    public class Bits
        {
        private var actualWords:[Word] = []
        
        internal var words:[Word]
            {
            get
                {
                return(self.actualWords)
                }
            set
                {
                self.actualWords = newValue
                }
            }
                    
        public init(_ bits:Bits)
            {
            self.words = bits.words
            }
            
        public convenience init(wordCount:Int)
            {
            try! self.init(bitCount: wordCount * Word.bitWidth)
            }
            
        public init(bitCount:Int) throws
            {
            let wordBitWidth = Word.bitWidth
            if bitCount % wordBitWidth != 0
                {
                throw(Argon.Error.bitCountMustBeMultipleOfWordBitWidth)
                }
            let wordCount = bitCount / Word.bitWidth
            self.words = Array<Word>(repeating: 0, count: wordCount)
            }
            
        public init()
            {
            }
            
        public subscript(_ index:Int) -> Word
            {
            get
                {
                return(self.words[index])
                }
            set
                {
                self.words[index] = newValue
                }
            }
            
        public subscript(_ index:BitIndex) -> Word
            {
            get
                {
                let word = self.words[index.wordIndex]
                return(word & index.wordMask)
                }
            set
                {
                var word = self.words[index.wordIndex]
                let mask = index.wordMask
                word &= ~mask
                word |= (mask & newValue)
                self.words[index.wordIndex] = word
                }
            }
            
        }
        
    public class BitsPointer:Bits
        {
        private let bitSetPointer:BitSetPointer
        
        public init(_ bitSetPointer:BitSetPointer)
            {
            self.bitSetPointer = bitSetPointer
            super.init()
            }
            
        public override var words:[Word]
            {
            get
                {
                var someWords:[Word] = []
                for index in 0..<bitSetPointer.wordCount
                    {
                    someWords.append(bitSetPointer[index])
                    }
                return(someWords)
                }
            set
                {
                self.bitSetPointer.wordCount = newValue.count
                for index in 0..<newValue.count
                    {
                    bitSetPointer[index] = newValue[index]
                    }
                }
            }
        }
        
    public struct BitFieldSection
        {
        private let wordIndex:Int
        public let wordFrom:Int
        private let wordTo:Int
        private var mask:Word = 0
        }
        
    public struct BitFieldMask
        {
        public struct BitFieldMaskLayout
            {
            public var bits:Bits
                {
                var bits = Bits(wordCount: wordCount)
                for section in self.sections
                    {
                    section.addMaskToBits(&bits)
                    }
                return(bits)
                }
                
            private let sections:[BitFieldSection]
            private let wordCount:Int
            
            public init(_ wordCount:Int,_ sections:[BitFieldSection])
                {
                self.sections = sections
                self.wordCount = wordCount
                }
                
            public func bits(of bitSet:BitSetPointer) -> Word
                {
                var word:Word = 0
                let firstIndex = self.sections.reduce(0,{min($0,$1.wordFrom)})
                var offset = firstIndex
                for section in self.sections
                    {
                    word = section.bits(of: bitSet) >> offset | word
                    offset = section.absoluteFrom - self.nearestWordBoundaryBitIndex(to: section.absoluteFrom)
                    }
                return(word)
                }
                
            public func nearestWordBoundaryBitIndex(to bitOffset:Int) -> Int
                {
                let factor = bitOffset / Word.bitWidth
                return(factor * Word.bitWidth)
                }
                
            public func setBits(of bitSet:BitSetPointer,to value:Word)
                {
//                var word:Word = 0
//                let firstIndex = self.sections.reduce(0,{min($0,$1.wordFrom)})
//                var offset = 0
//                for section in self.sections
//                    {
//                    word = word | 0
//                    }
                }
            }
        
        public var bits:Bits
            {
            return(self.layout.bits)
            }
            
        public var layout:BitFieldMaskLayout
            {
            let fullRange = Range<Int>(uncheckedBounds: (self.from,self.to))
            var wordRanges:[Range<Int>] = []
            var lastIndex = 0
            for index in Swift.stride(from: Word.bitWidth,to: self.wordCount * Word.bitWidth,by: Word.bitWidth)
                {
                wordRanges.append(Range<Int>(uncheckedBounds: (lastIndex,index)))
                lastIndex = index
                }
            let sections = fullRange.intersections(with: wordRanges)
            return(BitFieldMaskLayout(self.wordCount,sections.map{BitFieldSection($0)}))
            }
            
        internal let wordCount:Int
        internal let from:Int
        internal let to:Int
        
        public init(from:Int,to:Int,wordCount:Int)
            {
            self.from = from
            self.to = to
            self.wordCount = wordCount
            }
        
        public func bits(of pointer:BitSetPointer) -> Word
            {
            return(self.layout.bits(of: pointer))
            }
            
        public func setBits(of pointer:BitSetPointer,to value:Word)
            {
            self.layout.setBits(of: pointer,to:value)
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
            setWordAtIndexAtPointer(Word(newValue),Self.kBitSetWordCountIndex,self.pointer)
            }
        }
        
    public var bits:String
        {
        get
            {
            var string = ""
            for index in 0..<self.wordCount
                {
                string += self[index].bitString + "\n"
                }
            return(string)
            }
        set
            {
            let reversed = String(newValue.reversed())
            let count = reversed.count
            guard count % Word.bitWidth == 0 else
                {
                return
                }
            var wordCount = 0
            for index in Swift.stride(from:0,to:count,by:Word.bitWidth)
                {
                let lower = String.Index.init(utf16Offset: index, in: reversed)
                let upper = String.Index.init(utf16Offset: index+64, in: reversed)
                let range = Range<String.Index>(uncheckedBounds: (lower,upper))
                let wordString = reversed[range]
                var shift = 0
                var word:Word = 0
                for character in wordString
                    {
                    word |= ((character == "0") ? 0 : 1) << shift
                    shift += 1
                    }
                self[index / Word.bitWidth] = word
                wordCount += 1
                }
            self.wordCount = wordCount 
            }
        }
        
    public subscript(_ index:Int) -> Word
        {
        get
            {
            return(wordAtIndexAtBitsPointer(Self.kBitSetWordsIndex + index,self.pointer))
            }
        set
            {
            setWordAtIndexAtBitsPointer(newValue,Self.kBitSetWordsIndex + index,self.pointer)
            }
        }
        
    public subscript(_ mask:BitFieldMask) -> Word
        {
        get
            {
            return(mask.bits(of: self))
            }
        set
            {
            mask.setBits(of: self,to: newValue)
            }
        }
        
    public func setBitField(_ field:BitSetPointer.BitField,forKey name:String)
        {
        self.fields[field.name] = field
        }
        
    public func setValue(_ value:Word,forKey name:String)
        {
        guard let field = self.fields[name] else
            {
            return
            }
        field.setBits(of: self,to: value)
        }
        
    public func value(forKey name:String) -> UInt64
        {
        let field = self.fields[name]!
        return(field.bits(of: self))
        }
    }

extension BitSetPointer.Bits
    {
    public static prefix func ~(lhs:BitSetPointer.Bits) -> BitSetPointer.Bits
        {
        let newBits = BitSetPointer.Bits(lhs)
        for index in 0..<lhs.wordCount
            {
            newBits[index] = ~lhs[index]
            }
        return(newBits)
        }
        
    public static func &(lhs:BitSetPointer.Bits,rhs:BitSetPointer.Bits) -> BitSetPointer.Bits
        {
        let newBits = BitSetPointer.Bits(lhs)
        for index in 0..<newBits.wordCount
            {
            newBits[index] &= rhs[index]
            }
        return(newBits)
        }
        
    public static func &(lhs:BitSetPointer.Bits,rhs:BitSetPointer.BitFieldMask) -> BitSetPointer.Bits
        {
        return(lhs & rhs.bits)
        }
    
    public var bitString:String
        {
        var string = ""
        for index in Swift.stride(from:self.words.count-1,to:-1,by:-1)
            {
            string += (self[index].bitString + " ")
            }
        return(string)
        }
        
    public var wordCount:Int
        {
        return(self.words.count)
        }
        
    private var bitCount:Int
        {
        return(self.wordCount * Word.bitWidth)
        }
        
    public subscript(_ range:BitRange) -> Word
        {
        get
            {
            return((self.words[range.wordIndex] & range.mask) >> range.wordFrom)
            }
        set
            {
            self.words[range.wordIndex] = self.words[range.wordIndex] | ((newValue << range.wordFrom) & ~range.mask)
            }
        }
        
    public func setBits(of mask:BitSetPointer.BitFieldMask,to value:Word)
        {
//        let layout = mask.layout
//            let values = layout.valueSections(value)
        }
    }

extension BitSetPointer.BitFieldSection
    {
    public var absoluteFrom:Int
          {
          return(self.wordIndex * Word.bitWidth + self.wordFrom)
          }
          
    public var absoluteTo:Int
        {
        return(self.wordIndex * Word.bitWidth + self.wordTo)
        }
        
      public var maskWord:Word
          {
          var word:Word = 0
          for bit in Word(self.wordFrom)...Word(self.wordTo)
              {
              word += Word.twoToPower(of: bit)
              }
          return(word)
          }
          
      public var description:String
          {
          return(Line(.left("INDEX",10),.right("\(wordIndex)",10),.space(1),.right("\(self.wordFrom)",10),.space(1),.right("\(self.wordTo)",10)).string)
          }
          
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
          
      public func addMaskToBits(_ bits:inout BitSetPointer.Bits)
          {
          bits[wordIndex] |= self.maskWord
          }
          
      public func bits(of pointer:BitSetPointer) -> Word
          {
          let word = pointer[self.wordIndex]
          return(word & self.maskWord)
          }
    }

public struct BitRange
    {
    public var mask:Word
        {
        var mask:Word = 0
        for index in Word(self.wordFrom)...Word(self.wordTo)
            {
            mask |= Word.twoToPower(of: index)
            }
        return(mask)
        }
        
    public let wordIndex:Int
    public let wordFrom:Int
    public let wordTo:Int
    
    public init(from:Int,to:Int) throws
        {
        self.wordIndex = from / Word.bitWidth
        self.wordFrom = from - self.wordIndex * Word.bitWidth
        self.wordTo = to - ( self.wordIndex * Word.bitWidth ) - 1
        if self.wordTo >= Word.bitWidth
            {
            throw(Argon.Error.bitRangeWidthMustBeLessThanWordBitWidth)
            }
        }
    }
