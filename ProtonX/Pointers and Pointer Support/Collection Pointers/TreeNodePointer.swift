//
//  TreeNodePointer.swift
//  argon
//
//  Created by Vincent Coetzee on 31/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class TreeNodePointer:ObjectPointer
    {
    public static let kTreeNodeLeftNodeIndex = SlotIndex.two
    public static let kTreeNodeRightNodeIndex = SlotIndex.three
    public static let kTreeNodeParentNodeIndex = SlotIndex.four
    public static let kTreeNodeKeyIndex = SlotIndex.five
    public static let kTreeNodeValueIndex = SlotIndex.six
    
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(7)
        }
        
    private var cachedKeyHolder:ValueHolder?
    
    public var keyHolder:ValueHolder
        {
        get
            {
            if cachedKeyHolder == nil
                {
                cachedKeyHolder = ValueHolder(word: wordAtIndexAtPointer(Self.kTreeNodeKeyIndex,self.pointer))
                }
            return(cachedKeyHolder!)
            }
        set
            {
            guard let pointer = self.pointer else
                {
                return
                }
            var mutableValue:ValueHolder? = newValue
            mutableValue?.store(atPointer: pointer + Self.kTreeNodeKeyIndex)
            }
        }
        
    private var cachedValueHolder:ValueHolder?
    
    public var valueHolder:ValueHolder
        {
        get
            {
            if cachedValueHolder == nil
                {
                cachedValueHolder = ValueHolder(word: wordAtIndexAtPointer(Self.kTreeNodeValueIndex,self.pointer))
                }
            return(cachedValueHolder!)
            }
        set
            {
            guard let pointer = self.pointer else
                {
                return
                }
            var mutableValue:ValueHolder? = newValue
            mutableValue?.store(atPointer: pointer + Self.kTreeNodeValueIndex)
            }
        }
        
    public var keyAddress:Instruction.Address
        {
        get
            {
            return(wordAtIndexAtPointer(Self.kTreeNodeKeyIndex,self.pointer))
            }
        set
            {
            setWordAtIndexAtPointer(newValue,Self.kTreeNodeKeyIndex,self.pointer)
            }
        }

    public var valueAddress:Instruction.Address
        {
        get
            {
            return(wordAtIndexAtPointer(Self.kTreeNodeValueIndex,self.pointer))
            }
        set
            {
            setWordAtIndexAtPointer(newValue,Self.kTreeNodeValueIndex,self.pointer)
            }
        }
        
    public var leftNodeAddress:Instruction.Address
        {
        get
            {
            return(untaggedAddressAtIndexAtPointer(Self.kTreeNodeLeftNodeIndex,self.pointer))
            }
        set
            {
            tagAndSetAddressAtIndexAtPointer(newValue,Self.kTreeNodeLeftNodeIndex,self.pointer)
            }
        }
        
    public var parentNodeAddress:Instruction.Address
        {
        get
            {
            return(wordAtIndexAtPointer(Self.kTreeNodeParentNodeIndex,self.pointer))
            }
        set
            {
            setWordAtIndexAtPointer(newValue,Self.kTreeNodeParentNodeIndex,self.pointer)
            }
        }
        
    public var rightNodeAddress:Instruction.Address
        {
        get
            {
            return(untaggedAddressAtIndexAtPointer(Self.kTreeNodeRightNodeIndex,self.pointer))
            }
        set
            {
            tagAndSetAddressAtIndexAtPointer(newValue,Self.kTreeNodeRightNodeIndex,self.pointer)
            }
        }
        
    public var leftNodePointer:TreeNodePointer?
        {
        get
            {
            let address = RawMemory.untaggedAddress(self.leftNodeAddress)
            return(address == 0 ? nil : TreeNodePointer(address))
            }
        set
            {
            self.leftNodeAddress = taggedObject(newValue?.pointer)
            }
        }
        
    public var rightNodePointer:TreeNodePointer?
        {
        get
            {
            let address = RawMemory.untaggedAddress(self.rightNodeAddress)
            return(address == 0 ? nil : TreeNodePointer(address))
            }
        set
            {
            self.rightNodeAddress = taggedObject(newValue?.pointer)
            }
        }
        
    public var parentNodePointer:TreeNodePointer?
        {
        get
            {
            let address = RawMemory.untaggedAddress(self.parentNodeAddress)
            return(address == 0 ? nil : TreeNodePointer(address))
            }
        set
            {
            self.parentNodeAddress = taggedObject(newValue?.pointer)
            }
        }
        
    public var association:DoubleWordTuple
        {
        return((self.keyAddress,self.valueAddress))
        }
        
    public var keys:WordArray
        {
        return((self.leftNodePointer?.keys ?? WordArray()) + [self.keyAddress] + (self.rightNodePointer?.keys ?? WordArray()))
        }
        
    public var values:WordArray
        {
        return((self.leftNodePointer?.values ?? WordArray()) + [self.valueAddress] + (self.rightNodePointer?.values ?? WordArray()))
        }
        
    public var associations:DoubleWordTupleArray
        {
        return((self.leftNodePointer?.associations ?? DoubleWordTupleArray()) + [self.association] + (self.rightNodePointer?.associations ?? DoubleWordTupleArray()))
        }
    
    public var successor:TreeNodePointer
        {
        var node = Optional(self)
        if node?.rightNodePointer != nil
            {
            return(node!.minimum)
            }
        var currentNode = node?.parentNodePointer
        while currentNode != nil && self.taggedAddress == currentNode!.rightNodeAddress
            {
            node = currentNode
            currentNode = node?.parentNodePointer
            }
        return(currentNode!)
        }
        
    public var minimum:TreeNodePointer
        {
        var node = Optional(self)
        while node?.leftNodePointer != nil
            {
            node = node?.leftNodePointer
            }
        return(node!)
        }
        
    public func findValue<K>(forKey:K) -> Instruction.Address? where K:Key
        {
        return(self.findNode(forKey: forKey)?.valueAddress)
        }
        
    public func findNode<K>(forKey:K) -> TreeNodePointer? where K:Key
        {
        let keyHolder = ValueHolder(key: forKey)
        if keyHolder == self.keyHolder
            {
            return(self)
            }
        else if keyHolder < self.keyHolder
            {
            if let leftNode = self.leftNodePointer
                {
                return(leftNode.findNode(forKey: forKey))
                }
            else
                {
                return(nil)
                }
            }
        else
            {
            if let rightNode = self.rightNodePointer
                {
                return(rightNode.findNode(forKey: forKey))
                }
            else
                {
                return(nil)
                }
            }
        }
        
    public func remove<K>(key:K,from tree:TreePointer) -> Bool where K:Key
        {
        if let targetNode = self.findNode(forKey: key)
            {
            var currentNode:TreeNodePointer?
            if targetNode.leftNodePointer == nil || targetNode.rightNodePointer == nil
                {
                currentNode = targetNode
                }
            else
                {
                currentNode = targetNode.successor
                }
            var nextNode:TreeNodePointer?
            if currentNode?.leftNodePointer != nil
                {
                nextNode = currentNode?.leftNodePointer
                }
            else
                {
                nextNode = currentNode?.rightNodePointer
                }
            if nextNode != nil
                {
                nextNode?.parentNodePointer = currentNode?.parentNodePointer
                }
            if currentNode?.parentNodePointer == nil
                {
                tree.nodePointer = nextNode
                }
            else if ValueHolder(word: currentNode?.taggedAddress ?? 0) == ValueHolder(word: currentNode?.parentNodePointer?.leftNodePointer?.taggedAddress ?? 0)
                {
                currentNode?.parentNodePointer?.leftNodePointer = nextNode
                }
            else
                {
                currentNode?.parentNodePointer?.rightNodePointer = nextNode
                }
            if ValueHolder(word: currentNode?.taggedAddress ?? 0) != ValueHolder(word: targetNode.taggedAddress)
                {
                targetNode.keyAddress = currentNode!.keyAddress
                targetNode.valueAddress = currentNode!.valueAddress
                }
            return(true)
            }
        return(false)
        }
        
    public func insert(node:TreeNodePointer,into tree:TreePointer)
        {
        var parentNode:TreeNodePointer? = nil
        var currentNode:TreeNodePointer? = self
        while currentNode != nil
            {
            parentNode = currentNode
            if let thisNode = currentNode
                {
                if node.keyHolder < thisNode.keyHolder
                    {
                    currentNode = thisNode.leftNodePointer
                    }
                else
                    {
                    currentNode = thisNode.rightNodePointer
                    }
                }
            else
                {
                return
                }
            }
        node.parentNodePointer = parentNode
        if parentNode == nil
            {
            tree.nodePointer = node
            }
        else if node.keyHolder < parentNode!.keyHolder
            {
            parentNode!.leftNodePointer = node
            }
        else
            {
            parentNode!.rightNodePointer = node
            }
        }
        
    public func print()
        {
        self.leftNodePointer?.print()
        let keyHolder = ValueHolder(word: self.keyAddress)
        let valueHolder = ValueHolder(word: self.valueAddress)
        Swift.print("\tKEY   : \(keyHolder.debugString)")
        Swift.print("\tVALUE : \(valueHolder.debugString)")
        self.rightNodePointer?.print()
        }
    }
