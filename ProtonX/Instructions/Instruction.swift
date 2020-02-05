//
//  Instruction.swift
//  argon
//
//  Created by Vincent Coetzee on 31/12/2019.
//  Copyright © 2019 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class Instruction
    {
    public class func makeInstruction(from word1:Word,with word2:Word,with word3:Word) -> Instruction
        {
        let operation = Operation(rawValue: (word1 & Self.Operation.kMask) >> Self.Operation.kShift)!
        switch(operation)
            {
            case .NOP:
                return(NOPInstruction())
            case .MOV:
                return(MOVInstruction(word1,word2,word3))
            case .PUSH:
                return(PUSHInstruction(word1,word2,word3))
            case .POP:
                return(POPInstruction(word1,word2,word3))
            case .CALL:
                return(CALLInstruction(word1,word2,word3))
            case .ENTER:
                return(ENTERInstruction(word1,word2,word3))
            case .LEAVE:
                return(LEAVEInstruction(word1,word2,word3))
            case .RET:
                return(RETInstruction(word1,word2,word3))
            case .DISP:
                return(DISPInstruction(word1,word2,word3))
            case .BR:
                return(BRInstruction(word1,word2,word3))
            case .BRNZ:
                return(BRNZInstruction(word1,word2,word3))
            case .BRZ:
                return(BRZInstruction(word1,word2,word3))
            case .BREQ:
                return(BREQInstruction(word1,word2,word3))
            case .BRNEQ:
                return(BRNEQInstruction(word1,word2,word3))
            case .BRLT:
                return(BRLTInstruction(word1,word2,word3))
            case .BRGT:
                return(BRGTInstruction(word1,word2,word3))
            case .BRLTEQ:
                return(BRLTEQInstruction(word1,word2,word3))
            case .BRGTEQ:
                return(BRGTEQInstruction(word1,word2,word3))
            case .SLOTGET:
                return(SLOTGETInstruction(word1,word2,word3))
            case .SLOTSET:
                return(SLOTSETInstruction(word1,word2,word3))
            case .ADD:
                return(ADDInstruction(word1,word2,word3))
            case .SUB:
                return(SUBInstruction(word1,word2,word3))
            case .MUL:
                return(MULInstruction(word1,word2,word3))
            case .DIV:
                return(DIVInstruction(word1,word2,word3))
            case .MOD:
                return(MODInstruction(word1,word2,word3))
            case .AND:
                return(ANDInstruction(word1,word2,word3))
            case .OR:
                return(ORInstruction(word1,word2,word3))
            case .XOR:
                return(XORInstruction(word1,word2,word3))
            case .NOT:
                return(NOTInstruction(word1,word2,word3))
            case .PUSHPARM:
                return(PUSHPARMInstruction(word1,word2,word3))
            default:
                return(Instruction())
            }
        }
        
    public class func instructionWordHasAddress(_ word:Word) -> Bool
        {
        return(Mode(from: word).hasAddress)
        }
            
    public class func instructionWordHasImmediate(_ word:Word) -> Bool
        {
        return(Mode(from: word).hasImmediate)
        }
        
    public typealias Address = Word
    public typealias Offset = Int
    public typealias Index = Word
    public typealias Immediate = Int64
    
    public struct InstructionWord
        {
        var instruction:Word
        var address:Word
        var immediate:Word
        var hasAddress = false
        var hasImmediate = false
        }
        
    public enum Operation:Word
        {
        public static let kMask:Word = Word(4095) << Word(47)
        public static let kShift:Word = 47
        
        case NOP = 0
        case PUSH
        case PUSHPARM
        case POP
        case MAKE
        case MOV
        case MUL
        case FMUL
        case SUB
        case FSUB
        case DIV
        case FDIV
        case ADD
        case FADD
        case SADD
        case MOD
        case FMOD
        case AND
        case OR
        case XOR
        case NOT
        case DISP
        case NEXT
        case BR
        case BREQ
        case BRNEQ
        case BRGT
        case BRGTEQ
        case BRLT
        case BRLTEQ
        case BRZ
        case BRNZ
        case SLOTGET
        case SLOTSET
        case CALL
        case RET
        case ENTER
        case LEAVE
        
        public var orMask:Word
            {
            return(self.rawValue << Self.kShift)
            }
            
        public init(from word:Word)
            {
            let value = (word & Self.kMask) >> Self.kShift
            self.init(rawValue: value)!
            }
        }
        
    public enum Register:Int,CaseIterable
        {
        public static let kRegister1Mask:Word = Word(255) << Word(39)
        public static let kRegister1Shift:Word = 39
        public static let kRegister2Mask:Word = Word(255) << Word(31)
        public static let kRegister2Shift:Word = 31
        public static let kRegister3Mask:Word = Word(255) << Word(23)
        public static let kRegister3Shift:Word = 23
        
        case none = 0
        case sp
        case bp
        case ip
        case cp
        case r0
        case r1
        case r2
        case r3
        case r4
        case r5
        case r6
        case r7
        case r8
        case r9
        case r10
        case r11
        case r12
        case r13
        case r14
        case r15
        case fr0
        case fr1
        case fr2
        case fr3
        case fr4
        case fr5
        case fr6
        case fr7
        case fr8
        case fr9
        case fr10
        case fr11
        case fr12
        case fr13
        case fr14
        case fr15
        
        public var register1OrMask:Word
            {
            return(Word(self.rawValue) << Self.kRegister1Shift)
            }
            
        public var register2OrMask:Word
            {
            return(Word(self.rawValue) << Self.kRegister2Shift)
            }
            
        public var register3OrMask:Word
            {
            return(Word(self.rawValue) << Self.kRegister3Shift)
            }
            
        public init(register1 word:Word)
            {
            let value = Int((word & Self.kRegister1Mask) >> Self.kRegister1Shift)
            self.init(rawValue: value)!
            }
            
        public init(register2 word:Word)
            {
            let value = (word & Self.kRegister2Mask) >> Self.kRegister2Shift
            self.init(rawValue: Int(value))!
            }
            
        public init(register3 word:Word)
            {
            let value = (word & Self.kRegister3Mask) >> Self.kRegister3Shift
            self.init(rawValue: Int(value))!
            }
        }
        
    public enum Mode:Word
        {
        public static let kMask:Word = Word(15) << Word(59)
        public static let kShift:Word = 59
        
        public static func mode(of word:Word) -> Mode
            {
            return(Mode(rawValue: (word & Mode.kMask) >> Mode.kShift)!)
            }
            
        public var hasAddress:Bool
            {
            switch(self)
                {
                case .address:
                    return(true)
                case .addressImmediate:
                    return(true)
                case .registerAddress:
                    return(true)
                case .addressRegister:
                    return(true)
                case .registerAddressImmediate:
                    return(true)
                case .registerAddressLabel:
                    return(true)
                default:
                    return(false)
                }
            }
            
        public var hasImmediate:Bool
            {
            switch(self)
                {
                case .immediate:
                    return(true)
                case .addressImmediate:
                    return(true)
                case .registerImmediateRegister:
                    return(true)
                case .immediateRegisterRegister:
                    return(true)
                case .immediateRegister:
                    return(true)
                case .addressRegister:
                    return(true)
                case .registerAddressImmediate:
                    return(true)
                case .registerRegisterImmediate:
                    return(true)
                case .registerImmediateLabel:
                    return(true)
                default:
                    return(false)
                }
            }
            
        case none = 0
        case address = 1
        case addressImmediate = 2
        case immediate = 3
        case register = 4
        case registerRegister = 5
        case registerImmediateRegister = 15
        case immediateRegisterRegister = 16
        case registerRegisterRegister = 6
        case registerAddress = 7
        case addressRegister = 8
        case immediateRegister = 9
        case registerRegisterImmediate = 10
        case registerAddressImmediate = 11
        case label = 12
        case stackRegister = 13
        case registerStack = 14
        case registerRegisterLabel = 17
        case registerImmediateLabel = 18
        case registerAddressLabel = 19
        case immediateAddress = 20
        
        public func decodeOperand3(_ word1:Word,_ word2:Word,_ word3:Word) -> Operand
            {
            switch(self)
                {
                case .registerImmediateRegister:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister3Mask) >> Register.kRegister3Shift))!))
                case .immediateRegisterRegister:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister3Mask) >> Register.kRegister3Shift))!))
                case .registerRegisterRegister:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister3Mask) >> Register.kRegister3Shift))!))
                case .registerRegisterImmediate:
                    return(.immediate(Immediate(bitPattern: word3)))
                case .registerAddressImmediate:
                    return(.immediate(Immediate(bitPattern: word3)))
                case .registerRegisterLabel:
                    return(.label(Label(key: Int(Immediate(bitPattern:word3)))))
                case .registerImmediateLabel:
                    return(.label(Label(key: Int(Immediate(bitPattern:word3)))))
                case .registerAddressLabel:
                    return(.label(Label(key: Int(Immediate(bitPattern:word3)))))
                default:
                    break
                }
            return(.none)
            }
            
        public func decodeOperand2(_ word1:Word,_ word2:Word,_ word3:Word) -> Operand
            {
            switch(self)
                {
                case .none:
                    return(.none)
                case .addressImmediate:
                    return(.immediate(Immediate(bitPattern: word3)))
                case .registerRegister:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!))
                case .registerImmediateRegister:
                    return(.immediate(Immediate(bitPattern: word3)))
                case .immediateRegisterRegister:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!))
                case .registerRegisterRegister:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!))
                case .registerAddress:
                    return(.address(word2))
                case .addressRegister:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!))
                case .immediateRegister:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!))
                case .registerRegisterImmediate:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!))
                case .registerAddressImmediate:
                    return(.address(word2))
                case .stackRegister:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!))
                case .registerStack:
                    return(.stack(Int(Int64(bitPattern: word3))))
                case .registerRegisterLabel:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!))
                case .registerImmediateLabel:
                    return(.immediate(Immediate(bitPattern: word3)))
                case .registerAddressLabel:
                    return(.address(word2))
                case .immediateAddress:
                    return(.address(word2))
                default:
                    break
                }
            return(.none)
            }
            
        public func decodeOperand1(_ word1:Word,_ word2:Word,_ word3:Word) -> Operand
            {
            switch(self)
                {
                case .none:
                    return(.none)
                case .address:
                    return(.address(word2))
                case .addressImmediate:
                    return(.address(word2))
                case .immediate:
                    return(.immediate(Immediate(bitPattern: word3)))
                case .register:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!))
                case .registerRegister:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!))
                case .registerImmediateRegister:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!))
                case .immediateRegisterRegister:
                    return(.immediate(Immediate(bitPattern: word3)))
                case .registerRegisterRegister:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!))
                case .registerAddress:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!))
                case .addressRegister:
                    return(.address(word2))
                case .immediateRegister:
                    return(.immediate(Immediate(bitPattern: word3)))
                case .registerRegisterImmediate:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!))
                case .registerAddressImmediate:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!))
                case .label:
                    return(.label(Label(key: Int(Immediate(bitPattern:word3)))))
                case .stackRegister:
                    return(.stack(Int(Int64(bitPattern: word3))))
                case .registerStack:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!))
                case .registerRegisterLabel:
                     return(.register(Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!))
                case .registerImmediateLabel:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!))
                case .registerAddressLabel:
                    return(.register(Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!))
                case .immediateAddress:
                    return(.immediate(Immediate(bitPattern: word3)))
                default:
                    break
                }
            return(.none)
            }
            
        public func encode(operand3: Operand,into instruction:inout InstructionWord)
            {
            switch(self,operand3)
                {
                case let(.registerAddress,.address(value)):
                    instruction.address = value
                    instruction.hasAddress = true
                case let(.registerAddressImmediate,.immediate(value)):
                    instruction.immediate = UInt64(bitPattern: value)
                    instruction.hasImmediate = true
                case let(.registerRegisterRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister3Shift)
                case let(.registerRegisterImmediate,.immediate(value)):
                    instruction.immediate = UInt64(bitPattern: value)
                    instruction.hasImmediate = true
                default:
                    break
                }
            }

        public func encode(operand1: Operand,into instruction:inout InstructionWord)
            {
            switch(self,operand1)
                {
                case let(.address,.address(value)):
                    instruction.address = value
                    instruction.hasAddress = true
                case let(.addressRegister,.address(value)):
                    instruction.address = value
                    instruction.hasAddress = true
                case let(.register,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerRegisterRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerRegisterImmediate,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerAddressImmediate,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerAddress,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.immediate,.immediate(value)):
                    instruction.immediate = UInt64(bitPattern: value)
                    instruction.hasImmediate = true
                case let(.immediateRegister,.immediate(value)):
                     instruction.immediate = UInt64(bitPattern: value)
                     instruction.hasImmediate = true
                case let(.label,.label(value)):
                     instruction.instruction |= (Word(UInt32(value.key) & 4294967295))
                case let(.registerStack,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.stackRegister,.stack(value)):
                    let sign = value < 0 ? Word(2147483648) : Word(0)
                    let posValue = Word(abs(value))
                    print("SIGN = \(sign.bitString)")
                    print("POSVALUE = \(posValue.bitString)")
                    let wordValue = (posValue & 2147483647) | sign
                    print("WORDVALUE = \(wordValue.bitString)")
                    instruction.instruction |= wordValue
                default:
                    break
                }
            }

        public func encode(operand2: Operand,into instruction:inout InstructionWord)
            {
            switch(self,operand2)
                {
                case let(.registerAddress,.address(value)):
                    instruction.address = value
                    instruction.hasAddress = true
                case let(.registerAddressImmediate,.address(value)):
                    instruction.address = value
                    instruction.hasAddress = true
                case let(.registerRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                case let(.registerRegisterRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                case let(.registerRegisterImmediate,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                case let(.addressRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                case let(.immediateRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                case let(.registerStack,.stack(value)):
                    instruction.instruction |= (Word(UInt32(bitPattern: Int32(value)) & 4294967295))
                case let(.stackRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                default:
                    break
                }
            }
            
        public var orMask:Word
            {
            return(self.rawValue << Self.kShift)
            }
            
        public init(from word:Word)
            {
            let value = (word & Self.kMask) >> Self.kShift
            self.init(rawValue: value)!
            }
        }
        
    public static let kOperand1IsReferenceMask:Word = Word(1) << Word(22)
    public static let kOperand1IsReferenceShift:Word = 22
    public static let kOperand2IsReferenceMask:Word = Word(1) << Word(21)
    public static let kOperand2IsReferenceShift:Word = 21
    public static let kOperand3IsReferenceMask:Word = Word(1) << Word(20)
    public static let kOperand3IsReferenceShift:Word = 20
    
    public var hasAddress:Bool
        {
        return(self.mode.hasAddress)
        }
        
    public var hasImmediate:Bool
        {
        return(self.mode.hasImmediate)
        }
        
    public var hasRegister3:Bool
        {
        return(self.mode == .registerRegisterRegister)
        }
        
    public indirect enum Operand
        {
        public static func stringAsMode(_ string:String) -> Mode
            {
            switch(string)
                {
                case "none":
                    return(.none)
                case "address":
                    return(.address)
                case "immediate":
                    return(.immediate)
                case "register":
                    return(.register)
                case "registerRegister":
                    return(.registerRegister)
                case "registerRegisterRegister":
                    return(.registerRegisterRegister)
                case "registerAddress":
                    return(.registerAddress)
                case "addressRegister":
                    return(.addressRegister)
                case "immediateRegister":
                    return(.immediateRegister)
                case "registerRegisterImmediate":
                    return(.registerRegisterImmediate)
                case "registerAddressImmediate":
                    return(.registerAddressImmediate)
                case "label":
                    return(.label)
                default:
                    return(.none)
                }
            }
            
        case label(Label)
        case immediate(Immediate)
        case address(Address)
        case referenceAddress(Address)
        case register(Register)
        case referenceRegister(Register)
        case stack(Int)
        case none
        }
        
    public var encoded:InstructionWord
        {
        var word:InstructionWord = InstructionWord(instruction:0,address:0,immediate:0)
        word.instruction = self.operation.orMask | self.mode.orMask
        self.encode(into: &word)
        return(word)
        }
        
    public var sizeInWords:Int
        {
        return(self.hasAddress ? 2 : 1)
        }
        
    public var operation:Operation
    public let mode:Mode
    public private(set) var incomingLabel:Int = 0
    public private(set) var outgoingLabels:[Int] = []
    
    public init(_ operation:Operation,_ mode:Mode)
        {
        self.operation = operation
        self.mode = mode
        }

//    public convenience init(atAddress:Address)
//        {
//        let instructionWord = wordAtAddress(atAddress)
//        var address:Word = 0
//        if Mode(from:instructionWord).hasAddress
//            {
//            address = wordAtAddress(atAddress + Instruction.Address(MemoryLayout<Word>.stride))
//            }
//        self.init(instruction: instructionWord,address: address)
//        }
        
    public init()
        {
        self.operation = .NOP
        self.mode = .none
        }
        
    public init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operation = Operation(from: word1)
        self.mode = Mode(from: word1)
        }
        
    internal func encode(into doubleWord:inout InstructionWord)
        {
        }
        
    public func set(incomingLabel:Int)
        {
        self.incomingLabel = incomingLabel
        }
        
    public func append(outgoingLabel:Int)
        {
        self.outgoingLabels.append(outgoingLabel)
        }
        
    @inline(__always)
    public func encode(into pointer:inout UnsafeMutablePointer<Word>)
        {
        let word = self.encoded
        pointer.pointee = word.instruction
        if word.hasAddress
            {
            pointer += 1
            pointer.pointee = word.address
            }
        }
        
    public func execute(on:Thread) throws
        {
        }
    }

extension Instruction.Immediate
    {
    public init(from: Word)
        {
        let sign = (from & 2147483648 == 2147483648) ? Int32(-1) : Int32(1)
        let mask:Word = ~2147483648
        let newValue = from & mask
        self.init(Int32(Int(newValue & Word(4294967295))) * sign)
        }
    }

//case NOP = 0
//case PUSH
//case PUSHPARM
//case POP
//case MAKE
//case MOV
//case MUL
//case FMUL
//case SUB
//case FSUB
//case DIV
//case FDIV
//case ADD
//case FADD
//case SADD
//case MOD
//case FMOD
//case AND
//case OR
//case XOR
//case NOT
//case DISP
//case NEXT
//case BR
//case BREQ
//case BRNEQ
//case BRGT
//case BRGTEQ
//case BRLT
//case BRLTEQ
//case BRZ
//case BRNZ
//case SLOTGET
//case SLOTSET
//case CALL
//case RET
//case ENTER
//case LEAVE

public class InstructionComposer
    {
    public var address:Instruction.Address
        {
        get
            {
            return(0)
            }
        set
            {
            self.hasAddress = true
            self.addressWord = newValue
            }
        }
        
    public var immediate:Instruction.Immediate
        {
        get
            {
            return(0)
            }
        set
            {
            self.hasImmediate = true
            self.immediateWord = UInt64(bitPattern: newValue)
            }
        }
        
    public var register1:Instruction.Register
        {
        get
            {
            return(Instruction.Register(rawValue: Int((self.instructionWord & Instruction.Register.kRegister1Mask) >> Instruction.Register.kRegister1Shift))!)
            }
        set
            {
            self.instructionWord &= ~Instruction.Register.kRegister1Mask
            self.instructionWord |= Word(newValue.rawValue) << Instruction.Register.kRegister1Shift
            }
        }
    
    public var register2:Instruction.Register
        {
        get
            {
            return(Instruction.Register(rawValue: Int((self.instructionWord & Instruction.Register.kRegister2Mask) >> Instruction.Register.kRegister2Shift))!)
            }
        set
            {
            self.instructionWord &= ~Instruction.Register.kRegister2Mask
            self.instructionWord |= Word(newValue.rawValue) << Instruction.Register.kRegister2Shift
            }
        }
        
    
    public var register3:Instruction.Register
        {
        get
            {
            return(Instruction.Register(rawValue: Int((self.instructionWord & Instruction.Register.kRegister3Mask) >> Instruction.Register.kRegister3Shift))!)
            }
        set
            {
            self.instructionWord &= ~Instruction.Register.kRegister3Mask
            self.instructionWord |= Word(newValue.rawValue) << Instruction.Register.kRegister3Shift
            }
        }
        
    
    public var mode:Instruction.Mode
        {
        get
            {
            return(Instruction.Mode(rawValue: (self.instructionWord & Instruction.Mode.kMask) >> Instruction.Mode.kShift)!)
            }
        set
            {
            self.instructionWord &= ~Instruction.Mode.kMask
            self.instructionWord |= newValue.rawValue << Instruction.Mode.kShift
            }
        }
        
    
    public var operation:Instruction.Operation
        {
        get
            {
            return(Instruction.Operation(rawValue: (self.instructionWord & Instruction.Operation.kMask) >> Instruction.Operation.kShift)!)
            }
        set
            {
            self.instructionWord &= ~Instruction.Operation.kMask
            self.instructionWord |= newValue.rawValue << Instruction.Operation.kShift
            }
        }
        
    
    public var operand1IsReference:Bool
        {
        get
            {
            return((self.instructionWord & Instruction.kOperand1IsReferenceMask) == Instruction.kOperand1IsReferenceMask)
            }
        set
            {
            self.instructionWord &= ~(Instruction.kOperand1IsReferenceMask)
            self.instructionWord |= (newValue ? Word(1) : Word(0)) << Instruction.kOperand1IsReferenceShift
            }
        }
        
    public var operand2IsReference:Bool
        {
        get
            {
            return((self.instructionWord & Instruction.kOperand2IsReferenceMask) == Instruction.kOperand2IsReferenceMask)
            }
        set
            {
            self.instructionWord &= ~(Instruction.kOperand2IsReferenceMask)
            self.instructionWord |= (newValue ? Word(1) : Word(0)) << Instruction.kOperand2IsReferenceShift
            }
        }
        
    public var operand3IsReference:Bool
        {
        get
            {
            return((self.instructionWord & Instruction.kOperand3IsReferenceMask) == Instruction.kOperand3IsReferenceMask)
            }
        set
            {
            self.instructionWord &= ~(Instruction.kOperand3IsReferenceMask)
            self.instructionWord |= (newValue ? Word(1) : Word(0)) << Instruction.kOperand3IsReferenceShift
            }
        }
        
    private var instructionWord:Word = 0
    private var addressWord:Word = 0
    private var immediateWord:Word = 0
    public private (set) var hasImmediate = false
    private var hasAddress = false
    
    public init(instruction:Word,address:Word,immediate:Word)
        {
        self.instructionWord = instruction
        self.addressWord = address
        self.immediateWord = immediate
        }
    }
    
public class NOPInstruction:Instruction
    {
    public override init()
        {
        super.init(.NOP,.none)
        }
    }
    
public class PUSHInstruction:Instruction
    {
    private let operand:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(immediate:Immediate)
        {
        self.operand = .immediate(immediate)
        super.init(.PUSH,.immediate)
        }
        
    public init(address:Address)
        {
        self.operand = .address(address)
        super.init(.PUSH,.address)
        }
        
    public init(referenceAddress address:Address)
        {
        self.operand = .referenceAddress(address)
        super.init(.PUSH,.address)
        }
        
    public init(register:Register)
        {
        self.operand = .register(register)
        super.init(.PUSH,.register)
        }
        
    public init(referenceRegister register:Register)
        {
        self.operand = .referenceRegister(register)
        super.init(.PUSH,.register)
        }
        
    internal override func encode(into doubleWord:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand,into: &doubleWord)
        }
    }

public class PUSHPARMInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(immediate:Immediate,register:Register)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register)
        super.init(.PUSHPARM,.immediateRegister)
        }
        
    public init(immediate:Immediate,address:Address)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .address(address)
        super.init(.PUSHPARM,.immediateAddress)
        }
        
    public init(immediate:Immediate,referenceAddress address:Address)
        {
        self.operand2 = .referenceAddress(address)
        self.operand1 = .immediate(immediate)
        super.init(.PUSHPARM,.immediateAddress)
        }
        
    public init(register1:Register,register2:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        super.init(.PUSHPARM,.registerRegister)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        }
    }

public class POPInstruction:Instruction
    {
    private let operand:Operand
        
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(address:Address)
        {
        self.operand = .address(address)
        super.init(.POP,.address)
        }
        
    public init(referenceAddress address:Address)
        {
        self.operand = .referenceAddress(address)
        super.init(.PUSH,.address)
        }
        
    public init(register:Register)
        {
        self.operand = .register(register)
        super.init(.PUSH,.register)
        }
        
    public init(referenceRegister register:Register)
        {
        self.operand = .referenceRegister(register)
        super.init(.PUSH,.register)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand,into: &words)
        }
    }
        
public class MAKEInstruction:Instruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public override init()
        {
        super.init(.MAKE,.none)
        }
    }

public class ADDInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init(.ADD,.registerRegisterRegister)
        }
        
    public init(register1:Register,immediate:Immediate,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .immediate(immediate)
        self.operand3 = .register(register3)
        super.init(.ADD,.registerImmediateRegister)
        }
        
    public init(immediate:Immediate,register2:Register,register3:Register)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init(.ADD,.registerImmediateRegister)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }

public class SUBInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand

    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init(.SUB,.registerRegisterRegister)
        }
        
    public init(register1:Register,immediate:Immediate,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .immediate(immediate)
        self.operand3 = .register(register3)
        super.init(.SUB,.registerImmediateRegister)
        }
        
    public init(immediate:Immediate,register2:Register,register3:Register)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init(.SUB,.registerImmediateRegister)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }


public class MULInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand

    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init(.MUL,.registerRegisterRegister)
        }
        
    public init(register1:Register,immediate:Immediate,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .immediate(immediate)
        self.operand3 = .register(register3)
        super.init(.MUL,.registerImmediateRegister)
        }
        
    public init(immediate:Immediate,register2:Register,register3:Register)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init(.MUL,.registerImmediateRegister)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }


public class DIVInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand

    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init(.DIV,.registerRegisterRegister)
        }
        
    public init(register1:Register,immediate:Immediate,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .immediate(immediate)
        self.operand3 = .register(register3)
        super.init(.DIV,.registerImmediateRegister)
        }
        
    public init(immediate:Immediate,register2:Register,register3:Register)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init(.DIV,.registerImmediateRegister)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }


public class MODInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand

    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init(.MOD,.registerRegisterRegister)
        }
        
    public init(register1:Register,immediate:Immediate,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .immediate(immediate)
        self.operand3 = .register(register3)
        super.init(.MOD,.registerImmediateRegister)
        }
        
    public init(immediate:Immediate,register2:Register,register3:Register)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init(.MOD,.registerImmediateRegister)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }


public class ANDInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand

    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init(.AND,.registerRegisterRegister)
        }
        
    public init(register1:Register,immediate:Immediate,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .immediate(immediate)
        self.operand3 = .register(register3)
        super.init(.AND,.registerImmediateRegister)
        }
        
    public init(immediate:Immediate,register2:Register,register3:Register)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init(.AND,.registerImmediateRegister)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }


public class ORInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand

    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init(.OR,.registerRegisterRegister)
        }
        
    public init(register1:Register,immediate:Immediate,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .immediate(immediate)
        self.operand3 = .register(register3)
        super.init(.OR,.registerImmediateRegister)
        }
        
    public init(immediate:Immediate,register2:Register,register3:Register)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init(.OR,.registerImmediateRegister)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }


public class XORInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand

    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init(.XOR,.registerRegisterRegister)
        }
        
    public init(register1:Register,immediate:Immediate,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .immediate(immediate)
        self.operand3 = .register(register3)
        super.init(.XOR,.registerImmediateRegister)
        }
        
    public init(immediate:Immediate,register2:Register,register3:Register)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init(.XOR,.registerImmediateRegister)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }


public class NOTInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand

    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        super.init(.NOT,.registerRegister)
        }
        
    public init(immediate:Immediate,register1:Register)
        {
        self.operand2 = .register(register1)
        self.operand1 = .immediate(immediate)
        super.init(.NOT,.immediateRegister)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        }
    }


public class MOVInstruction:Instruction
    {
    private var operand1:Operand = .none
    private var operand2:Operand = .none
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register)
        {
        super.init(.MOV,.registerRegister)
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        }
        
    public init(immediate:Immediate,register2:Register)
        {
        super.init(.MOV,.registerImmediateRegister)
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register2)
        }
        
    public init(referenceAddress:Address,register2:Register)
        {
        super.init(.MOV,.addressRegister)
        self.operand1 = .referenceAddress(referenceAddress)
        self.operand2 = .register(register2)
        }
        
    public init(register1:Register,referenceAddress:Address)
        {
        super.init(.MOV,.registerAddress)
        self.operand2 = .referenceAddress(referenceAddress)
        self.operand1 = .register(register1)
        }
        
    public init(offsetInStack:Int,register2:Register)
        {
        super.init(.MOV,.stackRegister)
        self.operand2 = .register(register2)
        self.operand1 = .stack(offsetInStack)
        }
         
    public init(register1:Register,offsetInStack:Int)
         {
         super.init(.MOV,.registerStack)
         self.operand1 = .register(register1)
         self.operand2 = .stack(offsetInStack)
         }
         
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        }
    }


public class BRInstruction:Instruction
    {
    private let operand:Operand

    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(label:Label)
        {
        self.operand = .label(label)
        super.init(.MOV,.label)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand,into: &words)
        }
    }


public class BREQInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .label(label)
        super.init(.BREQ,.registerRegisterLabel)
        }
        
    public init(register1:Register,immediate:Immediate,label:Label)
        {
        self.operand2 = .immediate(immediate)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(.BREQ,.registerImmediateRegister)
        }
        
    public init(register1:Register,referenceAddress:Address,label:Label)
        {
        self.operand2 = .referenceAddress(referenceAddress)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(.BREQ,.registerAddressLabel)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }


public class BRNEQInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .label(label)
        super.init(.BRNEQ,.registerRegisterLabel)
        }
        
    public init(register1:Register,immediate:Immediate,label:Label)
        {
        self.operand2 = .immediate(immediate)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(.BRNEQ,.registerImmediateRegister)
        }
        
    public init(register1:Register,referenceAddress:Address,label:Label)
        {
        self.operand2 = .referenceAddress(referenceAddress)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(.BRNEQ,.registerAddressLabel)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }


public class BRZInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .label(label)
        super.init(.BRZ,.registerRegisterLabel)
        }
        
    public init(register1:Register,immediate:Immediate,label:Label)
        {
        self.operand2 = .immediate(immediate)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(.BRZ,.registerImmediateRegister)
        }
        
    public init(register1:Register,referenceAddress:Address,label:Label)
        {
        self.operand2 = .referenceAddress(referenceAddress)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(.BRZ,.registerAddressLabel)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }


public class BRNZInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .label(label)
        super.init(.BRNZ,.registerRegisterLabel)
        }
        
    public init(register1:Register,immediate:Immediate,label:Label)
        {
        self.operand2 = .immediate(immediate)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(.BRNZ,.registerImmediateRegister)
        }
        
    public init(register1:Register,referenceAddress:Address,label:Label)
        {
        self.operand2 = .referenceAddress(referenceAddress)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(.BRNZ,.registerAddressLabel)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }
    

public class BRGTInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .label(label)
        super.init(.BRGT,.registerRegisterLabel)
        }
        
    public init(register1:Register,immediate:Immediate,label:Label)
        {
        self.operand2 = .immediate(immediate)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(.BRGT,.registerImmediateRegister)
        }
        
    public init(register1:Register,referenceAddress:Address,label:Label)
        {
        self.operand2 = .referenceAddress(referenceAddress)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(.BRGT,.registerAddressLabel)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }


public class BRGTEQInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .label(label)
        super.init(.BRGTEQ,.registerRegisterLabel)
        }
        
    public init(register1:Register,immediate:Immediate,label:Label)
        {
        self.operand2 = .immediate(immediate)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(.BRGTEQ,.registerImmediateRegister)
        }
        
    public init(register1:Register,referenceAddress:Address,label:Label)
        {
        self.operand2 = .referenceAddress(referenceAddress)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(.BRGTEQ,.registerAddressLabel)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }


public class BRLTInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .label(label)
        super.init(.BRLT,.registerRegisterLabel)
        }
        
    public init(register1:Register,immediate:Immediate,label:Label)
        {
        self.operand2 = .immediate(immediate)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(.BRLT,.registerImmediateRegister)
        }
        
    public init(register1:Register,referenceAddress:Address,label:Label)
        {
        self.operand2 = .referenceAddress(referenceAddress)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(.BRLT,.registerAddressLabel)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }


public class BRLTEQInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .label(label)
        super.init(.BRLTEQ,.registerRegisterLabel)
        }
        
    public init(register1:Register,immediate:Immediate,label:Label)
        {
        self.operand2 = .immediate(immediate)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(.BRLTEQ,.registerImmediateRegister)
        }
        
    public init(register1:Register,referenceAddress:Address,label:Label)
        {
        self.operand2 = .referenceAddress(referenceAddress)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(.BRLTEQ,.registerAddressLabel)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }


public class SLOTGETInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,immediate:Immediate,register2:Register)
        {
        self.operand1 = .register(register1)
        self.operand3 = .register(register2)
        self.operand2 = .immediate(immediate)
        super.init(.SLOTGET,.registerImmediateRegister)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        self.operand2 = .register(register2)
        self.operand1 = .register(register1)
        self.operand3 = .register(register3)
        super.init(.SLOTGET,.registerRegisterRegister)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }


public class SLOTSETInstruction:Instruction
    {
    private let operand1:Operand
    private let operand2:Operand
    private let operand3:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,immediate:Immediate)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .immediate(immediate)
        super.init(.SLOTSET,.registerRegisterImmediate)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        self.operand2 = .register(register2)
        self.operand1 = .register(register1)
        self.operand3 = .register(register3)
        super.init(.SLOTSET,.registerRegisterRegister)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }


public class CALLInstruction:Instruction
    {
    private let operand1:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(label:Label)
        {
        self.operand1 = .label(label)
        super.init(.CALL,.label)
        }
        
    public init(address:Address)
        {
        self.operand1 = .address(address)
        super.init(.CALL,.address)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        }
    }


public class ENTERInstruction:Instruction
    {
    private let operand1:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(immediate:Immediate)
        {
        self.operand1 = .immediate(immediate)
        super.init(.ENTER,.immediate)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        }
    }


public class LEAVEInstruction:Instruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(immediate:Immediate)
        {
        super.init(.LEAVE,.none)
        }
    }


public class RETInstruction:Instruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public override init()
        {
        super.init(.RET,.none)
        }
    }


public class DISPInstruction:Instruction
    {
    private let operand:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(immediate:Immediate)
        {
        self.operand = .immediate(immediate)
        super.init(.DISP,.immediate)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand,into: &words)
        }
    }

