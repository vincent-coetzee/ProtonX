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
    
    public override class var totalSlotCount:Proton.SlotCount
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
//            return(ImmutableStringPointer(addressAtIndexAtAddress(Self.kPackageElementNameIndex,self.address)))
//            }
//        set
//            {
//            setAddressAtIndexAtAddress((newValue?.address ?? 0,Self.kPackageElementNameIndex,self.address)
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
            self._packagePointer = PackagePointer(addressAtIndexAtAddress(Self.kPackageElementPackageIndex,self.address))
            return(self._packagePointer)
            }
        set
            {
            self._packagePointer = newValue
            setAddressAtIndexAtAddress(newValue?.address ?? 0,Self.kPackageElementPackageIndex,self.address)
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
