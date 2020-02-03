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
    public class func NOP() -> Instruction
        {
        return(Instruction(.NOP))
        }

    public class func PUSH(operand:Operand) -> Instruction
        {
        return(Instruction(.PUSH,operand))
        }
        
    public class func POP(operand:Operand) -> Instruction
        {
        return(Instruction(.POP,operand))
        }
        
    public class func MAKE(verge:VergePointer,parameters:[Operand]) -> Instruction
        {
        return(Instruction(.MAKE,.literal(.verge(verge)),.array(parameters)))
        }
        
    public class func ADD(operand1:Operand,operand2:Operand,operand3:Operand) -> Instruction
        {
        return(Instruction(.ADD,operand1,operand2,operand3))
        }

    public class func SUB(operand1:Operand,operand2:Operand,operand3:Operand) -> Instruction
        {
        return(Instruction(.SUB,operand1,operand2,operand3))
        }
        
    public class func MUL(operand1:Operand,operand2:Operand,operand3:Operand) -> Instruction
        {
        return(Instruction(.MUL,operand1,operand2,operand3))
        }
        
    public class func DIV(operand1:Operand,operand2:Operand,operand3:Operand) -> Instruction
        {
        return(Instruction(.DIV,operand1,operand2,operand3))
        }
        
    public class func MOD(operand1:Operand,operand2:Operand,operand3:Operand) -> Instruction
        {
        return(Instruction(.MOD,operand1,operand2,operand3))
        }
        
    public class func FADD(operand1:Operand,operand2:Operand,operand3:Operand) -> Instruction
        {
        return(Instruction(.FADD,operand1,operand2,operand3))
        }

    public class func FSUB(operand1:Operand,operand2:Operand,operand3:Operand) -> Instruction
        {
        return(Instruction(.FSUB,operand1,operand2,operand3))
        }
        
    public class func FMUL(operand1:Operand,operand2:Operand,operand3:Operand) -> Instruction
        {
        return(Instruction(.FMUL,operand1,operand2,operand3))
        }
        
    public class func FDIV(operand1:Operand,operand2:Operand,operand3:Operand) -> Instruction
        {
        return(Instruction(.FDIV,operand1,operand2,operand3))
        }
        
    public class func FMOD(operand1:Operand,operand2:Operand,operand3:Operand) -> Instruction
        {
        return(Instruction(.FMOD,operand1,operand2,operand3))
        }
        
    public class func AND(operand1:Operand,operand2:Operand,operand3:Operand) -> Instruction
        {
        return(Instruction(.AND,operand1,operand2,operand3))
        }
        
    public class func OR(operand1:Operand,operand2:Operand,operand3:Operand) -> Instruction
        {
        return(Instruction(.OR,operand1,operand2,operand3))
        }
        
    public class func XOR(operand1:Operand,operand2:Operand,operand3:Operand) -> Instruction
        {
        return(Instruction(.XOR,operand1,operand2,operand3))
        }
        
    public class func NOT(operand1:Operand,operand2:Operand) -> Instruction
        {
        return(Instruction(.NOT,operand1,operand2))
        }
        
    public class func MOV(contentsOf address:Address,into register:Register) -> Instruction
        {
        return(Instruction(.MOV,.addressRegister,.address(address,.indirect),.register(register,.direct)))
        }
        
    public class func MOV(contentsOf register:Register,into address:Address) -> Instruction
        {
        return(Instruction(.MOV,.registerAddress,.register(register,.direct),.address(address,.indirect)))
        }
        
    public class func MOV(contentsOf register1:Register,into register2:Register) -> Instruction
        {
        return(Instruction(.MOV,.registerRegister,.register(register1,.direct),.register(register2,.direct)))
        }
        
    public class func MOV(contentsPointedToBy register1:Register,into register2:Register) -> Instruction
        {
        return(Instruction(.MOV,.registerRegister,.register(register1,.indirect),.register(register2,.direct)))
        }
        
    public class func DISP(method:MethodPointer,parameters:[Operand]) -> Instruction
        {
        return(Instruction(.DISP,.address(method.taggedAddress,.direct),.array(parameters)))
        }
        
    public class func BR(label:Label) -> Instruction
        {
        return(Instruction(.BR,.label(label)))
        }
        
    public class func BREQ(operand1:Operand,operand2:Operand,label:Label) -> Instruction
        {
        return(Instruction(.BREQ,operand1,operand2,.label(label)))
        }
        
    public class func BRNEQ(operand1:Operand,operand2:Operand,label:Label) -> Instruction
        {
        return(Instruction(.BRNEQ,operand1,operand2,.label(label)))
        }
        
    public class func BTLT(operand1:Operand,operand2:Operand,label:Label) -> Instruction
        {
        return(Instruction(.BRLT,operand1,operand2,.label(label)))
        }
        
    public class func BRLTEQ(operand1:Operand,operand2:Operand,label:Label) -> Instruction
        {
        return(Instruction(.BRLTEQ,operand1,operand2,.label(label)))
        }
        
    public class func BRGTEQ(operand1:Operand,operand2:Operand,label:Label) -> Instruction
        {
        return(Instruction(.BRGTEQ,operand1,operand2,.label(label)))
        }
        
    public class func BRGT(operand1:Operand,operand2:Operand,label:Label) -> Instruction
        {
        return(Instruction(.BRGT,operand1,operand2,.label(label)))
        }
        
    public class func BRZ(operand1:Operand,label:Label) -> Instruction
        {
        return(Instruction(.BRZ,operand1,.label(label)))
        }
        
    public class func BRNZ(operand1:Operand,label:Label) -> Instruction
        {
        return(Instruction(.BRNZ,operand1,.label(label)))
        }
        
    public class func SLOTGET(instanceAddress:Address,slotOffset:Int) -> Instruction
        {
        return(Instruction(.SLOTGET,.addressLiteral,Operand.address(instanceAddress,.indirect),Operand.immediate(slotOffset)))
        }
        
    public class func SLOTSET(instanceAddress:Address,slotOffset:Int,value:Address) -> Instruction
        {
        return(Instruction(.SLOTSET,.address(instanceAddress,.indirect),.immediate(slotOffset),.address(value,.direct)))
        }
        
    public class func CALL(label:Label) -> Instruction
        {
        return(Instruction(.CALL,.label,.label(label)))
        }
        
    public class func ENTER(parameterCount:Int,localCount:Int) -> Instruction
        {
        return(Instruction(.ENTER,.immediateImmediate,.immediate(parameterCount),.immediate(localCount)))
        }
        
    public class func LEAVE() -> Instruction
        {
        return(Instruction(.LEAVE))
        }
        
    public class func RET() -> Instruction
        {
        return(Instruction(.RET))
        }
            
    public typealias Address = Word
    public typealias Offset = Int
    public typealias Index = Word
    public typealias Immediate = Int
    
    public enum DirectIndirect
        {
        case direct
        case indirect
        }
        
    public enum Operation:Word
        {
        public static let kMask:Word = Word(8191) << Word(47)
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
        public static let kRegister2Mask:Word = Word(255) << Word(32)
        public static let kRegister2Shift:Word = 32
        public static let kRegister3Mask:Word = Word(255) << Word(24)
        public static let kRegister3Shift:Word = 24
        
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
        
        case none = 0
        case address
        case addressLiteral
        case immediate
        case immediateImmediate
        case register
        case registerRegister
        case registerRegisterRegister
        case registerAddress
        case addressRegister
        case immediateRegister
        case registerRegisterImmediate
        case registerAddressImmediate
        case literal
        case literalAddress
        case label
        
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
        
    public var hasAddress:Bool
        {
        return(self.mode == .address || self.mode == .registerAddress || self.mode == .addressRegister || self.mode == .registerAddressImmediate)
        }

    public var hasRegister3:Bool
        {
        return(self.mode == .registerRegisterRegister)
        }
        
    public enum Literal
        {
        case integer(Argon.Integer)
        case uinteger(Argon.UInteger)
        case float32(Argon.Float32)
        case float64(Argon.Float64)
        case string(String)
        case boolean(Bool)
        case byte(Argon.Byte)
        case verge(VergePointer)
        case none
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
                case "literal":
                    return(.literal)
                case "literalAddress":
                    return(.literalAddress)
                case "label":
                    return(.label)
                default:
                    return(.none)
                }
            }
            
        case label(Label)
        case immediate(Immediate)
        case address(Address,DirectIndirect)
        case register(Register,DirectIndirect)
        case literal(Literal)
        case array([Operand])
        case none
        
    public func mode(with string:String) -> String
        {
        switch(self)
            {
            case .label:
                return(string + "Label")
            case .immediate:
                return(string + "Immediate")
            case .register:
                return(string + "Register")
            case .literal:
                return(string + "Literal")
            case .address:
                return(string + "Address")
            default:
                return("none")
            }
        }
        
        
        public func mode(forMode mode:String,with second:Operand) -> String
            {
            switch(self)
                {
                case .label:
                    return(second.mode(with: mode + "Label"))
                case .immediate:
                    return(second.mode(with: mode + "Immediate"))
                case .register:
                    return(second.mode(with: mode + "Register"))
                case .literal:
                    return(second.mode(with: mode + "Literal"))
                case .address:
                    return(second.mode(with: mode + "Address"))
                default:
                    return("none")
                }
            }
            
        public func mode(with first:Operand,with second:Operand) -> String
            {
            switch(self)
                {
                case .label:
                    return(first.mode(forMode: "label",with:second))
                case .immediate:
                    return(first.mode(forMode: "immediate",with:second))
                case .register:
                    return(first.mode(forMode: "register",with:second))
                case .literal:
                    return(first.mode(forMode: "literal",with:second))
                case .address:
                    return(first.mode(forMode: "address",with:second))
                default:
                    return("none")
                }
            }
            
        public func mode(with first:Operand) -> String
            {
            switch(self)
                {
                case .label:
                    return(first.mode(with: "label"))
                case .immediate:
                    return(first.mode(with: "immediate"))
                case .register:
                    return(first.mode(with: "register"))
                case .literal:
                    return(first.mode(with: "literal"))
                case .address:
                    return(first.mode(with: "address"))
                default:
                    return("none")
                }
            }
            
        public func mode() -> Mode
            {
            switch(self)
                {
                case .label:
                    return(.label)
                case .immediate:
                    return(.immediate)
                case .register:
                    return(.register)
                case .literal:
                    return(.literal)
                case .address:
                    return(.address)
                default:
                    return(.none)
                }
            }
            
        public func modeWithAddress() -> Mode
            {
            switch(self)
                {
                case .register:
                    return(.registerAddress)
                case .literal:
                    return(.literalAddress)
                default:
                    return(.none)
                }
            }
        }
        
    public let operation:Operation
    public let operand1:Operand
    public let operand2:Operand
    public let operand3:Operand
    public let mode:Mode
    public private(set) var incomingLabel:Int = 0
    public private(set) var outgoingLabels:[Int] = []
    
    public init(_ operation:Operation)
        {
        self.operation = operation
        self.mode = .none
        self.operand1 = .none
        self.operand2 = .none
        self.operand3 = .none
        }
        
    public init(_ operation:Operation,_ operand:Operand)
        {
        self.operation = operation
        self.mode = operand.mode()
        self.operand1 = operand
        self.operand2 = .none
        self.operand3 = .none
        }
        
    public init(_ operation:Operation,_ operand1:Operand,_ operand2:Operand)
        {
        self.operation = operation
        self.mode = Operand.stringAsMode(operand1.mode(with: operand2))
        self.operand1 = operand1
        self.operand2 = operand2
        self.operand3 = .none
        }
        
    public init(_ operation:Operation,_ operand1:Operand,_ address:Address)
        {
        self.operation = operation
        self.mode = operand1.modeWithAddress()
        self.operand2 = .address(address,.indirect)
        self.operand1 = operand1
        self.operand3 = .none
        }
        
    public init(_ operation:Operation,_ mode:Mode,_ operand1:Operand,_ operand2:Operand,_ operand3:Operand)
        {
        self.operation = operation
        self.mode = mode
        self.operand2 = operand2
        self.operand1 = operand1
        self.operand3 = operand3
        }
        
    public init(_ operation:Operation,_ mode:Mode,_ operand1:Operand)
        {
        self.operation = operation
        self.mode = mode
        self.operand2 = .none
        self.operand1 = operand1
        self.operand3 = .none
        }
        
    public init(_ operation:Operation,_ mode:Mode,_ operand1:Operand,_ operand2:Operand)
        {
        self.operation = operation
        self.mode = mode
        self.operand2 = operand2
        self.operand1 = operand1
        self.operand3 = .none
        }
        
    public init(_ operation:Operation,_ operand1:Operand,_ operand2:Operand,_ operand3:Operand)
        {
        self.operation = operation
        self.mode = Operand.stringAsMode(operand1.mode(with:operand2,with:operand3))
        self.operand2 = operand2
        self.operand1 = operand1
        self.operand3 = operand3
        }
        
    public init(_ operation:Operation,_ indirect:DirectIndirect = .direct,_ address:Word)
        {
        self.operation = operation
        self.mode = .address
        self.operand1 = .address(address,indirect)
        self.operand2 = .none
        self.operand3 = .none
        }
        
    public init(_ operation:Operation,_ immediate:Immediate)
        {
        self.operation = operation
        self.mode = .immediate
        self.operand1 = .immediate(immediate)
        self.operand2 = .none
        self.operand3 = .none
        }
        
    public init(_ operation:Operation,_ isIndirect:DirectIndirect = .direct,_ register:Register)
        {
        self.operation = operation
        self.mode = .register
        self.operand1 = .register(register,isIndirect)
        self.operand2 = .none
        self.operand3 = .none
        }
        
    public init(_ operation:Operation,_ isIndirect1:DirectIndirect = .direct,_ register1:Register,isIndirect2:DirectIndirect = .direct,_ register2:Register,isIndirect3:DirectIndirect = .direct,_ register3:Register)
        {
        self.operation = operation
        self.mode = .registerRegisterRegister
        self.operand1 = .register(register1,isIndirect1)
        self.operand2 = .register(register2,isIndirect2)
        self.operand3 = .register(register3,isIndirect3)
        }
        
    public init(_ operation:Operation,_ isIndirect1:DirectIndirect = .direct,_ register1:Register,isIndirect2:DirectIndirect = .direct,_ register2:Register)
        {
        self.operation = operation
        self.mode = .registerRegister
        self.operand1 = .register(register1,isIndirect1)
        self.operand2 = .register(register2,isIndirect2)
        self.operand3 = .none
        }
        
    public init(_ operation:Operation,_ isIndirect1:DirectIndirect = .direct,_ register1:Register,isIndirect2:DirectIndirect = .direct,_ address:Word)
        {
        self.operation = operation
        self.mode = .registerAddress
        self.operand1 = .register(register1,isIndirect1)
        self.operand2 = .address(address,isIndirect2)
        self.operand3 = .none
        }
        
    public init(_ operation:Operation,_ isIndirect1:DirectIndirect = .direct,_ address:Word,isIndirect2:DirectIndirect = .direct,_ register1:Register)
        {
        self.operation = operation
        self.mode = .addressRegister
        self.operand1 = .address(address,isIndirect1)
        self.operand2 = .register(register1,isIndirect2)
        self.operand3 = .none
        }
        
    public init(_ operation:Operation,_ immediate:Immediate,_ isIndirect1:DirectIndirect = .direct,_ register1:Register)
        {
        self.operation = operation
        self.mode = .immediateRegister
        self.operand1 = .immediate(immediate)
        self.operand2 = .register(register1,isIndirect1)
        self.operand3 = .none
        }
        
    public init(_ operation:Operation,_ isIndirect1:DirectIndirect = .direct,_ register1:Register,_ isIndirect2:DirectIndirect = .direct,_ register2:Register,_ immediate:Immediate)
        {
        self.operation = operation
        self.mode = .registerRegisterImmediate
        self.operand1 = .register(register1,isIndirect1)
        self.operand2 = .register(register2,isIndirect2)
        self.operand3 = .immediate(immediate)
        }
        
    public init(_ operation:Operation,_ isIndirect1:DirectIndirect = .direct,_ register1:Register,_ isIndirect2:DirectIndirect = .direct,_ address:Word,_ immediate:Immediate)
        {
        self.operation = operation
        self.mode = .registerAddressImmediate
        self.operand1 = .register(register1,isIndirect1)
        self.operand2 = .address(address,isIndirect2)
        self.operand3 = .immediate(immediate)
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
//    private func encode(immediate:Immediate,into:inout Word)
//        {
//        let value = Word(UInt32(bitPattern: immediate))
//        into |= (value & 4294967295)
//        }
        
    @inline(__always)
    private func encode(operand1:Register,into:inout Word)
        {
        into |= operand1.register1OrMask
        }
        
    @inline(__always)
    private func encode(operand2:Register,into:inout Word)
        {
        into |= operand2.register2OrMask
        }
        
    @inline(__always)
    private func encode(operand3:Register,into:inout Word)
        {
        into |= operand3.register3OrMask
        }
        
    @inline(__always)
    public func encode() -> (Word,Word)
        {
        var word:Word = 0
        word |= self.operation.orMask | self.mode.orMask
//        self.encode(immediate: self.immediate,into: &word)
//        self.encode(operand1: self.operand1,into: &word)
//        self.encode(operand2: self.operand2,into: &word)
//        if self.hasRegister3
//            {
//            self.encode(operand3: self.operand3,into: &word)
//            }
        return((word,0))
        }
        
    public func execute(on:Thread) throws
        {
        }
    }

extension Instruction.Immediate
    {
    public init(from: Word)
        {
        self.init(Int32(Int(from & Word(4294967295))))
        }
    }
