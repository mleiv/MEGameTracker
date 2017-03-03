//
//  UIPDFView.swift
//  MEGameTracker
//
//  Created by Emily Ivie on 10/8/15.
//  Copyright © 2015 Emily Ivie. All rights reserved.
//

import UIKit

public class UIPDFView: UIView {
    let myPageRef: CGPDFPage?

    public init?(url: URL) {
        guard let myDocumentRef = CGPDFDocument(url as CFURL),
              let myPageRef = myDocumentRef.page(at: 1)
        else {
            self.myPageRef = nil
            super.init(frame: CGRect.zero)
            return nil
        }
        self.myPageRef = myPageRef
        let pageRect = myPageRef.getBoxRect(CGPDFBox.mediaBox).integral
        super.init(frame: pageRect)
        if let layer = self.layer as? CATiledLayer {
            layer.delegate = self
            layer.tileSize = CGSize(width: 1024.0, height: 1024.0)
            layer.levelsOfDetail = 3
            layer.levelsOfDetailBias = 2
            layer.frame = pageRect
        }
        backgroundColor = UIColor.clear
        contentScaleFactor = 1.0
    }

    public required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public class var layerClass : (AnyClass) {
        return CATiledLayer.self
    }
    
    override public func draw(_ layer: CALayer, in ctx: CGContext) {
        if let myPageRef = self.myPageRef {
            ctx.clear(ctx.boundingBoxOfClipPath)
            ctx.translateBy(x: 0.0, y: layer.bounds.size.height)
            ctx.scaleBy(x: 1.0, y: -1.0)
//            CGContextConcatCTM(ctx, CGPDFPageGetDrawingTransform(myPageRef, CGPDFBox.MediaBox, layer.bounds, 0, true))
            ctx.drawPDFPage(myPageRef)
        }
    }
}

