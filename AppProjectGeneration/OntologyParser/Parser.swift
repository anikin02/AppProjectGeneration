//
//  Parser.swift
//  AppProjectGeneration
//
//  Created by Данил Аникин on 17/04/2026.
//

class Parser {
  static let shared = Parser()
  
  private init() {}
  
  func parseAppObjects(from text: String) -> [AppObject] {
    return attachArguments(to: justParseObjects(from:  text), from: text)
  }
  
  func justParseObjects(from text: String) -> [AppObject] {
      var result: [AppObject] = []
      
      let lines = text.components(separatedBy: .newlines)
      
      for line in lines {
          let trimmed = line.trimmingCharacters(in: .whitespaces)
          
          guard trimmed.hasPrefix("Сорт ") else { continue }
          
          let withoutPrefix = trimmed.dropFirst("Сорт ".count)
          let parts = withoutPrefix.components(separatedBy: ":")
          
          guard parts.count >= 2 else { continue }
          
          let name = parts[0].trimmingCharacters(in: .whitespaces)
          let definition = parts[1].trimmingCharacters(in: .whitespaces)
          
          if definition.contains("->") ||
              definition.contains("→") ||
              definition.contains("(") ||
              definition.contains(")") {
              continue
          }
          
          let object = AppObject(name: name)
          result.append(object)
      }
      
      return result
  }
  
  func attachArguments(to objects: [AppObject], from text: String) -> [AppObject] {
      var objects = objects
      
      let lines = text.components(separatedBy: .newlines)
      
      for line in lines {
          let trimmed = line.trimmingCharacters(in: .whitespaces)
          
          guard trimmed.hasPrefix("Сорт "),
                trimmed.contains("->"),
                trimmed.contains("("),
                trimmed.contains(")")
          else { continue }
          
          let withoutPrefix = trimmed.dropFirst("Сорт ".count)
          let parts = withoutPrefix.components(separatedBy: ":")
          guard parts.count >= 2 else { continue }
          
          let argumentName = parts[0].trimmingCharacters(in: .whitespaces)
          
          let definition = parts[1]
              .trimmingCharacters(in: .whitespaces)
              .replacingOccurrences(of: "(", with: "")
              .replacingOccurrences(of: ")", with: "")
          
          let components = definition.components(separatedBy: "->")
          guard components.count == 2 else { continue }
          
          let objectName = components[0].trimmingCharacters(in: .whitespaces)
          var typeRaw = components[1].trimmingCharacters(in: .whitespaces)
          
          let isArray = typeRaw.contains("{}")
          typeRaw = typeRaw.replacingOccurrences(of: "{}", with: "")
          
          var typeOfData = ""
          var relatedObject: AppObject? = nil
          
          switch typeRaw {
          case "N":
              typeOfData = isArray ? "Array<String>" : "String"
          case "I":
              typeOfData = isArray ? "Array<Int>" : "Integer"
          case "R":
              typeOfData = isArray ? "Array<Double>" : "Double"
          default:
              typeOfData = isArray ? "Array" : ""
              relatedObject = objects.first { $0.name == typeRaw }
          }
          
          let argument = Argument(
              name: argumentName,
              typeOfData: typeOfData,
              appObject: relatedObject
          )
          
          // 👇 ВОТ ГЛАВНОЕ — находим нужный объект и добавляем аргумент
          if let index = objects.firstIndex(where: { $0.name == objectName }) {
              objects[index].arguments.append(argument)
          }
      }
      
      return objects
  }
}
