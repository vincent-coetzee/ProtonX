//
//  MethodInstancePointer.swift
//  argon
//
//  Created by Vincent Coetzee on 31/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public struct InstructionValue
    {
    public static let kAddressBit = (Word(1) << Word(63))
    
    public var hasAddress:Bool
        {
        return((instruction & Self.kAddressBit) == Self.kAddressBit)
        }
        
    public let instruction:Word
    public let address:Word
    }
    
public class MethodInstancePointer:CodeBlockPointer
    {
    public static let kMethodInstanceNameIndex = SlotIndex.six
    public static let kMethodInstanceBaseSlotCount = SlotIndex.seven
        
    public override class var totalSlotCount:Proton.SlotCount
        {
        return(8)
        }
        
    public var namePointer:ImmutableStringPointer
        {
        get
            {
            return(ImmutableStringPointer(addressAtIndexAtAddress(Self.kMethodInstanceNameIndex,self.address)))
            }
        set
            {
            setAddressAtIndexAtAddress(newValue.address,Self.kMethodInstanceNameIndex,self.address)
            }
        }
    
    public override var hashedValue:Int
        {
        return(0)
        }
        
    public init(name:String,instructions:InstructionVector,segment:MemorySegment = Memory.managedSegment)
        {
        super.init(instructions: instructions,segment: segment)
        self.valueType = .methodInstance
        self.hasExtraSlotsAtEnd = false
        self.namePointer = ImmutableStringPointer(name)
        }   
    
    public required init(_ address: Proton.Address)
        {
        super.init(address)
        }
}
