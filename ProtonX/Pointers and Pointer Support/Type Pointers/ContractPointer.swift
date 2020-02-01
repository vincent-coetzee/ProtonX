//
//  ContractTypePointer.swift
//  argon
//
//  Created by Vincent Coetzee on 02/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class ContractPointer:TypePointer
    {
    public static let kContractMethodArrayIndex = SlotIndex.ten
    public static let kContractConstantSlotArrayIndex = SlotIndex.ten + .one
        
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(12)
        }
        
    public var methodArrayPointer:ArrayPointer
        {
        get
            {
            return(ArrayPointer(untaggedPointerAtIndexAtPointer(Self.kContractMethodArrayIndex,self.pointer)))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue.pointer,Self.kContractMethodArrayIndex,self.pointer)
            }
        }
        
    public var constantSlotArrayPointer:ArrayPointer
        {
        get
            {
            return(ArrayPointer(untaggedPointerAtIndexAtPointer(Self.kContractConstantSlotArrayIndex,self.pointer)))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue.pointer,Self.kContractConstantSlotArrayIndex,self.pointer)
            }
        }
    }

public class ContractSlotPointer:SlotPointer
    {
    }
    
public class ContractMethodPointer:MethodPointer
    {
    }
