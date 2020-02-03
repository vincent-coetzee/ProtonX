//
//  EnumerationPointer.swift
//  argon
//
//  Created by Vincent Coetzee on 03/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class EnumerationCasePointer:ObjectPointer
    {
    public struct EnumerationCase
        {
        public let name:String
        public let index:Int
        public var associatedValueTypes:[TypePointer?]
        public let associatedValueTypeNames:[String]
        }
        
    public static let kEnumerationCaseNameIndex = SlotIndex.two
    public static let kEnumerationCaseEnumerationIndex = SlotIndex.three
    public static let kEnumerationCaseIndexIndex = SlotIndex.four
    public static let kEnumerationCaseAssociatedValueCountIndex = SlotIndex.five
    public static let kEnumerationCaseAssociatedValueTypesIndex = SlotIndex.six

    public override class var totalSlotCount:Argon.SlotCount
        {
        return(7)
        }
        
    public var name:String
        {
        get
            {
            return(self.namePointer.string)
            }
        set
            {
            self.namePointer = ImmutableStringPointer(newValue)
            }
        }
        
    public var namePointer:ImmutableStringPointer
        {
        get
            {
            return(ImmutableStringPointer(untaggedPointerAtIndexAtPointer(Self.kEnumerationCaseNameIndex,self.pointer)))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue.pointer,Self.kEnumerationCaseNameIndex,self.pointer)
            }
        }
        
    public var enumerationPointer:EnumerationPointer
        {
        get
            {
            return(EnumerationPointer(untaggedPointerAtIndexAtPointer(Self.kEnumerationCaseEnumerationIndex,self.pointer)))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue.pointer,Self.kEnumerationCaseEnumerationIndex,self.pointer)
            }
        }
        
    public var elementIndex:Int
        {
        get
            {
            return(Int(untaggedWordAtIndexAtPointer(Self.kEnumerationCaseIndexIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),Self.kEnumerationCaseIndexIndex,self.pointer)
            }
        }
        
    public var associatedValueCount:Int
        {
        get
            {
            return(Int(untaggedWordAtIndexAtPointer(Self.kEnumerationCaseAssociatedValueCountIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),Self.kEnumerationCaseAssociatedValueCountIndex,self.pointer)
            }
        }
        
    public func associatedValueTypePointer(at index:Int) -> TypePointer
        {
        return(TypePointer(Instruction.Address(untaggedAddressAtIndexAtPointer(Self.kEnumerationCaseAssociatedValueTypesIndex,self.pointer))))
        }
        
    public init(_ enumerationCase:EnumerationCase)
        {
        let segment = Memory.staticSegment
        let totalSlotCount = Self.totalSlotCount + enumerationCase.associatedValueTypes.count
        super.init(segment.allocate(slotCount: totalSlotCount))
        self.name = enumerationCase.name
        self.elementIndex = enumerationCase.index
        self.associatedValueCount = enumerationCase.associatedValueTypes.count
        var offset = 0
        for type in enumerationCase.associatedValueTypes
            {
            setWordAtIndexAtPointer(taggedObject(type?.pointer),Self.kEnumerationCaseAssociatedValueTypesIndex + offset,self.pointer)
            offset += 1
            }
        }
    
    required public init(_ address: UnsafeMutableRawPointer?) {
        fatalError("init(_:) has not been implemented")
    }
    
    public required init(_ address: Instruction.Address)
        {
        super.init(address)
        }
}
    
public class EnumerationPointer:TypePointer
    {
    public static let kEnumerationCaseTypeIndex = SlotIndex.ten + .one
    public static let kEnumerationCaseCountIndex = SlotIndex.ten + .two
    public static let kEnumerationCasesIndex = SlotIndex.ten + .three
        
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(14)
        }
        
    public var caseCount:Int
        {
        get
            {
            return(Int(untaggedWordAtIndexAtPointer(Self.kEnumerationCaseCountIndex,self.pointer)))
            }
        set
            {
            setWordAtIndexAtPointer(Word(newValue),Self.kEnumerationCaseCountIndex,self.pointer)
            }
        }
        
    public subscript(_ index:Int) -> EnumerationCasePointer
        {
        get
            {
            return(EnumerationCasePointer(untaggedPointerAtIndexAtPointer(Self.kEnumerationCasesIndex + index,self.pointer)))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue.pointer,Self.kEnumerationCasesIndex + index,self.pointer)
            }
        }
        
    public func index(of elementName:String) -> Int?
        {
        for index in 0..<self.caseCount
            {
            if self[index].name == elementName
                {
                return(index)
                }
            }
        return(nil)
        }
        
    public convenience init(_ name:String,_ caseType:TypePointer,_ someCases:[EnumerationCasePointer.EnumerationCase])
        {
        let pointer = Memory.staticSegment.allocateEnumeration(named: name,cases: someCases)
        self.init(pointer)
        var cases:[EnumerationCasePointer.EnumerationCase] = someCases
        for index in 0..<cases.count
            {
            cases[index].associatedValueTypes = cases[index].associatedValueTypeNames.map{Memory.type(atName: $0)}
            let casePointer = EnumerationCasePointer(cases[index])
            setObjectPointerAtIndexAtPointer(casePointer.pointer,Self.kEnumerationCasesIndex + index,pointer)
            }
        }
    
    public required init(_ pointer: Argon.Pointer) {
        fatalError("init(_:) has not been implemented")
    }
    
    required public init(_ address: UnsafeMutableRawPointer?)
        {
        fatalError("init(_:) has not been implemented")
        }
    
    public required init(_ address: Instruction.Address)
        {
        super.init(address)
        }
}
