//
//	main.swift
//	QRCode
//   
//	Created by Miaoqi Wang on 2021/11/29
//	Copyright © 2021 Alibaba. All rights reserved.
//

import Foundation
import CoreImage

func createQRCodeFromString(_ content: String) {
    guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
        print("createQRCodeFromString: create filter failed")
        return
    }
    
    guard let data = content.data(using: .utf8) else {
        print("createQRCodeFromString: create data from content:\(content) failed")
        return
    }
    
    filter.setDefaults()
    filter.setValue(data, forKey: "inputMessage")
    guard var image = filter.outputImage else {
        print("createQRCodeFromString create image failed")
        return
    }
    
    image = image.transformed(by: CGAffineTransform(scaleX: 8, y: 8))
    
    do {
        try CIContext().writePNGRepresentation(of: image, 
                                                to: URL(fileURLWithPath: "./qrcode.png"), 
                                                format: CIFormat.ARGB8, 
                                                colorSpace: CGColorSpace(name: CGColorSpace.sRGB)!, 
                                                options: [kCGImageDestinationLossyCompressionQuality as CIImageRepresentationOption : 1.0])
    } catch {
        print("createQRCodeFromString create png file error \(error)")
    }
}

func decodeQRCodeWithPath(_ imagePath: String) {
    let data = try! Data(contentsOf: URL(fileURLWithPath: imagePath))
    guard let ciImage = CIImage(data: data), 
    let detector = CIDetector(ofType: CIDetectorTypeQRCode, context: nil, options: [CIDetectorAccuracy: CIDetectorAccuracyLow]) else {
        print("decodeQRCodeString no image data or create detector failed")
        return
    }

    let features = detector.features(in: ciImage)
    guard let result = features.first as? CIQRCodeFeature, let resulStr = result.messageString else {
        print("decodeQRCodeWithPath no CIQRCodeFeature found or no resultStr found")
        return
    }
    print(resulStr)
}

if CommandLine.arguments.count < 3 {
    print("Command like: encode/decode xxx/xxx.jpg")
} else if CommandLine.arguments[1] == "encode" {
    createQRCodeFromString(CommandLine.arguments[2]) 
} else if CommandLine.arguments[1] == "decode" {
    decodeQRCodeWithPath(CommandLine.arguments[2])
} else {
    print("Command like: encode/decode xxx/xxx.jpg")
}
