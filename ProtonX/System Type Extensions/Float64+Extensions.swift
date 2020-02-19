//
//  Float64+Extensions.swift
//  argon
//
//  Created by Vincent Coetzee on 20/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

extension Proton.Float64
    {
    public var taggedAddress:Proton.Address
        {
        return(0)
        }
        
    public init(_ word:Word)
        {
        self.init(taggedBits: word)
        }
        
    public func asWord() -> Word
        {
        return(0)
        }
        
    public func store(atAddress pointer:Proton.Address)
        {
        setAddressAtAddress(self.taggedAddress,pointer)
        }
        
    public func withTagBitsZeroed() -> Proton.Float64
        {
        return(self)
        }
            
    public var taggedBits:Word
        {
        let untaggedWord:Word = self.bitPattern
        let sign = untaggedWord & Proton.kSignMask
        return(((untaggedWord >> 4) & Proton.kTagBitsZeroMask) | (Proton.kTagBitsFloat64 << Proton.kTagBitsShift) | sign)
        }
        
    public init(taggedBits:Word)
        {
        self.init(bitPattern: ((taggedBits & Proton.kTagBitsZeroMask) << 4) | (taggedBits & Proton.kSignMask))
        }
    }
