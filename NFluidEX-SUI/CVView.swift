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
    
    //var document : Document = Document(message: "")
    
    var body: some View {
        VStack (spacing: 10){
            Text("CV")
                .font(.title)
            Spacer()
            Text("Potential range:")
                .font(.subheadline)
            Text("-0.1 V to 0.5 V")
            Spacer()
            Text("Scan rate:")
                .font(.subheadline)
            HStack {
                Button("0.02 V/s") {
                    print("0.02 V/s")
                    scanRate = "0.02"
                }
                Spacer()
                Button("0.05 V/s") {
                    print("0.05 V/s")
                    scanRate = "0.05"
                }
                Spacer()
                Button("0.10 V/s") {
                    print("0.10 V/s")
                    scanRate = "0.1"
                }
            }.padding()
            Spacer()
            HStack {
                Spacer()
                Spacer()
                Button("Begin test"){
                    print("start CV test clicked")
                    bleManager.method = 2
                    bleManager.sendMessage(msg: "f3ac" + "-0.1" + "\t" + "0.5" + "\t" + "\(scanRate)" + "\t" + "10" + "\t")
                }.padding().font(.title2).overlay(Capsule(style: .continuous)
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
            
        }
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
