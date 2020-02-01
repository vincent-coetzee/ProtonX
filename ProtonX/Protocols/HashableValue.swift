//
//  Hashed.swift
//  argon
//
//  Created by Vincent Coetzee on 27/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public protocol HashableValue
    {
    var hashedValue:Int { get }
    }
