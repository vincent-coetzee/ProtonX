//
//  Array+Extensions.swift
//  argon
//
//  Created by Vincent Coetzee on 31/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation

public typealias IndexArray = Array<Int>

extension Array
    {
    public static func randomIndices(countIn count: Range<Int>,indexIn index:Range<Int>) -> IndexArray
        {
        let number = Int.random(in: count)
        var indices:IndexArray = []
        for _ in 0..<number
            {
            indices.append(Int.random(in: index))
            }
        return(indices)
        }
        
    public subscript(_ indices:IndexArray) -> Array<Element>
        {
        var elements:Array<Element> = []
        for index in indices
            {
            elements.append(self[index])
            }
        return(elements)
        }
    }
