//
//  ResultView.swift
//  AppProjectGeneration
//
//  Created by Данил Аникин on 04/03/2026.
//

import SwiftUI
import AppKit
import BeautifulMermaid


class TestData {
  var user: AppObject
  var system: AppObject
  var bill: AppObject
  var transaction: AppObject
  
  init() {
    bill = AppObject(name: "Bill", arguments: [
      Argument(name: "name", typeOfData: "String", appObject: nil),
      Argument(name: "money", typeOfData: "Double", appObject: nil)])
    
    user = AppObject(name: "User", arguments: [
      Argument(name: "name", typeOfData: "String", appObject: nil),
      Argument(name: "age", typeOfData: "Integer", appObject: nil),
      Argument(name: "bill", typeOfData: "", appObject: bill)])
    
    system = AppObject(name: "System", arguments: [
      Argument(name: "users", typeOfData: "Array", appObject: user)])
    
    transaction = AppObject(name: "Transaction", arguments: [
      Argument(name: "id", typeOfData: "Integer", appObject: nil),
      Argument(name: "userFrom", typeOfData: "", appObject: user),
      Argument(name: "userTo", typeOfData: "", appObject: user)])
    
  }
}

struct MermaidViewRepresentable: NSViewRepresentable {
  var source: String
  var theme: DiagramTheme = .default
  
  func makeNSView(context: Context) -> MermaidView {
    let view = MermaidView(frame: .zero)
    view.translatesAutoresizingMaskIntoConstraints = false
    
    view.setContentHuggingPriority(.defaultLow, for: .horizontal)
    view.setContentHuggingPriority(.defaultLow, for: .vertical)
    
    view.setContentCompressionResistancePriority(.defaultLow, for: .horizontal)
    view.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    
    view.wantsLayer = true
    return view
    
  }
  
  func updateNSView(_ nsView: MermaidView, context: Context) {
    nsView.source = source
    nsView.theme = theme
  }
}

struct ResultView: View {
  let project: DesignData
  var code: String = ""
  
  init() {
    
    let testData = TestData()
    project = DesignData(name: "Test", objects: [testData.system, testData.bill, testData.user, testData.transaction])
    
    
    code = getMermaidCode()
  }
  
  var body: some View {
    
    VStack(alignment: .leading) {
      MermaidViewRepresentable(source: code)
    }
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

#Preview {
  ResultView()
}
