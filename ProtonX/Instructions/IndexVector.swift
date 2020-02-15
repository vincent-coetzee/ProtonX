//
//  IndexVector.swift
//  argon
//
//  Created by Vincent Coetzee on 31/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation

public struct IndexVector
    {
    private var elements:[Argon.Index] = []
    
    public var count:Int
        {
        return(self.elements.count)
        }
        
    public var isEmpty:Bool
        {
        return(self.elements.count == 0)
        }
        
    public var hasSingleIndex:Bool
        {
        return(self.elements.count == 1)
        }
        
    public var first:Argon.Index
        {
        return(self.elements.first!)
        }
        
    public init(_ elements:[Argon.Index])
        {
        self.elements = elements
        }
        
    public func withoutFirst() -> IndexVector
        {
        return(IndexVector(Array(self.elements.dropFirst())))
        }
    }
