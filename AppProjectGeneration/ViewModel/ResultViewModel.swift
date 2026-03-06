//
//  ResultViewModel.swift
//  AppProjectGeneration
//
//  Created by Данил Аникин on 06/03/2026.
//
import Foundation

class TestData {
  var user: AppObject
  var system: AppObject
  var bill: AppObject
  var transaction: AppObject
  var user1: AppObject
  var system1: AppObject
  var bill1: AppObject
  var transaction1: AppObject
  var transaction2: AppObject
  var transaction3: AppObject
  
  init() {
    bill = AppObject(name: "Bill", arguments: [
      Argument(name: "name", typeOfData: "String", appObject: nil),
      Argument(name: "money", typeOfData: "Double", appObject: nil)])
    
    user = AppObject(name: "User", arguments: [
      Argument(name: "name", typeOfData: "String", appObject: nil),
      Argument(name: "age", typeOfData: "Integer", appObject: nil),
      Argument(name: "bill", typeOfData: "", appObject: bill)])
    
    transaction = AppObject(name: "Transaction", arguments: [
      Argument(name: "id", typeOfData: "Integer", appObject: nil),
      Argument(name: "userFrom", typeOfData: "", appObject: user),
      Argument(name: "userTo", typeOfData: "", appObject: user)])
    
    system = AppObject(name: "System", arguments: [
      Argument(name: "users", typeOfData: "Array", appObject: user),
      //      Argument(name: "transactions", typeOfData: "Array", appObject: transaction) поискать конфиги для спэйсинга объектов ЕРД
    ])
    
    bill1 = AppObject(name: "Bill1", arguments: [
      Argument(name: "name", typeOfData: "String", appObject: nil),
      Argument(name: "money", typeOfData: "Double", appObject: nil)])
    
    user1 = AppObject(name: "User1", arguments: [
      Argument(name: "name", typeOfData: "String", appObject: nil),
      Argument(name: "age", typeOfData: "Integer", appObject: nil),
      Argument(name: "bill1", typeOfData: "", appObject: bill1)])
    
    system1 = AppObject(name: "System1", arguments: [
      Argument(name: "users", typeOfData: "Array", appObject: user1)])
    
    transaction1 = AppObject(name: "Transaction1", arguments: [
      Argument(name: "id", typeOfData: "Integer", appObject: nil),
      Argument(name: "userFrom", typeOfData: "", appObject: user1),
      Argument(name: "userTo", typeOfData: "", appObject: user1)])
    
    transaction2 = AppObject(name: "Transaction1", arguments: [
      Argument(name: "id", typeOfData: "Integer", appObject: nil),
      Argument(name: "userFrom", typeOfData: "", appObject: user1),
      Argument(name: "userTo", typeOfData: "", appObject: user1)])
    
    transaction3 = AppObject(name: "Transaction2", arguments: [Argument(name: "id", typeOfData: "Integer", appObject: nil)])
    transaction2 = AppObject(name: "Transaction3", arguments: [Argument(name: "id", typeOfData: "Integer", appObject: nil)])
    
  }
}

class ResultViewModel: ObservableObject {
  @Published var mermaidCode: String = ""
  var project: DesignData
  
  init() {
    let testData = TestData()
    project = DesignData(name: "Test", objects: [testData.bill, testData.user, testData.transaction, testData.system,])
    project.objects.append(testData.system1)
    project.objects.append(testData.bill1)
    project.objects.append(testData.user1)
    project.objects.append(testData.transaction1)
    project.objects.append(testData.transaction2)
    project.objects.append(testData.transaction3)
    
    
  }
  
  
  private func getMermaidCode() -> String {
    var code: String = "erDiagram"
    for object in project.objects {
      code +=  "\n \(object.name) {"
      for argument in object.arguments {
        code += "\n \(argument.typeOfData)"
        code += "\(argument.typeOfData == "Array" ? "<": "")\(argument.appObject?.name ?? "")\(argument.typeOfData == "Array" ? ">": "")"
        code += " \(argument.name)"
      }
      code += "\n }"
    }
    
    for object in project.objects {
      for argument in object.arguments {
        if let appObjectName = argument.appObject?.name {
          if (argument.typeOfData == "Array") || (object.arguments.filter { $0.appObject?.name == argument.appObject?.name}.count > 1) {
            code += "\n \(object.name) ||--|{ \(appObjectName) : contains"
          } else {
            code += "\n \(object.name) ||--|| \(appObjectName) : has"
          }
        }
      }
    }
    
    return code
  }
}
