//
//  Proton.Byte+Extensions.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/19.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

extension Proton.Byte:Value
    {
    public var taggedAddress:Proton.Address
        {
        return((Proton.kTagBitsByte << Proton.kTagBitsShift) | Word(self))
        }
        
    public func store(atAddress pointer:Proton.Address)
        {
        setAddressAtAddress(self.taggedAddress,pointer)
        }
        
    public func equals(_ value:Value) -> Bool
        {
        if value is Proton.Byte
            {
            return(self == (value as! Proton.Byte))
            }
        return(false)
        }
        
    public func asWord() -> Word
        {
        return(unsafeBitCast(self,to:Word.self))
        }
        
    public func isLessThan(_ value:Value) -> Bool
        {
        if value is Proton.Byte
            {
            return(self < (value as! Proton.Byte))
            }
        return(false)
        }

    public func withTagBitsZeroed() -> Proton.Byte
        {
        return(self)
        }
        
    public init(taggedBits word:Word)
        {
        self = UInt8(word & ~(Proton.kTagBitsMask << Proton.kTagBitsShift))
        }
    }
