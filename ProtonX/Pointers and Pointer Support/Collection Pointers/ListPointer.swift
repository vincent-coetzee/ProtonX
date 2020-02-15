//
//  ListTypePointer.swift
//  argon
//
//  Created by Vincent Coetzee on 03/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class ListPointer:CollectionPointer
    {
    public static let kListFirstNodePointerIndex = SlotIndex.five
    public static let kListLastNodePointerIndex = SlotIndex.six
        
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(7)
        }
        
    public var firstElementAddress:Argon.Address
        {
        get
            {
            let address = addressAtIndexAtAddress(Self.kListFirstNodePointerIndex,self.address)
            if address == 0
                {
                return(0)
                }
            return(ListNodePointer(address).valueAddress)
            }
        set
            {
            let address = addressAtIndexAtAddress(Self.kListFirstNodePointerIndex,self.address)
            if address == 0
                {
                ListNodePointer(address).valueAddress = newValue
                }
            }
        }
        
    public var firstNodeAddress:Argon.Address
        {
        get
            {
            return(addressAtIndexAtAddress(Self.kListFirstNodePointerIndex,self.address))
            }
        set
            {
            setAddressAtIndexAtAddress(newValue,Self.kListFirstNodePointerIndex,self.address)
            }
        }
        
    public var lastNodeAddress:Argon.Address
        {
        get
            {
            return(addressAtIndexAtAddress(Self.kListLastNodePointerIndex,self.address))
            }
        set
            {
            setAddressAtIndexAtAddress(newValue,Self.kListLastNodePointerIndex,self.address)
            }
        }
        
    public var firstNodePointer:ListNodePointer?
        {
        get
            {
            let address = addressAtIndexAtAddress(Self.kListFirstNodePointerIndex,self.address)
            if address == 0
                {
                return(nil)
                }
            return(ListNodePointer(address))
            }
        set
            {
            setAddressAtIndexAtAddress(newValue?.address ?? 0,Self.kListFirstNodePointerIndex,self.address)
            }
        }
        
    public var lastNodePointer:ListNodePointer?
        {
        get
            {
            let address = addressAtIndexAtAddress(Self.kListLastNodePointerIndex,self.address)
            if address == 0
                {
                return(nil)
                }
            return(ListNodePointer(address))
            }
        set
            {
            setAddressAtIndexAtAddress(newValue?.address ?? 0,Self.kListLastNodePointerIndex,self.address)
            }
        }
        
    public var lastElementAddress:Argon.Address
        {
        get
            {
            let address = addressAtIndexAtAddress(Self.kListLastNodePointerIndex,self.address)
            if address == 0
                {
                return(0)
                }
            return(ListNodePointer(address).valueAddress)
            }
        set
            {
            let address = addressAtIndexAtAddress(Self.kListLastNodePointerIndex,self.address)
            if address == 0
                {
                ListNodePointer(address).valueAddress = newValue
                }
            }
        }
        
    private func node(withValue:Value) -> ListNodePointer?
        {
        let targetHolder = ValueHolder(value: withValue)
        var nodePointer:ListNodePointer? = self.firstNodePointer
        while nodePointer != nil && nodePointer != self.lastNodePointer && targetHolder != nodePointer!.valueHolder
            {
            nodePointer = nodePointer?.nextNodePointer
            }
        if nodePointer != nil  && targetHolder == nodePointer!.valueHolder
            {
            return(nodePointer)
            }
        return(nil)
        }
        
    public func remove(_ value:Value)
        {
        if let valueNodePointer = self.node(withValue: value)
            {
            valueNodePointer.previousNodePointer?.nextNodePointer = valueNodePointer.nextNodePointer
            valueNodePointer.nextNodePointer?.previousNodePointer = valueNodePointer.previousNodePointer
            if valueNodePointer == self.firstNodePointer
                {
                self.firstNodePointer = self.firstNodePointer?.nextNodePointer
                }
            if valueNodePointer == self.lastNodePointer
                {
                self.lastNodePointer = self.lastNodePointer?.previousNodePointer
                }
            self.count -= 1
            }
        }
        
    public func append(_ value:Value)
        {
        let node = self.segment.allocateListNode(element: value)
        if self.lastNodePointer == nil
            {
            self.lastNodePointer = node
            node.nextNodePointer = nil
            node.previousNodePointer = nil
            self.firstNodePointer = node
            }
        else
            {
            node.previousNodePointer = self.lastNodePointer
            self.lastNodePointer?.nextNodePointer = node
            self.lastNodePointer = node
            if self.firstNodePointer == nil
                {
                self.firstNodePointer = node
                }
            }
        self.count += 1
        }
        
    public func contains(_ value:Value) -> Bool
        {
        guard node(withValue: value) != nil else
            {
            return(false)
            }
        return(true)
        }
        
    public func insert(_ elementAddress:Value)
        {
        let node = self.segment.allocateListNode(element: elementAddress)
        if self.firstNodePointer == nil
            {
            self.firstNodePointer = node
            node.nextNodePointer = nil
            node.previousNodePointer = nil
            self.lastNodePointer = node
            }
        else
            {
            node.previousNodePointer = nil
            node.nextNodePointer = self.firstNodePointer
            self.firstNodePointer = node
            node.nextNodePointer?.previousNodePointer = node
            if self.lastNodePointer == nil
                {
                self.lastNodePointer = node
                }
            }
        self.count += 1
        }
        
    public func print()
        {
        Log.console()
        Log.log("LIST @ 0x\(self.address.hexString)")
        Log.log("COUNT : \(self.count)")
        var node:ListNodePointer? = self.firstNodePointer
        var index = 0
        while node != nil
            {
            let holder = node!.valueHolder
            Log.log(.rightInteger(index,10),.centre(":",3),.natural(holder.debugString))
            node = node?.nextNodePointer
            index += 1
            }
        Log.silent()
        }
    }

