//
//  Proton.UInteger+Extensions.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/19.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

    
extension Proton.UInteger
    {
    public var taggedAddress:Proton.Address
        {
        return((Proton.kTagBitsUInteger << Proton.kTagBitsShift) | self)
        }
        
    public func equals(_ value:Value) -> Bool
        {
        if value is Proton.UInteger
            {
            return(self == (value as! Proton.UInteger))
            }
        return(false)
        }
        
    public func isLessThan(_ value:Value) -> Bool
        {
        if value is Proton.UInteger
            {
            return(self < (value as! Proton.UInteger))
            }
        return(false)
        }
        
    public func store(atAddress pointer:Proton.Address)
        {
        setAddressAtAddress(self.taggedAddress,pointer)
        }
        
    public func withTagBitsZeroed() -> Proton.UInteger
        {
        return(self & ~(Self(Proton.kTagBitsMask) << Self(Proton.kTagBitsShift)))
        }
        
    public init(word:Word)
        {
        self = word & (Proton.kTagBitsMask << Proton.kTagBitsShift)
        }
        
    public init(taggedBits word:Word)
        {
        self = word & (Proton.kTagBitsMask << Proton.kTagBitsShift)
        }
    }
