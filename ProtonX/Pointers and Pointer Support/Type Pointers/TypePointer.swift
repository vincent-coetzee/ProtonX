//
//  TypePointer.swift
//  argon
//
//  Created by Vincent Coetzee on 29/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class TypePointer:PackageElementPointer
    {
    public static func ==(lhs:TypePointer,rhs:TypePointer) -> Bool
        {
        return(lhs.fullName == rhs.fullName)
        }
        
    public static func <(lhs:TypePointer,rhs:TypePointer) -> Bool
        {
        return(lhs.fullName < rhs.fullName)
        }

    public static let kFlagInstanceContainsBits:Word = 1
    
    public static let kTypeVisibilityModifierIndex = SlotIndex.three
    public static let kTypeFlagsIndex = SlotIndex.four
    public static let kTypeInstanceTypeIndex = SlotIndex.five
    
    public override class var totalSlotCount:Proton.SlotCount
        {
        return(6)
        }
        
//    public class func pointer(forType pointer:Argon.Pointer?) -> ValuePointer
//        {
//        let typePointer = TypePointer(pointer)
//        switch(typePointer.instanceTypeFlag)
//            {
//            case Argon.kTypeArray:
//                return(ArrayTypePointer(pointer))
//            case Argon.kTypeList:
//                return(ListTypePointer(pointer))
//            case Argon.kTypeSet:
//                return(SetTypePointer(pointer))
//            case Argon.kTypeBitSet:
//                return(BitSetTypePointer(pointer))
//            case Argon.kTypeObject:
//                return(ObjectTypePointer(pointer))
//            case Argon.kTypeString:
//                return(StringTypePointer(pointer))
//            case Argon.kTypeSigned:
//                return(ScalarTypePointer(pointer))
//            case Argon.kTypeUnsigned:
//                return(ScalarTypePointer(pointer))
//            case Argon.kTypeBoolean:
//                return(ScalarTypePointer(pointer))
//            case Argon.kTypeByte:
//                return(ScalarTypePointer(pointer))
//            case Argon.kTypeContract:
//                return(ContractTypePointer(pointer))
//            case Argon.kTypeMethodInstance:
//                return(MethodInstanceTypePointer(pointer))
//            case Argon.kTypeMethod:
//                return(MethodTypePointer(pointer))
//            default:
//                fatalError("Invalid type in \(#function)")
//            }
//        }
        
    public var visibilityModifier:VisibilityModifier
        {
        get
            {
            return(VisibilityModifier(rawValue: wordAtIndexAtAddress(Self.kTypeVisibilityModifierIndex,self.address))!)
            }
        set
            {
            setWordAtIndexAtAddress(newValue.rawValue,Self.kTypeVisibilityModifierIndex,self.address)
            }
        }
        
    public var instanceType:Word
        {
        get
            {
            return(wordAtIndexAtAddress(Self.kTypeInstanceTypeIndex,self.address))
            }
        set
            {
            setWordAtIndexAtAddress(newValue,Self.kTypeInstanceTypeIndex,self.address)
            }
        }
        
    public var typeFlags:Word
        {
        get
            {
            return(wordAtIndexAtAddress(Self.kTypeFlagsIndex,self.address))
            }
        set
            {
            setWordAtIndexAtAddress(newValue,Self.kTypeFlagsIndex,self.address)
            }
        }
        
    public override var objectStrideInBytes:Proton.ByteCount
        {
//        let stride = MemoryLayout<Word>.stride
//        return(Argon.ByteCount(max(self.slotArrayPointer.count * stride,stride)))
        return(Proton.ByteCount(0))
        }
        
    public override var taggedAddress:Proton.Address
        {
        return(RawMemory.taggedAddress(self.address))
        }
        
    public convenience init(_ name:String,segment:MemorySegment = Memory.staticSegment)
        {
        fatalError("This should not be used")
//        let byteCount = Argon.ByteCount(Self.totalSlotCount)
//        var newSlotCount = Argon.SlotCount(0)
//        let address = segment.allocate(byteCount: byteCount,slotCount: &newSlotCount)
//        self.init(address)
//        self.parentArrayPointer = segment.allocateArray(count: 16,elementType: Memory.kTypeInteger!)
//        self.parentCount = 0
//        self.slotArrayPointer = segment.allocateArray(count: 16,elementType: Memory.kTypeUInteger!)
//        self.typePointer = Memory.kTypeType
//        self.totalSlotCount = newSlotCount
//        self.isMarked = true
//        self.valueType = .typeType
//        self.instanceTypeFlag = Argon.kTypeType
//        self.instanceSlotCount = 0
//        self.instanceHasBytes = false
//        self.name = name
        }
        
    public init(_ name:String,_ address:Proton.Address)
        {
        super.init(address)
        self.name = name
        }
        
    public required  init(_ address:Proton.Address)
        {
        super.init(address)
        }
        
    public func typedValue(of word:Word) -> Value?
        {
        return(Proton.UInteger(word))
        }
        
    public override func makeInstance(in segment:MemorySegment = Memory.managedSegment) -> Proton.Address
        {
        fatalError("A type itself should not be making instances")
        }
        
    public func flag(_ value:Word) -> Bool
        {
        let mask = Word.twoToPower(of: value)
        return((self.typeFlags & mask) == mask)
        }
        
    public func setFlag(_ value:Word,to:Bool)
        {
        let mask = Word.twoToPower(of: value)
        let newValue = Word((to ? 1 : 0) << (value - 1))
        self.typeFlags = (self.typeFlags & ~mask) | newValue
        }
    }

public class MetaTypePointer:TypePointer
    {
    }
    
