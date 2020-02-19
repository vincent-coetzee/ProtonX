//
//  Float+Extensions.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/17.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

extension Float
    {
    public var taggedBits:Word
        {
        return(Word(self.bitPattern & 4294967295) | (Proton.kTagBitsFloat32 << Proton.kTagBitsShift))
        }
        
    public init(taggedBits:Word)
        {
        self.init(bitPattern: UInt32(taggedBits & 4294967295))
        }
    }
