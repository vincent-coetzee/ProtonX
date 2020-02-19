//
//  Proton.Boolean+Extensions.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/19.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

extension Proton.Boolean:Value
    {
    public var taggedAddress:Proton.Address
        {
        return(taggedBoolean(self))
        }
        
    public init(_ word:Word)
        {
        self.init(word == 1)
        }
        
    public func asWord() -> Word
        {
        return(self ? 1 : 0)
        }
        
    public func equals(_ value:Value) -> Bool
        {
        if value is Proton.Boolean
            {
            return(self == (value as! Proton.Boolean))
            }
        return(false)
        }
        
    public func isLessThan(_ value:Value) -> Bool
        {
        return(false)
        }
        
    public func store(atAddress pointer:Proton.Address)
        {
        setAddressAtAddress(self.taggedAddress,pointer)
        }
        
    public func withTagBitsZeroed() -> Proton.Boolean
        {
        return(self)
        }
    }
