//
//  PackageElementPointer.swift
//  argon
//
//  Created by Vincent Coetzee on 31/01/2020.
//  Copyright © 2020 macsemantics. All rights reserved.
//

import Foundation
import RawMemory

public class PackageElementPointer:ObjectPointer,NamedPointer
    {
    public static let kPackageElementNameIndex = SlotIndex.nine
    public static let kPackageElementPackageIndex = SlotIndex.ten
    
    public override class var totalSlotCount:Argon.SlotCount
        {
        return(11)
        }
        
    public var fullName:String
        {
        return((self.packagePointer?.fullName ?? "") + "::" + self.name)
        }
        
    public var namePointer:ImmutableStringPointer?
        {
        get
            {
            return(ImmutableStringPointer(untaggedPointerAtIndexAtPointer(Self.kPackageElementNameIndex,self.pointer)))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue?.pointer,Self.kPackageElementNameIndex,self.pointer)
            }
        }
        
    public var packagePointer:PackagePointer?
        {
        get
            {
            return(PackagePointer(untaggedPointerAtIndexAtPointer(Self.kPackageElementPackageIndex,self.pointer)))
            }
        set
            {
            tagAndSetPointerAtIndexAtPointer(newValue?.pointer,Self.kPackageElementPackageIndex,self.pointer)
            }
        }
        
    public var name:String
        {
        get
            {
            return(self.namePointer?.string ?? "")
            }
        set
            {
            self.namePointer = ImmutableStringPointer(newValue)
            }
        }
    }
