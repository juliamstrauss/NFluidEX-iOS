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

    var body: some View {
        VStack (spacing: 10){
            Text("DPV")
                .font(.largeTitle)
            Text("Differential Pulse Voltammetry")
            Spacer()
            //RoundedRectangle(cornerRadius: 5)
            //    .fill(Color(red: 0.84, green: 0.92, blue: 1.0))
            VStack {
                Text("Start voltage (V):")
                HStack {
                    Button("-0.2 V") {
                        print("-0.2 V")
                        startV = "-0.2"
                    }
                    Spacer()
                    Button("-0.1 V") {
                        print("-0.1 V")
                        startV = "-0.1"
                    }
                    Spacer()
                    Button("0 V") {
                        print("0.10 V/s")
                        startV = "0"
                    }
                }.padding()
                Text("End voltage (V):")
                HStack {
                    Button("0.4 V") {
                        print("0.4 V")
                        endV = "0.4"
                    }
                    Spacer()
                    Button("0.5 V") {
                        print("0.5 V")
                        endV = "0.5"
                    }
                    Spacer()
                    Button("0.6 V") {
                        print("0.6 V")
                        endV = "0.6"
                    }
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
                    if (bleManager.cycleOver) {
                        print("DPV CYCLE OVER")
                        AudioServicesPlaySystemSound(1108)
                    }
                }.padding().font(.title2).overlay(Capsule(style: .continuous)
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
