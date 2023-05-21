//
//  ContentView.swift
//  app
//
//  Created by Carlos Leon on 2023-05-20.
//

import SwiftUI
import AWSDynamoDB
//import AWSCore
import AWSCognitoIdentityProvider


func initAWS(){
    let credentialsProvider = AWSStaticCredentialsProvider(
        accessKey: "",
        secretKey: ""
    )
    
    let configuration = AWSServiceConfiguration(
        region: .USEast2,
        credentialsProvider: credentialsProvider
    )
    
    AWSServiceManager.default().defaultServiceConfiguration = configuration
}

func listAWSTables(){
    let db = AWSDynamoDB.default()
    
    let tables = AWSDynamoDBListTablesInput()
    
    db.listTables(tables!).continueWith { (task:AWSTask<AWSDynamoDBListTablesOutput>) -> Any? in
        if let error = task.error as? NSError {
        print("Error occurred: \(error)")
            return nil
        }

        let tables = task.result

        for tableName in tables!.tableNames! {
            print("\(tableName)")
        }

        return nil
    }
}


struct ContentView: View {
    @State private var isButtonTapped = false
    
    var body: some View {
        NavigationView {
            VStack {

                Button(action: {
                    isButtonTapped.toggle()
                }){
                    Text("Purpose")
//                        .font(.custom("Baskerville", size:30))
//                        .frame(width: 200, height: 50)
                        .frame(width: 200)
                        .fontWeight(.bold)
                        .padding(10)
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                    

                }
                
                if isButtonTapped {
                    Text("The purpose of this Cloud Goal Tracker program is to help you to achieve your goals through gamification (turning your goals into a game)")
                        .frame(width: 200, alignment: .center)
                        .padding(10)
    //                    .frame(width:300, height: 80, alignment: .center)
                        .background(Color.gray.opacity(0.3))
                        .cornerRadius(10)
                        
                }
                    
                
                NavigationLink("Show my goals history", destination: AdditionalView())
                    .frame(width: 200)
                    .fontWeight(.bold)
                    .padding(10)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .navigationBarTitle("Goal Tracker")
        }
        
        
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
