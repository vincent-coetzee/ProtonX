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

extension Argon.Address
    {
    public static func +(lhs:Argon.Address,rhs:SlotIndex) -> Self
        {
        return(lhs + Argon.Address(rhs.index * MemoryLayout<Word>.stride))
        }
        
    @discardableResult
    public static postfix func ++(lhs:inout Self) -> Self
        {
        let before = lhs
        lhs += Argon.Address(MemoryLayout<Self>.size)
        return(before)
        }
        
    public static func +(lhs:Self,rhs:SlotOffset) -> Self
        {
        return(lhs + Argon.Address(rhs.offset))
        }
        
    public static let zero = 0

    public var addressesInstancePointer:Bool
        {
        return(wordAtAddress(untaggedAddress(self)).tag == Argon.kTagBitsAddress)
        }
        
    public var addressesStringPointer:Bool
        {
        let word = wordAtAddress(untaggedAddress(self))
        if word.tag != Argon.kTagBitsAddress
            {
            return(false)
            }
        return(wordAtAddress(untaggedAddress(word)).objectType == Argon.kTypeString)
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
        return(((self & (Argon.kTagBitsMask << Argon.kTagBitsShift)) >> Argon.kTagBitsShift) == Argon.HeaderTag.address.rawValue)
        }
        
    public var isInteger:Bool
        {
        return(((self & (Argon.kTagBitsMask << Argon.kTagBitsShift)) >> Argon.kTagBitsShift) == Argon.kTagBitsInteger)
        }
        
    public var isUInteger:Bool
        {
        return(((self & (Argon.kTagBitsMask << Argon.kTagBitsShift)) >> Argon.kTagBitsShift) == Argon.kTagBitsUInteger)
        }
        
    public var isBoolean:Bool
        {
        return(((self & (Argon.kTagBitsMask << Argon.kTagBitsShift)) >> Argon.kTagBitsShift) == Argon.kTagBitsBoolean)
        }
        
    public var isFloat:Bool
        {
        return(((self & (Argon.kTagBitsMask << Argon.kTagBitsShift)) >> Argon.kTagBitsShift) == Argon.kTagBitsFloat32)
        }
        
//    public var isDouble:Bool
//        {
//        return(((self & (Argon.kTagBitsMask << Argon.kTagBitsShift)) >> Argon.kTagBitsShift) == Argon.kTagBitsFloat64)
//        }

    public var isByte:Bool
        {
        return(((self & (Argon.kTagBitsMask << Argon.kTagBitsShift)) >> Argon.kTagBitsShift) == Argon.kTagBitsByte)
        }
    }
