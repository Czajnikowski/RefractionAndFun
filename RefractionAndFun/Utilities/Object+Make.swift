//
//  Object+Make.swift
//  RefractionAndFun
//
//  Created by Maciek Czarnik on 12/02/2024.
//

import Satin
import simd
import SatinCore

extension Object {
  static func makeGrid() -> Object {
    let object = Object()
    let material = BasicColorMaterial(simd_make_float4(1.0, 1.0, 1.0, 1.0))
    let intervals = 6
    let intervalsf = Float(intervals)
    let geometryX = CapsuleGeometry(size: (0.005, intervalsf), axis: .x)
    let geometryZ = CapsuleGeometry(size: (0.005, intervalsf), axis: .z)
    for i in 0 ... intervals {
        let fi = Float(i)
        let meshX = Mesh(geometry: geometryX, material: material)
        let offset = remap(fi, 0.0, Float(intervals), -intervalsf * 0.5, intervalsf * 0.5)
        meshX.position = [0.0, 0.0, offset]
        object.add(meshX)

        let meshZ = Mesh(geometry: geometryZ, material: material)
        meshZ.position = [offset, 0.0, 0.0]
        object.add(meshZ)
    }
    
    return object
  }
}
