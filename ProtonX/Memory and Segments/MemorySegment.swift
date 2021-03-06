//
//  MemorySegment.swift
//  argon
//
//  Created by Vincent Coetzee on 23/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory
    
public func print(_ line:Line)
    {
    Swift.print(line.string)
    }
    
public func print(_ string:String,count:Int)
    {
    Swift.print(String(repeating: string, count: count))
    }
    
public func print(_ elements:Line.Element...)
    {
    print(Line(elements))
    }
    
public class MemorySegment:Equatable
    {
    public class var managed:ManagedSegment
        {
        return(Memory.managedSegment)
        }
        
    public class var `static`:StaticSegment
        {
        return(Memory.staticSegment)
        }
        
    public static let BytesPerKilobyte = 1024
    public static let KilobytesPerMegabyte = 1024
    public static let MegabytesPerGigabyte = 1024
    public static let BytesPerMegabyte = 1024 * 1024
    
    public static let kLabelWidth:Int = 20
    
    public static func test()
        {
        Log.silent()
        Memory.initTypes()
        self.testThreads()
        print("STRIDE OF Int IS \(MemoryLayout<Int>.stride)")
        print("STRIDE OF Int64 IS \(MemoryLayout<Int64>.stride)")
        self.testInstructions()
        self.testBitFieldMaskSections()
        self.testTrees()
        self.testLists()
        self.testHammerDictionary()
        self.testValueHolders()
        self.testBasics()
        self.testAlignments()
        self.testInstructionBuffers()
        self.testStrings()
        self.testDictionaries()
        Log.log("INSTANCE TYPE NAME IS \(Memory.kTypeObject!.name)")
        let segment = Memory.staticSegment
        let stringPointer = ImmutableStringPointer("This is a string that has a few words in it but only one sentence.",segment: segment)
        assert(stringPointer.valueType == .string)
        Log.log("HEADER SLOT COUNT IS \(stringPointer.totalSlotCount)")
        assert(stringPointer.valueType == .string)
        assert(stringPointer.hasExtraSlotsAtEnd == true)
        Log.log("STRING IS '\(stringPointer.string)'")
        self.testArrays()
        self.testStringDictionaries()
        self.testTypes()
        segment.dump()
        }
        
    public static func testBitFieldMaskSections()
        {
        try! BitSetPointer.testSections()
        var bitSetPointer = Memory.staticSegment.allocateBitSet(maximumBitCount: 128)
        bitSetPointer.bits = "1111111111111111000000000000000011111111111111110000000000000000111111111111111100000000000000001111111111111111000000000000000011111111111111110000000000000000111111111111111100000000000000001111111111111111000000000000000011111111111111110000000000000000"
        var bits = BitSetPointer.BitsPointer(bitSetPointer)
        let mixedBits = bits[try! BitRange(from:12,to:20)]
        bitSetPointer = Memory.staticSegment.allocateBitSet(maximumBitCount: 64)
        bitSetPointer.bits = "1110111010101010101010101010101010101010101010101010101011101110"
        print(mixedBits.bitString)
        bits = BitSetPointer.BitsPointer(bitSetPointer)
        let extracted = bits[try! BitRange(from:0,to:8)]
        print(extracted.bitString)
        print(bitSetPointer.bits)
        }
        
    public static func testThreads()
        {
        let codeBlockAddress = self.makeCode()
        let memory = Memory()
        let thread = Thread(memory: memory)
        thread.execute(codeBlockAddress: codeBlockAddress)
        }
        
    public static func makeCode() -> Instruction.Address
        {
        let string1 = ImmutableStringPointer("Test String 1")
        let string2 = ImmutableStringPointer("Test String 2")
        let codeBlock = CodeBlock()
        let anInstruction:Instruction = ENTERInstruction(byteCount: 10 * 8)
        codeBlock.appendInstruction(anInstruction)
        codeBlock.appendInstruction(PUSHInstruction(address: string1.taggedAddress))
        codeBlock.appendInstruction(PUSHInstruction(address: string2.taggedAddress))
        codeBlock.appendInstruction(PUSHInstruction(register:.bp))
        codeBlock.appendInstruction(MOVInstruction(register1:.sp,register2:.bp))
        codeBlock.appendInstruction(ADDInstruction(register1:.sp,immediate:24,register3:.sp))
        codeBlock.appendInstruction(MOVInstruction(immediate:-10,register2:.r9))
        codeBlock.appendInstruction(ADDInstruction(register1:.r9,immediate:100,register3:.r10))
        codeBlock.appendInstruction(LEAVEInstruction(byteCount: 10 * 8))
        codeBlock.appendInstruction(RETInstruction())
        let pointer = Memory.staticSegment.allocateCodeBlock(initialSizeInWords: 128)
        pointer.appendInstructions(codeBlock)
        return(Instruction.Address(bitPattern: pointer.pointer!))
        }
        
    public static func testInstructions()
        {
        let string1 = ImmutableStringPointer("Test String 1")
        let string2 = ImmutableStringPointer("Test String 2")
        let codeBlock = CodeBlock()
        let anInstruction:Instruction = ENTERInstruction(byteCount: 10 * 8)
        codeBlock.appendInstruction(anInstruction)
        print("ENTER ENCODED = 0x\(anInstruction.encoded.instruction.hexString)")
        codeBlock.appendInstruction(PUSHInstruction(address: string1.taggedAddress))
        codeBlock.appendInstruction(PUSHInstruction(address: string2.taggedAddress))
        codeBlock.appendInstruction(PUSHInstruction(register:.bp))
        codeBlock.appendInstruction(MOVInstruction(register1:.sp,register2:.bp))
        codeBlock.appendInstruction(ADDInstruction(register1:.sp,immediate:24,register3:.sp))
        codeBlock.appendInstruction(MOVInstruction(immediate:-10,register2:.r9))
        codeBlock.appendInstruction(ADDInstruction(register1:.r9,immediate:100,register3:.r10))
        codeBlock.appendInstruction(LEAVEInstruction(byteCount: 10 * 8))
        codeBlock.appendInstruction(RETInstruction())
        let pointer = Memory.staticSegment.allocateCodeBlock(initialSizeInWords: 128)
        pointer.appendInstructions(codeBlock)
        let newPointer = CodeBlockPointer(pointer.pointer)
        assert(newPointer.count == pointer.count)
        for instruction in newPointer.instructions
            {
            print(instruction.displayString)
            }
        }
        
    public static func testTrees()
        {
        let tree = Memory.staticSegment.allocateTree()
        let indices = EnglishWordSet.indexSet(withCount:1000)
        let sampleWords = EnglishWord.wordsAtIndices(inSet: indices)
        for word in sampleWords
            {
            tree.setValue(Argon.Integer(word.hashedValue),forKey: word)
            }
        Log.console()
        tree.print()
        Log.silent()
        let delta = sampleWords.count / 25
        for index in stride(from:0,to:sampleWords.count-1,by:delta)
            {
            let word = sampleWords.word(at:index)!
            let answer = tree.value(forKey: word)!
            assert(answer == word.hashedValue,"The fetched value was \(answer) and should have been \(word.hashedValue)")
            }
        for word in sampleWords
            {
            tree.remove(key: word)
            }
        for word in sampleWords
            {
            assert(tree.value(forKey: word) == nil,"The word '\(word)' should have been deleted fromm the tree, but is still there")
            }
        }
        
    public static func testLists()
        {
        let stringList = MemorySegment.managed.allocateList()
        var stringValues:[String] = []
        for _ in 0...200
            {
            let word = EnglishWord.random()
            stringList.append(word)
            stringValues.append(word)
            }
        Log.console()
        stringList.print()
        Log.silent()
        for value in stringValues
            {
            assert(stringList.contains(value),"List should contain value \(value) but does not")
            }
        let index = Int.random(in: 0...200)
        let selectedWord = stringValues[index]
        stringList.remove(selectedWord)
        assert(!stringList.contains(selectedWord),"List should not contain value \(selectedWord) but does")
        }
        
    public static func testBasics()
        {
        }
        
    public static func testValueHolders()
        {
        let int1 = ValueHolder(word: taggedInteger(10))
        let int2 = ValueHolder(word: taggedInteger(10))
        let int3 = ValueHolder(word: taggedInteger(47))
        assert(int1 == int2,"\(int1) should == \(int2)")
        assert(int1 != int3,"\(int1) should != \(int3)")
        let uint1 = ValueHolder(word: taggedUInteger(10))
        let uint2 = ValueHolder(word: taggedUInteger(10))
        let uint3 = ValueHolder(word: taggedUInteger(47))
        assert(uint1 == uint2,"\(uint1) should == \(uint2)")
        assert(uint1 != uint3,"\(uint1) should != \(uint3)")
        let float321 = ValueHolder(word: taggedFloat32(10))
        let float322 = ValueHolder(word: taggedFloat32(10))
        let float323 = ValueHolder(word: taggedFloat32(47))
        assert(float321 == float322,"\(float321) should == \(float322)")
        assert(float321 != float323,"\(float321) should != \(float323)")
//        let float641 = ValueHolder(taggedFloat64(10))
//        let float642 = ValueHolder(taggedFloat64(10))
//        let float643 = ValueHolder(taggedFloat64(47))
//        assert(float641 == float642,"\(float641) should == \(float642)")
//        assert(float641 != float643,"\(float641) should != \(float643)")
        let boolean1 = ValueHolder(word: taggedBoolean(true))
        let boolean2 = ValueHolder(word: taggedBoolean(true))
        let boolean3 = ValueHolder(word: taggedBoolean(false))
        assert(boolean1 == boolean2,"\(boolean1) should == \(boolean2)")
        assert(boolean1 != boolean3,"\(boolean1) should != \(boolean3)")
        let byte1 = ValueHolder(word: taggedByte(10))
        let byte2 = ValueHolder(word: taggedByte(10))
        let byte3 = ValueHolder(word: taggedByte(47))
        assert(byte1 == byte2,"\(byte1) should == \(byte2)")
        assert(byte1 != byte3,"\(byte1) should != \(byte3)")
        let string1 = ValueHolder(string: "This is ten")
        let string2 = ValueHolder(string: "This is ten")
        let string3 = ValueHolder(string: "This is not ten")
        assert(string1 == string2,"\(string1) should == \(string2)")
        assert(string1 != string3,"\(string1) should != \(string3)")
        let string4 = ValueHolder(object:ImmutableStringPointer("This is ten"))
        let string5 = ValueHolder(object:ImmutableStringPointer("This is ten"))
        let string6 = ValueHolder(object:ImmutableStringPointer("This is not ten"))
        assert(string4 == string5,"\(string4) should == \(string5)")
        assert(string4 == string1,"\(string4) should == \(string1)")
        assert(string4 != string6,"\(string4) should != \(string6)")
        assert(string1 != string6,"\(string1) should != \(string6)")
        }
        
    public static func testStrings()
        {
        let string1 = ImmutableStringPointer("This is a string of some length that has a fair number of letters and some special %$$^&&*%^ charecters and some 1284795950 digits", segment: .static)
        let string2 = ImmutableStringPointer(string1.pointer)
        assert(string1.string == string2.string)
        let string3 = ImmutableStringPointer("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",segment: .static)
        Log.log("STRING 3 COUNT = \(string3.count)")
        let string4 = ImmutableStringPointer("Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.",segment: .static)
        assert(string3.string == string4.string)
        assert(string1.string == "This is a string of some length that has a fair number of letters and some special %$$^&&*%^ charecters and some 1284795950 digits")
        assert(string2.string == string1.string)
        let string1Address = string1.taggedAddress
        let newPointer = ImmutableStringPointer(string1Address)
        assert(newPointer.string == string1.string)
        Log.log("===================================================================================\n\nSTRING TESTS PASSED\n\n===================================================================================")
        }
        
    public static func testTypes()
        {
        let seamType = SeamPointer("Seam",segment: .static)
        var index:SlotIndex = .object
        seamType.appendSlot(name: "name",type: Memory.kTypeString,flags: 0,index: index++,segment: .static)
        }
        
    public static func testInstructionBuffers()
        {
        let buffer = InstructionVector()
        buffer.append(NOPInstruction())
        }
        
    public static func testDictionaries()
        {
        let pointer = DictionaryPointer(chunkFactor: 1024,segment: .static)
        let keys = ["hello","gopodbye","new","first","3","98753635","good morning dave how are you today","end"]
        for index in 0..<keys.count
            {
            pointer.setValue(Word(index),forKey: keys[index])
            }
        for index in stride(from: keys.count-1,to:0,by: -1)
            {
            let value = pointer.value(forKey: keys[index])
            assert(value != nil,"Value was nil for key \(keys[index]) and should have been \(index)")
            }
        assert(pointer.value(forKey: "this is a load of rubbish") == nil,"The value for this keyt should have been nil and was not")
        MemorySegment.static.dump(baseAddress: pointer.untaggedAddress, nextAddress: pointer.untaggedAddress + 4096)
        let extraValues:[String:String] = ["A":"Aye","B":"Bee","C":"Cee","G":"Gee","K":"Kay"]
        let extraKeys = ["A","B","C","D","E","G","H","J","K","Q"]
        for key in extraKeys
            {
            let value = extraValues[key]
            pointer.setValue(value,forKey: key)
            }
        pointer.print()
        for key in extraKeys
            {
            let localValue = ValueHolder(string: extraValues[key])
            let storedValue = ValueHolder(word: pointer.value(forKey: key))
            assert(localValue == storedValue,"Key is \(key) value is \(localValue) and should be \(storedValue)")
            }
        }
        
    public static func testHammerDictionary()
        {
        let pointer = DictionaryPointer(chunkFactor: 2048,segment: .static)
        var totalTime:UInt64 = 0
        for index in 0...10_000
            {
            let key = String(format: "%012llX",index)
            let value = String("\(key.hashedValue)")
            totalTime += Timer.time
                {
                pointer.setValue(value,forKey: key)
                }
            }
        Log.console()
        Log.log("Added \(pointer.count) elements")
        Log.log("Average time to add \(totalTime / UInt64(pointer.count)) milliseconds")
        pointer.print()
        Log.silent()
        totalTime = 0
        for index in stride(from:10_000,to:0,by: -1)
            {
            let key = String(format: "%012llX",index)
            let targetValue = ValueHolder(string: String("\(key.hashedValue)"))
            totalTime += Timer.time
                {
                let actualValue = ValueHolder(word: pointer.value(forKey: key))
                assert(targetValue == actualValue,"For key \(key) target value \(targetValue) should equal actual value \(actualValue)")
                }
            }
        Log.console()
        Log.log("Looked up \(pointer.count) elements")
        Log.log("Average time to lookup \(totalTime / UInt64(pointer.count)) milliseconds")
        }
        
    public static func testStringDictionaries()
        {
//        let dict = DictionaryPointer(count: 128, keyType: Memory.kTypeString!, valueType: Memory.kTypeString!, keyIsWordSize: false, valueIsWordSize: false, segment: .managed)
//        let words = ["hello","vincent","123","aleph","zeta","beta","growth","hedonsitically right as hell","sustainable","perfect","elementally sound","0000"]
//        for index in 0..<words.count
//            {
//            dict[words[index]] = Instruction.Address(index)
//            }
//        var index:Word = 0
//        for word in words
//            {
//            let value = dict[word]
//            assert((value as! Word) == index)
//            index += 1
//            }
        }
        
    public static func testAlignments()
        {
        let value1 = 1600
        let value1Aligned2 = value1.aligned(to: 2)
        let value1Aligned4 = value1.aligned(to: 4)
        let value1Aligned8 = value1.aligned(to: 8)
        Log.log("VALUE1(\(value1) ALIGNED TO 2: \(value1Aligned2) 4: \(value1Aligned4) 8: \(value1Aligned8)")
        let value2 = 2100
        let value2Aligned2 = value2.aligned(to: 2)
        let value2Aligned4 = value2.aligned(to: 4)
        let value2Aligned8 = value2.aligned(to: 8)
        Log.log("VALUE2(\(value2) ALIGNED TO 2: \(value2Aligned2) 4: \(value2Aligned4) 8: \(value2Aligned8)")
        let value3 = 1601
        let value3Aligned2 = value3.aligned(to: 2)
        let value3Aligned4 = value3.aligned(to: 4)
        let value3Aligned8 = value3.aligned(to: 8)
        Log.log("VALUE3(\(value3) ALIGNED TO 2: \(value3Aligned2) 4: \(value3Aligned4) 8: \(value3Aligned8)")
        }
        
    public static func testArrays()
        {
        let elements:Array<Word> = [0,1,2,3,4]
        let array = Memory.staticSegment.allocateArray(count: 48,elementType: Memory.kTypeUInteger!,elements: elements)
        Log.log("ARRAY COUNT IS \(array.count)")
        Log.log("ARRAY ALLOCATED COUNT IS \(array.maximumCount)")
        Log.log("ARRAY HEADER TYPE IS \(array.valueType)")
        Log.log("ARRAY HEADER SLOT COUNT IS \(array.totalSlotCount)")
        Log.log("ARRAY ELEMENT[2] = \(array[2])")
        array.append(5)
        assert(array.count == 6)
        for index in 0..<array.count
            {
            Log.log("ARRAY[\(index)] = \(array[index])")
            }
        for index in 0...(array.maximumCount + 5)
            {
            if index == array.maximumCount - 1
                {
                Log.log("halt")
                }
            array.append(Word(index) + 6)
            assert(array.count == 7 + index)
            }
        Log.log("ARRAY AFTER GROW COUNT IS \(array.count)")
        Log.log("ARRAY AFTER GROW ALLOCATED COUNT IS \(array.maximumCount)")
        for index in 0..<array.count
            {
            Log.log("ARRAY[\(index)] = \(array[index])")
            }
        }
        
    public class var zero:MemorySegment
        {
        return(Self())
        }
    
    public static func ==(lhs:MemorySegment,rhs:MemorySegment) -> Bool
        {
        if lhs.baseAddress != rhs.baseAddress
            {
            return(false)
            }
        if lhs.nextAddress != rhs.nextAddress
            {
            return(false)
            }
        if lhs.sizeInBytes != rhs.sizeInBytes
            {
            return(false)
            }
        if lhs.pointer != rhs.pointer
            {
            return(false)
            }
        return(true)
        }
        
    public enum Identifier:Int,Equatable
        {
        case none = 0
        case code = 1
        case data = 2
        case `static` = 3
        case stack = 4
        case managed = 5
        }
    
    public var isZeroSegment:Bool
        {
        return(self.sizeInBytes == 0 && self.baseAddress == 0 && self.nextAddress == 0)
        }
        
    public var identifier:Identifier
        {
        return(.none)
        }
        
    private let baseAddress:Word
    private let topAddress:Word
    internal var nextAddress:Word
    internal let sizeInBytes:Word
    private let pointer:UnsafeMutableRawPointer
    public let index = Argon.nextIndex
    private let roundToPageSize = true
    public private(set) var highwaterMark:Word
    
    public init(sizeInMegabytes:Int)
        {
        self.sizeInBytes = Word(sizeInMegabytes * 1024 * 1024)
        self.pointer = UnsafeMutableRawPointer.allocate(byteCount: Int(self.sizeInBytes), alignment: MemoryLayout<Word>.alignment)
        memset(self.pointer,0,Int(self.sizeInBytes))
        self.baseAddress = Word(Int(bitPattern: self.pointer))
        self.topAddress = self.baseAddress + self.sizeInBytes
        self.nextAddress = self.baseAddress
        self.highwaterMark = self.baseAddress
        Memory.register(memorySegment: self)
        }
        
    required public init()
        {
        self.baseAddress = 0
        self.topAddress = 0
        self.nextAddress = 0
        self.sizeInBytes = 0
        self.pointer = UnsafeMutableRawPointer.allocate(byteCount: 0, alignment: MemoryLayout<Word>.alignment)
        self.highwaterMark = 0
        }
        
    public func contains(address:Instruction.Address) -> Bool
        {
        return(self.baseAddress <= address && address <= self.topAddress)
        }
        
    public func allocate(byteCount count:Argon.ByteCount,slotCount:inout Argon.SlotCount) -> Argon.Pointer?
        {
        // round the byte count up to the nearest word count
        let wordSize = MemoryLayout<Word>.size
        let byteCount = Argon.ByteCount(Argon.SlotCount(count) + 1)
        let address = Argon.Pointer(bitPattern: self.nextAddress)
        let alignedCount = byteCount.aligned(to: wordSize) + Argon.SlotCount(1)
        slotCount = Argon.SlotCount(alignedCount)
        memset(address,0,alignedCount.count)
        self.nextAddress += alignedCount
        self.highwaterMark  = self.nextAddress > self.highwaterMark ? self.nextAddress : self.highwaterMark
        return(address)
        }
        
           
    public func allocateEmptyType() -> TypePointer
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
        
    public func allocateEmptyPackage() -> PackagePointer
        {
        let pointer = PackagePointer(self.allocate(slotCount: PackagePointer.totalSlotCount))
        pointer.isMarked = true
        pointer.valueType = .package
        pointer.hasExtraSlotsAtEnd = false
        pointer.packagePointer = nil
        pointer.typePointer = Memory.kTypePackage
        pointer.segment = self
        pointer.contentDictionaryPointer = self.allocateDictionary(chunkFactor: 1024)
        pointer.name = "Package"
        Log.log("ALLOCATED EMPTY PACKAGE AT \(pointer.hexString) TO \(self.highwaterMark.hexString)")
        return(pointer)
        }
        
    public func allocateType(named:String) -> TypePointer
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
        
    public func allocateCodeBlock(initialSizeInWords:Int) -> CodeBlockPointer
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
        
    public func allocateEnumeration(named:String,cases:[EnumerationCasePointer.EnumerationCase]) -> Argon.Pointer?
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
            setObjectPointerAtIndexAtPointer(casePointer.pointer,EnumerationPointer.kEnumerationCasesIndex + index,pointer.pointer)
            index += 1
            }
        Log.log("ALLOCATED ENUMERATION(\(named)) AT \(pointer.hexString)")
        return(pointer.pointer)
        }
        
    public func allocateEmptyScalarType(_ type:Argon.ScalarType) -> ScalarTypePointer
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
        
    public func allocate(slotCount:Argon.SlotCount) -> Argon.Pointer?
        {
        let byteCount = Argon.ByteCount(slotCount)
        var newSlotCount = Argon.SlotCount(0)
        let pointer = self.allocate(byteCount: byteCount,slotCount: &newSlotCount)
        ObjectPointer(pointer).totalSlotCount = newSlotCount
        return(pointer)
        }
        
    public func allocateArray(count:Int,elementType:TypePointer,elements:Array<Word> = []) -> ArrayPointer
        {
        let maximumCount = max(count,elements.count)
        let allocationSlotCount = maximumCount * 2
        let byteCount = Argon.ByteCount(ArrayPointer.totalSlotCount.count * elementType.objectStrideInBytes.count)
        var newSlotCount = Argon.SlotCount(0)
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
        tagAndSetPointerAtIndexAtPointer(bufferPointer.pointer,ArrayPointer.kArrayWordBufferPointerIndex,array.pointer)
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
        
    public func allocateBitSet(maximumBitCount:Int) -> BitSetPointer
        {
        let extraWordCount = (maximumBitCount / Word.bitWidth) + 1
        let slotCount = BitSetPointer.totalSlotCount
        let byteCount = Argon.ByteCount((slotCount + extraWordCount) * MemoryLayout<Word>.stride)
        var newSlotCount = Argon.SlotCount(0)
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
        
    public func allocateList(elements:Array<Instruction.Address> = []) -> ListPointer
        {
        let byteCount = Argon.ByteCount(ListPointer.totalSlotCount)
        var newSlotCount = Argon.SlotCount(0)
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
        
    public func allocateTree() -> TreePointer
        {
        let byteCount = Argon.ByteCount(TreePointer.totalSlotCount)
        var newSlotCount = Argon.SlotCount(0)
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
        
    public func allocateTreeNode<K>(key:K,value:Value,left:Instruction.Address = 0,right:Instruction.Address = 0) -> TreeNodePointer where K:Key
        {
        let byteCount = Argon.ByteCount(TreeNodePointer.totalSlotCount)
        var newSlotCount = Argon.SlotCount(0)
        let address = self.allocate(byteCount: byteCount,slotCount: &newSlotCount)
        let node = TreeNodePointer(address)
        node.isMarked = true
        node.valueType = .listNode
        node.hasExtraSlotsAtEnd = false
        node.totalSlotCount = newSlotCount
        node.typePointer = Memory.kTypeListNode
        node.segment = self
        node.store(key: key,atIndex: TreeNodePointer.kTreeNodeKeyIndex)
        node.store(value: value,atIndex: TreeNodePointer.kTreeNodeValueIndex)
        node.leftNodeAddress = left
        node.rightNodeAddress = right
        Log.log("ALLOCATED TREENODE AT \(node.hexString)")
        return(node)
        }
        
    public func allocateListNode(element:Value,previous:Instruction.Address = 0,next:Instruction.Address = 0) -> ListNodePointer
        {
        let byteCount = Argon.ByteCount(ListNodePointer.totalSlotCount)
        var newSlotCount = Argon.SlotCount(0)
        let address = self.allocate(byteCount: byteCount,slotCount: &newSlotCount)
        let node = ListNodePointer(address)
        node.isMarked = true
        node.valueType = .listNode
        node.hasExtraSlotsAtEnd = false
        node.totalSlotCount = newSlotCount
        node.typePointer = Memory.kTypeListNode
        element.store(atPointer: Argon.Pointer(address)! + ListNodePointer.kListElementPointerIndex)
        node.segment = self
        node.nextNodeAddress = next
        node.previousNodeAddress = next
        Log.log("ALLOCATED LISTNODE AT \(node.hexString)")
        return(node)
        }
        
    public func allocateDictionary(chunkFactor:Int) -> DictionaryPointer
        {
        let byteCount = Argon.ByteCount((DictionaryPointer.totalSlotCount.count + chunkFactor) * MemoryLayout<Word>.stride)
        var newSlotCount = Argon.SlotCount(0)
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
        
    public func allocateStringConstant(_ contents:String,segment:MemorySegment = .managed) -> Argon.Pointer?
        {
        let size = MemoryLayout<Word>.size
        let byteCount = ImmutableStringPointer.storageBytesRequired(for: contents)
        let count = (ImmutableStringPointer.totalSlotCount.count * size) + byteCount.count
        let unitCount = Argon.ByteCount(count.aligned(to: MemoryLayout<Word>.alignment))
        var newSlotCount = Argon.SlotCount(0)
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
        return(pointer.pointer)
        }
        
    public func dump()
        {
        self.dump(baseAddress: self.baseAddress,nextAddress: self.nextAddress)
        }
        
    public func dump(baseAddress:Word,nextAddress:Word)
        {
        var address = baseAddress
        while address < nextAddress
            {
            let word = wordAtAddress(address)
            if word.isHeader
                {
                let header = HeaderPointer(address)
                let slotCount = header.totalSlotCount
                Log.log()
                Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(header.headerWord.bitString)"),.space(1),.natural("HEADER(TYPE=\(header.valueType),SLOTS=\(header.totalSlotCount),EXTRA=\(header.hasExtraSlotsAtEnd),FORWARD=\(header.isForwarded))"))
                for _ in 2...slotCount.count
                    {
                    address++
                    let slotWord = wordAtAddress(address)
                    switch(slotWord.tag)
                        {
                        case Argon.kTagBitsObject:
                            let objectHeader = HeaderPointer(untaggedAddress(slotWord))
                            let type = objectHeader.valueType
                            let stringValue = type == .string ? "\"" + ImmutableStringPointer(untaggedAddress(slotWord)).string + "\"" : ""
                            Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(objectHeader.headerWord.bitString)"),.space(1),.natural("POINTER TO \(type) \(stringValue)"))
                        case Argon.kTagBitsInteger:
                            Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("SIGNED(\(Int64(bitPattern: slotWord)))"))
                        case Argon.kTagBitsUInteger:
                            Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("SIGNED(\(Int64(bitPattern: slotWord)))"))
//                        case Argon.kTagBitsUnsigned:
//                            Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("UNSIGNED(\(slotWord))"))
//                        case Argon.kTagBitsCharacter:
//                            let character = Unicode.Scalar(UInt16(untaggedWord(slotWord)))
//                            let string = String(character!)
//                            Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("CHARACTER(\(string))"))
                        case Argon.kTagBitsByte:
                            let byte = UInt8(slotWord)
                            Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("BYTE(\(byte))"))
                        case Argon.kTagBitsBoolean:
                            let boolean = slotWord == 1
                            Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("BOOLEAN(\(boolean))"))
                        case Argon.kTagBitsFloat32:
                            let float = Float(bitPattern: slotWord)
                            Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("FLOAT32(\(float))"))
                        default:
                            Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"))
                        }
                    }
                address++
                }
            else
                {
                Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(word.bitString)"),.space(1),.natural("SIGNED(\(Int64(bitPattern: word)))"))
                address++
                }
            }
//            let header = HeaderPointer(address)
//            Log.log()
//            switch(header.valueType)
//                {
//                case .typeType:
//                    self.dumpInstance(at: &address)
//                case .string:
//                    self.dumpStringInstance(at: &address)
//                default:
//                    self.dumpInstance(at: &address)
//                }
//            }
        }
        
    public func dumpObjectContents(at address:inout Instruction.Address)
        {
        let header = HeaderPointer(Argon.Pointer(address))
        let slotCount = header.totalSlotCount
        address++
        for index in 1..<slotCount.count
            {
            self.dumpSlot(at: &address,index: index)
            }
        }
        
    private func dumpInstance(at address:inout Instruction.Address)
        {
        let header = HeaderPointer(Argon.Pointer(address))
        let type = TypePointer(untaggedAddress(wordAtIndexAtAddress(.one,address)))
        let typeName = type.name
        Log.log(.right("OBJECT(\(header.valueType)) ",Self.kLabelWidth),.natural(": 0x\(address.hexString) : "),.natural("SLOT-COUNT(\(header.totalSlotCount))"),.space(1),.natural("HAS-EXTRA-SLOTS(\(header.hasExtraSlotsAtEnd))"),.space(1),.natural("IS-FORWARDED(\(header.isForwarded))"),.space(1),.left(typeName,30))
        self.dumpObjectContents(at: &address)
        }
        
    private func dumpStringInstance(at address:inout Instruction.Address)
        {
        let headerWord = wordAtAddress(address)
        let header = Header(headerWord)
        Log.log(.right("HEADER(String) ",Self.kLabelWidth),.natural(": 0x\(address.hexString)[0000] "),.natural("SLOT-COUNT(\(header.totalSlotCount))"),.space(1),.natural("HAS-EXTRA-SLOTS(\(header.hasExtraSlotsAtEnd))"),.space(1),.natural("IS-FORWARDED(\(header.isForwarded))"))
        
//        Log.log(.right("STRING : ",Self.kLabelWidth),.natural("0x\(address.hexString) "),.index("",0,4),.left(" HEADER ",10),.natural("String"))
        address++
        let slotCount = header.totalSlotCount
        Log.log(.right("TYPE PTR ",Self.kLabelWidth),.natural(": 0x\(address.hexString)[0001] "),.natural(wordAtAddress(address).bitString),.space(1),.natural(" String"))
        address++
        let countWord = wordAtAddress(address)
        Log.log(.right("COUNT ",Self.kLabelWidth),.natural(": 0x\(address.hexString)[0002] "),.natural(countWord.bitString),.space(1),.natural(Argon.ScalarType.integer.valueText(for: countWord)))
        address++
        let maxCountWord = wordAtAddress(address)
        Log.log(.right("MAX COUNT ",Self.kLabelWidth),.natural(": 0x\(address.hexString)[0003] "),.natural(maxCountWord.bitString),.space(1),.natural(Argon.ScalarType.integer.valueText(for: maxCountWord)))
        address++
        var offset = 0
        for index in 0..<(slotCount.count - 4)
            {
            let bytesWord = wordAtAddress(address)
            let indexString = String(format: "[%04d]",index)
            Log.log(.right("BYTES[\(offset)] ",Self.kLabelWidth),.natural(": 0x\(address.hexString)\(indexString) "),.natural(bytesWord.bitString))
            offset += 8
            address++
            }
        }
        
    private func dumpSlot(at address:inout Instruction.Address,index:Int)
        {
        let indexString = String(format: "[%04d]",index)
        let word = wordAtAddress(untaggedAddress(address))
        if word.isNull
            {
            Log.log(.right(" ",Self.kLabelWidth),.natural(": 0x\(address.hexString)\(indexString) "),.natural(word.bitString),.space(1),.natural("NULL"))
            address++
            return
            }
        let header = Header(word)
        if header.tag == .object
            {
            let valueType = ObjectPointer(untaggedPointerAtAddress(address)).valueType
            if valueType == .string
                {
                Log.log(.right("STRING PTR ",Self.kLabelWidth),.natural(": 0x\(address.hexString)\(indexString) "),.natural(word.bitString),.space(1),.left(address.addressedString,30))
                }
            else if valueType == .custom
                {
                Log.log(.right("OBJECT PTR ",Self.kLabelWidth),.natural(": 0x\(address.hexString)\(indexString)  "),.natural(word.bitString),.space(1),.left(address.addressedInstanceTypeName,30))
                }
            else if valueType == .typeType
                {
                Log.log(.right("TYPE PTR ",Self.kLabelWidth),.natural(": 0x\(address.hexString)\(indexString)  "),.natural(word.bitString),.space(1),.left(address.addressedTypeName,30))
                }
            else if valueType == .object
                {
                Log.log(.right("OBJECT PTR ",Self.kLabelWidth),.natural(": 0x\(address.hexString)\(indexString)  "),.natural(word.bitString),.space(1),.left(address.addressedTypeName,30))
                }
            else
                {
                fatalError("Unsupported tag type \(header.tag) \(header.valueType)")
                }
            }
        else
            {
            let rawTag = header.tag
            let tag = "\(rawTag)"
            Log.log(.right("\(tag.uppercased()) ",Self.kLabelWidth),.natural(": 0x\(address.hexString) : "),.natural(word.bitString),.space(1),.natural(Argon.ScalarType(rawTag).valueText(for: word)))
            }
        address++
        }
    }

