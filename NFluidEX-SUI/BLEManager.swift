//
//  BLEManager.swift
//  NFluidEX-SUI
//
//  Created by Julia Strauss on 6/22/22.
//

import Foundation
import CoreBluetooth

//This class is the equivalent of BLEService in the Android app
//Manages BLE operations so that we can maintain Bluetooth connection across view controllers
//todo - what is nsobject?
//any view can subscribe to this and get updates about the peripheral
public class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var centralManager : CBCentralManager!
    
    
    //published so our UIs can update when status changes
    @Published var isSwitchedOn = false
    @Published var nfluidexFound = false
    @Published var nfluidexConnected = false
    
    @Published var cycleOver = false
    
    //EIS
    var Frequency1s : [String] = []
    var Z1s : [String] = []
    var Zi1s : [String] = []
    
    var EIS1_incoming : Bool = false
    
    var Freq1_incoming : Bool = false
    var Ž1_incoming : Bool = false
    var Zi1_incoming : Bool = false
    
    //CV
    var CV1_potentials : [String] = []
    var CV1_currents : [String] = []
    
    var CV1_incoming : Bool = false
    var CV2_incoming : Bool = false
    
    //DPV
    var DPV_E1s : [String] = []
    var DPV_I1s : [String] = []
    
    var DPV1_incoming : Bool = false
    
    
    //let inPipe = Pipe()
    //let outPipe = Pipe()
    //var inputStream : InputStream
    
    //-------------------------------------------------
    //taken from ViewController
    let deviceName : String = ""
    var discoveredPeripherals : [CBPeripheral] = []
    var discoveredPeripheralNames : [String] = [String]()
    
    private var nfluidexPeripheral: CBPeripheral!
    private var nfluidexChar: CBCharacteristic!
    //-------------------------------------------------
    //Methods
    var method : Int = 0 //EIS = 1, CV = 2, DPV = 3
    var eisIncrement : String = "10" //samples per decade
    //-------------------------------------------------
    
    override public init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
        centralManager.delegate = self
    }
    
    public func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch (centralManager.state) {
        case CBManagerState.poweredOn:
            print("Bluetooth is powered on")
            isSwitchedOn = true
            break
        case CBManagerState.poweredOff:
            print("Bluetooth not on")
            isSwitchedOn = false
            break
        case CBManagerState.unauthorized:
            print("User has not authorized BT")
            //ask user to allow BT access?
            break
        default:
            break
        }
    }
    
    public func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData : [String : Any], rssi RSSI: NSNumber) {
        
        nfluidexPeripheral = peripheral
        nfluidexPeripheral.delegate = self
        
        print("peripheral discovered")
        print("peripheral name: \(peripheral.name ?? "unknown")")
        
        discoveredPeripherals.append(peripheral)
        if let deviceName = peripheral.name {
            discoveredPeripheralNames.append(deviceName)
        } else {
            discoveredPeripheralNames.append("Unknown device")
        }
        stopScanning()
    }
    
    //start scanning
    //only searches for NFluidEX
    public func startScanning() {
        print("scanning has started")
        centralManager?.scanForPeripherals(withServices: [UUIDs.BLEService_UUID])
    }
    
    //stop scanning
    public func stopScanning() {
        print("stopped scanning")
        centralManager?.stopScan()
        nfluidexFound = true
    }
    
    //initiate connection
    public func connect() {
        centralManager?.connect(nfluidexPeripheral, options: nil)
    }
    
    public func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        nfluidexPeripheral.discoverServices([UUIDs.BLEService_UUID])
        print("discovering services")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        if ((error) != nil){
            print("Error discovering services")
            return
        }
        guard let services = peripheral.services else {
            return
        }
        for service in services {
            print("service: \(service.uuid)")
            //confirmed only service is service3
            peripheral.discoverCharacteristics([UUIDs.BLECharacteristic_UUID], for: service)
        }
        print("discovered services")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        guard let characteristics = service.characteristics else {
            return
        }
        print("found characteristics")
        for characteristic in characteristics {
            //confirmed only characteristic is char3
            print("characteristic: \(characteristic.uuid)")
            if (characteristic.uuid.isEqual(UUIDs.BLECharacteristic_UUID)) {
                print("chars match up")
                nfluidexChar = characteristic
                print("Setting notifications on for characteristic")
                peripheral.setNotifyValue(true, for: characteristic)
                print("discovering descriptors for char3")
                peripheral.discoverDescriptors(for: characteristic)
                
            }
        }
    }
    public func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsFor characteristic: CBCharacteristic, error: Error?) {
        if (error != nil) {
            print("Error discovering descriptors")
            return
        }
        print("Discovered descriptors")
        guard let descriptors = characteristic.descriptors
                else {
            return
        }
        for descriptor in descriptors {
            (peripheral.readValue(for: descriptor))
            print("read descriptor value")
        }
    }
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor descriptor: CBDescriptor, error: Error?) {
        if (error != nil) {
            print("error updating descriptor value")
            return
        }
        print("updated value for descriptor")
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateNotificationStateFor characteristic: CBCharacteristic, error: Error?) {
        if (error != nil) {
            print("Error updating notif state: \(String(describing: error))")
            return
        }
        print("updateNotificationStateFor called successfully")
        nfluidexConnected = true
        //TODO - take this out
        //testEISButton.isEnabled = true
        //EISbutton.isEnabled = true
        //CVbutton.isEnabled = true
    }
    
    public func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        //print("didUpdateValueFor characteristic called")
        if ((error) != nil){
            print("Error updating value: \(String(describing: error))")
            return
        }
        guard let characteristicData = characteristic.value,
              let dataString = String(data: characteristicData, encoding:.utf8)
        else {
            return
        }
        print("new message: \(dataString)")
        readMessage(msg: dataString)
    }
    
    public func readMessage(msg: String) {
        print("read message called")
        //CV cycle is over
        if (msg.contains("c") && method == 2) {
            print("CV cycle over")
            cycleOver = true
        }
        //DPV cycle is over
        if (msg.contains("c") && method == 3) {
            print("DPV cycle over")
            cycleOver = true
        }
        if CV1_incoming {
            let arr : [Character] = Array(msg)
            readCVData(msg: arr)
            CV1_incoming = false
        }
        else if EIS1_incoming {
            let arr: [Character] = Array(msg)
            readEISData(msg: arr)
            EIS1_incoming = false
        }
        else if DPV1_incoming {
            let arr : [Character] = Array(msg)
            readDPVdata(msg: arr)
            DPV1_incoming = false
        }
        //incoming EIS
        else if (msg.hasPrefix("f") && method == 1) {
            //measurement is in this message
            if (msg.count > 1) {
                var arr: [Character] = Array(msg)
                //remove the f character
                arr.remove(at: 0)
                readEISData(msg: arr)
            } else {
                EIS1_incoming = true
            }
        }
        //a new CV measurement is coming
        else if (msg.hasPrefix("d") && method == 2) {
            //measurement is in this message
            if (msg.count > 1) {
                var arr : [Character] = Array(msg)
                //remove the d character
                arr.remove(at: 0)
                readCVData(msg: arr)
            } else {
                CV1_incoming = true
                print("CV incoming")
            }
        }
        else if (msg.hasPrefix("d") && method == 3) {
            if (msg.count > 1) {
                var arr : [Character] = Array(msg)
                arr.remove(at: 0)
                readDPVdata(msg: arr)
            } else {
                DPV1_incoming = true
                print("DPV incoming")
            }
            
        }
    }
    
    public func readEISData(msg: [Character]) {
        //issue is it doesn't wait if data is spread out among multiple messages
        //check that frequency, impedance, and im are filled before moving on?
        //but then we might lose decimal values?
        print("reading EIS data")
        var freq : String = ""
        var imp : String = ""
        var im : String = ""
        let result = read(msg: msg)
        freq = result.val
        print("freq: \(freq)")
        if (freq.elementsEqual("100000.00")) {
            print("last EIS measurement")
            cycleOver = true
        }
        let result2 = read(msg: result.remaining)
        imp = result2.val
        print("imp: \(imp)")
        let result3 = read(msg: result2.remaining)
        im = result3.val
        print("im: \(im)")
        Frequency1s.append(freq)
        Z1s.append(imp)
        Zi1s.append(im)
    }
    
    //idea: create an array with the message, send to separate function
    public func readCVData(msg: [Character]) {
        //then treat at input stream, "read" and remove characters one by one
        print("reading CV data")
        var cur : String = ""
        var pot : String = ""
        let result = read(msg: msg)
        cur = result.val
        print("cur: \(cur)")
        let result2 = read(msg: result.remaining)
        pot = result2.val
        print("pot: \(pot)")
        CV1_potentials.append(pot)
        CV1_currents.append(cur)
        
    }
    
    public func readDPVdata(msg: [Character]) {
        print("reading DPV data")
        var p : String = ""
        var c : String = ""
        let result = read(msg: msg)
        p = result.val
        print("p: \(p)")
        let result2 = read(msg: result.remaining)
        c = result2.val
        print("c: \(c)")
        DPV_E1s.append(p)
        DPV_I1s.append(c)
    }
    public func read(msg: [Character]) -> (val: String, remaining: [Character]) {
        var data = ""
        var char : Character
        var arr = msg
        //test arr = ["a","b","c"]
        //char = a
        //arr = ["b","c"]
        //data = a
        //evaluate while (char = a, arr.count = 2
        //go again
        //char = b
        //arr = ["c"]
        //data = ab
        //evaluate while (char = b, arr.count = 1
        //go again
        //char = c
        //arr = []
        //data = abc
        //evaulate while char = c arr.count = 0
        if (arr.count == 0) {
            print("read called on an array of size 0")
            return (data, arr)
        }
        repeat {
            char = arr.remove(at: 0)
            if (char != "\t") {data.append(char)}
        }
        while (char != "\t" && arr.count > 0)
        
        return (data, arr)
    }
    
    public func createDoc() -> String {
        var message : String = ""
        switch (method) {
        case 1:
            print("create EIS doc")
            for (index,value) in Frequency1s.enumerated() {
                message.append("\(value), \(Z1s[index]), \(Zi1s[index]) \n")
            }
        case 2:
            for (index, value) in CV1_potentials.enumerated() {
                message.append("\(value), \(CV1_currents[index]) \n")
            }
        case 3:
            print("create DPV doc")
            for (index, value) in DPV_E1s.enumerated() {
                message.append("\(value), \(DPV_I1s[index]) \n")
            }
        default:
            print("CREATE DOC: there's an issue with the method var")
        }
        return message
    }
    
    public func sendMessage(msg: String) {
        guard let data = msg.data(using: .utf8) else {
            print("issue with message content")
            return
        }
        print("sending message:" + msg)
    
        //max length (with response) = 512 bytes
        //max length (without response) = 182 bytes
        //actual max length seems to be 20 bytes
        //todo - implement queue system?
        //todo - check length of message before sending ✅
        let tooLong : Bool
        let length = data.count
        print("length of message is \(length) bytes")
        tooLong = (length > 20)
        if (tooLong) {
            print("message too long, splitting up")
            let data1 = data.subdata(in: 0..<20)
            guard let str1 = String(data: data1, encoding: .utf8) else { return }
            let data2 = data.subdata(in: 20..<length)
            guard let str2 = String(data: data2, encoding: .utf8) else { return }
            
            nfluidexPeripheral.writeValue(data1, for: nfluidexChar, type: .withResponse)
            print("write value called: " + str1)
            nfluidexPeripheral.writeValue(data2, for: nfluidexChar, type: .withResponse)
            print("write value called: " + str2)
        }
        else {
            nfluidexPeripheral.writeValue(data, for: nfluidexChar, type: .withResponse)
            print("write value called")
        }

        
    }
    
    private class connectionThread : Thread {
        private var stopThread : Bool = false
        
        public func connectionThread(){
            print("created connection thread")
        }
        
        public func run() {
            print("connection thread beginning")
            while(!stopThread) {
                
            }
        }
    }
    
}

