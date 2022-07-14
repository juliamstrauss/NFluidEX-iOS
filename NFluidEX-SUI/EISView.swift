//
//  EISView.swift
//  NFluidEX-SUI
//
//  Created by Julia Strauss on 6/23/22.
//

import SwiftUI

struct EISView: View {
    
    @ObservedObject var bleManager : BLEManager
    @State var signalAmp : String = "0.01"
    @State var showingExporter = false
    
    @State var ampIsOne = false
    @State var ampIsTen = false
    @State var testStarted = false
    
    var body: some View {
        VStack {
            if (bleManager.cycleOver){
                Color.green.opacity(0.5)
                    .ignoresSafeArea()
            }
            Text("EIS")
                .font(.largeTitle)
            Text("Electrochemical Impedance Spectroscopy").font(.subheadline)
            Spacer()
            VStack {
                Text("Signal Amplitude:")
                    .font(.subheadline)
                HStack {
                    Spacer()
                    Button("0.01 V"){
                        print("0.01 V")
                        signalAmp = "0.01"
                        ampIsOne = true
                        ampIsTen = false
                    }.disabled(ampIsOne).padding().border(Color.white, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    Spacer()
                    Button("0.1V"){
                        print("0.1 V")
                        signalAmp = "0.1"
                        ampIsOne = false
                        ampIsTen = true
                    }.disabled(ampIsTen).padding().border(Color.white, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                    Spacer()
                }.padding()
            }.padding().background(Rectangle().fill(Color(red: 0.84, green: 0.92, blue: 1.0)))
            Spacer()
            HStack {
                Spacer()
                Spacer()
                Button("Begin test") {
                    print("Begin test clicked")
                    bleManager.method = 1
                    bleManager.sendMessage(msg: "f3ae" + "0.1" + "\t" + "100000" + "\t" + "10"  + "\t" + "0" + "\t" + "\(signalAmp)" + "\t" + "10"  + "\t")
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

struct EISView_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            EISView(bleManager: BLEManager())
        }
    }
}
