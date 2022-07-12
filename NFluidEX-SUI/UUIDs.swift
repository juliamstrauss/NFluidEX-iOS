//
//  UUIDs.swift
//  NFluidEX-SUI
//
//  Created by Julia Strauss on 6/22/22.
//

import Foundation
import CoreBluetooth

struct UUIDs {
    static let NFluidEX_Service_UUID = "65333333-A115-11E2-9E9A-0800200CA100";
    static let NFluidEX_Characteristic_UUID = "65333333-A115-11E2-9E9A-0800200CA101";
    static let NFluidEX_Descriptor_UUID = "00002902-0000-1000-8000-00805F9B34FB";
    
    static let BLEService_UUID = CBUUID(string: NFluidEX_Service_UUID);
    static let BLECharacteristic_UUID = CBUUID(string: NFluidEX_Characteristic_UUID);
    static let BLEDescriptor_UUID = CBUUID(string: NFluidEX_Descriptor_UUID)
    
}
