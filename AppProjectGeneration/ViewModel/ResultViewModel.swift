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
    var code: String = "erDiagram LR"
    for object in project.objects {
      code +=  "\n \(object.name) {"
      for argument in object.arguments {
        code += "\n \(argument.typeOfData)"
        code += "\(argument.typeOfData == "Array" ? "<": "")\(argument.appObject?.name ?? "")\(argument.typeOfData == "Array" ? ">": "")"
        code += " \(argument.name)"
      }
      code += "\n }"
    }
    
    var relations: [RelationKey: RelationInfo] = [:]
    
    for object in project.objects {
      for argument in object.arguments {
        guard let target = argument.appObject?.name else { continue }
        
        let isMany =
        argument.typeOfData == "Array" ||
        object.arguments.filter { $0.appObject?.name == target }.count > 1
        
        let key = RelationKey(
          a: min(object.name, target),
          b: max(object.name, target)
        )
        
        var info = relations[key] ?? RelationInfo()
        
        if object.name < target {
          if isMany {
            info.hasManyAtoB = true
          }
        } else {
          if isMany {
            info.hasManyBtoA = true
          }
        }
        
        relations[key] = info
      }
    }
    
    let sortedRelations = relations.sorted {
      $0.key.a + $0.key.b < $1.key.a + $1.key.b
    }
    
    for (key, info) in sortedRelations {
      let relation: String

      if info.hasManyAtoB && info.hasManyBtoA {
        relation = "\(key.a) }o--o{ \(key.b) : many-to-many"
      } else if info.hasManyAtoB {
        relation = "\(key.a) ||--|{ \(key.b) : contains"
      } else if info.hasManyBtoA {
        relation = "\(key.b) ||--|{ \(key.a) : contains"
      } else {
        relation = "\(key.a) ||--|| \(key.b) : has"
      }

      code += "\n " + relation
    }
    print(code)
    return code
  }
}

struct RelationKey: Hashable {
  let a: String
  let b: String
}

struct RelationInfo {
  var hasManyAtoB: Bool = false
  var hasManyBtoA: Bool = false
}
