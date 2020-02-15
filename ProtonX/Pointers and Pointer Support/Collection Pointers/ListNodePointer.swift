//
//  ListNodePointer.swift
//  argon
//
//  Created by Vincent Coetzee on 31/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class ListNodePointer:ObjectPointer
    {
    public static let kListNextNodePointerIndex = SlotIndex.two
    public static let kListPreviousNodePointerIndex = SlotIndex.three
    public static let kListElementPointerIndex = SlotIndex.four
        
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(5)
        }
        
    public var valueHolder:ValueHolder
        {
        return(ValueHolder(word: self.valueAddress))
        }
        
    public var valueAddress:Argon.Address
        {
        get
            {
            return(wordAtIndexAtAddress(Self.kListElementPointerIndex,self.address))
            }
        set
            {
            setWordAtIndexAtAddress(newValue,Self.kListElementPointerIndex,self.address)
            }
        }

    public var nextNodePointer:ListNodePointer?
        {
        get
            {
            let address = addressAtIndexAtAddress(Self.kListNextNodePointerIndex,self.address)
            if address == 0
                {
                return(nil)
                }
            return(ListNodePointer(address))
            }
        set
            {
            setAddressAtIndexAtAddress(newValue?.address ?? 0,Self.kListNextNodePointerIndex,self.address)
            }
        }
        
    public var previousNodePointer:ListNodePointer?
        {
        get
            {
            let address = addressAtIndexAtAddress(Self.kListPreviousNodePointerIndex,self.address)
            if address == 0
                {
                return(nil)
                }
            return(ListNodePointer(address))
            }
        set
            {
            setAddressAtIndexAtAddress(newValue?.address ?? 0,Self.kListPreviousNodePointerIndex,self.address)
            }
        }
        
    public var nextNodeAddress:Argon.Address
        {
        get
            {
            return(addressAtIndexAtAddress(Self.kListNextNodePointerIndex,self.address))
            }
        set
            {
            setAddressAtIndexAtAddress(newValue,Self.kListNextNodePointerIndex,self.address)
            }
        }
        
    public var previousNodeAddress:Argon.Address
        {
        get
            {
            return(addressAtIndexAtAddress(Self.kListPreviousNodePointerIndex,self.address))
            }
        set
            {setAddressAtIndexAtAddress(newValue,Self.kListPreviousNodePointerIndex,self.address)
            }
        }
        
    }
