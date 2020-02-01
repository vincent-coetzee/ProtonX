//
//  NamedPointer.swift
//  argon
//
//  Created by Vincent Coetzee on 31/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation

public protocol NamedPointer
    {
    var name:String { get }
    var fullName:String { get }
    }
