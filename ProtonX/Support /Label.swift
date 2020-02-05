//
//  Label.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 03/02/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation

public class Label
    {
    private static var _labels:[Int:Label] = [:]
    
    public class func label(at:Int) -> Label?
        {
        return(self._labels[at])
        }
        
    private static var _nextLabelKey = 10_000
    
    public class func nextLabel() -> Label
        {
        let key = Self._nextLabelKey
        Self._nextLabelKey += 2
        return(Label(key: key))
        }
        
    public let key:Int
    
    public init(key:Int)
        {
        if Self._labels[key] != nil
            {
            fatalError("Attempt to create duplicate label \(key)")
            }
        self.key = key
        Self._labels[key] = self
        }
    }
