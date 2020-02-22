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
    public class func makeInstruction(atAddress:Proton.Address) -> Instruction
        {
        var address = atAddress
        let word1 = wordAtAddress(address)
        var word2:Word = 0
        var word3:Word = 0
        var word4:Word = 0
        if Self.instructionWordHasAddress(word1)
            {
            address += Proton.Address(MemoryLayout<Word>.stride)
            word2 = wordAtAddress(address)
            }
        if Self.instructionWordHasImmediate(word1)
            {
            address += Proton.Address(MemoryLayout<Word>.stride)
            word3 = wordAtAddress(address)
            }
        if Self.instructionWordHasOffsets(word1)
            {
            address += Proton.Address(MemoryLayout<Word>.stride)
            word4 = wordAtAddress(address)
            }
        return(self.makeInstruction(from: word1,with: word2,with: word3,with: word4))
        }
        
    public class func makeInstruction(from word1:Word,with word2:Word,with word3:Word,with word4:Word) -> Instruction
        {
        let operation = Operation(rawValue: (word1 & Self.Operation.kMask) >> Self.Operation.kShift)!
        switch(operation)
            {
            case .NOP:
                return(NOPInstruction())
            case .MOV:
                return(MOVInstruction(word1,word2,word3,word4))
            case .PUSH:
                return(PUSHInstruction(word1,word2,word3,word4))
            case .POP:
                return(POPInstruction(word1,word2,word3,word4))
            case .CALL:
                return(CALLInstruction(word1,word2,word3,word4))
            case .ENTER:
                return(ENTERInstruction(word1,word2,word3,word4))
            case .LEAVE:
                return(LEAVEInstruction(word1,word2,word3,word4))
            case .RET:
                return(RETInstruction(word1,word2,word3,word4))
            case .DISP:
                return(DISPInstruction(word1,word2,word3,word4))
            case .BR:
                return(BRInstruction(word1,word2,word3,word4))
            case .BRNZ:
                return(BRNZInstruction(word1,word2,word3,word4))
            case .BRZ:
                return(BRZInstruction(word1,word2,word3,word4))
            case .BREQ:
                return(BREQInstruction(word1,word2,word3,word4))
            case .BRNEQ:
                return(BRNEQInstruction(word1,word2,word3,word4))
            case .BRLT:
                return(BRLTInstruction(word1,word2,word3,word4))
            case .BRGT:
                return(BRGTInstruction(word1,word2,word3,word4))
            case .BRLTEQ:
                return(BRLTEQInstruction(word1,word2,word3,word4))
            case .BRGTEQ:
                return(BRGTEQInstruction(word1,word2,word3,word4))
            case .SLOTGET:
                return(SLOTGETInstruction(word1,word2,word3,word4))
            case .SLOTSET:
                return(SLOTSETInstruction(word1,word2,word3,word4))
            case .ADD:
                return(ADDInstruction(word1,word2,word3,word4))
            case .SUB:
                return(SUBInstruction(word1,word2,word3,word4))
            case .MUL:
                return(MULInstruction(word1,word2,word3,word4))
            case .DIV:
                return(DIVInstruction(word1,word2,word3,word4))
            case .MOD:
                return(MODInstruction(word1,word2,word3,word4))
            case .AND:
                return(ANDInstruction(word1,word2,word3,word4))
            case .OR:
                return(ORInstruction(word1,word2,word3,word4))
            case .XOR:
                return(XORInstruction(word1,word2,word3,word4))
            case .NOT:
                return(NOTInstruction(word1,word2,word3,word4))
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
    
    public class func instructionWordHasOffsets(_ word:Word) -> Bool
        {
        return(word & Self.kOperand1HasOffsetMask == Self.kOperand1HasOffsetMask || word & Self.kOperand2HasOffsetMask == Self.kOperand2HasOffsetMask || word & Self.kOperand3HasOffsetMask == Self.kOperand3HasOffsetMask)
        }
        
    public struct InstructionWord
        {
        public static let kOffset1Mask:Word = Word(2097151)
        public static let kOffset1MaskShifted:Word = Word(2097151) << Word(42)
        public static let kOffset1Shift:Word = 42
        
        public static let kOffset2Mask:Word = Word(2097151)
        public static let kOffset2MaskShifted:Word = Word(2097151) << Word(21)
        public static let kOffset2Shift:Word = 21
        
        public static let kOffset3Mask:Word = Word(2097151)
        public static let kOffset3MaskShifted:Word = Word(2097151)
        public static let kOffset3Shift:Word = 0
        
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
            
        public var offset1:Word
            {
            get
                {
                return((self.offsets & Self.kOffset1MaskShifted) >> Self.kOffset1Shift)
                }
            set
                {
                self.hasOffset = true
                self.offsets &= ~Self.kOffset1MaskShifted
                self.offsets |= (newValue & Self.kOffset1Mask) << Self.kOffset1Shift
                }
            }
            
        public var offset2:Word
            {
            get
                {
                return((self.offsets & Self.kOffset2MaskShifted) >> Self.kOffset2Shift)
                }
            set
                {
                self.hasOffset = true
                self.offsets &= ~Self.kOffset2MaskShifted
                self.offsets |= (newValue & Self.kOffset2Mask) << Self.kOffset2Shift
                }
            }
            
        public var offset3:Word
            {
            get
                {
                return((self.offsets & Self.kOffset3MaskShifted) >> Self.kOffset3Shift)
                }
            set
                {
                self.hasOffset = true
                self.offsets &= ~Self.kOffset3MaskShifted
                self.offsets |= (newValue & Self.kOffset3Mask) << Self.kOffset3Shift
                }
            }
            
        public var instruction:Word
        private var _address:Word
        private var _immediate:Word
        private var offsets:Word
        public var hasAddress = false
        public var hasImmediate = false
        public var hasOffset = false
        
        public init(instruction:Word,address:Word,immediate:Word,offsets:Word)
            {
            self.instruction = instruction
            self._address = address
            self._immediate = immediate
            self.offsets = offsets
            }
        }
        
    public enum Operation:Word
        {
        public static let kMask:Word = Word(4095) << Word(46)
        public static let kShift:Word = 46
        
        case NOP = 0
        case PUSH
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
        case COERCEF32
        case COERCEF64
        case COERCEINT
        case COERCEUINT
        case COERCECHAR
        case COERCEBYTE
        case LOCALGET
        case LOCALSET
        case PARMGET
        
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
        case fp
        case ip
        case cbp
        case rr
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
        case r16
        case r17
        case r18
        case r19
        case r20
        case r21
        case r22
        case r23
        case r24
        case r25
        case r26
        case r27
        case r28
        case r29
        case r30
        case r31
        case r32
        case r33
        case r34
        case r35
        case r36
        case r37
        case r38
        case r39
        case r40
        case r41
        case r42
        case r43
        case r44
        case r45
        case r46
        case r47
        case r48
        case r49
        case r50
        case r51
        case r52
        case r53
        case r54
        case r55
        case r56
        case r57
        case r58
        case r59
        case r60
        case r61
        case r62
        case r63
        
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
        
        public func decodeOperand3(_ word1:Word,_ word2:Word,_ word3:Word,_ word4:Word) -> Operand
            {
            switch(self)
                {
                case .registerImmediateRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister3Mask) >> Register.kRegister3Shift))!
                    let offset = word1 & kOperand3HasOffsetMask == kOperand3HasOffsetMask ? (word4 & kOperand3HasOffsetMask) >> kOperand3HasOffsetShift : nil
                    return((word1 & kOperand3IsReferenceMask) == kOperand3IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .immediateRegisterRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister3Mask) >> Register.kRegister3Shift))!
                    let offset = word1 & kOperand3HasOffsetMask == kOperand3HasOffsetMask ? (word4 & kOperand3HasOffsetMask) >> kOperand3HasOffsetShift : nil
                    return((word1 & kOperand3IsReferenceMask) == kOperand3IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .registerRegisterRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister3Mask) >> Register.kRegister3Shift))!
                    let offset = word1 & kOperand3HasOffsetMask == kOperand3HasOffsetMask ? (word4 & kOperand3HasOffsetMask) >> kOperand3HasOffsetShift : nil
                    return((word1 & kOperand3IsReferenceMask) == kOperand3IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .registerRegisterImmediate:
                    return(.immediate(Proton.Immediate(bitPattern: word3)))
                case .registerAddressImmediate:
                    return(.immediate(Proton.Immediate(bitPattern: word3)))
                case .registerRegisterLabel:
                    return(.label(Label(key: Int(Proton.Immediate(bitPattern:word3)))))
                case .registerImmediateLabel:
                    return(.label(Label(key: Int(Proton.Immediate(bitPattern:word3)))))
                case .registerAddressLabel:
                    return(.label(Label(key: Int(Proton.Immediate(bitPattern:word3)))))
                default:
                    break
                }
            return(.none)
            }
            
        public func decodeOperand2(_ word1:Word,_ word2:Word,_ word3:Word,_ word4:Word) -> Operand
            {
            switch(self)
                {
                case .none:
                    return(.none)
                case .addressImmediate:
                    return(.immediate(Proton.Immediate(bitPattern: word3)))
                case .registerRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!
                    let offset = word1 & kOperand2HasOffsetMask == kOperand2HasOffsetMask ? (word4 & kOperand2HasOffsetMask) >> kOperand2HasOffsetShift : nil
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .registerImmediateRegister:
                    return(.immediate(Proton.Immediate(bitPattern: word3)))
                case .immediateRegisterRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!
                    let offset = word1 & kOperand2HasOffsetMask == kOperand2HasOffsetMask ? (word4 & kOperand2HasOffsetMask) >> kOperand2HasOffsetShift : nil
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .registerRegisterRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!
                    let offset = word1 & kOperand2HasOffsetMask == kOperand2HasOffsetMask ? (word4 & kOperand2HasOffsetMask) >> kOperand2HasOffsetShift : nil
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .registerAddress:
                    return(.address(word2))
                case .addressRegister:
                     let register = Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!
                     let offset = word1 & kOperand2HasOffsetMask == kOperand2HasOffsetMask ? (word4 & kOperand2HasOffsetMask) >> kOperand2HasOffsetShift : nil
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .immediateRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!
                    let offset = word1 & kOperand2HasOffsetMask == kOperand2HasOffsetMask ? (word4 & kOperand2HasOffsetMask) >> kOperand2HasOffsetShift : nil
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .registerRegisterImmediate:
                    let register = Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!
                    let offset = word1 & kOperand2HasOffsetMask == kOperand2HasOffsetMask ? (word4 & kOperand2HasOffsetMask) >> kOperand2HasOffsetShift : nil
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .registerAddressImmediate:
                    let offset = word1 & kOperand2HasOffsetMask == kOperand2HasOffsetMask ? (word4 & kOperand2HasOffsetMask) >> kOperand2HasOffsetShift : nil
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .addressee(word2,offset) : .address(word2))
                case .stackRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!
                    let offset = word1 & kOperand2HasOffsetMask == kOperand2HasOffsetMask ? (word4 & kOperand2HasOffsetMask) >> kOperand2HasOffsetShift : nil
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .registerStack:
                    return(.stack(Int(Int64(bitPattern: word3))))
                case .registerRegisterLabel:
                    let register = Register(rawValue: Int((word1 & Register.kRegister2Mask) >> Register.kRegister2Shift))!
                    let offset = word1 & kOperand2HasOffsetMask == kOperand2HasOffsetMask ? (word4 & kOperand2HasOffsetMask) >> kOperand2HasOffsetShift : nil
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .registerImmediateLabel:
                    return(.immediate(Proton.Immediate(bitPattern: word3)))
                case .registerAddressLabel:
                    let offset = word1 & kOperand2HasOffsetMask == kOperand2HasOffsetMask ? (word4 & kOperand2HasOffsetMask) >> kOperand2HasOffsetShift : nil
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .addressee(word2,offset) : .address(word2))
                case .immediateAddress:
                    let offset = word1 & kOperand2HasOffsetMask == kOperand2HasOffsetMask ? (word4 & kOperand2HasOffsetMask) >> kOperand2HasOffsetShift : nil
                    return((word1 & kOperand2IsReferenceMask) == kOperand2IsReferenceMask ? .addressee(word2,offset) : .address(word2))
                default:
                    break
                }
            return(.none)
            }
            
        public func decodeOperand1(_ word1:Word,_ word2:Word,_ word3:Word,_ word4:Word) -> Operand
            {
            switch(self)
                {
                case .none:
                    return(.none)
                case .address:
                    let offset = word1 & kOperand1HasOffsetMask == kOperand1HasOffsetMask ? (word4 & kOperand1HasOffsetMask) >> kOperand1HasOffsetShift : nil
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .addressee(word2,offset) : .address(word2))
                case .addressImmediate:
                    let offset = word1 & kOperand1HasOffsetMask == kOperand1HasOffsetMask ? (word4 & kOperand1HasOffsetMask) >> kOperand1HasOffsetShift : nil
                   return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .addressee(word2,offset) : .address(word2))
                case .immediate:
                    return(.immediate(Proton.Immediate(bitPattern: word3)))
                case .register:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    let offset = word1 & kOperand1HasOffsetMask == kOperand1HasOffsetMask ? (word4 & kOperand1HasOffsetMask) >> kOperand1HasOffsetShift : nil
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .registerRegister:
                     let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                     let offset = word1 & kOperand1HasOffsetMask == kOperand1HasOffsetMask ? (word4 & kOperand1HasOffsetMask) >> kOperand1HasOffsetShift : nil
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .registerImmediateRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    let offset = word1 & kOperand1HasOffsetMask == kOperand1HasOffsetMask ? (word4 & kOperand1HasOffsetMask) >> kOperand1HasOffsetShift : nil
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .immediateRegisterRegister:
                    return(.immediate(Proton.Immediate(bitPattern: word3)))
                case .registerRegisterRegister:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    let offset = word1 & kOperand1HasOffsetMask == kOperand1HasOffsetMask ? (word4 & kOperand1HasOffsetMask) >> kOperand1HasOffsetShift : nil
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .registerAddress:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    let offset = word1 & kOperand1HasOffsetMask == kOperand1HasOffsetMask ? (word4 & kOperand1HasOffsetMask) >> kOperand1HasOffsetShift : nil
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .addressRegister:
                    return(.address(word2))
                case .immediateRegister:
                    return(.immediate(Proton.Immediate(bitPattern: word3)))
                case .registerAddressImmediate:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    let offset = word1 & kOperand1HasOffsetMask == kOperand1HasOffsetMask ? (word4 & kOperand1HasOffsetMask) >> kOperand1HasOffsetShift : nil
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .label:
                    return(.label(Label(key: Int(Proton.Immediate(bitPattern:word3)))))
                case .stackRegister:
                    return(.stack(Int(Int64(bitPattern: word3))))
                case .registerStack:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    let offset = word1 & kOperand1HasOffsetMask == kOperand1HasOffsetMask ? (word4 & kOperand1HasOffsetMask) >> kOperand1HasOffsetShift : nil
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .registerRegisterLabel:
                     let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                     let offset = word1 & kOperand1HasOffsetMask == kOperand1HasOffsetMask ? (word4 & kOperand1HasOffsetMask) >> kOperand1HasOffsetShift : nil
                     return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .registerImmediateLabel:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    let offset = word1 & kOperand1HasOffsetMask == kOperand1HasOffsetMask ? (word4 & kOperand1HasOffsetMask) >> kOperand1HasOffsetShift : nil
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .registerAddressLabel:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    let offset = word1 & kOperand1HasOffsetMask == kOperand1HasOffsetMask ? (word4 & kOperand1HasOffsetMask) >> kOperand1HasOffsetShift : nil
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                case .immediateAddress:
                    return(.immediate(Proton.Immediate(bitPattern: word3)))
                case .registerRegisterImmediate:
                    let register = Register(rawValue: Int((word1 & Register.kRegister1Mask) >> Register.kRegister1Shift))!
                    let offset = word1 & kOperand1HasOffsetMask == kOperand1HasOffsetMask ? (word4 & kOperand1HasOffsetMask) >> kOperand1HasOffsetShift : nil
                    return((word1 & kOperand1IsReferenceMask) == kOperand1IsReferenceMask ? .registerAddressee(register,offset) : .register(register))
                }
            }
            
        public func encode(operand3: Operand,into instruction:inout InstructionWord)
            {
            switch(self,operand3)
                {
                case let(.registerAddress,.addressee(value,offset)):
                    instruction.address = value
                    instruction.operand3IsReference = true
                    if let offset = offset
                        {
                        instruction.offset3 = offset
                        }
                case let(.registerAddress,.address(value)):
                    instruction.address = value
                    instruction.operand3IsReference = false
                case let(.registerAddressImmediate,.immediate(value)):
                    instruction.immediate = UInt64(bitPattern: value)
                case let(.registerRegisterRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister3Shift)
                    instruction.operand3IsReference = false
                case let(.registerRegisterRegister,.registerAddressee(value,offset)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister3Shift)
                    instruction.operand3IsReference = true
                    if let offset = offset
                        {
                        instruction.offset3 = offset
                        }
                case let(.registerRegisterImmediate,.immediate(value)):
                    instruction.immediate = UInt64(bitPattern: value)
                case let(.registerImmediateRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister3Shift)
                    instruction.operand3IsReference = false
                case let(.registerImmediateRegister,.registerAddressee(value,offset)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister3Shift)
                    instruction.operand3IsReference = true
                    if let offset = offset
                        {
                        instruction.offset3 = offset
                        }
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
                case let(.address,.addressee(value,offset)):
                    instruction.address = value
                    instruction.operand1IsReference = true
                    if let offset = offset
                        {
                        instruction.offset1 = offset
                        }
                case let(.addressRegister,.address(value)):
                    instruction.address = value
                case let(.addressRegister,.addressee(value,offset)):
                    instruction.address = value
                    instruction.operand1IsReference = true
                    if let offset = offset
                        {
                        instruction.offset1 = offset
                        }
                case let(.registerImmediateRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerImmediateRegister,.registerAddressee(value,offset)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                    instruction.operand1IsReference = true
                    if let offset = offset
                        {
                        instruction.offset1 = offset
                        }
                case let(.register,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.register,.registerAddressee(value,offset)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                    instruction.operand1IsReference = true
                    if let offset = offset
                        {
                        instruction.offset1 = offset
                        }
                case let(.registerRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerRegister,.registerAddressee(value,offset)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                    instruction.operand1IsReference = true
                    if let offset = offset
                        {
                        instruction.offset1 = offset
                        }
                case let(.registerRegisterRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerRegisterRegister,.registerAddressee(value,offset)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                    instruction.operand1IsReference = true
                    if let offset = offset
                        {
                        instruction.offset1 = offset
                        }
                case let(.registerRegisterImmediate,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerRegisterImmediate,.registerAddressee(value,offset)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                    instruction.operand1IsReference = true
                    if let offset = offset
                        {
                        instruction.offset1 = offset
                        }
                case let(.registerAddressImmediate,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerAddressImmediate,.registerAddressee(value,offset)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                    instruction.operand1IsReference = true
                    if let offset = offset
                        {
                        instruction.offset1 = offset
                        }
                case let(.registerAddress,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerAddress,.registerAddressee(value,offset)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                    instruction.operand1IsReference = true
                    if let offset = offset
                        {
                        instruction.offset1 = offset
                        }
                case let(.immediate,.immediate(value)):
                    instruction.immediate = UInt64(bitPattern: value)
                case let(.immediateRegister,.immediate(value)):
                     instruction.immediate = UInt64(bitPattern: value)
                case let(.label,.label(value)):
                     instruction.immediate = Word(UInt(bitPattern: value.key))
                case let(.registerStack,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                case let(.registerStack,.registerAddressee(value,offset)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister1Shift)
                    instruction.operand1IsReference = true
                    if let offset = offset
                        {
                        instruction.offset1 = offset
                        }
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
                case let(.registerRegister,.registerAddressee(value,offset)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                    instruction.operand2IsReference = true
                    if let offset = offset
                        {
                        instruction.offset2 = offset
                        }
                case let(.registerRegisterRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                case let(.registerRegisterRegister,.registerAddressee(value,offset)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                    instruction.operand2IsReference = true
                    if let offset = offset
                        {
                        instruction.offset2 = offset
                        }
                case let(.registerRegisterImmediate,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                case let(.registerRegisterImmediate,.registerAddressee(value,offset)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                    instruction.operand2IsReference = true
                    if let offset = offset
                        {
                        instruction.offset2 = offset
                        }
                case let(.addressRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                case let(.addressRegister,.registerAddressee(value,offset)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                    instruction.operand2IsReference = true
                    if let offset = offset
                        {
                        instruction.offset2 = offset
                        }
                case let(.immediateRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                case let(.immediateRegister,.registerAddressee(value,offset)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                    instruction.operand2IsReference = true
                    if let offset = offset
                        {
                        instruction.offset2 = offset
                        }
                case let(.registerStack,.stack(value)):
                    instruction.instruction |= (Word(UInt32(bitPattern: Int32(value)) & 4294967295))
                case let(.stackRegister,.register(value)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                case let(.stackRegister,.registerAddressee(value,offset)):
                    instruction.instruction |= Word(value.rawValue << Register.kRegister2Shift)
                    instruction.operand2IsReference = true
                    if let offset = offset
                        {
                        instruction.offset2 = offset
                        }
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
    
    public static let kOperand1HasOffsetMask:Word = Word(1) << Word(18)
    public static let kOperand1HasOffsetShift:Word = 18
    public static let kOperand2HasOffsetMask:Word = Word(1) << Word(17)
    public static let kOperand2HasOffsetShift:Word = 17
    public static let kOperand3HasOffsetMask:Word = Word(1) << Word(16)
    public static let kOperand3HasOffsetShift:Word = 16
    
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
                case .addressee(let value,let offset):
                    let offsetString = offset == nil ? "" : " + \(offset!)"
                    return("[\(value)\(offsetString)]")
                case .register(let value):
                    return("\(value)")
                case .registerAddressee(let value):
                    return("[\(value)]")
                case .stack(let value):
                    return("BP[\(value)]")
                case .none:
                    return("NONE")
                }
            }
            
            
        public var hasOffset:Bool
            {
            switch(self)
                {
                case .addressee(_,let offset):
                    return(offset != nil)
                case .registerAddressee(_,let offset):
                    return(offset != nil)
                default:
                    return(false)
                }
            }
            
        case label(Label)
        case immediate(Proton.Immediate)
        case address(Proton.Address)
        case addressee(Proton.Address,Proton.Offset?)
        case register(Register)
        case registerAddressee(Register,Proton.Offset?)
        case stack(Int)
        case none
        }
        
    public var encoded:InstructionWord
        {
        var word:InstructionWord = InstructionWord(instruction:0,address:0,immediate:0,offsets:0)
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
        
    public init(_ word1:Word,_ word2:Word,_ word3:Word,_ word4:Word)
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
        
//    @inline(__always)
//    public func encode(into pointer:inout UnsafeMutablePointer<Word>)
//        {
//        let word = self.encoded
//        pointer.pointee = word.instruction
//        if word.hasAddress
//            {
//            pointer += 1
//            pointer.pointee = word.address
//            }
//        }
        
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
    public var address:Proton.Address
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
        
    public var immediate:Proton.Immediate
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

