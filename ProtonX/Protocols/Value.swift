//
//  Value.swift
//  argon
//
//  Created by Vincent Coetzee on 27/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public protocol Value
    {
    var taggedAddress:Argon.Address { get }
//    var typePointer:TypePointer? { get }
//    var valueStride:Int { get }
    func asWord() -> Word
    func store(atAddress:Argon.Address)
    func equals(_ value:Value) -> Bool
    func isLessThan(_ value:Value) -> Bool
    }
