//
//  Memory.swift
//  argon
//
//  Created by Vincent Coetzee on 29/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class Memory
    {
    public static let BytesPerMegabyte = 1024 * 1024

    public static let codeSegment = CodeSegment(sizeInMegabytes: 64)
    public static let dataSegment = DataSegment(sizeInMegabytes: 16)
    public static let staticSegment = StaticSegment(sizeInMegabytes: 32)
    public static let managedSegment = ManagedSegment(sizeInMegabytes: 128)
    
    private static var typesKeyedByName:[String:TypePointer] = [:]
    private static var segmentsKeyedByIndex:[Word:MemorySegment] = [:]
    
    public static let null = unsafeBitCast(0,to: MemorySegment.self)

    public static var kTypeType:TypePointer?
    public static var kTypeString:TypePointer?
    public static var kTypeObject:TypePointer?
    public static var kTypeMeta:TypePointer?
    public static var kTypeArray:TypePointer?
    public static var kTypeMethod:TypePointer?
    public static var kTypeMethodInstance:TypePointer?
    public static var kTypeScalarType:TypePointer?
    public static var kTypeUInteger:ScalarTypePointer?
    public static var kTypeInteger:ScalarTypePointer?
    public static var kTypeBoolean:ScalarTypePointer?
    public static var kTypeByte:ScalarTypePointer?
    public static var kTypeFloat32:ScalarTypePointer?
    public static var kTypeFloat64:ScalarTypePointer?
    public static var kTypeWordBuffer:TypePointer?
    public static var kTypeList:TypePointer?
    public static var kTypeSet:TypePointer?
    public static var kTypeDictionary:TypePointer?
    public static var kTypeBitSet:TypePointer?
    public static var kTypeSlot:TypePointer?
    public static var kTypeCodeBlock:TypePointer?
    public static var kTypeEnumeration:TypePointer?
    public static var kTypeEnumerationCase:TypePointer?
    public static var kTypeNone:TypePointer?
    public static var kTypeAssociation:TypePointer?
    public static var kTypeGenericType:TypePointer?
    public static var kTypeBucket:TypePointer?
    public static var kTypePackage:TypePointer?
    public static var kTypeListNode:TypePointer?
    public static var kTypeTree:TypePointer?
    public static var kTypeTreeNode:TypePointer?
    public static var kTypeInstruction:TypePointer?
    
    public static var kPackageArgon:PackagePointer?
        
    public class func register(memorySegment:MemorySegment)
        {
        self.segmentsKeyedByIndex[memorySegment.index] = memorySegment
        }
        
    public func makeStackSegment(sizeInMegabytes size:Int) -> StackSegment
        {
        let segment = StackSegment(sizeInMegabytes: size)
        Self.register(memorySegment: segment)
        return(segment)
        }
        
    public class func segmentContaining(address:Instruction.Address) -> MemorySegment?
        {
        for segment in segmentsKeyedByIndex.values
            {
            if segment.contains(address: address)
                {
                return(segment)
                }
            }
        return(nil)
        }
        
    public class func type(atName:String) -> TypePointer?
        {
        return(self.typesKeyedByName[atName])
        }
        
    public class func setType(_ type:TypePointer?,atName:String)
        {
        self.typesKeyedByName[atName] = type
        }
        
    public class func initTypes()
        {
        Self.kTypePackage = Self.staticSegment.allocateEmptyType()
        Self.kPackageArgon = Self.staticSegment.allocateEmptyPackage()
        Self.kPackageArgon!.name = "Argon"
        Self.kTypeNone = Self.staticSegment.allocateEmptyType()
        Self.kTypeType = Self.staticSegment.allocateEmptyType()
        Self.kPackageArgon!.append(Self.kTypeType!)
        Self.kTypeString = Self.staticSegment.allocateEmptyType()
        Self.kPackageArgon!.append(Self.kTypeString!)
        Self.kPackageArgon!.append(Self.kTypePackage!)
        Self.kTypeType?.name = "Type"
        Self.kTypeNone?.name = "None"
        Self.kTypePackage?.name = "Package"
        Self.kTypeString?.name = "String"
        Self.kTypeObject = Self.staticSegment.allocateEmptyType()
        Self.kTypeObject?.name = "Object"
        Self.kPackageArgon!.append(Self.kTypeObject!)
        Self.kTypeMeta = Self.staticSegment.allocateEmptyType()
        Self.kTypeMeta?.typePointer = Self.kTypeType
        Self.kTypeType?.typePointer = Self.kTypeMeta
        Self.kTypeMeta?.name = "MetaType"
        Self.kPackageArgon!.append(Self.kTypeMeta!)
        Self.kTypeArray = Self.staticSegment.allocateEmptyType()
        Self.kTypeArray?.name = "Array"
        Self.kPackageArgon!.append(Self.kTypeArray!)
        Self.kTypeWordBuffer = Self.staticSegment.allocateEmptyType()
        Self.kTypeWordBuffer?.name = "WordBuffer"
        Self.kPackageArgon!.append(Self.kTypeWordBuffer!)
        Self.kTypeMethod = Self.staticSegment.allocateEmptyType()
        Self.kTypeMethod?.name = "Method"
        Self.kPackageArgon!.append(Self.kTypeMethod!)
        Self.kTypeMethodInstance = Self.staticSegment.allocateEmptyType()
        Self.kTypeMethodInstance?.name = "MethodInstance"
        Self.kPackageArgon!.append(Self.kTypeMethodInstance!)
        Self.kTypeScalarType = Self.staticSegment.allocateEmptyType()
        Self.kTypeScalarType?.name = "ScalarType"
        Self.kPackageArgon!.append(Self.kTypeScalarType!)
        Self.kTypeGenericType = Self.staticSegment.allocateEmptyType()
        Self.kTypeGenericType?.name = "GenericType"
        Self.kPackageArgon!.append(Self.kTypeGenericType!)
        Self.kTypeSlot = Self.staticSegment.allocateEmptyType()
        Self.kTypeSlot?.name = "Slot"
        Self.kPackageArgon!.append(Self.kTypeSlot!)
        Self.kTypeScalarType?.typePointer = Self.kTypeType
        Self.kTypeUInteger = Self.staticSegment.allocateEmptyScalarType(.uinteger)
        Self.kTypeUInteger?.scalarType = .uinteger
        Self.kTypeUInteger?.instanceType = Argon.kTypeUInteger
        Self.kTypeUInteger?.name = "UInteger"
        Self.kPackageArgon!.append(Self.kTypeUInteger!)
        Self.kTypeInteger = Self.staticSegment.allocateEmptyScalarType(.integer)
        Self.kTypeInteger?.scalarType = .integer
        Self.kTypeInteger?.instanceType = Argon.kTypeInteger
        Self.kTypeInteger?.name = "Integer"
        Self.kPackageArgon!.append(Self.kTypeInteger!)
        Self.kTypeBoolean = Self.staticSegment.allocateEmptyScalarType(.boolean)
        Self.kTypeBoolean?.scalarType = .boolean
        Self.kTypeBoolean?.name = "Boolean"
        Self.kTypeBoolean?.instanceType = Argon.kTypeBoolean
        Self.kPackageArgon!.append(Self.kTypeBoolean!)
        Self.kTypeByte = Self.staticSegment.allocateEmptyScalarType(.byte)
        Self.kTypeByte?.scalarType = .byte
        Self.kTypeByte?.name = "Byte"
        Self.kTypeByte?.instanceType = Argon.kTypeByte
        Self.kPackageArgon!.append(Self.kTypeByte!)
        Self.kTypeFloat32 = Self.staticSegment.allocateEmptyScalarType(.float32)
        Self.kTypeFloat32?.scalarType = .float32
        Self.kTypeFloat32?.name = "Float32"
        Self.kTypeFloat32?.instanceType = Argon.kTypeFloat32
        Self.kPackageArgon!.append(Self.kTypeFloat32!)
        Self.kTypeFloat64 = Self.staticSegment.allocateEmptyScalarType(.float64)
        Self.kTypeFloat64?.scalarType = .float64
        Self.kTypeFloat64?.name = "Float64"
        Self.kTypeFloat64?.instanceType = Argon.kTypeFloat64
        Self.kPackageArgon!.append(Self.kTypeFloat64!)
        Self.kTypeDictionary = Self.staticSegment.allocateEmptyType()
        Self.kTypeDictionary?.name = "Dictionary"
        Self.kTypeDictionary?.instanceType = Argon.kTypeDictionary
        Self.kPackageArgon!.append(Self.kTypeDictionary!)
        Self.kTypeList = Self.staticSegment.allocateEmptyType()
        Self.kTypeList?.name = "List"
        Self.kTypeList?.instanceType = Argon.kTypeList
        Self.kPackageArgon!.append(Self.kTypeList!)
        Self.kTypeSet = Self.staticSegment.allocateEmptyType()
        Self.kTypeSet?.name = "Set"
        Self.kTypeSet?.instanceType = Argon.kTypeSet
        Self.kPackageArgon!.append(Self.kTypeSet!)
        Self.kTypeBitSet = Self.staticSegment.allocateEmptyType()
        Self.kTypeBitSet?.name = "BitSet"
        Self.kTypeBitSet?.instanceType = Argon.kTypeBitSet
        Self.kPackageArgon!.append(Self.kTypeBitSet!)
        Self.kTypeCodeBlock = Self.staticSegment.allocateEmptyType()
        Self.kTypeCodeBlock?.name = "CodeBlock"
        Self.kTypeCodeBlock?.instanceType = Argon.kTypeCodeBlock
        Self.kPackageArgon!.append(Self.kTypeCodeBlock!)
        Self.kTypeEnumeration = Self.staticSegment.allocateType(named: "Enumeration")
        Self.kTypeEnumeration?.instanceType = Argon.kTypeEnumeration
        Self.kPackageArgon!.append(Self.kTypeEnumeration!)
        Self.kTypeEnumerationCase = Self.staticSegment.allocateType(named: "EnumerationCase")
        Self.kTypeEnumerationCase?.instanceType = Argon.kTypeEnumerationCase
        Self.kPackageArgon!.append(Self.kTypeEnumerationCase!)
        Self.kTypeListNode = Self.staticSegment.allocateType(named: "ListNode")
        Self.kTypeListNode?.instanceType = Argon.kTypeListNode
        Self.kPackageArgon!.append(Self.kTypeListNode!)
        Self.kTypeTreeNode = Self.staticSegment.allocateType(named: "TreeNode")
        Self.kTypeTreeNode?.instanceType = Argon.kTypeTreeNode
        Self.kPackageArgon!.append(Self.kTypeTreeNode!)
        Self.kTypeTree = Self.staticSegment.allocateType(named: "Tree")
        Self.kTypeTree?.instanceType = Argon.kTypeTree
        Self.kPackageArgon!.append(Self.kTypeTree!)
        Self.kTypeInstruction = Self.staticSegment.allocateType(named: "Instruction")
        Self.kTypeInstruction?.instanceType = Argon.kTypeInstruction
        Self.kPackageArgon!.append(Self.kTypeInstruction!)
        }
    }
