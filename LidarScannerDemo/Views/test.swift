//
//  test.swift
//  LidarScannerDemo
//
//  Created by Tao Hu on 2023/11/20.
//

import Foundation
import RealityKit
import ARKit
import MetalKit
import ModelIO

@IBOutlet var arView: ARView!
var saveButton: UIButton!
let rect = CGRect(x: 50, y: 50, width: 100, height: 50)

override func viewDidLoad() {
    super.viewDidLoad()

    let tui = UIControl.Event.touchUpInside
    saveButton = UIButton(frame: rect)
    saveButton.setTitle("Save", for: [])
    saveButton.addTarget(self, action: #selector(saveButtonTapped), for: tui)
    self.view.addSubview(saveButton)
}

@objc func saveButtonTapped(sender: UIButton) {
    print("Saving is executing...")
    
    guard let frame = arView.session.currentFrame
    else { fatalError("Can't get ARFrame") }
            
    guard let device = MTLCreateSystemDefaultDevice()
    else { fatalError("Can't create MTLDevice") }
    
    let allocator = MTKMeshBufferAllocator(device: device)
    let asset = MDLAsset(bufferAllocator: allocator)
    let meshAnchors = frame.anchors.compactMap { $0 as? ARMeshAnchor }
    
    for ma in meshAnchors {
        let geometry = ma.geometry
        let vertices = geometry.vertices
        let faces = geometry.faces
        let vertexPointer = vertices.buffer.contents()
        let facePointer = faces.buffer.contents()
        
        for vtxIndex in 0 ..< vertices.count {
            
            let vertex = geometry.vertex(at: UInt32(vtxIndex))
            var vertexLocalTransform = matrix_identity_float4x4
            
            vertexLocalTransform.columns.3 = SIMD4<Float>(x: vertex.0,
                                                          y: vertex.1,
                                                          z: vertex.2,
                                                          w: 1.0)
            
            let vertexWorldTransform = (ma.transform * vertexLocalTransform).position
            let vertexOffset = vertices.offset + vertices.stride * vtxIndex
            let componentStride = vertices.stride / 3
            
            vertexPointer.storeBytes(of: vertexWorldTransform.x,
                           toByteOffset: vertexOffset,
                                     as: Float.self)
            
            vertexPointer.storeBytes(of: vertexWorldTransform.y,
                           toByteOffset: vertexOffset + componentStride,
                                     as: Float.self)
            
            vertexPointer.storeBytes(of: vertexWorldTransform.z,
                           toByteOffset: vertexOffset + (2 * componentStride),
                                     as: Float.self)
        }
        
        let byteCountVertices = vertices.count * vertices.stride
        let byteCountFaces = faces.count * faces.indexCountPerPrimitive * faces.bytesPerIndex
        
        let vertexBuffer = allocator.newBuffer(with: Data(bytesNoCopy: vertexPointer,
                                                                count: byteCountVertices,
                                                          deallocator: .none), type: .vertex)
        
        let indexBuffer = allocator.newBuffer(with: Data(bytesNoCopy: facePointer,
                                                               count: byteCountFaces,
                                                         deallocator: .none), type: .index)
        
        let indexCount = faces.count * faces.indexCountPerPrimitive
        let material = MDLMaterial(name: "material",
                     scatteringFunction: MDLPhysicallyPlausibleScatteringFunction())
        
        let submesh = MDLSubmesh(indexBuffer: indexBuffer,
                                  indexCount: indexCount,
                                   indexType: .uInt32,
                                geometryType: .triangles,
                                    material: material)
        
        let vertexFormat = MTKModelIOVertexFormatFromMetal(vertices.format)
        
        let vertexDescriptor = MDLVertexDescriptor()
        
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                          format: vertexFormat,
                                                          offset: 0,
                                                     bufferIndex: 0)
        
        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: ma.geometry.vertices.stride)
        
        let mesh = MDLMesh(vertexBuffer: vertexBuffer,
                            vertexCount: ma.geometry.vertices.count,
                             descriptor: vertexDescriptor,
                              submeshes: [submesh])

        asset.add(mesh)
    }

    let filePath = FileManager.default.urls(for: .documentDirectory,
                                             in: .userDomainMask).first!
    
    let usd: URL = filePath.appendingPathComponent("model.usd")

    if MDLAsset.canExportFileExtension("usd") {
        do {
            try asset.export(to: usd)
            
            let controller = UIActivityViewController(activityItems: [usd],
                                              applicationActivities: nil)
            controller.popoverPresentationController?.sourceView = sender
            self.present(controller, animated: true, completion: nil)

        } catch let error {
            fatalError(error.localizedDescription)
        }
    } else {
        fatalError("Can't export USD")
    }
}

