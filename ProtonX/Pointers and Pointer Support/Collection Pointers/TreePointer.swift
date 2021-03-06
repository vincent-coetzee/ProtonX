//
//  TreePointer.swift
//  argon
//
//  Created by Vincent Coetzee on 31/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class TreePointer:CollectionPointer
    {
    public static let kTreeNodeIndex = SlotIndex.five

    public override class var totalSlotCount:Argon.SlotCount
        {
        return(6)
        }
        
    public var nodeAddress:Instruction.Address
        {
        get
            {
            return(wordAtIndexAtPointer(Self.kTreeNodeIndex,self.pointer))
            }
        set
            {
            setWordAtIndexAtPointer(newValue,Self.kTreeNodeIndex,self.pointer)
            }
        }
        
    public var nodePointer:TreeNodePointer?
        {
        get
            {
            let address = untaggedAddressAtIndexAtPointer(Self.kTreeNodeIndex,self.pointer)
            if address == 0
                {
                return(nil)
                }
            return(TreeNodePointer(address))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue?.pointer,Self.kTreeNodeIndex,self.pointer)
            }
        }
        
    @discardableResult
    public func remove<K>(key:K) -> Bool where K:Key
        {
        let node = self.nodePointer
        if node == nil
            {
            return(false)
            }
        else
            {
            if node!.remove(key: key,from: self)
                {
                self.count -= 1
                return(true)
                }
            return(false)
            }
        }
        
    public func keys() -> WordArray
        {
        let node = self.nodePointer
        if node == nil
            {
            return([])
            }
        else
            {
            return(node!.keys)
            }
        }
        
    public func values() -> WordArray
        {
        let node = self.nodePointer
        if node == nil
            {
            return([])
            }
        else
            {
            return(node!.values)
            }
        }
        
    public func associations() -> DoubleWordTupleArray
        {
        let node = self.nodePointer
        if node == nil
            {
            return([])
            }
        else
            {
            return(node!.associations)
            }
        }
        
    public func value<T>(forKey key:T) -> Instruction.Address? where T:Key
        {
        if let nodePointer = self.nodePointer
            {
            return(nodePointer.findValue(forKey: key))
            }
        else
            {
            return(nil)
            }
        }
        
    public func setValue<K>(_ value:Value,forKey:K) where K:Key
        {
        let newNode = self.segment.allocateTreeNode(key:forKey,value:value)
        if self.nodeAddress.isNull
            {
            self.nodeAddress = newNode.taggedAddress
            }
        else
            {
            self.nodePointer?.insert(node: newNode,into: self)
            }
        self.count += 1
        }
        
    public func print()
        {
        Swift.print("TREE @ \(self.hexString)")
        Swift.print("COUNT : \(self.count)")
        self.nodePointer?.print()
        }
    }
