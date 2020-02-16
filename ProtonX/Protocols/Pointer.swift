//
//  Pointer.swift
//  argon
//
//  Created by Vincent Coetzee on 03/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation

public protocol Pointer
    {
    var address:Proton.Address { get }
    init(_ address:Proton.Address)
    }
