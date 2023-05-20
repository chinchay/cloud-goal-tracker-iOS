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

class ViewModel: ObservableObject {
    // @Published var items: [[String: Any]] = []
    @Published var awsDict: [String : Any] = [:]
    
    
    //func scanTable(completion: @escaping ([[String: Any]]) -> Void) {
    func scanTable(completion: @escaping ( [String: Any] ) -> Void) {
        let input = AWSDynamoDBScanInput()
        input?.tableName = "sample_table_1"
        
        let db = AWSDynamoDB.default()
        
        db.scan(input!).continueWith { task in
            if let error = task.error {
                print("Error scanning table: \(error)")
                completion([:])
                //completion([])
                //return nil
            }
            
            if let result = task.result {
                // Extract the items as dictionaries with actual values
                let items = result.items?.map { item -> [String: Any] in
                    var processedItem: [String: Any] = [:]
                    
                    // original values have AWS tags that we are not interested in
                    // This time, our valus are either string (`.s`),
                    // numbers (`.n`) or boolean types:
                    for (key, attributeValue) in item {
                        if let stringValue = attributeValue.s {
                            processedItem[key] = stringValue
                        } else if let numberValue = attributeValue.n {
                            processedItem[key] = numberValue
                        } else if let boolValue = attributeValue.boolean {
                            processedItem[key] = boolValue
                        }
                        // Handle other types as needed
                    }
                    return processedItem
                } ?? []
                
                
                DispatchQueue.main.async {
                    // Update the view model's property with the retrieved data
//                    self.items = items
//                    completion(items)

                    var awsDict: [String: Any] = [:]
                    for dict in items{
                        if let a = dict["date"] as? String,
                           let b = dict["read_scriptures"] as? Bool,
                           let c = dict["wrote_journal"] as? Bool {
                            awsDict[a] = [b, c]
                        }
                    }

                    self.awsDict = awsDict
                    completion(awsDict)
                }
            }
            
            return nil
        }
    }
}


func getDictionaryFromAWS(){
//    var items = getRawItems()
//    var items: [[String: Any]] = getRawItems()
//    print(items)
    
}


struct ContentView: View {
    var body: some View {
        VStack {
            NavigationView {
                VStack {
                    Text("Main Screen")
                    NavigationLink("Go to Additional Screen", destination: AdditionalView())
                    
                    Image(systemName: "globe")
                        .imageScale(.large)
                        .foregroundColor(.accentColor)
//                    Text("Hello, world!")
                    
                    Button("Click me to connect to AWS DynamoDB"){
                        initAWS()
                        listAWSTables()
                        print("Hello world from the console!")
                    }
                    Button("scan"){
                        initAWS()
//                        getRawItems()
                        
                        let viewModel = ViewModel()
//                        viewModel.scanTable { items in
//                            print(items)
//                        }
                        viewModel.scanTable { awsDict in
                            print(awsDict)
                        }
                        print("scanned!")
                    }
                    
                }
                .navigationBarTitle("Goal Tracker")
                
            }
            
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
