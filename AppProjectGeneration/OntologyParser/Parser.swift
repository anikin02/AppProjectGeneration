//
//  Parser.swift
//  AppProjectGeneration
//
//  Created by Данил Аникин on 17/04/2026.
//

import Foundation

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
      
      if let index = typeRaw.firstIndex(where: { $0 == "[" || $0 == "(" }) {
        typeRaw = String(typeRaw[..<index])
      }
      
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
      
      if let index = objects.firstIndex(where: { $0.name == objectName }) {
        objects[index].arguments.append(argument)
      }
    }
    
    return objects
  }
  

  func parseRequirements(from text: String) -> [String] {
      var requirements: [String] = []

      let lines = text.components(separatedBy: .newlines)

      for rawLine in lines {
          let line = rawLine.trimmingCharacters(in: .whitespaces)
          guard line.hasPrefix("Сорт ") else { continue }

          let body = String(line.dropFirst(5))
          guard let colon = body.firstIndex(of: ":") else { continue }

          let name = String(body[..<colon]).trimmingCharacters(in: .whitespaces)
          let definition = String(body[body.index(after: colon)...]).trimmingCharacters(in: .whitespaces)

          // Объектный сорт
          if definition == "{}N" {
              requirements.append("Система должна поддерживать хранение объектов типа \(name).")
              continue
          }

          // Ищем начало интервала
          guard let start = definition.firstIndex(where: { $0 == "I" || $0 == "R" }) else {
              continue
          }

          var interval = String(definition[start...])

          // Если запись заканчивается двумя ')', удаляем внешнюю
          while interval.hasSuffix("))") {
              interval.removeLast()
          }
        while interval.hasSuffix("])") {
            interval.removeLast()
        }

          if let requirement = buildRequirement(field: name, interval: interval) {
              requirements.append(requirement)
          }
      }
      
    print(requirements)
      return requirements
  }
  
  private func buildRequirement(field: String,
                                interval: String) -> String? {

      guard let first = interval.first else { return nil }

      let type = first == "I"
          ? "Целочисленное"
          : "Вещественное"

      let body = String(interval.dropFirst())

      guard body.count >= 2 else { return nil }

      let leftBracket = body.first!
      let rightBracket = body.last!

      let content = String(body.dropFirst().dropLast())

      let parts = content
          .split(separator: ",", maxSplits: 1)
          .map {
              $0.trimmingCharacters(in: .whitespaces)
          }

      guard parts.count == 2 else { return nil }

      let left = parts[0]
      let right = parts[1]

      let leftInfinite = left == "-∞"
      let rightInfinite = right == "∞"

      let leftClosed = leftBracket == "["
      let rightClosed = rightBracket == "]"

      // Полностью замкнутый диапазон
      if !leftInfinite &&
          !rightInfinite &&
          leftClosed &&
          rightClosed {

          return "\(type) значение \(field) должно принадлежать быть больше или равно \(left) и меньше или равно \(right)."
      }

      var conditions: [String] = []

      if !leftInfinite {
          conditions.append(
              leftClosed
              ? "больше либо равно \(left)"
              : "строго больше \(left)"
          )
      }

      if !rightInfinite {
          conditions.append(
              rightClosed
              ? "меньше или равно \(right)"
              : "меньше \(right)"
          )
      }

      guard !conditions.isEmpty else { return nil }

      return "\(type) значение \(field) должно быть \(conditions.joined(separator: " и "))."
  }
}
