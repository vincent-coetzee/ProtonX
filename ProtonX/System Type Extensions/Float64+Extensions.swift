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
    public init(_ double:Double)
        {
        self.init()
        self.float64 = double
        }
        
    public init(bitPattern word:Word)
        {
        self.init()
        self.float64 = Double(bitPattern: word)
        }
    }
