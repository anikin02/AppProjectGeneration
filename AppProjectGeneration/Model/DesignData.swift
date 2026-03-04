//
//  DesignData.swift
//  AppProjectGeneration
//
//  Created by Данил Аникин on 04/03/2026.
//

struct DesignData {
  let name: String
  let baseTypesOfArgument: [String] = ["Integer", "Double", "String", "Array<String>", "Array<Integer>", "Array<Double>", "Array"]
  var objects: [AppObject]
}
