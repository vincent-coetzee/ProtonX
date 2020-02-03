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
        return((self.packagePointer?.fullName ?? "") + "::" + self.nameSlot.value.string)
        }
    
//    public var namePointer:ImmutableStringPointer?
//        {
//        get
//            {
//            return(ImmutableStringPointer(untaggedPointerAtIndexAtPointer(Self.kPackageElementNameIndex,self.pointer)))
//            }
//        set
//            {
//            tagAndSetPointerAtIndexAtPointer(newValue?.pointer,Self.kPackageElementNameIndex,self.pointer)
//            }
//        }
        
    private var  _packagePointer:PackagePointer?
    
    public var packagePointer:PackagePointer?
        {
        get
            {
            if self._packagePointer != nil
                {
                return(self._packagePointer)
                }
            self._packagePointer = PackagePointer(untaggedPointerAtIndexAtPointer(Self.kPackageElementPackageIndex,self.pointer))
            return(self._packagePointer)
            }
        set
            {
            self._packagePointer = newValue
            tagAndSetPointerAtIndexAtPointer(newValue?.pointer,Self.kPackageElementPackageIndex,self.pointer)
            }
        }
        
    public var name:String
        {
        get
            {
            return(self.nameSlot.value.string)
            }
        set
            {
            self.nameSlot.value = ImmutableStringPointer(newValue)
            }
        }
        
    public let nameSlot = SlotValue<ImmutableStringPointer>(index: PackageElementPointer.kPackageElementNameIndex)
    
    internal override func initSlots()
        {
        self.nameSlot.source = self
        }

    }
