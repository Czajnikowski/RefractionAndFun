//
//  Mesh+Parameters.swift
//  RefractionAndFun
//
//  Created by Maciek Czarnik on 13/02/2024.
//

import Satin

extension Mesh {
  enum PositionParameter: String {
    case x
    
    var label: String {
      rawValue
    }
  }
  
  var positionParameters: ParameterGroup {
    let p = FloatParameter(PositionParameter.x.label, position.x, .inputfield)
    p.delegate = self
    return ParameterGroup("position", [p])
  }
}

extension Mesh: ParameterDelegate {
  public func updated(parameter: Satin.Parameter) {
    if parameter.label == PositionParameter.x.label {
      position.x = (parameter as! FloatParameter).value
    }
  }
}
