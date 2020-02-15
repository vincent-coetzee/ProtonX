//
//  SlotValue.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 03/02/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class SlotValue<T> where T:CachedPointer
    {
    public var source:ObjectPointer
        {
        get
            {
            return(self._source!)
            }
        set
            {
            self._source = newValue
            }
        }
        
    public var value:T
        {
        get
            {
            if let aValue = self.cachedValue
                {
                return(aValue)
                }
            self.cachedValue = T.init(addressAtIndexAtAddress(self.index,self._source!.address))
            return(self.cachedValue!)
            }
        set
            {
            self.cachedValue = newValue
            setAddressAtIndexAtAddress(newValue.taggedAddress,self.index,self._source!.address)
            }
        }
        
    private var cachedValue:T?
    private let index:SlotIndex
    private var _source:ObjectPointer?
    
    public init(index:SlotIndex)
        {
        self.index = index
        }
    }

public class StringSlotValue
    {
    public init(index:SlotIndex)
        {
    
        }
    }
