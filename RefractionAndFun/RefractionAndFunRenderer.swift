//
//  RefractionAndFunRenderer.swift
//  RefractionAndFun
//
//  Created by Maciek Czarnik on 12/02/2024.
//

import SatinCore
import Satin
import MetalKit

class RefractionAndFunRenderer: BaseRenderer {
  lazy var background: Object = {
    let numberOfSpheres = 10
    let amountInOneDimensionRange = 0 ..< numberOfSpheres
    
    return Object(
      "Background",
      amountInOneDimensionRange.flatMap { row in
        amountInOneDimensionRange.map { column in
          let mesh = Mesh(
            geometry: IcoSphereGeometry(radius: 0.22, res: 2),
            material: BasicDiffuseMaterial(0.7)
          )
          let centerOffset = Float(numberOfSpheres - 1) / 2
          mesh.position = .init(
            x: Float(row) - centerOffset,
            y: Float(column) - centerOffset,
            z: 0
          )
          
          return mesh
        }
      }
    )
  }()
  private var backgroundTexture: MTLTexture?
  
  let foreground: Mesh = {
    let mesh = Mesh(
      geometry: IcoSphereGeometry(radius: 2, res: 3),
      material: nil
    )
    mesh.position = [0, 0, -3]
    return mesh
  }()
  
  lazy var scene = Object("Scene", [background, foreground])
  lazy var context = Context(device, sampleCount, colorPixelFormat, depthPixelFormat, stencilPixelFormat)
  lazy var camera = PerspectiveCamera(position: [0,0,-10], near: 0.01, far: 100.0, fov: 100)
  lazy var cameraController = PerspectiveCameraController(camera: camera, view: mtkView)
  lazy var renderer = Satin.Renderer(context: context)
  
  override func setupMtkView(_ metalKitView: MTKView) {
    metalKitView.sampleCount = 1
    metalKitView.depthStencilPixelFormat = .depth32Float
    metalKitView.preferredFramesPerSecond = 120
  }
  
  override func setup() {
    camera.lookAt(target: .zero)
    renderer.compile(scene: scene, camera: camera)
  }
  
  deinit {
    cameraController.disable()
  }
  
  override func update() {
    if backgroundTexture == nil {
      backgroundTexture = createTexture("Background", mtkView.colorPixelFormat)
    }
    cameraController.update()
  }
  
  override func draw(_ view: MTKView, _ commandBuffer: MTLCommandBuffer) {
    guard let renderPassDescriptor = view.currentRenderPassDescriptor else { return }
    guard let backgroundTexture else { return }
    
    foreground.visible = false
    
    renderer.draw(
      renderPassDescriptor: renderPassDescriptor,
      commandBuffer: commandBuffer,
      scene: scene,
      camera: camera,
      renderTarget: backgroundTexture
    )
    
    let funMaterial = BasicTextureMaterial(texture: backgroundTexture)
    funMaterial.shader = Shader(
      "ForegroundMaterialShader",
      "vertexFunction",
      "fragmentFunction"
    )
    foreground.material = funMaterial
    foreground.visible = true
    
    renderer.draw(
      renderPassDescriptor: renderPassDescriptor,
      commandBuffer: commandBuffer,
      scene: scene,
      camera: camera
    )
  }
  
  override func resize(_ size: (width: Float, height: Float)) {
    camera.aspect = size.width / size.height
    renderer.resize(size)
  }
  
  func createTexture(_ label: String, _ pixelFormat: MTLPixelFormat) -> MTLTexture? {
    if mtkView.drawableSize.width > 0, mtkView.drawableSize.height > 0 {
      let descriptor = MTLTextureDescriptor()
      descriptor.pixelFormat = pixelFormat
      descriptor.width = Int(mtkView.drawableSize.width)
      descriptor.height = Int(mtkView.drawableSize.height)
      descriptor.sampleCount = 1
      descriptor.textureType = .type2D
      descriptor.usage = [.renderTarget, .shaderRead, .shaderWrite]
      descriptor.storageMode = .private
      descriptor.resourceOptions = .storageModePrivate
      guard let texture = device.makeTexture(descriptor: descriptor) else { return nil }
      texture.label = label
      return texture
    }
    return nil
  }
}
