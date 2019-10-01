//
//  ImagePIX.swift
//  PixelKit
//
//  Created by Hexagons on 2018-08-07.
//  Open Source - MIT License
//

#if os(iOS) || os(tvOS)
import UIKit
#elseif os(macOS)
import AppKit
#endif
#if canImport(SwiftUI)
import SwiftUI
#endif

#if canImport(SwiftUI)
@available(iOS 13.0.0, *)
@available(OSX 10.15, *)
@available(tvOS 13.0.0, *)
public struct ImagePIXUI: View, PIXUI {
    public let pix: PIX
    let imagePix: ImagePIX
    public var body: some View {
        PIXRepView(pix: pix)
    }
    #if os(iOS) || os(tvOS)
    public init(image: UIImage) {
        imagePix = ImagePIX()
        imagePix.image = image
        pix = imagePix
    }
    #elseif os(macOS)
    public init(image: NSImage) {
        imagePix = ImagePIX()
        imagePix.image = image
        pix = imagePix
    }
    #endif
}
#endif

public class ImagePIX: PIXResource {
    
    #if os(iOS) || os(tvOS)
    override open var shader: String { return "contentResourceFlipPIX" }
    #elseif os(macOS)
    override open var shader: String { return "contentResourceBGRPIX" }
    #endif
    
    // MARK: - Public Properties
    
    #if os(iOS) || os(tvOS)
    public var image: UIImage? { didSet { setNeedsBuffer() } }
    #elseif os(macOS)
    public var image: NSImage? { didSet { setNeedsBuffer() } }
    #endif
    
    public var resizeToFitRes: Res? = nil
    var resizedRes: Res? {
        guard let res = resizeToFitRes else { return nil }
        guard let image = image else { return nil }
        return PIX.Res.cgSize(image.size).aspectRes(to: .fit, in: res)
    }
    
    // MARK: - Life Cycle
    
    public override init() {
        super.init()
        name = "image"
        self.applyRes {
            self.setNeedsRender()
        }
//        pixelKit.listenToFramesUntil {
//            if self.realResolution != nil {
//                return .done
//            }
//            if self.resolution != ._128 {
//                self.applyRes {
//                    self.setNeedsRender()
//                }
//                return .done
//            }
//            return .continue
//        }
    }
    
    // MARK: Buffer
    
    func setNeedsBuffer() {
        guard var image = image else {
            pixelKit.log(pix: self, .debug, .resource, "Nil not supported yet.")
            return
        }
        if let res = resizedRes {
            image = PixelKit.resize(image, to: res.size.cg)
        }
        if pixelKit.frame == 0 {
            pixelKit.log(pix: self, .debug, .resource, "One frame delay.")
            pixelKit.delay(frames: 1, done: {
                self.setNeedsBuffer()
            })
            return
        }
        guard let buffer = pixelKit.buffer(from: image) else {
            pixelKit.log(pix: self, .error, .resource, "Pixel Buffer creation failed.")
            return
        }
        pixelBuffer = buffer
        pixelKit.log(pix: self, .info, .resource, "Image Loaded.")
        applyRes { self.setNeedsRender() }
    }
    
}
