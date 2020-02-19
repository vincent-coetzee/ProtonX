//
//  Argon.Address + Extensions.swift
//  argon
//
//  Created by Vincent Coetzee on 18/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

postfix operator ++

extension Proton.Address
    {
    public static func +(lhs:Proton.Address,rhs:SlotIndex) -> Self
        {
        return(lhs + Proton.Address(rhs.index * MemoryLayout<Word>.stride))
        }
        
    @discardableResult
    public static postfix func ++(lhs:inout Self) -> Self
        {
        let before = lhs
        lhs += Proton.Address(MemoryLayout<Self>.size)
        return(before)
        }
        
    public static func +(lhs:Self,rhs:SlotOffset) -> Self
        {
        return(lhs + Proton.Address(rhs.offset))
        }
        
    public static let zero = 0

    public var addressesInstancePointer:Bool
        {
        return(wordAtAddress(untaggedAddress(self)).tag == Proton.kTagBitsAddress)
        }
        
    public var addressesStringPointer:Bool
        {
        let word = wordAtAddress(untaggedAddress(self))
        if word.tag != Proton.kTagBitsAddress
            {
            return(false)
            }
        return(wordAtAddress(untaggedAddress(word)).objectType == Proton.kTypeString)
        }
        
    public var addressedInstanceTypeName:String
        {
        return(ObjectPointer(untaggedAddress(wordAtAddress(untaggedAddress(self)))).typePointer?.name ?? "**ERROR**")
        }
        
    public var addressedString:String
        {
        return(ImmutableStringPointer(untaggedAddress(wordAtAddress(untaggedAddress(self)))).string)
        }
        
    public var addressedTypeName:String
        {
        return(TypePointer(untaggedAddress(wordAtAddress(untaggedAddress(self)))).name)
        }
        
    public var isInstancePointer:Bool
        {
        return(((self & (Proton.kTagBitsMask << Proton.kTagBitsShift)) >> Proton.kTagBitsShift) == Proton.HeaderTag.address.rawValue)
        }
        
    public var isInteger:Bool
        {
        return(((self & (Proton.kTagBitsMask << Proton.kTagBitsShift)) >> Proton.kTagBitsShift) == Proton.kTagBitsInteger)
        }
        
    public var isBoolean:Bool
        {
        return(((self & (Proton.kTagBitsMask << Proton.kTagBitsShift)) >> Proton.kTagBitsShift) == Proton.kTagBitsBoolean)
        }
        
    public var isFloat32:Bool
        {
        return(((self & (Proton.kTagBitsMask << Proton.kTagBitsShift)) >> Proton.kTagBitsShift) == Proton.kTagBitsFloat32)
        }
        
    public var isFloat64:Bool
        {
        return(((self & (Proton.kTagBitsMask << Proton.kTagBitsShift)) >> Proton.kTagBitsShift) == Proton.kTagBitsFloat64)
        }

    public var isPersistent:Bool
        {
        return(((self & (Proton.kTagBitsMask << Proton.kTagBitsShift)) >> Proton.kTagBitsShift) == Proton.kTagBitsPersistent)
        }
        
    public var isByte:Bool
        {
        return(((self & (Proton.kTagBitsMask << Proton.kTagBitsShift)) >> Proton.kTagBitsShift) == Proton.kTagBitsByte)
        }
    }
