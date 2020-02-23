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
        self.testDoubles()
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
        
    public static func testDoubles()
        {
        Log.console()
        let double1 = Double(5632876.5634252897978)
        Log.log("DOUBLE1 IS \(double1)")
        let taggedDouble1:Word = double1.bitPattern
        Log.log("DOUBLE1 BITPATTERN IS   \(taggedDouble1.bitString)")
        Log.log("DOUBLE1 EXPONENT IS     \(Word(double1.exponentBitPattern).bitString)")
        Log.log("DOUBLE1 SIGNIFICAND IS  \(Word(double1.significandBitPattern).bitString)")
        Log.log("DOUBLE RADIX IS         \(Double.radix)")
        Log.log("DOUBLE EXP BITWIDTH IS  \(Double.exponentBitCount)")
        Log.log("DOUBLE SIG BITWIDTH IS  \(Double.significandBitCount)")
        let double2 = -double1
        Log.log("-DOUBLE1 IS \(double2)")
        let taggedDouble2:Word = double2.bitPattern
        Log.log("-DOUBLE1 BITPATTERN IS  \(taggedDouble2.bitString)")
        Log.log("-DOUBLE1 EXPONENT IS    \(Word(double2.exponentBitPattern).bitString)")
        Log.log("-DOUBLE1 SIGNIFICAND IS \(Word(double2.significand.bitPattern).bitString)")
        let signMask:Word = 9223372036854775808
        let sign = taggedDouble2 & signMask
        let newDouble = ((taggedDouble2 >> 4) & Proton.kTagBitsZeroMask) | (Proton.kTagBitsFloat64 << Proton.kTagBitsShift) | sign
        Log.log("-DOUBLE1 TAGGED BITS IS \(newDouble.bitString)")
        let finalSign = newDouble & signMask
        let finalDouble = Double(bitPattern: ((newDouble & Proton.kTagBitsZeroMask) << 4) | finalSign)
        Log.log("-DOUBLE1 UNTAGGED IS    \(finalDouble)")
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
        do
            {
            let codeBlockAddress = self.makeCode()
            let memory = Memory()
            let thread = Thread(memory: memory)
            try thread.execute(codeBlockAddress: codeBlockAddress)
            }
        catch(let error)
            {
            print(error)
            }
        }
        
    public static func makeCode() -> Proton.Address
        {
        let string1 = ImmutableStringPointer("Test String 1")
        let string2 = ImmutableStringPointer("Test String 2")
        let codeBlock = CodeBlock()
        let anInstruction:Instruction = ENTERInstruction(byteCount: 10 * 8)
        codeBlock.appendInstruction(anInstruction)
        codeBlock.appendInstruction(PUSHInstruction(address: string1.taggedAddress))
        codeBlock.appendInstruction(PUSHInstruction(address: string2.taggedAddress))
        codeBlock.appendInstruction(PUSHInstruction(register:.fp))
        codeBlock.appendInstruction(MOVInstruction(register1:.sp,register2:.fp))
        codeBlock.appendInstruction(ADDInstruction(register1:.sp,immediate:24,register3:.sp))
        codeBlock.appendInstruction(MOVInstruction(immediate:-10,register2:.r9))
        codeBlock.appendInstruction(ADDInstruction(register1:.r9,immediate:100,register3:.r10))
        codeBlock.appendInstruction(LEAVEInstruction(byteCount: 10 * 8))
        codeBlock.appendInstruction(RETInstruction())
        let pointer = Memory.staticSegment.allocateCodeBlock(initialSizeInWords: 128)
        pointer.appendInstructions(codeBlock)
        return(pointer.address)
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
        codeBlock.appendInstruction(PUSHInstruction(register:.fp))
        codeBlock.appendInstruction(MOVInstruction(register1:.sp,register2:.fp))
        codeBlock.appendInstruction(ADDInstruction(register1:.sp,immediate:24,register3:.sp))
        codeBlock.appendInstruction(MOVInstruction(immediate:-10,register2:.r9))
        codeBlock.appendInstruction(ADDInstruction(register1:.r9,immediate:100,register3:.r10))
        codeBlock.appendInstruction(LEAVEInstruction(byteCount: 10 * 8))
        codeBlock.appendInstruction(RETInstruction())
        let pointer = Memory.staticSegment.allocateCodeBlock(initialSizeInWords: 128)
        pointer.appendInstructions(codeBlock)
        let newPointer = CodeBlockPointer(pointer.address)
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
            tree.setValue(Proton.Integer(word.hashedValue),forKey: word)
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
        var missingWords = [String]()
        for _ in 0..<15
            {
            missingWords.append(EnglishWord.random())
            }
        for word in missingWords
            {
            assert(!stringList.contains(word),"List should not contain value \(word) but does")
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
        let string2 = ImmutableStringPointer(string1.address)
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
//            dict[words[index]] = Argon.Address(index)
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
            array.append(Word(index + 6))
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

    public var isZeroSegment:Bool
        {
        return(self.sizeInBytes == 0 && self.baseAddress == 0 && self.nextAddress == 0)
        }

    internal let baseAddress:Word
    internal let topAddress:Word
    internal var nextAddress:Word
    internal let sizeInBytes:Word
    internal let pointer:UnsafeMutableRawPointer
    public let index = Proton.nextIndex
    private let roundToPageSize = true
    internal var highwaterMark:Word
    internal var lock = RecursiveLock()
    
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
        
    public func contains(address:Proton.Address) -> Bool
        {
        return(self.baseAddress <= address && address <= self.topAddress)
        }
        
    public func allocate(byteCount count:Proton.ByteCount,slotCount:inout Proton.SlotCount) -> Proton.Address
        {
        fatalError("Should have been overriden in a subclass")
        }
        
           
    public func allocateEmptyType() -> TypePointer
        {
        fatalError("Should have been overriden in a subclass")
        }
        
    public func allocateEmptyPackage() -> PackagePointer
        {
        fatalError("Should have been overriden in a subclass")
        }
        
    public func allocateType(named:String) -> TypePointer
        {
        fatalError("Should have been overriden in a subclass")
        }
        
    public func allocateSeam(named:String) -> SeamPointer
        {
        fatalError("Should have been overriden in a subclass")
        }
        
    public func allocateCodeBlock(initialSizeInWords:Int) -> CodeBlockPointer
        {
        fatalError("Should have been overriden in a subclass")
        }
        
    public func allocateEnumeration(named:String,cases:[EnumerationCasePointer.EnumerationCase]) -> EnumerationPointer
        {
        fatalError("Should have been overriden in a subclass")
        }
        
    public func allocateEmptyScalarType(_ type:Proton.ScalarType) -> ScalarTypePointer
        {
        fatalError("Should have been overriden in a subclass")
        }
        
    public func allocate(slotCount:Proton.SlotCount) -> Proton.Address
        {
        fatalError("Should have been overriden in a subclass")
        }
        
    public func allocateArray(count:Int,elementType:TypePointer,elements:Array<Word> = []) -> ArrayPointer
        {
        fatalError("Should have been overriden in a subclass")
        }
        
    public func allocateBitSet(maximumBitCount:Int) -> BitSetPointer
        {
        fatalError("Should have been overriden in a subclass")
        }
        
    public func allocateList(elements:Array<Proton.Address> = []) -> ListPointer
        {
        fatalError("Should have been overriden in a subclass")
        }
        
    public func allocateTree() -> TreePointer
        {
        fatalError("Should have been overriden in a subclass")
        }
        
    public func allocateTreeNode<K>(key:K,value:Value,left:Proton.Address = 0,right:Proton.Address = 0) -> TreeNodePointer where K:Key
        {
        fatalError("Should have been overriden in a subclass")
        }
        
    public func allocateListNode(element:Value,previous:Proton.Address = 0,next:Proton.Address = 0) -> ListNodePointer
        {
        fatalError("Should have been overriden in a subclass")
        }
        
    public func allocateDictionary(chunkFactor:Int) -> DictionaryPointer
        {
        fatalError("Should have been overriden in a subclass")
        }
        
    public func allocateStringConstant(_ contents:String,segment:MemorySegment = .managed) -> ImmutableStringPointer
        {
        fatalError("Should have been overriden in a subclass")
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
                        case Proton.kTagBitsAddress:
                            let objectHeader = HeaderPointer(untaggedAddress(slotWord))
                            let type = objectHeader.valueType
                            let stringValue = type == .string ? "\"" + ImmutableStringPointer(untaggedAddress(slotWord)).string + "\"" : ""
                            Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(objectHeader.headerWord.bitString)"),.space(1),.natural("POINTER TO \(type) \(stringValue)"))
                        case Proton.kTagBitsInteger:
                            Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("INTEGER(\(Int64(bitPattern: slotWord)))"))
                        case Proton.kTagBitsByte:
                            let byte = UInt8(slotWord)
                            Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("BYTE(\(byte))"))
                        case Proton.kTagBitsBoolean:
                            let boolean = slotWord == 1
                            Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("BOOLEAN(\(boolean))"))
                        case Proton.kTagBitsFloat32:
                            let float = Float(taggedBits: slotWord)
                            Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("FLOAT32(\(float))"))
                        case Proton.kTagBitsFloat64:
                            let float = Double(taggedBits: slotWord)
                            Log.log(.natural("0x\(address.hexString):"),.space(1),.natural("\(slotWord.bitString)"),.space(1),.natural("FLOAT64(\(float))"))
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
        
    public func dumpObjectContents(at address:inout Proton.Address)
        {
        let header = HeaderPointer(address)
        let slotCount = header.totalSlotCount
        address++
        for index in 1..<slotCount.count
            {
            self.dumpSlot(at: &address,index: index)
            }
        }
        
    private func dumpInstance(at address:inout Proton.Address)
        {
        let header = HeaderPointer(address)
        let type = TypePointer(untaggedAddress(wordAtIndexAtAddress(.one,address)))
        let typeName = type.name
        Log.log(.right("OBJECT(\(header.valueType)) ",Self.kLabelWidth),.natural(": 0x\(address.hexString) : "),.natural("SLOT-COUNT(\(header.totalSlotCount))"),.space(1),.natural("HAS-EXTRA-SLOTS(\(header.hasExtraSlotsAtEnd))"),.space(1),.natural("IS-FORWARDED(\(header.isForwarded))"),.space(1),.left(typeName,30))
        self.dumpObjectContents(at: &address)
        }
        
    private func dumpStringInstance(at address:inout Proton.Address)
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
        Log.log(.right("COUNT ",Self.kLabelWidth),.natural(": 0x\(address.hexString)[0002] "),.natural(countWord.bitString),.space(1),.natural(Proton.ScalarType.integer.valueText(for: countWord)))
        address++
        let maxCountWord = wordAtAddress(address)
        Log.log(.right("MAX COUNT ",Self.kLabelWidth),.natural(": 0x\(address.hexString)[0003] "),.natural(maxCountWord.bitString),.space(1),.natural(Proton.ScalarType.integer.valueText(for: maxCountWord)))
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
        
    private func dumpSlot(at address:inout Proton.Address,index:Int)
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
        if header.tag == .address
            {
            let valueType = ObjectPointer(addressAtAddress(address)).valueType
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
            Log.log(.right("\(tag.uppercased()) ",Self.kLabelWidth),.natural(": 0x\(address.hexString) : "),.natural(word.bitString),.space(1),.natural(Proton.ScalarType(rawTag).valueText(for: word)))
            }
        address++
        }
    }

