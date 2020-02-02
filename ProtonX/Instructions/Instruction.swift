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
        
    public class func MAKE(operand1:Operand,_ operand2:Operand) -> Instruction
        {
        return(Instruction(.MAKE,operand1,operand2))
        }
        
    public class func ARITHMETIC(_ operation:Operation,operand1:Operand,operand2:Operand,operand3:Operand) -> Instruction
        {
        return(Instruction(operation,operand1,operand2,operand3))
        }
        
    public class func DISP(operand1:Operand) -> Instruction
        {
        return(Instruction(.DISP,operand1))
        }
        
    public class func BRANCH(operation:Operation,operand1:Operand,operand2:Operand,operand3:Operand) -> Instruction
        {
        return(Instruction(operation,operand1,operand2,operand3))
        }
        
    public class func SLOTGET(operand1:Operand,operand2:Operand) -> Instruction
        {
        return(Instruction(.SLOTGET,operand1,operand2))
        }
        
    public class func SLOTSET(operand1:Operand,operand2:Operand,operand3:Operand) -> Instruction
        {
        return(Instruction(.SLOTSET,operand1,operand2,operand3))
        }
        
    public class func CALL(operand1:Operand) -> Instruction
        {
        return(Instruction(.CALL,.label,operand1))
        }
        
    public class func ENTER(operand1:Operand) -> Instruction
        {
        return(Instruction(.CALL,.immediate,operand1))
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
    public typealias Immediate = Int32
    
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
        case MOD
        case FMOD
        case AND
        case OR
        case XOR
        case NOT
        case DISP
        case NEXT
        case BR
        case BRE
        case BRNE
        case BRGT
        case BRGTE
        case BRLT
        case BRLTE
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
        
    public enum Register:Int
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
        case immediate
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
        case none
        }
        
    public enum Operand
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
            
        case label(Int)
        case immediate(Immediate)
        case address(Address,DirectIndirect)
        case register(Register,DirectIndirect)
        case literal(Literal)
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
        
    public init(word:Word,address1:Word,literal:Literal = .none,label:Int = 0)
        {
        self.operation = Operation(from: word)
        self.mode = Mode(from: word)
        switch(mode)
            {
            case .literal:
                self.operand3 = .none
                self.operand1 = .literal(literal)
                    
                self.operand2 = .none
            case .literalAddress:
                self.operand3 = .none
                self.operand1 = .literal(literal)
                self.operand2 = .address(address1,.indirect)
            case .none:
                self.operand3 = .none
                self.operand1 = .none
                self.operand2 = .none
            case .immediate:
                self.operand3 = .none
                self.operand1 = .immediate(Immediate(from: word))
                self.operand2 = .none
            case .address:
                self.operand3 = .none
                self.operand1 = .address(Address(address1),.direct)
                self.operand2 = .none
            case .register:
                self.operand1 = .register(Register(register1: word),.direct)
                self.operand3 = .none
                self.operand2 = .none
            case .registerRegister:
                self.operand1 = .register(Register(register1: word),.direct)
                self.operand2 = .register(Register(register2: word),.direct)
                self.operand3 = .none
            case .registerAddress:
                self.operand1 = .register(Register(register1: word),.direct)
                self.operand3 = .address(address1,.direct)
                self.operand2 = .none
            case .registerRegisterImmediate:
                self.operand1 = .register(Register(register1: word),.direct)
                self.operand2 = .register(Register(register2: word),.direct)
                self.operand3 = .immediate(Immediate(from: word))
            case .registerRegisterRegister:
                self.operand1 = .register(Register(register1: word),.direct)
                self.operand2 = .register(Register(register2: word),.direct)
                self.operand3 = .register(Register(register3: word),.direct)
            case .addressRegister:
                self.operand2 = .register(Register(register2: word),.direct)
                self.operand3 = .none
                self.operand1 = .none
            case .registerAddressImmediate:
                self.operand1 = .register(Register(register1: word),.direct)
                self.operand3 = .immediate(Immediate(from: word))
                self.operand2 = .address(address1,.direct)
            case .immediateRegister:
                self.operand2 = .register(Register(register2: word),.direct)
                self.operand3 = .none
                self.operand1 = .immediate(Immediate(from: word))
            case .label:
                self.operand2 = .none
                self.operand3 = .none
                self.operand1 = .label(label)
            }
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
    private func encode(immediate:Immediate,into:inout Word)
        {
        let value = Word(UInt32(bitPattern: immediate))
        into |= (value & 4294967295)
        }
        
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
