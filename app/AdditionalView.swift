//
//  AdditionalView.swift
//  app
//
//  Created by Carlos Leon on 2023-05-20.
//

import SwiftUI
import AWSDynamoDB
import AWSCognitoIdentityProvider




struct AdditionalView: View {

    
    let tableName = "sample_table_1"
    @State private var tableData: [[String: AWSDynamoDBAttributeValue]] = []
    @State private var awsDict: [String : Any] = [:]

    func updateAwsDict(){
        let request = AWSDynamoDBScanInput()
        request?.tableName = tableName
        
        initAWS()
        let dynamoDB = AWSDynamoDB.default()
                    
        dynamoDB.scan(request!).continueWith { task in
            if let error = task.error {
                print("Error scanning table: \(error)")
            } else if let response = task.result {
                
                let items = response.items?.map { item -> [String: Any] in
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
                    self.tableData = response.items ?? []
                    
                    var awsDict: [String: Any] = [:]
                    for dict in items{
                        if let a = dict["date"] as? String,
                           let b = dict["read_scriptures"] as? Bool,
                           let c = dict["wrote_journal"] as? Bool {
                            awsDict[a] = [b, c]
                        }
                    }
                    self.awsDict = awsDict
                }
            }
            return nil
        }

    }
    
    
    var body: some View {
        NavigationView {
            VStack (spacing: 10) {
                if tableData.isEmpty {
                    Text("Table data not available")
                }else {
//                    Text("Your history:")
//                    Text("==============================")
                    Text("Date      Read scriptures     Wrote journal")
                    
                    ForEach(awsDict.sorted(by: { $0.key < $1.key }), id: \.key) { entry in
                        HStack {
                            Text("\(entry.key)")
                            Spacer().frame(width: 40)
                            if let values = entry.value as? [Bool] {
                                ForEach(values.indices, id: \.self) { index in
                                    // Text(values[index] ? "true" : "false")
                                    Text(values[index] ? "       ✅     " : "       ❌     ")
                                }
                            }
                        }
                    }
                    
                }
            }.onAppear {
                 updateAwsDict()
            }
            .navigationBarTitle("History")
        }
    }

}

struct AdditionalView_Previews: PreviewProvider {
    static var previews: some View {
        AdditionalView(   ) // value updated in ContentView.swift
    }
    


}
