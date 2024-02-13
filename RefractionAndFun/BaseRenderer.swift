//
//  BaseRenderer.swift
//  RefractionAndFun
//
//  Created by Maciek Czarnik on 12/02/2024.
//

import Forge
import Metal
import Satin
import Youi

class BaseRenderer: Forge.Renderer {
  // MARK: - Paths
  
  var assetsURL: URL { Bundle.main.resourceURL!.appendingPathComponent("Assets") }
  var sharedAssetsURL: URL { assetsURL.appendingPathComponent("Shared") }
  var rendererAssetsURL: URL { assetsURL.appendingPathComponent(String(describing: type(of: self))) }
  var dataURL: URL { rendererAssetsURL.appendingPathComponent("Data") }
  var pipelinesURL: URL { rendererAssetsURL.appendingPathComponent("Pipelines") }
  var texturesURL: URL { rendererAssetsURL.appendingPathComponent("Textures") }
  var modelsURL: URL { rendererAssetsURL.appendingPathComponent("Models") }
  
  // MARK: - UI
  
  var inspectorWindow: InspectorWindow?
  var _updateInspector: Bool = true
  
  // MARK: - Parameters
  
  var params: [String: ParameterGroup?] = [:]
  
  override func preDraw() -> MTLCommandBuffer? {
    updateInspector()
    return super.preDraw()
  }
  
  override func cleanup() {
    super.cleanup()
    print("cleanup: \(String(describing: type(of: self)))")
#if os(macOS)
    inspectorWindow?.setIsVisible(false)
#endif
  }
  
  deinit {
    print("deinit: \(String(describing: type(of: self)))")
  }
}
