//
//  ResultViewModel.swift
//  AppProjectGeneration
//
//  Created by Данил Аникин on 06/03/2026.
//
import Foundation
import BeautifulMermaid

class ResultViewModel: ObservableObject {
  @Published var mermaidCode: String = ""
  @Published var diagramScale: Double = 1
  @Published var selectedMermaidTheme: String = "Default"
  
  let mermaidTheme: [String] = ["Default", "Dracula", "Tokyo Night", ]
  
  var project: DesignData = DesignData(name: "Test", objects: []) {
    didSet {
      mermaidCode = getMermaidCode()
    }
  }
  
  init() {
    mermaidCode = getMermaidCode()
  }
  
  func resetDiagramScale() {
    diagramScale = 1
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
