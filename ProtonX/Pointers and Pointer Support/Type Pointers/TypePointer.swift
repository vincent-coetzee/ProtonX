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
        
    public static let kTypeInstanceTypeFlagIndex = SlotIndex.two
    public static let kTypeSlotCountIndex = SlotIndex.three
    public static let kTypeSlotArrayIndex = SlotIndex.four
    public static let kTypeParentCountIndex = SlotIndex.five
    public static let kTypeParentArrayIndex = SlotIndex.six
    public static let kTypeInstanceSlotCountIndex = SlotIndex.seven
    public static let kTypeInstanceHasBytesIndex = SlotIndex.eight

    public override class var totalSlotCount:Argon.SlotCount
        {
        return(9)
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
        

        
    public var slotArrayPointer:ArrayPointer
        {
        get
            {
            return(ArrayPointer(wordAsPointer(untaggedWordAtIndexAtPointer(Self.kTypeSlotArrayIndex,self.pointer))))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue.pointer,Self.kTypeSlotArrayIndex,self.pointer)
            }
        }
        
    public var parentArrayPointer:ArrayPointer?
        {
        get
            {
            return(ArrayPointer(untaggedPointerAtIndexAtPointer(Self.kTypeParentArrayIndex,self.pointer)))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue?.pointer,Self.kTypeParentArrayIndex,self.pointer)
            }
        }
        
    public var typeSlotCount:Int
        {
        get
            {
            return(Int(untaggedWordAtIndexAtPointer(Self.kTypeSlotCountIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),Self.kTypeSlotCountIndex,self.pointer)
            }
        }
        
    public var instanceTypeFlag:Word
        {
        get
            {
            return(untaggedWordAtIndexAtPointer(Self.kTypeInstanceTypeFlagIndex,self.pointer))
            }
        set
            {
            setWordAtIndexAtPointer(newValue,Self.kTypeInstanceTypeFlagIndex,self.pointer)
            }
        }
        
    public var fitsInWord:Bool
        {
        let flag = untaggedWordAtIndexAtPointer(Self.kTypeInstanceTypeFlagIndex,self.pointer)
        return(flag == Argon.kTypeUnsigned || flag == Argon.kTypeSigned || flag == Argon.kTypeBoolean || flag == Argon.kTypeByte || flag == Argon.kTypeFloat32)
        }
        
    public var instanceHasBytes:Bool
        {
        get
            {
            return(untaggedWordAtIndexAtPointer(Self.kTypeInstanceHasBytesIndex,self.pointer) == 1)
            }
        set
            {
            setWordAtIndexAtPointer(newValue ? 1 : 0,Self.kTypeInstanceHasBytesIndex,self.pointer)
            }
        }
        
    public var instanceSlotCount:Int
        {
        get
            {
            return(Int(untaggedWordAtIndexAtPointer(Self.kTypeInstanceSlotCountIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),Self.kTypeInstanceSlotCountIndex,self.pointer)
            }
        }
        
    public var parentCount:Int
        {
        get
            {
            return(Int(untaggedWordAtIndexAtPointer(Self.kTypeParentCountIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),Self.kTypeParentCountIndex,self.pointer)
            }
        }

    public override var objectStrideInBytes:Argon.ByteCount
        {
        let stride = MemoryLayout<Word>.stride
        return(Argon.ByteCount(max(self.slotArrayPointer.count * stride,stride)))
        }
        
    public override var taggedAddress:Instruction.Address
        {
        return(taggedObject(self.pointer))
        }
        
    public convenience init(_ name:String,segment:MemorySegment = Memory.staticSegment)
        {
        let byteCount = Argon.ByteCount(Self.totalSlotCount)
        var newSlotCount = Argon.SlotCount(0)
        let address = segment.allocate(byteCount: byteCount,slotCount: &newSlotCount)
        self.init(address)
        self.parentArrayPointer = segment.allocateArray(count: 16,elementType: Memory.kTypeInteger!)
        self.parentCount = 0
        self.slotArrayPointer = segment.allocateArray(count: 16,elementType: Memory.kTypeUInteger!)
        self.typePointer = Memory.kTypeType
        self.totalSlotCount = newSlotCount
        self.isMarked = true
        self.valueType = .typeType
        self.instanceTypeFlag = Argon.kTypeType
        self.instanceSlotCount = 0
        self.instanceHasBytes = false
        self.name = name
        }
        
    public required init(_ pointer:Argon.Pointer)
        {
        super.init(pointer)
        }
        
    public init(_ name:String,_ pointer:Argon.Pointer)
        {
        super.init(pointer)
        self.name = name
        }
        
    public override  init(_ address:Instruction.Address)
        {
        super.init(untaggedAddressAsPointer(address))
        }
    
    required public init(_ address: UnsafeMutableRawPointer?)
        {
        super.init(address)
        }
    
    public func storeObject(_ instance:ObjectPointer?,at:Argon.Pointer)
        {
        }
        
    public func loadObject(at:Argon.Pointer) -> ObjectPointer?
        {
        return(nil)
        }
        
    public func typedValue(of word:Word) -> Value?
        {
        return(Argon.UInteger(word))
        }

    public func appendSlot(name:String,type:TypePointer?,flags:Word,index:SlotIndex,segment: MemorySegment)
        {
        self.appendSlot(SlotPointer(name: name,type: type,flags: flags,index: index,segment: segment))
        }
        
    public func appendSlot(_ slot:SlotPointer)
        {
        if self.slotArrayPointer.isNull
            {
            self.slotArrayPointer = self.segment.allocateArray(count: 16, elementType: Memory.kTypeSlot!)
            if self.slotArrayPointer.isNull
                {
                fatalError("SlotArray not allocating correctly")
                }
            }
        self.slotArrayPointer.append(slot.taggedAddress)
        self.instanceSlotCount+=1
        }
        
    public override func makeInstance(in segment:MemorySegment = Memory.managedSegment) -> Argon.Pointer?
        {
        fatalError("A type itself should not be making instances")
        }
    }

public class MetaTypePointer:TypePointer
    {
    }
    
