//
//  BackgroundColorView.swift
//  Demo
//
//  Created by Alessandro Toschi on 02/01/22.
//

import SwiftUI
import MetalViewUI
import MetalKit
import Combine

struct BackgroundColorView: View {
    
    @State private var backgroundColor: Color = Color.yellow
    
    private let metalDelegate = DefaultRenderer()
    private let metalDevice = MTLCreateSystemDefaultDevice()!
    private let setNeedsDisplayTrigger = PassthroughSubject<Void, Never>()
    
    var colorPixelFormat: MTLPixelFormat = {
        #if targetEnvironment(simulator)
        return .bgra8Unorm
        #else
        return (UIScreen.main.traitCollection.displayGamut == .P3) ? .bgra10_xr : .bgra8Unorm
        #endif
    }()
    
    var body: some View {
        return VStack {
            MetalView(
                metalDevice: self.metalDevice,
                drawableSizeWillChangeCallback: nil,
                drawCallback: nil,
                contentTrigger: self.setNeedsDisplayTrigger.eraseToAnyPublisher()
            )
                .isPaused(true)
                .enableSetNeedsDisplay(true)
                .clearColor(backgroundColor.asMTLClearColor())
                .framebufferOnly(true)
                .colorPixelFormat(colorPixelFormat)
                .padding(10.0)
            ColorPicker("Choose color:", selection: $backgroundColor).padding(10.0).onChange(of: backgroundColor, perform: { _ in
                self.setNeedsDisplayTrigger.send()
            })
        }
    }
}

extension Color {
    
    func asMTLClearColor() -> MTLClearColor {
        
        var red: CGFloat = 0.0
        var green: CGFloat = 0.0
        var blue: CGFloat = 0.0
        var alpha: CGFloat = 0.0
        
        guard UIColor(self).getRed(&red, green: &green, blue: &blue, alpha: &alpha) else { return MTLClearColorMake(0.0, 0.0, 0.0, 1.0) }
        
        return MTLClearColorMake(red, green, blue, alpha)
        
    }
    
}

class DefaultRenderer: NSObject, MTKViewDelegate {
    
    var commandQueue: MTLCommandQueue?
    
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) { }
    
    func draw(in view: MTKView) {
        
        if self.commandQueue == nil {
            self.commandQueue = view.device?.makeCommandQueue()
        }
                        
        guard let commandQueue = commandQueue,
        let commandBuffer = commandQueue.makeCommandBuffer(),
        let renderPassDescriptor = view.currentRenderPassDescriptor,
        let renderCommandEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: renderPassDescriptor),
        let drawable = view.currentDrawable else { return }
        
        renderCommandEncoder.endEncoding()
        commandBuffer.present(drawable)
        commandBuffer.commit()

    }
    
}

struct BackgroundColorView_Previews: PreviewProvider {
    static var previews: some View {
        BackgroundColorView()
    }
}
