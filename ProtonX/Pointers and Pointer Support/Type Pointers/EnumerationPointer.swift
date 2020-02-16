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

    public override class var totalSlotCount:Proton.SlotCount
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
            return(ImmutableStringPointer(addressAtIndexAtAddress(Self.kEnumerationCaseNameIndex,self.address)))
            }
        set
            {
            setAddressAtIndexAtAddress(newValue.address,Self.kEnumerationCaseNameIndex,self.address)
            }
        }
        
    public var enumerationPointer:EnumerationPointer
        {
        get
            {
            return(EnumerationPointer(addressAtIndexAtAddress(Self.kEnumerationCaseEnumerationIndex,self.address)))
            }
        set
            {
            setAddressAtIndexAtAddress(newValue.address,Self.kEnumerationCaseEnumerationIndex,self.address)
            }
        }
        
    public var elementIndex:Int
        {
        get
            {
            return(Int(wordAtIndexAtAddress(Self.kEnumerationCaseIndexIndex,self.address)))
            }
        set
            {
            setWordAtIndexAtAddress(Word(newValue),Self.kEnumerationCaseIndexIndex,self.address)
            }
        }
        
    public var associatedValueCount:Int
        {
        get
            {
            return(Int(wordAtIndexAtAddress(Self.kEnumerationCaseAssociatedValueCountIndex,self.address)))
            }
        set
            {
            setWordAtIndexAtAddress(Word(newValue),Self.kEnumerationCaseAssociatedValueCountIndex,self.address)
            }
        }
        
    public func associatedValueTypePointer(at index:Int) -> TypePointer
        {
        return(TypePointer(Proton.Address(addressAtIndexAtAddress(Self.kEnumerationCaseAssociatedValueTypesIndex,self.address))))
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
            setAddressAtIndexAtAddress(type?.address ?? 0,Self.kEnumerationCaseAssociatedValueTypesIndex + offset,self.address)
            offset += 1
            }
        }
    
    required public init(_ address: UnsafeMutableRawPointer?) {
        fatalError("init(_:) has not been implemented")
    }
    
    public required init(_ address: Proton.Address)
        {
        super.init(address)
        }
}
    
public class EnumerationPointer:TypePointer
    {
    public static let kEnumerationCaseTypeIndex = SlotIndex.ten + .one
    public static let kEnumerationCaseCountIndex = SlotIndex.ten + .two
    public static let kEnumerationCasesIndex = SlotIndex.ten + .three
        
    public override class var totalSlotCount:Proton.SlotCount
        {
        return(14)
        }
        
    public var caseCount:Int
        {
        get
            {
            return(Int(wordAtIndexAtAddress(Self.kEnumerationCaseCountIndex,self.address)))
            }
        set
            {
            setWordAtIndexAtAddress(Word(newValue),Self.kEnumerationCaseCountIndex,self.address)
            }
        }
        
    public subscript(_ index:Int) -> EnumerationCasePointer
        {
        get
            {
            return(EnumerationCasePointer(addressAtIndexAtAddress(Self.kEnumerationCasesIndex + index,self.address)))
            }
        set
            {
            setAddressAtIndexAtAddress(newValue.address,Self.kEnumerationCasesIndex + index,self.address)
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
        self.init(pointer.address)
        var cases:[EnumerationCasePointer.EnumerationCase] = someCases
        for index in 0..<cases.count
            {
            cases[index].associatedValueTypes = cases[index].associatedValueTypeNames.map{Memory.type(atName: $0)}
            let casePointer = EnumerationCasePointer(cases[index])
            setAddressAtIndexAtAddress(casePointer.address,Self.kEnumerationCasesIndex + index,pointer.address)
            }
        }
    
    public required init(_ address: Proton.Address)
        {
        super.init(address)
        }
}
