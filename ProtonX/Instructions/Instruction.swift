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
    public class func makeInstruction(atAddress:Argon.Address) -> Instruction
        {
        var address = atAddress
        let word1 = wordAtAddress(address)
        var word2:Word = 0
        var word3:Word = 0
        if Self.instructionWordHasAddress(word1)
            {
            address += Argon.Address(MemoryLayout<Word>.stride)
            word2 = wordAtAddress(address)
            }
        if Self.instructionWordHasImmediate(word1)
            {
            address += Argon.Address(MemoryLayout<Word>.stride)
            word3 = wordAtAddress(address)
            }
        return(self.makeInstruction(from: word1,with: word2,with: word3))
        }
        
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
    
    public struct InstructionWord
        {
        public var address:Word
            {
            get
                {
                return(self._address)
                }
            set
                {
                self.hasAddress = true
                self._address = newValue
                }
            }
            
        public var immediate:Word
            {
            get
                {
                return(self._immediate)
                }
            set
                {
                self.hasImmediate = true
                self._immediate = newValue
                }
            }
            
        public var operand1IsReference:Bool
            {
            get
                {
                return(self.instruction & Instruction.kOperand1IsReferenceMask == Instruction.kOperand1IsReferenceMask)
                }
            set
                {
                self.instruction &= ~Instruction.kOperand1IsReferenceMask
                if newValue
                    {
                    self.instruction |= Instruction.kOperand1IsReferenceMask
                    }
                }
            }
            
        public var operand2IsReference:Bool
            {
            get
                {
                return(self.instruction & Instruction.kOperand2IsReferenceMask == Instruction.kOperand2IsReferenceMask)
                }
            set
                {
                self.instruction &= ~Instruction.kOperand2IsReferenceMask
                if newValue
                    {
                    self.instruction |= Instruction.kOperand2IsReferenceMask
                    }
                }
            }
            
        public var operand3IsReference:Bool
            {
            get
                {
                return(self.instruction & Instruction.kOperand3IsReferenceMask == Instruction.kOperand3IsReferenceMask)
                }
            set
                {
                self.instruction &= ~Instruction.kOperand3IsReferenceMask
                if newValue
                    {
                    self.instruction |= Instruction.kOperand3IsReferenceMask
                    }
                }
            }
            
        public var instruction:Word
        private var _address:Word
        private var _immediate:Word
        public var hasAddress = false
        public var hasImmediate = false
        
        public init(instruction:Word,address:Word,immediate:Word)
            {
            self.instruction = instruction
            self._address = address
            self._immediate = immediate
            }
        }
        
    public enum Operation:Word
        {
        public static let kMask:Word = Word(4095) << Word(46)
        public static let kShift:Word = 46
        
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
        public static let kRegister1Mask:Word = Word(255) << Word(38)
        public static let kRegister1Shift:Word = 38
        public static let kRegister2Mask:Word = Word(255) << Word(30)
        public static let kRegister2Shift:Word = 30
        public static let kRegister3Mask:Word = Word(255) << Word(22)
        public static let kRegister3Shift:Word = 22
        
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
        public static let kMask:Word = Word(31) << Word(58)
        public static let kShift:Word = 58
        
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
                    let register = Register(rawValue: Int((word1 & Register.kRegister3Mask) >> Register.kRegister3Shift))!
                    return((word1 & kOperand3IsReferenceMask) == kOperand3IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .immediateRegisterRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister3Mask) >> Register.kRegister3Shift))!
                    return((word1 & kOperand3IsReferenceMask) == kOperand3IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .registerRegisterRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister3Mask) >> Register.kRegister3Shift))!
                    return((word1 & kOperand3IsReferenceMask) == kOperand3IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .registerRegisterImmediate:
                    return(.immediate(Argon.Immediate(bitPattern: word3)))
                case .registerAddressImmediate:
                    return(.immediate(Argon.Immediate(bitPattern: word3)))
                case .registerRegisterLabel:
                    return(.label(Label(key: Int(Argon.Immediate(bitPattern:word3)))))
                case .registerImmediateLabel:
                    return(.label(Label(key: Int(Argon.Immediate(bitPattern:word3)))))
                case .registerAddressLabel:
                    return(.label(Label(key: Int(Argon.Immediate(bitPattern:word3)))))
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
                    return(.immediate(Argon.Immediate(bitPattern: word3)))
                case .registerRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .registerImmediateRegister:
                    return(.immediate(Argon.Immediate(bitPattern: word3)))
                case .immediateRegisterRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .registerRegisterRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .registerAddress:
                    return(.address(word2))
                case .addressRegister:
                     let register = Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .immediateRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .registerRegisterImmediate:
                    let register = Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .registerAddressImmediate:
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .referenceAddress(word2) : .address(word2))
                case .stackRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .registerStack:
                    return(.stack(Int(Int64(bitPattern: word3))))
                case .registerRegisterLabel:
                    let register = Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .registerImmediateLabel:
                    return(.immediate(Argon.Immediate(bitPattern: word3)))
                case .registerAddressLabel:
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .referenceAddress(word2) : .address(word2))
                case .immediateAddress:
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .referenceAddress(word2) : .address(word2))
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
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .referenceAddress(word2) : .address(word2))
                case .addressImmediate:
                   return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .referenceAddress(word2) : .address(word2))
                case .immediate:
                    return(.immediate(Argon.Immediate(bitPattern: word3)))
                case .register:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .registerRegister:
                     let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .registerImmediateRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .immediateRegisterRegister:
                    return(.immediate(Argon.Immediate(bitPattern: word3)))
                case .registerRegisterRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .registerAddress:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .addressRegister:
                    return(.address(word2))
                case .immediateRegister:
                    return(.immediate(Argon.Immediate(bitPattern: word3)))
                case .registerAddressImmediate:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .label:
                    return(.label(Label(key: Int(Argon.Immediate(bitPattern:word3)))))
                case .stackRegister:
                    return(.stack(Int(Int64(bitPattern: word3))))
                case .registerStack:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .registerRegisterLabel:
                     let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                     return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .registerImmediateLabel:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .registerAddressLabel:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .referenceRegister(register) : .register(register))
                case .immediateAddress:
                    return(.immediate(Argon.Immediate(bitPattern: word3)))
                case .registerRegisterImmediate:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .referenceRegister(register) : .register(register))
                }
            }
            
        public func encode(operand3: Operand,into instruction:inout InstructionWord)
            {
            switch(self,operand3)
                {
                case let(.registerAddress,.referenceAddress(value)):
                    instruction.address = value
                    instruction.operand3IsReference = true
                case let(.registerAddress,.address(value)):
                    instruction.address = value
                    instruction.operand3IsReference = false
                case let(.registerAddressImmediate,.immediate(value)):
                    instruction.immediate = UInt64(bitPattern: value)
                case let(.registerRegisterRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister3Shift)
                    instruction.operand3IsReference = false
                case let(.registerRegisterRegister,.referenceRegister(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister3Shift)
                    instruction.operand3IsReference = true
                case let(.registerRegisterImmediate,.immediate(value)):
                    instruction.immediate = UInt64(bitPattern: value)
                case let(.registerImmediateRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister3Shift)
                    instruction.operand3IsReference = false
                case let(.registerImmediateRegister,.referenceRegister(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister3Shift)
                    instruction.operand3IsReference = true
                default:
                    break
                }
            }

        public func encode(operand1: Operand,into instruction:inout InstructionWord)
            {
            instruction.operand1IsReference = false
            switch(self,operand1)
                {
                case let(.address,.address(value)):
                    instruction.address = value
                case let(.address,.referenceAddress(value)):
                    instruction.address = value
                    instruction.operand1IsReference = true
                case let(.addressRegister,.address(value)):
                    instruction.address = value
                case let(.addressRegister,.referenceAddress(value)):
                    instruction.address = value
                    instruction.operand1IsReference = true
                case let(.registerImmediateRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerImmediateRegister,.referenceRegister(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                    instruction.operand1IsReference = true
                case let(.register,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.register,.referenceRegister(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                    instruction.operand1IsReference = true
                case let(.registerRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerRegister,.referenceRegister(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                    instruction.operand1IsReference = true
                case let(.registerRegisterRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerRegisterRegister,.referenceRegister(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                    instruction.operand1IsReference = true
                case let(.registerRegisterImmediate,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerRegisterImmediate,.referenceRegister(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                    instruction.operand1IsReference = true
                case let(.registerAddressImmediate,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerAddressImmediate,.referenceRegister(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                    instruction.operand1IsReference = true
                case let(.registerAddress,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerAddress,.referenceRegister(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                    instruction.operand1IsReference = true
                case let(.immediate,.immediate(value)):
                    instruction.immediate = UInt64(bitPattern: value)
                case let(.immediateRegister,.immediate(value)):
                     instruction.immediate = UInt64(bitPattern: value)
                case let(.label,.label(value)):
                     instruction.immediate = Word(UInt(bitPattern: value.key))
                case let(.registerStack,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerStack,.referenceRegister(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                    instruction.operand1IsReference = true
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
                case let(.registerImmediateRegister,.immediate(value)):
                    instruction.immediate = Word(bitPattern: value)
                case let(.registerAddress,.address(value)):
                    instruction.address = value
                case let(.registerAddressImmediate,.address(value)):
                    instruction.address = value
                case let(.registerRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                case let(.registerRegister,.referenceRegister(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                    instruction.operand2IsReference = true
                case let(.registerRegisterRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                case let(.registerRegisterRegister,.referenceRegister(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                    instruction.operand2IsReference = true
                case let(.registerRegisterImmediate,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                case let(.registerRegisterImmediate,.referenceRegister(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                    instruction.operand2IsReference = true
                case let(.addressRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                case let(.addressRegister,.referenceRegister(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                    instruction.operand2IsReference = true
                case let(.immediateRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                case let(.immediateRegister,.referenceRegister(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                    instruction.operand2IsReference = true
                case let(.registerStack,.stack(value)):
                    instruction.instruction |= (Word(UInt32(bitPattern: Int32(value)) & 4294967295))
                case let(.stackRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                case let(.stackRegister,.referenceRegister(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                    instruction.operand2IsReference = true
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
        
    public static let kOperand1IsReferenceMask:Word = Word(1) << Word(21)
    public static let kOperand1IsReferenceShift:Word = 21
    public static let kOperand2IsReferenceMask:Word = Word(1) << Word(20)
    public static let kOperand2IsReferenceShift:Word = 20
    public static let kOperand3IsReferenceMask:Word = Word(1) << Word(19)
    public static let kOperand3IsReferenceShift:Word = 19
    
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
            
        public var displayString:String
            {
            switch(self)
                {
                case .label(let value):
                    return("LABEL\(value.key)")
                case .immediate(let value):
                    return("\(value)")
                case .address(let value):
                    return("\(value)")
                case .referenceAddress(let value):
                    return("[\(value)]")
                case .register(let value):
                    return("\(value)")
                case .referenceRegister(let value):
                    return("[\(value)]")
                case .stack(let value):
                    return("BP[\(value)]")
                case .none:
                    return("NONE")
                }
            }
            
        case label(Label)
        case immediate(Argon.Immediate)
        case address(Argon.Address)
        case referenceAddress(Argon.Address)
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
        var count = 1
        count = self.hasAddress ? count + 1 : count
        count = self.hasImmediate ? count + 1 : count
        return(count)
        }
        
    public var displayString:String
        {
        return(Line(.left("\(operation)",10),.space(1)).string)
        }
        
    public var totalByteCount:Word
        {
        var count = 1
        count += self.hasAddress ? 1 : 0
        count += self.hasImmediate ? 1 : 0
        return(Word(count * MemoryLayout<Word>.stride))
        }
        
    public var operation:Operation
    public var mode:Mode
    public private(set) var incomingLabel:Int = 0
    public private(set) var outgoingLabels:[Int] = []
        
    public init(_ operation:Operation,_ mode:Mode)
        {
        self.operation = operation
        self.mode = mode
        }

//    public convenience init(atAddress:Argon.Address)
//        {
//        let instructionWord = wordAtAddress(atAddress)
//        var address:Word = 0
//        if Mode(from:instructionWord).hasAddress
//            {
//            address = wordAtAddress(atAddress + Argon.Address(MemoryLayout<Word>.stride))
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
    public var address:Argon.Address
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
        
    public var immediate:Argon.Immediate
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
    public override var displayString:String
        {
        return(super.displayString + self.operand.displayString)
        }
        
    private let operand:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(immediate:Argon.Immediate)
        {
        self.operand = .immediate(immediate)
        super.init(.PUSH,.immediate)
        }
        
    public init(address:Argon.Address)
        {
        self.operand = .address(address)
        super.init(.PUSH,.address)
        }
        
    public init(referenceAddress address:Argon.Address)
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
        
    public override func execute(on thread:Thread) throws
        {
        thread.stack.push(self.operand,on: thread)
        }
    }

public class PUSHPARMInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString + self.operand1.displayString + "," + self.operand2.displayString)
        }
        
    private let operand1:Operand
    private let operand2:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(immediate:Argon.Immediate,register:Register)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register)
        super.init(.PUSHPARM,.immediateRegister)
        }
        
    public init(immediate:Argon.Immediate,address:Argon.Address)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .address(address)
        super.init(.PUSHPARM,.immediateAddress)
        }
        
    public init(immediate:Argon.Immediate,referenceAddress address:Argon.Address)
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
    public override var displayString:String
        {
        return(super.displayString + self.operand.displayString)
        }
        
    private let operand:Operand
        
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(address:Argon.Address)
        {
        self.operand = .address(address)
        super.init(.POP,.address)
        }
        
    public init(referenceAddress address:Argon.Address)
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
    public override var displayString:String
        {
        return(super.displayString)
        }
        
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public override init()
        {
        super.init(.MAKE,.none)
        }
    }

public class ArithmeticInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString + self.operand1.displayString + "," + self.operand2.displayString + "," + self.operand3.displayString)
        }
        
    internal var operand1:Operand
    internal var operand2:Operand
    internal var operand3:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(operation:Operation,register1:Register,register2:Register,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init()
        self.operation = operation
        self.mode = .registerRegisterRegister
        }
        
    public init(operation:Operation,register1:Register,immediate:Argon.Immediate,register3:Register)
        {
        self.operand1 = .register(register1)
        self.operand2 = .immediate(immediate)
        self.operand3 = .register(register3)
        super.init()
        self.operation = operation
        self.mode = .registerImmediateRegister
        }
        
    public init(operation:Operation,immediate:Argon.Immediate,register2:Register,register3:Register)
        {
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register2)
        self.operand3 = .register(register3)
        super.init()
        self.operation = operation
        self.mode = .immediateRegisterRegister
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }
    
public class ADDInstruction:ArithmeticInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        super.init(operation:.ADD,register1:register1,register2:register2,register3:register3)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,register3:Register)
        {
        super.init(operation:.ADD,register1:register1,immediate:immediate,register3:register3)
        }
        
    public init(immediate:Argon.Immediate,register2:Register,register3:Register)
        {
        super.init(operation:.ADD,immediate:immediate,register2:register2,register3:register3)
        }
    }

public class SUBInstruction:ArithmeticInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        super.init(operation:.SUB,register1:register1,register2:register2,register3:register3)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,register3:Register)
        {
        super.init(operation:.SUB,register1:register1,immediate:immediate,register3:register3)
        }
        
    public init(immediate:Argon.Immediate,register2:Register,register3:Register)
        {
        super.init(operation:.SUB,immediate:immediate,register2:register2,register3:register3)
        }
    }


public class MULInstruction:ArithmeticInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        super.init(operation:.MUL,register1:register1,register2:register2,register3:register3)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,register3:Register)
        {
        super.init(operation:.MUL,register1:register1,immediate:immediate,register3:register3)
        }
        
    public init(immediate:Argon.Immediate,register2:Register,register3:Register)
        {
        super.init(operation:.MUL,immediate:immediate,register2:register2,register3:register3)
        }
    }


public class DIVInstruction:ArithmeticInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        super.init(operation:.DIV,register1:register1,register2:register2,register3:register3)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,register3:Register)
        {
        super.init(operation:.DIV,register1:register1,immediate:immediate,register3:register3)
        }
        
    public init(immediate:Argon.Immediate,register2:Register,register3:Register)
        {
        super.init(operation:.DIV,immediate:immediate,register2:register2,register3:register3)
        }
    }


public class MODInstruction:ArithmeticInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        super.init(operation:.MOD,register1:register1,register2:register2,register3:register3)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,register3:Register)
        {
        super.init(operation:.MOD,register1:register1,immediate:immediate,register3:register3)
        }
        
    public init(immediate:Argon.Immediate,register2:Register,register3:Register)
        {
        super.init(operation:.MOD,immediate:immediate,register2:register2,register3:register3)
        }
    }


public class ANDInstruction:ArithmeticInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        super.init(operation:.AND,register1:register1,register2:register2,register3:register3)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,register3:Register)
        {
        super.init(operation:.AND,register1:register1,immediate:immediate,register3:register3)
        }
        
    public init(immediate:Argon.Immediate,register2:Register,register3:Register)
        {
        super.init(operation:.AND,immediate:immediate,register2:register2,register3:register3)
        }
    }


public class ORInstruction:ArithmeticInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        super.init(operation:.OR,register1:register1,register2:register2,register3:register3)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,register3:Register)
        {
        super.init(operation:.OR,register1:register1,immediate:immediate,register3:register3)
        }
        
    public init(immediate:Argon.Immediate,register2:Register,register3:Register)
        {
        super.init(operation:.OR,immediate:immediate,register2:register2,register3:register3)
        }
    }


public class XORInstruction:ArithmeticInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,register3:Register)
        {
        super.init(operation:.XOR,register1:register1,register2:register2,register3:register3)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,register3:Register)
        {
        super.init(operation:.XOR,register1:register1,immediate:immediate,register3:register3)
        }
        
    public init(immediate:Argon.Immediate,register2:Register,register3:Register)
        {
        super.init(operation:.XOR,immediate:immediate,register2:register2,register3:register3)
        }
    }


public class NOTInstruction:ArithmeticInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register)
        {
        super.init(operation:.NOT,register1:register1,register2:register2,register3:.none)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,register3:Register)
        {
        super.init(operation:.MUL,register1:register1,immediate:immediate,register3:.none)
        }
        
    public init(immediate:Argon.Immediate,register2:Register,register3:Register)
        {
        super.init(operation:.MUL,immediate:immediate,register2:register2,register3:.none)
        }
    }


public class MOVInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString + self.operand1.displayString + "," + self.operand2.displayString)
        }
        
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
        
    public init(immediate:Argon.Immediate,register2:Register)
        {
        super.init(.MOV,.immediateRegister)
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register2)
        }
        
    public init(referenceAddress:Argon.Address,register2:Register)
        {
        super.init(.MOV,.addressRegister)
        self.operand1 = .referenceAddress(referenceAddress)
        self.operand2 = .register(register2)
        }
        
    public init(register1:Register,referenceAddress:Argon.Address)
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
        
    public override func execute(on thread:Thread) throws
        {
        switch(self.operand1,self.operand2)
            {
            case let(.address(address1),.address(address2)):
                setWordAtAddress(wordAtAddress(address1),address2)
            case let(.address(address1),.register(register)):
                thread.registers[register] = address1
            case let(.address(address1),.referenceRegister(register)):
                setWordAtAddress(address1,thread.registers[register])
            case let(.address(address1),.referenceAddress(address2)):
                setWordAtAddress(address1,address2)
            case let(.address(address1),.stack(offset)):
                thread.stack.setStackValue(address1,on: thread,at: offset)
            case let (.immediate(value),.register(register)):
                thread.registers[register] = Word(bitPattern: value)
            case let (.immediate(value),.referenceRegister(register)):
                setWordAtAddress(Word(bitPattern: value),thread.registers[register])
            case let (.immediate(value),.referenceAddress(address)):
                setWordAtAddress(Word(bitPattern: value),address)
            case let (.immediate(value),.stack(offset)):
                thread.stack.setStackValue(Word(bitPattern: value),on: thread,at: offset)
            case let (.register(register1),.register(register2)):
                thread.registers[register2] = thread.registers[register1]
            case let (.register(register1),.referenceAddress(address)):
                setWordAtAddress(thread.registers[register1],address)
            case let (.register(register1),.referenceRegister(register2)):
                setWordAtAddress(thread.registers[register1],thread.registers[register2])
            case let (.register(register1),.stack(offset)):
                thread.stack.setStackValue(thread.registers[register1],on: thread,at: offset)
            case let (.stack(offset1),.stack(offset2)):
                thread.stack.setStackValue(thread.stack.stackValue(on: thread,at: offset1),on: thread,at: offset2)
            case let (.stack(offset1),.register(register)):
                 thread.registers[register] = thread.stack.stackValue(on: thread,at: offset1)
            case let (.stack(offset1),.referenceRegister(register)):
                 setWordAtAddress(thread.stack.stackValue(on: thread,at: offset1),thread.registers[register])
            case let (.stack(offset1),.referenceAddress(address)):
                 setWordAtAddress(thread.stack.stackValue(on: thread,at: offset1),address)
            case let (.referenceAddress(address1),.referenceAddress(address2)):
                 setWordAtAddress(wordAtAddress(address1),address2)
            case let (.referenceAddress(address1),.register(register)):
                 thread.registers[register] = wordAtAddress(address1)
            case let (.referenceAddress(address1),.referenceRegister(register)):
                 setWordAtAddress(wordAtAddress(address1),thread.registers[register])
            case let (.referenceAddress(address1),.stack(offset)):
                 thread.stack.setStackValue(wordAtAddress(address1),on: thread,at: offset)
            case let (.referenceRegister(register1),.referenceAddress(address2)):
                 setWordAtAddress(wordAtAddress(thread.registers[register1]),address2)
            case let (.referenceRegister(register1),.register(register)):
                 thread.registers[register] = wordAtAddress(thread.registers[register1])
            case let (.referenceRegister(register1),.referenceRegister(register)):
                 setWordAtAddress(wordAtAddress(thread.registers[register1]),thread.registers[register])
            case let (.referenceRegister(register1),.stack(offset)):
                 thread.stack.setStackValue(wordAtAddress(thread.registers[register1]),on: thread,at: offset)
            default:
                fatalError("Invalid MOV operand pairing")
            }
        }
    }


public class BRInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString + self.operand.displayString)
        }
        
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

public class ConditionalBranchInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString + self.operand1.displayString + "," + self.operand2.displayString + "," + self.operand3.displayString)
        }
        
    private var operand1:Operand
    private var operand2:Operand
    private var operand3:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        self.operand2 = Mode.mode(of: word1).decodeOperand2(word1,word2,word3)
        self.operand3 = Mode.mode(of: word1).decodeOperand3(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(operation:Operation,register1:Register,register2:Register,label:Label)
        {
        self.operand1 = .register(register1)
        self.operand2 = .register(register2)
        self.operand3 = .label(label)
        super.init(operation,.registerRegisterLabel)
        }
        
    public init(operation:Operation,register1:Register,immediate:Argon.Immediate,label:Label)
        {
        self.operand2 = .immediate(immediate)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(operation,.registerImmediateRegister)
        }
        
    public init(operation:Operation,register1:Register,referenceAddress:Argon.Address,label:Label)
        {
        self.operand2 = .referenceAddress(referenceAddress)
        self.operand1 = .register(register1)
        self.operand3 = .label(label)
        super.init(operation,.registerAddressLabel)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        self.mode.encode(operand2: self.operand2,into: &words)
        self.mode.encode(operand3: self.operand3,into: &words)
        }
    }
    
public class BREQInstruction:ConditionalBranchInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        super.init(operation:.BREQ,register1:register1,register2:register2,label:label)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,label:Label)
        {
        super.init(operation:.BREQ,register1:register1,immediate:immediate,label:label)
        }
        
    public init(register1:Register,referenceAddress:Argon.Address,label:Label)
        {
        super.init(operation:.BREQ,register1:register1,referenceAddress:referenceAddress,label:label)
        }
    }


public class BRNEQInstruction:ConditionalBranchInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        super.init(operation:.BRNEQ,register1:register1,register2:register2,label:label)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,label:Label)
        {
        super.init(operation:.BRNEQ,register1:register1,immediate:immediate,label:label)
        }
        
    public init(register1:Register,referenceAddress:Argon.Address,label:Label)
        {
        super.init(operation:.BRNEQ,register1:register1,referenceAddress:referenceAddress,label:label)
        }
    }


public class BRZInstruction:ConditionalBranchInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        super.init(operation:.BRZ,register1:register1,register2:register2,label:label)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,label:Label)
        {
        super.init(operation:.BRZ,register1:register1,immediate:immediate,label:label)
        }
        
    public init(register1:Register,referenceAddress:Argon.Address,label:Label)
        {
        super.init(operation:.BRZ,register1:register1,referenceAddress:referenceAddress,label:label)
        }
    }


public class BRNZInstruction:ConditionalBranchInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        super.init(operation:.BRNZ,register1:register1,register2:register2,label:label)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,label:Label)
        {
        super.init(operation:.BRNZ,register1:register1,immediate:immediate,label:label)
        }
        
    public init(register1:Register,referenceAddress:Argon.Address,label:Label)
        {
        super.init(operation:.BRNZ,register1:register1,referenceAddress:referenceAddress,label:label)
        }
    }
    

public class BRGTInstruction:ConditionalBranchInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        super.init(operation:.BRGT,register1:register1,register2:register2,label:label)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,label:Label)
        {
        super.init(operation:.BRGT,register1:register1,immediate:immediate,label:label)
        }
        
    public init(register1:Register,referenceAddress:Argon.Address,label:Label)
        {
        super.init(operation:.BRGT,register1:register1,referenceAddress:referenceAddress,label:label)
        }
    }


public class BRGTEQInstruction:ConditionalBranchInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        super.init(operation:.BRGTEQ,register1:register1,register2:register2,label:label)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,label:Label)
        {
        super.init(operation:.BRGTEQ,register1:register1,immediate:immediate,label:label)
        }
        
    public init(register1:Register,referenceAddress:Argon.Address,label:Label)
        {
        super.init(operation:.BRGTEQ,register1:register1,referenceAddress:referenceAddress,label:label)
        }
    }


public class BRLTInstruction:ConditionalBranchInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        super.init(operation:.BRLT,register1:register1,register2:register2,label:label)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,label:Label)
        {
        super.init(operation:.BRLT,register1:register1,immediate:immediate,label:label)
        }
        
    public init(register1:Register,referenceAddress:Argon.Address,label:Label)
        {
        super.init(operation:.BRLT,register1:register1,referenceAddress:referenceAddress,label:label)
        }
    }


public class BRLTEQInstruction:ConditionalBranchInstruction
    {
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        super.init(word1,word2,word3)
        }
        
    public init(register1:Register,register2:Register,label:Label)
        {
        super.init(operation:.BRLTEQ,register1:register1,register2:register2,label:label)
        }
        
    public init(register1:Register,immediate:Argon.Immediate,label:Label)
        {
        super.init(operation:.BRLTEQ,register1:register1,immediate:immediate,label:label)
        }
        
    public init(register1:Register,referenceAddress:Argon.Address,label:Label)
        {
        super.init(operation:.BRLTEQ,register1:register1,referenceAddress:referenceAddress,label:label)
        }
    }


public class SLOTGETInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString + self.operand1.displayString + "," + self.operand2.displayString)
        }
        
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
        
    public init(register1:Register,immediate:Argon.Immediate,register2:Register)
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
    public override var displayString:String
        {
        return(super.displayString + self.operand1.displayString + "," + self.operand2.displayString)
        }
        
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
        
    public init(register1:Register,register2:Register,immediate:Argon.Immediate)
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
    public override var displayString:String
        {
        return(super.displayString + self.operand1.displayString)
        }
        
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
        
    public init(address:Argon.Address)
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
    public override var displayString:String
        {
        return(super.displayString + self.operand1.displayString)
        }
        
    private let operand1:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand1 = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(byteCount:Argon.Immediate)
        {
        self.operand1 = .immediate(byteCount)
        super.init(.ENTER,.immediate)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand1,into: &words)
        }
        
    public override func execute(on thread:Thread) throws
        {
        thread.stack.enterBlock(on: thread,localsSizeInBytes: self.operand1)
        }
    }


public class LEAVEInstruction:Instruction
    {
    public override var displayString:String
        {
        return(super.displayString + self.operand.displayString)
        }
        
    private let operand:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(byteCount:Argon.Immediate)
        {
        self.operand = .immediate(byteCount)
        super.init(.LEAVE,.immediate)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand,into: &words)
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
    public override var displayString:String
        {
        return(super.displayString + self.operand.displayString)
        }
        
    private let operand:Operand
    
    public override init(_ word1:Word,_ word2:Word,_ word3:Word)
        {
        self.operand = Mode.mode(of: word1).decodeOperand1(word1,word2,word3)
        super.init(word1,word2,word3)
        }
        
    public init(address:Argon.Address)
        {
        self.operand = .referenceAddress(address)
        super.init(.DISP,.address)
        }
        
    internal override func encode(into words:inout InstructionWord)
        {
        self.mode.encode(operand1: self.operand,into: &words)
        }
    }

