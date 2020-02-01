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
    
    internal let keyPointer:Argon.Pointer
    internal let valuePointer:Argon.Pointer
    internal let keyType:TypePointer?
    internal let valueType:TypePointer?
    
    public init(atPointer:Argon.Pointer,keyType:TypePointer?,valueType:TypePointer?)
        {
        self.keyType = keyType
        self.valueType = valueType
        self.keyPointer = pointerAtPointer(atPointer)
        self.valuePointer = pointerAtPointer(atPointer + 1)
        }
    }
