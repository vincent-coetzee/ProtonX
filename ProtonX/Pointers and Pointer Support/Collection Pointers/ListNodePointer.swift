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
        
    public var valueAddress:Instruction.Address
        {
        get
            {
            return(wordAtIndexAtPointer(Self.kListElementPointerIndex,self.pointer))
            }
        set
            {
            setWordAtIndexAtPointer(newValue,Self.kListElementPointerIndex,self.pointer)
            }
        }

    public var nextNodePointer:ListNodePointer?
        {
        get
            {
            let address = untaggedAddressAtIndexAtPointer(Self.kListNextNodePointerIndex,self.pointer)
            if address == 0
                {
                return(nil)
                }
            return(ListNodePointer(address))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue?.pointer,Self.kListNextNodePointerIndex,self.pointer)
            }
        }
        
    public var previousNodePointer:ListNodePointer?
        {
        get
            {
            let address = untaggedAddressAtIndexAtPointer(Self.kListPreviousNodePointerIndex,self.pointer)
            if address == 0
                {
                return(nil)
                }
            return(ListNodePointer(address))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue?.pointer,Self.kListPreviousNodePointerIndex,self.pointer)
            }
        }
        
    public var nextNodeAddress:Instruction.Address
        {
        get
            {
            return(untaggedAddressAtIndexAtPointer(Self.kListNextNodePointerIndex,self.pointer))
            }
        set
            {
            tagAndSetAddressAtIndexAtPointer(newValue,Self.kListNextNodePointerIndex,self.pointer)
            }
        }
        
    public var previousNodeAddress:Instruction.Address
        {
        get
            {
            return(untaggedAddressAtIndexAtPointer(Self.kListPreviousNodePointerIndex,self.pointer))
            }
        set
            {
            tagAndSetAddressAtIndexAtPointer(newValue,Self.kListPreviousNodePointerIndex,self.pointer)
            }
        }
        
    }
