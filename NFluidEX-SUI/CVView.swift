//
//  CVView.swift
//  NFluidEX-SUI
//
//  Created by Julia Strauss on 6/23/22.
//

import SwiftUI
import MessageUI

struct CVView: View {
    
    @State var showingExporter = false
    @State var scanRate : String = "0.02" //volts/second
    @ObservedObject var bleManager : BLEManager
    @State var startTestClicked = false
    
    @State var scanRateIsTwenty = false
    @State var scanRateIsFifty = false
    @State var scanRateIsHundred = false
    
    
    //var document : Document = Document(message: "")
    
    var body: some View {
        VStack (spacing: 10){
            Text("CV")
                .font(.largeTitle)
            Text("Cyclic Voltammetry").font(.subheadline)
            Spacer()
            Text("Potential range:")
            Text("-0.1 V to 0.5 V")
            Spacer()
            Text("Scan rate:")
                
            HStack {
                Button("0.02 V/s") {
                    print("0.02 V/s")
                    scanRate = "0.02"
                    scanRateIsTwenty = true
                    scanRateIsFifty = false
                    scanRateIsHundred = false
                }.disabled(scanRateIsTwenty).padding().border(Color.white, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                Spacer()
                Button("0.05 V/s") {
                    print("0.05 V/s")
                    scanRate = "0.05"
                    scanRateIsTwenty = false
                    scanRateIsFifty = true
                    scanRateIsHundred = false
                }.disabled(scanRateIsFifty).padding().border(Color.white, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
                Spacer()
                Button("0.10 V/s") {
                    print("0.10 V/s")
                    scanRate = "0.1"
                    scanRateIsTwenty = false
                    scanRateIsFifty = false
                    scanRateIsHundred = true
                }.disabled(scanRateIsHundred).padding().border(Color.white, width: /*@START_MENU_TOKEN@*/1/*@END_MENU_TOKEN@*/)
            }.padding().background(Rectangle().fill(Color(red: 0.84, green: 0.92, blue: 1.0)))
            Spacer()
            HStack {
                Spacer()
                Spacer()
                Button("Begin test"){
                    print("start CV test clicked")
                    bleManager.method = 2
                    bleManager.sendMessage(msg: "f3ac" + "-0.1" + "\t" + "0.5" + "\t" + "\(scanRate)" + "\t" + "10" + "\t")
                    startTestClicked = true
                }.padding().disabled(startTestClicked).font(.title2).overlay(Capsule(style: .continuous)
                    .stroke(Color.blue, lineWidth: 3)
                )
                Spacer()
                Button("Export"){
                    print("export clicked")
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
    public mutating func exportData() {
        var dataString : String = ""
        dataString.append("Current, Potential \n")
        dataString.append("Sample 1, Sample 2 \n")
        //todo - add back in if we go from plain text to data
        //let data = dataString.data(using: .utf8)
        //if let content = data {
       //     print("success creating data file")
       // } else {
        //    print("ERROR: issue with exporting data")
       // }
        //document = Document(message: dataString)
        
    }
}



struct CVView_Previews: PreviewProvider {
    static var previews: some View {
        CVView(bleManager: BLEManager())
    }
}
