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

extension BaseRenderer {
  func setupInspector() {
    guard !params.isEmpty else { return }
    
    var panelOpenStates: [String: Bool] = [:]
    if let inspectorWindow = self.inspectorWindow, let inspector = inspectorWindow.inspectorViewController {
      let panels = inspector.getPanels()
      for panel in panels {
        if let label = panel.title {
          panelOpenStates[label] = panel.open
        }
      }
    }
    
    if inspectorWindow == nil {
#if os(macOS)
      let inspectorWindow = InspectorWindow("Inspector")
      inspectorWindow.setIsVisible(true)
#elseif os(iOS)
      let inspectorWindow = InspectorWindow("Inspector", edge: .right)
      mtkView.addSubview(inspectorWindow.view)
#endif
      self.inspectorWindow = inspectorWindow
    }
    
    if let inspectorWindow = self.inspectorWindow, let inspectorViewController = inspectorWindow.inspectorViewController {
      if inspectorViewController.getPanels().count > 0 {
        inspectorViewController.removeAllPanels()
      }
      
      updateUI(inspectorViewController)
      
      let panels = inspectorViewController.getPanels()
      for panel in panels {
        if let label = panel.title {
          if let open = panelOpenStates[label] {
            panel.open = open
          }
        }
      }
    }
  }
  
  func updateUI(_ inspectorViewController: InspectorViewController) {
    for key in params.keys {
      if let param = params[key], let p = param {
        let panel = PanelViewController(key, parameters: p)
        inspectorViewController.addPanel(panel)
      }
    }
  }
  
  func updateInspector() {
    if _updateInspector {
      DispatchQueue.main.async { [unowned self] in
        self.setupInspector()
      }
      _updateInspector = false
    }
  }
}
