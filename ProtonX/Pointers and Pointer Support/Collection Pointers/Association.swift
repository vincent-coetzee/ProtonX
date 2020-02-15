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
    public static var strideInBytes:Argon.ByteCount
        {
        return(Argon.ByteCount(2*MemoryLayout<Word>.stride))
        }
        
    public static let stride = Word.stride * 2
    
    internal let keyPointer:Argon.Address
    internal let valuePointer:Argon.Address
    internal let keyType:TypePointer?
    internal let valueType:TypePointer?
    
    public init(atAddress:Argon.Address,keyType:TypePointer?,valueType:TypePointer?)
        {
        self.keyType = keyType
        self.valueType = valueType
        self.keyPointer = addressAtAddress(atAddress)
        self.valuePointer = addressAtAddress(atAddress + 1)
        }
    }
