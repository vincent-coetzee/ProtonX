//
//  Argon.swift
//  argon
//
//  Created by Vincent Coetzee on 26/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory
    
public class Proton
    {
    public class func greatestCommonDivisor(_ aIn : Int,_ bIn : Int) -> Int
        {
        var a = aIn
        var b = bIn
        while b != 0
            {
            let (a1,b1) = (b,a%b)
            a = a1
            b = b1
            }
        return abs(a)
        }

    // GCD of a vector of numbers:
    public class func greatestCommonDivisor(_ vector:[Int]) -> Int
        {
        return(vector.reduce(0,{ self.greatestCommonDivisor($0,$1)}))
        }

    // LCM of two numbers:
    public class func lowestCommonMultiple(_ a:Int,_ b:Int) -> Int
        {
        return((a / self.greatestCommonDivisor(a, b)) * b)
        }

    // LCM of a vector of numbers:
    public class func lowestCommonMultiple(_ vector:[Int]) -> Int
        {
        return(vector.reduce(1,{self.lowestCommonMultiple($0,$1)}))
        }
        
    public static let kTypeNone:Word = ValueType.none.rawValue
    public static let kTypeMethodInstance:Word = ValueType.methodInstance.rawValue
    public static let kTypeString:Word = ValueType.string.rawValue
    public static let kTypeDictionary:Word = ValueType.dictionary.rawValue
    public static let kTypeSet:Word = ValueType.set.rawValue
    public static let kTypeBitSet:Word = ValueType.bitSet.rawValue
    public static let kTypeArray:Word = ValueType.array.rawValue
    public static let kTypeList:Word = ValueType.list.rawValue
    public static let kTypeEnumeration:Word = ValueType.enumeration.rawValue
    public static let kTypeEnumerationCase:Word = ValueType.enumerationCase.rawValue
    public static let kTypeType:Word = ValueType.type.rawValue
    public static let kTypeCustom:Word = ValueType.custom.rawValue
    public static let kTypeWordBuffer:Word = ValueType.wordBuffer.rawValue
    public static let kTypeSlot:Word = ValueType.slot.rawValue
    public static let kTypeBits:Word = ValueType.bits.rawValue
    public static let kTypeVirtualSlot:Word = ValueType.virtualSlot.rawValue
    public static let kTypeSystemSlot:Word = ValueType.systemSlot.rawValue
    public static let kTypeCodeBlock:Word = ValueType.codeBlock.rawValue
    public static let kTypeClosure:Word = ValueType.closure.rawValue
    public static let kTypeByteArray:Word = ValueType.byteArray.rawValue
    public static let kTypeMetaType:Word = ValueType.metaType.rawValue
    public static let kTypeInteger:Word = ValueType.integer.rawValue
    public static let kTypeUInteger:Word = ValueType.uinteger.rawValue
    public static let kTypeBoolean:Word = ValueType.boolean.rawValue
    public static let kTypeByte:Word = ValueType.byte.rawValue
    public static let kTypeObject:Word = ValueType.object.rawValue
    public static let kTypeContract:Word = ValueType.contract.rawValue
    public static let kTypeMethod:Word = ValueType.method.rawValue
    public static let kTypeFloat32:Word = ValueType.float32.rawValue
    public static let kTypeFloat64:Word = ValueType.float64.rawValue
    public static let kTypeTypeType:Word = ValueType.typeType.rawValue
    public static let kTypeStringType:Word = ValueType.stringType.rawValue
    public static let kTypePackage:Word = ValueType.package.rawValue
    public static let kTypeContractMethod:Word = ValueType.contractMethod.rawValue
    public static let kTypeContractSlot:Word = ValueType.contractSlot.rawValue
    public static let kTypePackageImportElement:Word = ValueType.packageImportElement.rawValue
    public static let kTypeListNode:Word = ValueType.listNode.rawValue
    public static let kTypeTreeNode:Word = ValueType.treeNode.rawValue
    public static let kTypeTree:Word = ValueType.tree.rawValue
    public static let kTypeInstruction:Word = ValueType.instruction.rawValue
    
    public enum ValueType:Word
        {
        case none = 0
        case methodInstance
        case string
        case dictionary
        case set
        case bitSet
        case array
        case list
        case tree
        case custom
        case enumeration
        case type
        case wordBuffer
        case byteArray
        case slot
        case virtualSlot
        case systemSlot
        case codeBlock
        case closure
        case typeType
        case metaType
        case integer
        case uinteger
        case boolean
        case byte
        case contract
        case method
        case float32
        case float64
        case enumerationCase
        case package
        case object
        case stringType
        case contractMethod
        case contractSlot
        case packageImportElement
        case bits
        case treeNode
        case listNode
        case instruction
        case setClass
        case arrayClass
        case listClass
        case objectClass
        case dictionaryClass
        case treeClass
        }
        
    public enum HeaderTag:Word
        {
        case uinteger = 0
        case integer = 1
        case float32 = 2
        case float64 = 3
        case boolean = 4
        case character = 5
        case byte = 6
        case string = 7
        case address = 8
        case bits = 9
        case persistent = 10
        }
        
    public static let kTagBitsFloat64:Word = HeaderTag.float64.rawValue
    public static let kTagBitsInteger:Word = HeaderTag.integer.rawValue
    public static let kTagBitsFloat32:Word = HeaderTag.float32.rawValue
    public static let kTagBitsBoolean:Word = HeaderTag.boolean.rawValue
    public static let kTagBitsAddress:Word = HeaderTag.address.rawValue
    public static let kTagBitsByte:Word = HeaderTag.byte.rawValue
    public static let kTagBitsBits:Word = HeaderTag.bits.rawValue
    public static let kTagBitsPersistent:Word = HeaderTag.persistent.rawValue
    public static let kTagBitsCharacter:Word = HeaderTag.character.rawValue
    public static let kTagBitsUInteger:Word = HeaderTag.uinteger.rawValue
    public static let kTagBitsString:Word = HeaderTag.string.rawValue
    
    public static let kTagBitsZeroMask:Word =  ~(Word(15) << Word(59))
    
    public static let kSignMask:Word = Word(1) << Word(63)
    
    public static let kPageMask:Word = 1099511627775
    public static let kPageShift:Word = 16
    public static let kOffsetMask:Word = 65535
    public static let kOffsetShift:Word = 0
    
    public static let kTagBitsMask:Word = 15
    public static let kTagBitsShift:Word = 59
    public static let kTagBitsWidth:Word = 4
    public static let kTagBitsFloat32Mask:Word = 4294967295
    public static let kTagBitsTop5Mask:Word = 17870283321406128128

    public static let kHeaderMarkerMask:Word = 1
    public static let kHeaderMarkerShift:Word = 58
    
    public static let kHeaderHasExtraSlotsAtEndMask:Word = 1
    public static let kHeaderHasExtraSlotsAtEndShift:Word = 57
    
    public static let kHeaderIsForwardedMask:Word = 1
    public static let kHeaderIsForwardedShift:Word = 56
    
    public static let kHeaderSegmentIndexMask:Word = 65535
    public static let kHeaderSegmentIndexShift:Word = 40
    
    public static let kHeaderSlotCountMask:Word = 4294967295
    public static let kHeaderSlotCountShift:Word = 8
    
    public static let kHeaderValueTypeMask:Word = 255
    public static let kHeaderValueTypeShift:Word = 0
    
    public static let kSizeGrowthUpperFactor = 5
    public static let kSizeGrowthLowerFactor = 3
    
    public static var nextIndex:Word
        {
        let index = self._nextIndex
        self._nextIndex += 1
        return(index)
        }
        
    private static var _nextIndex:Word = 1
    
    public typealias WordPointer = UnsafeMutablePointer<Word>
    public typealias Float32 = Float
    public typealias Float64 = Double
    public typealias Integer = Int64
    public typealias UInteger = UInt64
    public typealias Boolean = Bool
    public typealias Byte = UInt8
    public typealias Address = Word
    public typealias Immediate = Int64
    public typealias Index = Int
    public typealias Offset = Word
    
    public struct ByteCount
        {
        public static func +(lhs:ByteCount,rhs:SlotCount) -> ByteCount
            {
            return(ByteCount(lhs.count + (rhs.count * MemoryLayout<Word>.stride)))
            }
            
        public static func +(lhs:ByteCount,rhs:ByteCount) -> ByteCount
            {
            return(ByteCount(lhs.count + rhs.count))
            }
            
        public var wordCount:Int
            {
            if self.count % MemoryLayout<Word>.stride  != 0
                {
                fatalError("Fatal misalignment of words and bytes")
                }
            return(self.count / MemoryLayout<Word>.stride)
            }
            
        internal var count:Int = 0

        public init(_ count:SlotCount)
            {
            self.count = count.count * MemoryLayout<Word>.stride
            }
            
        public init(_ count:Word)
            {
            self.count = Int(count)
            }
            
        public init(_ count:Int)
            {
            self.count = count
            }
            
        public func aligned(to:Int) -> ByteCount
            {
            return(ByteCount(self.count.aligned(to: to)))
            }
        }
    
    public struct WordCount
        {
        public static func +(lhs:WordCount,rhs:SlotCount) -> WordCount
            {
            return(WordCount(lhs.count + rhs.count))
            }
            
        public static func +(lhs:WordCount,rhs:WordCount) -> WordCount
            {
            return(WordCount(lhs.count + rhs.count))
            }
            
        internal var count:Int = 0

        public init(_ count:SlotCount)
            {
            self.count = count.count
            }
            
        public init(_ count:Word)
            {
            self.count = Int(count)
            }
            
        public init(_ count:Int)
            {
            self.count = count
            }
            
        public func aligned(to:Int) -> WordCount
            {
            return(WordCount(self.count.aligned(to: to)))
            }
        }
        
    public struct SlotCount:Equatable,ExpressibleByIntegerLiteral
        {
        public init(integerLiteral value: Int)
            {
            self.count = value
            }
        
        public typealias IntegerLiteralType = Int
        
        public static func ==(lhs:SlotCount,rhs:SlotCount) -> Bool
            {
            return(lhs.count == rhs.count)
            }
            
        public static func ==(lhs:SlotCount,rhs:Int) -> Bool
            {
            return(lhs.count == rhs)
            }
            
        public static func *(lhs:SlotCount,rhs:Int) -> SlotCount
            {
            return(SlotCount(lhs.count * rhs))
            }
            
        public static func +(lhs:SlotCount,rhs:Int) -> SlotCount
            {
            return(SlotCount(lhs.count + rhs))
            }
            
        internal var count:Int = 0

        public init(_ count:Word)
            {
            self.count = Int(count)
            }
            
        public init(_ count:ByteCount)
            {
            self.count = count.count / MemoryLayout<Word>.stride
            }
            
        public init(_ count:Int)
            {
            self.count = count
            }
            
        public func aligned(to alignment:Int) -> SlotCount
            {
            let word1 = Word(alignment) - 1
            let word2 = ~Word(alignment - 1)
            let word0 = Word(self.count)
            return(Proton.SlotCount(word0 + (word1 & word2)))
            }
        }
        
    public enum ScalarType:Word
        {
        public var valueType:ValueType
            {
            switch(self)
                {
                case .uinteger:
                    return(.uinteger)
                case .integer:
                    return(.integer)
                case .boolean:
                    return(.boolean)
                case .byte:
                    return(.byte)
                case .float32:
                    return(.float32)
                case .float64:
                    return(.float64)
                case .bits:
                    return(.bits)
                default:
                    return(.none)
                }
            }
            
        case integer = 0
        case uinteger
        case boolean
        case byte
        case float32
        case float64
        case none
        case bits
        
        public init(_ tag:Proton.ValueType)
            {
            switch(tag)
                {
                case .integer:
                    self = .integer
                case .uinteger:
                    self = .uinteger
                case .boolean:
                    self = .boolean
                case .byte:
                    self = .byte
                case .float32:
                    self = .float32
                case .float64:
                    self = .float64
                case .bits:
                    self = .bits
                default:
                    self = .none
                }
            }
            
        public init(_ tag:Proton.HeaderTag)
            {
            switch(tag)
                {
                case .bits:
                    self = .bits
                case .integer:
                    self = .integer
                case .boolean:
                    self = .boolean
                case .byte:
                    self = .byte
                case .float32:
                    self = .float32
                case .float64:
                    self = .float64
                default:
                    self = .none
                }
            }
            
        public func valueText(for word:Word) -> String
            {
            switch(self)
                {
                case .bits:
                    return("\(word.bitString)")
                case .integer:
                    return("\(Int64(bitPattern: word))")
                case .uinteger:
                    return("\(untaggedUInteger(word))")
                case .boolean:
                    return("\(word == 1)")
                case .byte:
                    return("\(UInt8(word))")
                case .none:
                    return("none")
                case .float32:
                    return("\(Proton.Float32(bitPattern: UInt32(word)))")
                case .float64:
                    return("\(Proton.Float64(bitPattern: UInt64(word)))")
                }
            }
        }
        
    public enum Error:Swift.Error
        {
        case bitCountMustBeMultipleOfWordBitWidth
        case bitRangeWidthMustBeLessThanWordBitWidth
        case arrayIndexBoundsViolation(Int,Int)
        case outOfMemory(MemorySegment)
        case internalErrorCanNotGrowArray
        case integerTypeMismatch
        case registerValueInvalid(Instruction.Register)
        case invalidOperands
        }
    }

