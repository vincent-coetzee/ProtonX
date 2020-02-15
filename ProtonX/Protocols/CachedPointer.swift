//
//  CachedPointer.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 03/02/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation

public protocol CachedPointer
    {
    var taggedAddress:Argon.Address { get }
    init(_ address:Argon.Address)
    }
