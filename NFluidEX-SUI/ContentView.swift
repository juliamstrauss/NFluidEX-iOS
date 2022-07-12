//
//  ContentView.swift
//  NFluidEX-SUI
//
//  Created by Julia Strauss on 6/22/22.
//

import SwiftUI
import AudioToolbox

struct ContentView: View {
    @ObservedObject var bleManager = BLEManager()
    @State var showingExporter = false
    //@State var document : Document = Document(message: "This is a test message")
    
    var body: some View {
        NavigationView {
            VStack(alignment: .center, spacing: 10) {
                Text("NFluidEX")
                    .font(.title)
                    .foregroundColor(.black)

                Image("mcgill_university_logo")
                    .resizable()
                    .scaledToFit()
                Spacer()
                /*Button("Export"){
                    showingExporter = true
                }.fileExporter(isPresented: $showingExporter,
                               document: document,
                               contentType: .plainText
                 ) { result in
                    if case .success = result {
                        print("success")
                    } else {
                        print("failure")
                    }
                 }*/
                
                //Connect to NFluidEX
                if (bleManager.nfluidexFound && !bleManager.nfluidexConnected) {
                    Button("Connect to NFluidEX") {
                        print("connect clicked")
                        AudioServicesPlaySystemSound(1330)
                        self.bleManager.connect()
                    }
                }
                Spacer()
                if (bleManager.nfluidexConnected) {
                    HStack  {
                        NavigationLink(destination: EISView(bleManager: bleManager)) {
                            Text("EIS")
                            //bleManager.method = 1
                        }
                        Spacer()
                        NavigationLink(destination: CVView(bleManager: bleManager)){
                            Text("CV")
                        }
                        Spacer()
                        NavigationLink(destination: DPVView(bleManager: bleManager)){
                            Text("DPV")
                            //bleManager.method = 3
                        }
                    }.font(.title)
                        .padding()
                }
                Spacer()
            //Status
            if bleManager.isSwitchedOn {
                Text("Bluetooth on")
                    .foregroundColor(.green)
            } else {
                Text("Bluetooth off")
                    .foregroundColor(.red)
            }
            Button("Find devices") {
                print("find devices clicked")
                self.bleManager.startScanning()
            }
            .disabled(bleManager.nfluidexFound)
    
            
        }.padding()
         
    }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .preferredColorScheme(.light)
    }
}
