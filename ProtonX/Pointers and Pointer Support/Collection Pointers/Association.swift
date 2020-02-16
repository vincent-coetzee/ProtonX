//
//  Association.swift
//  argon
//
//  Created by Vincent Coetzee on 27/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory
    
public struct Association
    {
    public static var strideInBytes:Proton.ByteCount
        {
        return(Proton.ByteCount(2*MemoryLayout<Word>.stride))
        }
        
    public static let stride = Word.stride * 2
    
    internal let keyPointer:Proton.Address
    internal let valuePointer:Proton.Address
    internal let keyType:TypePointer?
    internal let valueType:TypePointer?
    
    public init(atAddress:Proton.Address,keyType:TypePointer?,valueType:TypePointer?)
        {
        self.keyType = keyType
        self.valueType = valueType
        self.keyPointer = addressAtAddress(atAddress)
        self.valuePointer = addressAtAddress(atAddress + 1)
        }
    }
