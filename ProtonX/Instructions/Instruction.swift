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
    public typealias Address = Word
    public typealias Offset = Int
    public typealias Index = Word
    public typealias Immediate = Int32
    
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
        
    public let operation:Operation
    public let register1:Register
    public let register2:Register
    public let register3:Register
    public let mode:Mode
    public var address:Word
    public var immediate:Immediate
        
    public init(_ operation:Operation)
        {
        self.operation = operation
        self.mode = .none
        self.address = 0
        self.immediate = 0
        self.register1 = .none
        self.register2 = .none
        self.register3 = .none
        }
        
    public init(word:Word,address:Word)
        {
        self.operation = Operation(from: word)
        self.mode = Mode(from: word)
        self.immediate = 0
        self.address = 0
        switch(mode)
            {
            case .none:
                self.register3 = .none
                self.register1 = .none
                self.register2 = .none
            case .immediate:
                self.immediate = Immediate(from: word)
                self.address = address
                self.register3 = .none
                self.register1 = .none
                self.register2 = .none
            case .address:
                self.address = address
                self.register3 = .none
                self.register1 = .none
                self.register2 = .none
            case .register:
                self.register1 = Register(register1: word)
                self.register3 = .none
                self.register2 = .none
            case .registerRegister:
                self.register1 = Register(register1: word)
                self.register2 = Register(register2: word)
                self.register3 = .none
            case .registerAddress:
                self.register1 = Register(register1: word)
                self.register3 = .none
                self.register2 = .none
                self.address = address
            case .registerRegisterImmediate:
                self.register1 = Register(register1: word)
                self.register2 = Register(register2: word)
                self.register3 = .none
                self.immediate = Immediate(from: word)
            case .registerRegisterRegister:
                self.register1 = Register(register1: word)
                self.register2 = Register(register2: word)
                self.register3 = Register(register2: word)
            case .addressRegister:
                self.register2 = Register(register1: word)
                self.register3 = .none
                self.register1 = .none
                self.address = address
            case .registerAddressImmediate:
                self.register1 = Register(register1: word)
                self.register3 = .none
                self.register2 = .none
                self.address = address
                self.immediate = Immediate(from: word)
            case .immediateRegister:
                self.register2 = Register(register1: word)
                self.register3 = .none
                self.register1 = .none
                self.immediate = Immediate(from: word)
            }
        }
        
    @inline(__always)
    private func encode(immediate:Immediate,into:inout Word)
        {
        let value = Word(UInt32(bitPattern: immediate))
        into |= (value & 4294967295)
        }
        
    @inline(__always)
    private func encode(register1:Register,into:inout Word)
        {
        into |= register1.register1OrMask
        }
        
    @inline(__always)
    private func encode(register2:Register,into:inout Word)
        {
        into |= register1.register2OrMask
        }
        
    @inline(__always)
    private func encode(register3:Register,into:inout Word)
        {
        into |= register1.register3OrMask
        }
        
    @inline(__always)
    public func encode() -> (Word,Word)
        {
        var word:Word = 0
        word |= self.operation.orMask | self.mode.orMask
        self.encode(immediate: self.immediate,into: &word)
        self.encode(register1: self.register1,into: &word)
        self.encode(register2: self.register2,into: &word)
        if self.hasRegister3
            {
            self.encode(register3: self.register3,into: &word)
            }
        return((word,address))
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
