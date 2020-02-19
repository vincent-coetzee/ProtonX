//
//  EnumeratedArray.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/17.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public struct EnumeratedArray<Index,Element>:ExpressibleByArrayLiteral  where Index:RawRepresentable,Index.RawValue == Int,Index:CaseIterable
    {
    public typealias ArrayLiteralElement = Element
    
    internal var elements:[Element] = []
    
    public init(arrayLiteral elements: Element...)
        {
        self.elements = elements
        }
    
    public subscript(_ index:Index) -> Element
        {
        get
            {
            return(self.elements[Int(index.rawValue)])
            }
        set
            {
            self.elements[Int(index.rawValue)] = newValue
            }
        }
    }
