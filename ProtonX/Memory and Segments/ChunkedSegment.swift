//
//  ChunkedSegment.swift
//  ProtonX
//
//  Created by Vincent Coetzee on 2020/02/23.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class ChunkedSegment:MemorySegment
    {
    public override func allocate(byteCount count:Proton.ByteCount,slotCount:inout Proton.SlotCount) -> Proton.Address
        {
        self.lock.lock()
        defer
            {
            self.lock.unlock()
            }
        // round the byte count up to the nearest word count
        let wordSize = MemoryLayout<Word>.size
        let byteCount = Proton.ByteCount(Proton.SlotCount(count) + 1)
        let address = self.nextAddress
        let alignedCount = byteCount.aligned(to: wordSize) + Proton.SlotCount(1)
        slotCount = Proton.SlotCount(alignedCount)
        memset(UnsafeMutableRawPointer(bitPattern: Int(Int64(bitPattern: address))),0,alignedCount.count)
        self.nextAddress += alignedCount
        self.highwaterMark  = self.nextAddress > self.highwaterMark ? self.nextAddress : self.highwaterMark
        return(address)
        }
        
           
    public override func allocateEmptyType() -> TypePointer
        {
        let pointer = TypePointer(self.allocate(slotCount: TypePointer.totalSlotCount))
        pointer.isMarked = true
        pointer.valueType = .typeType
        pointer.hasExtraSlotsAtEnd = false
        pointer.typePointer = Memory.kTypeType
        pointer.segment = self
        Log.log("ALLOCATED EMPTY TYPE AT \(pointer.hexString) TO \(self.highwaterMark.hexString)")
        return(pointer)
        }
        
    public override func allocateEmptyPackage() -> PackagePointer
        {
        let pointer = PackagePointer(self.allocate(slotCount: PackagePointer.totalSlotCount))
        pointer.isMarked = true
        pointer.valueType = .package
        pointer.hasExtraSlotsAtEnd = false
        pointer.packagePointer = nil
        pointer.typePointer = Memory.kTypePackage
        pointer.segment = self
        pointer.contentDictionaryPointer = self.allocateDictionary(chunkFactor: 1024)
        Log.log("ALLOCATED EMPTY PACKAGE AT \(pointer.hexString) TO \(self.highwaterMark.hexString)")
        return(pointer)
        }
        
    public override func allocateType(named:String) -> TypePointer
        {
        let pointer = TypePointer(self.allocate(slotCount: TypePointer.totalSlotCount))
        pointer.name = named
        pointer.isMarked = true
        pointer.valueType = .typeType
        pointer.hasExtraSlotsAtEnd = false
        pointer.typePointer = Memory.kTypeType
        pointer.segment = self
        Log.log("ALLOCATED TYPE(\(named)) AT \(pointer.hexString)")
        return(pointer)
        }
        
        
//    public override func allocateSeam(named:String) -> SeamPointer
//        {
//        let pointer = TypePointer(self.allocate(slotCount: SeamPointer.totalSlotCount))
//        pointer.name = named
//        pointer.isMarked = true
//        pointer.valueType = .typeType
//        pointer.hasExtraSlotsAtEnd = false
//        pointer.typePointer = Memory.kTypeType
//        pointer.segment = self
//        Log.log("ALLOCATED TYPE(\(named)) AT \(pointer.hexString)")
//        return(pointer)
//        }
        
    public override func allocateCodeBlock(initialSizeInWords:Int) -> CodeBlockPointer
        {
        let pointer = CodeBlockPointer(self.allocate(slotCount: CodeBlockPointer.totalSlotCount))
        pointer.isMarked = true
        pointer.valueType = .typeType
        pointer.hasExtraSlotsAtEnd = false
        pointer.typePointer = Memory.kTypeType
        pointer.segment = self
        pointer.count = 0
        pointer.instructionArrayPointer = self.allocateArray(count: initialSizeInWords * 3, elementType: Memory.kTypeInstruction!)
        Log.log("ALLOCATED CODEBLOCK AT \(pointer.hexString)")
        return(pointer)
        }
        
    public override func allocateEnumeration(named:String,cases:[EnumerationCasePointer.EnumerationCase]) -> EnumerationPointer
        {
        let pointer = EnumerationPointer(self.allocate(slotCount: EnumerationPointer.totalSlotCount + cases.count))
        pointer.name = named
        pointer.isMarked = true
        pointer.valueType = .enumeration
        pointer.hasExtraSlotsAtEnd = false
        pointer.typePointer = Memory.kTypeEnumeration
        pointer.caseCount = cases.count
        pointer.segment = self
        var index = 0
        for aCase in cases
            {
            let casePointer = EnumerationCasePointer(aCase)
            setAddressAtIndexAtAddress(casePointer.address,EnumerationPointer.kEnumerationCasesIndex + index,pointer.address)
            index += 1
            }
        Log.log("ALLOCATED ENUMERATION(\(named)) AT \(pointer.hexString)")
        return(pointer)
        }
        
    public override func allocateEmptyScalarType(_ type:Proton.ScalarType) -> ScalarTypePointer
        {
        let pointer = ScalarTypePointer(self.allocate(slotCount: ScalarTypePointer.totalSlotCount))
        pointer.isMarked = true
        pointer.valueType = type.valueType
        pointer.hasExtraSlotsAtEnd = false
        pointer.typePointer = Memory.kTypeScalarType
        pointer.scalarType = .none
        pointer.segment = self
        Log.log("ALLOCATED EMPTY SCALAR TYPE AT \(pointer.hexString)")
        pointer.segment = self
        return(pointer)
        }
        
    public override func allocate(slotCount:Proton.SlotCount) -> Proton.Address
        {
        self.lock.lock()
        defer
            {
            self.lock.unlock()
            }
        let byteCount = Proton.ByteCount(slotCount)
        var newSlotCount = Proton.SlotCount(0)
        let pointer = self.allocate(byteCount: byteCount,slotCount: &newSlotCount)
        ObjectPointer(pointer).totalSlotCount = newSlotCount
        return(pointer)
        }
        
    public override func allocateArray(count:Int,elementType:TypePointer,elements:Array<Word> = []) -> ArrayPointer
        {
        let maximumCount = max(count,elements.count)
        let allocationSlotCount = maximumCount * 2
        let byteCount = Proton.ByteCount(ArrayPointer.totalSlotCount.count * elementType.objectStrideInBytes.count)
        var newSlotCount = Proton.SlotCount(0)
        let address = self.allocate(byteCount: byteCount,slotCount: &newSlotCount)
        let bufferPointer = WordBlockPointer(elementCount: allocationSlotCount,elementType: elementType)
        let array = ArrayPointer(address)
        array.isMarked = true
        array.arrayIndexType = ArrayPointer.ArrayIndexType.vector
        array.elementTypePointer = elementType
        array.valueType = .array
        array.hasExtraSlotsAtEnd = false
        array.totalSlotCount = newSlotCount
        array.typePointer = Memory.kTypeArray
        array.count = elements.count
        array.maximumCount = allocationSlotCount
        array.segment = self
        setAddressAtIndexAtAddress(bufferPointer.address,ArrayPointer.kArrayWordBufferPointerIndex,array.address)
        if !elements.isEmpty
            {
            var index = 0
            for element in elements
                {
                array[index] = element
                }
            index += 1
            }
        Log.log("ALLOCATED ARRAY AT \(array.hexString)")
        return(array)
        }
        
    public override func allocateBitSet(maximumBitCount:Int) -> BitSetPointer
        {
        let extraWordCount = (maximumBitCount / Word.bitWidth) + 1
        let slotCount = BitSetPointer.totalSlotCount
        let byteCount = Proton.ByteCount((slotCount + extraWordCount) * MemoryLayout<Word>.stride)
        var newSlotCount = Proton.SlotCount(0)
        let address = self.allocate(byteCount: byteCount,slotCount: &newSlotCount)
        let bitSet = BitSetPointer(address)
        bitSet.isMarked = true
        bitSet.valueType = .bitSet
        bitSet.hasExtraSlotsAtEnd = true
        bitSet.totalSlotCount = newSlotCount
        bitSet.typePointer = Memory.kTypeBitSet
        bitSet.bitCount = maximumBitCount
        bitSet.segment = self
        Log.log("ALLOCATED BITSET AT \(bitSet.hexString)")
        return(bitSet)
        }
        
    public override func allocateList(elements:Array<Proton.Address> = []) -> ListPointer
        {
        let byteCount = Proton.ByteCount(ListPointer.totalSlotCount)
        var newSlotCount = Proton.SlotCount(0)
        let address = self.allocate(byteCount: byteCount,slotCount: &newSlotCount)
        let list = ListPointer(address)
        list.isMarked = true
        list.valueType = .list
        list.hasExtraSlotsAtEnd = false
        list.totalSlotCount = newSlotCount
        list.typePointer = Memory.kTypeList
        list.count = elements.count
        list.segment = self
        list.firstNodePointer = nil
        list.lastNodePointer = nil
        if !elements.isEmpty
            {
            for element in elements
                {
                list.append(element)
                }
            }
        Log.log("ALLOCATED LIST AT \(list.hexString)")
        return(list)
        }
        
    public override func allocateTree() -> TreePointer
        {
        let byteCount = Proton.ByteCount(TreePointer.totalSlotCount)
        var newSlotCount = Proton.SlotCount(0)
        let address = self.allocate(byteCount: byteCount,slotCount: &newSlotCount)
        let tree = TreePointer(address)
        tree.isMarked = true
        tree.valueType = .tree
        tree.hasExtraSlotsAtEnd = false
        tree.totalSlotCount = newSlotCount
        tree.typePointer = Memory.kTypeTree
        tree.count = 0
        tree.segment = self
        tree.nodePointer = nil
        Log.log("ALLOCATED TREE AT \(tree.hexString)")
        return(tree)
        }
        
    public override func allocateTreeNode<K>(key:K,value:Value,left:Proton.Address = 0,right:Proton.Address = 0) -> TreeNodePointer where K:Key
        {
        let byteCount = Proton.ByteCount(TreeNodePointer.totalSlotCount)
        var newSlotCount = Proton.SlotCount(0)
        let address = self.allocate(byteCount: byteCount,slotCount: &newSlotCount)
        let node = TreeNodePointer(address)
        node.isMarked = true
        node.valueType = .treeNode
        node.hasExtraSlotsAtEnd = false
        node.totalSlotCount = newSlotCount
        node.typePointer = Memory.kTypeTreeNode
        node.segment = self
        node.store(key: key,atIndex: TreeNodePointer.kTreeNodeKeyIndex)
        node.store(value: value,atIndex: TreeNodePointer.kTreeNodeValueIndex)
        node.leftNodeAddress = left
        node.rightNodeAddress = right
        Log.log("ALLOCATED TREENODE AT \(node.hexString)")
        return(node)
        }
        
    public override func allocateListNode(element:Value,previous:Proton.Address = 0,next:Proton.Address = 0) -> ListNodePointer
        {
        let byteCount = Proton.ByteCount(ListNodePointer.totalSlotCount)
        var newSlotCount = Proton.SlotCount(0)
        let address = self.allocate(byteCount: byteCount,slotCount: &newSlotCount)
        let node = ListNodePointer(address)
        node.isMarked = true
        node.valueType = .listNode
        node.hasExtraSlotsAtEnd = false
        node.totalSlotCount = newSlotCount
        node.typePointer = Memory.kTypeListNode
        element.store(atAddress: address + ListNodePointer.kListElementPointerIndex)
        node.segment = self
        node.nextNodeAddress = next
        node.previousNodeAddress = next
        Log.log("ALLOCATED LISTNODE AT \(node.hexString)")
        return(node)
        }
        
    public override func allocateDictionary(chunkFactor:Int) -> DictionaryPointer
        {
        let byteCount = Proton.ByteCount((DictionaryPointer.totalSlotCount.count + chunkFactor) * MemoryLayout<Word>.stride)
        var newSlotCount = Proton.SlotCount(0)
        let address = self.allocate(byteCount: byteCount,slotCount: &newSlotCount)
        let dictionary = DictionaryPointer(address)
        dictionary.isMarked = true
        dictionary.valueType = .dictionary
        dictionary.hasExtraSlotsAtEnd = true
        dictionary.totalSlotCount = newSlotCount
        dictionary.typePointer = Memory.kTypeDictionary
        dictionary.count = 0
        dictionary.segment = self
        dictionary.chunkFactor = chunkFactor
        Log.log("ALLOCATED DICTIONARY AT \(dictionary.hexString)")
        return(dictionary)
        }
        
    public override func allocateStringConstant(_ contents:String,segment:MemorySegment = .managed) -> ImmutableStringPointer
        {
        let size = MemoryLayout<Word>.size
        let byteCount = ImmutableStringPointer.storageBytesRequired(for: contents)
        let count = (ImmutableStringPointer.totalSlotCount.count * size) + byteCount.count
        let unitCount = Proton.ByteCount(count.aligned(to: MemoryLayout<Word>.alignment))
        var newSlotCount = Proton.SlotCount(0)
        let pointer = ImmutableStringPointer(segment.allocate(byteCount: unitCount,slotCount: &newSlotCount))
        pointer.typePointer = Memory.kTypeString
        pointer.isMarked = true
        pointer.totalSlotCount = newSlotCount
        pointer.hasExtraSlotsAtEnd = true
        pointer.valueType = .string
        pointer.string = contents
        pointer.segment = self
        Log.log("ALLOCATED STRING CONSTANT AT \(pointer.hexString) TO \(self.highwaterMark.hexString) WITH \(newSlotCount) SLOTS \(byteCount) BYTES")
        self.dump(baseAddress: pointer.untaggedAddress, nextAddress: self.highwaterMark)
        return(pointer)
        }
    }
