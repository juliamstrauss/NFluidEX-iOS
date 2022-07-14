//
//  DPVView.swift
//  NFluidEX-SUI
//
//  Created by Julia Strauss on 6/23/22.
//

import SwiftUI
import AudioToolbox

struct DPVView: View {
    @ObservedObject var bleManager : BLEManager
    @State var startV : String = "-0.2"
    @State var endV : String = "0.5"
    @State var showingExporter = false
    
    @State var startVoltageIsTwo = false
    @State var startVoltageIsOne = false
    @State var startVoltageIsZero = false
    
    @State var endVoltageIsFour = false
    @State var endVoltageIsFive = false
    @State var endVoltageIsSix = false
    
    @State var testStarted = false

    var body: some View {
        VStack (spacing: 10){
            Text("DPV")
                .font(.largeTitle)
            Text("Differential Pulse Voltammetry").font(.subheadline)
            Spacer()
            //RoundedRectangle(cornerRadius: 5)
            //    .fill(Color(red: 0.84, green: 0.92, blue: 1.0))
            VStack {
                Text("Start voltage:")
                HStack {
                    Button("-0.2 V") {
                        print("-0.2 V")
                        startV = "-0.2"
                        startVoltageIsTwo = true
                        startVoltageIsOne = false
                        startVoltageIsZero = false
                    }.disabled(startVoltageIsTwo).padding().border(Color.white, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    Spacer()
                    Button("-0.1 V") {
                        print("-0.1 V")
                        startV = "-0.1"
                        startVoltageIsTwo = false
                        startVoltageIsOne = true
                        startVoltageIsZero = false
                    }.disabled(startVoltageIsOne).padding().border(Color.white, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    Spacer()
                    Button("0 V") {
                        print("0.10 V")
                        startV = "0"
                        startVoltageIsTwo = false
                        startVoltageIsOne = false
                        startVoltageIsZero = true
                    }.disabled(startVoltageIsZero).padding().border(Color.white, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                }.padding()
                Text("End voltage:")
                HStack {
                    Button("0.4 V") {
                        print("0.4")
                        endV = "0.4"
                        endVoltageIsFour = true
                        endVoltageIsFive = false
                        endVoltageIsSix = false
                    }.disabled(endVoltageIsFour).padding().border(Color.white, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    Spacer()
                    Button("0.5 V") {
                        print("0.5")
                        endV = "0.5"
                        endVoltageIsFour = false
                        endVoltageIsFive = true
                        endVoltageIsSix = false
                    }.disabled(endVoltageIsFive).padding().border(Color.white, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    Spacer()
                    Button("0.6 V") {
                        print("0.6")
                        endV = "0.6"
                        endVoltageIsFour = false
                        endVoltageIsFive = false
                        endVoltageIsSix = true
                    }
                    .disabled(endVoltageIsSix).padding().border(Color.white, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                }.padding()
            }.padding().background(Rectangle().fill(Color(red: 0.84, green: 0.92, blue: 1.0)))
            //Text("Step frequency:")
            //Text("Step potential (mV):")
            //Text("Pulse Amplitude (mV):")
            //Text("Equilibration time (s)")
            Spacer()
            HStack {
                Spacer()
                Spacer()
                Button("Begin test") {
                    print("Begin test clicked")
                    bleManager.method = 3
                    bleManager.sendMessage(msg: "f3ad" + "\(startV)" + "\t" + "\(endV)" + "\t" + "25" + "\t" + "2" + "\t" + "25" + "\t" + "10"  + "\t")
                    testStarted = true
                }.disabled(testStarted).padding().font(.title2).overlay(Capsule(style: .continuous)
                        .stroke(Color.blue, lineWidth: 3)
                )
                Spacer()
                Button("Export"){
                    print("Export clicked")
                    showingExporter = true
                }.fileExporter(isPresented: $showingExporter,
                               document: Document(message: bleManager.createDoc()),
                               contentType: .plainText
                 ) { result in
                    if case .success = result {
                        print("success")
                    } else {
                        print("failure")
                    }
                 }
            }.padding()
        }.padding()
        
    }
}

struct DPVView_Previews: PreviewProvider {
    static var previews: some View {
        DPVView(bleManager: BLEManager())
    }
}
