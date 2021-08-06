//
//  ADImageEditConfigurable.swift
//  ADPhotoKit
//
//  Created by xu on 2021/7/23.
//

import Foundation

public typealias ADImageProcessorable = (UIViewController & ImageProcessor)
public protocol ImageProcessor: AnyObject {
    
    func process() -> UIImage?
    
}

public protocol ADImageEditTool: ImageProcessor {
    
    var image: UIImage { get }
    var selectImage: UIImage? { get }
    var isSelected: Bool { set get }
    
    var contentStatus: ((Bool) -> Void)? { set get }
    
    var toolConfigView: (UIView & ADToolConfigable)? { set get }
    var toolInteractView: (UIView & ADToolInteractable)? { set get }
    
    func toolDidSelect(ctx: ADImageProcessorable?) -> Bool
        
}

public extension ADImageEditTool {
    var selectImage: UIImage? { return nil }
}

public protocol ADToolConfigable {
    func singleTap(with point: CGPoint) -> Bool
}

extension ADToolConfigable {
    public func singleTap(with point: CGPoint) -> Bool {
        return false
    }
}

public enum ADInteractZIndex: Int {
    case Top = 100
    case Mid = 50
    case Bottom = 0
}

public enum ADInteractPolicy {
    case simult //同时相应
    case single
    case none
}

public enum ADInteractType {
    case pan(loc: CGPoint, trans: CGPoint)
    case pinch(CGFloat)
    case rotate(CGFloat)
}

public protocol ADToolInteractable {
    
    var zIndex: Int { get }
    
    var policy: ADInteractPolicy { get }
        
    func shouldInteract(_ gesture: UIGestureRecognizer, point: CGPoint) -> Bool
    
    func interact(with type: ADInteractType, scale: CGFloat, state: UIGestureRecognizer.State) -> Bool
}

extension ADToolInteractable {
    public func interact(with type: ADInteractType, scale: CGFloat, state: UIGestureRecognizer.State) -> Bool { return true }
}

public typealias ADImageStickerSelectable = (UIViewController & ADImageStickerSelectConfigurable)
public protocol ADImageStickerSelectConfigurable: AnyObject {
    
    var imageDidSelect: ((UIImage) -> Void)? { get set }
    
}

public typealias ADTextStickerColor = (textColor: UIColor, bgColor: UIColor)

public typealias ADTextStickerEditable = (UIViewController & ADTextStickerEditConfigurable)
public protocol ADTextStickerEditConfigurable: AnyObject {
    
    var textDidEdit: ((String, ADTextStickerColor) -> Void)? { get set }
    
}

public class ADImageEditConfigurable {
    
    public typealias ViewState = (center: CGPoint, scale: CGFloat)
    
    public static var contentViewState: ViewState?
    
    static func imageStickerSelectVC() -> ADImageStickerSelectable {
        return ADPhotoKitConfiguration.default.customImageStickerSelectVC ?? ADImageStickerSelectController(dataSource: ADPhotoKitConfiguration.default.imageStickerDataSource!)
    }
    
    static func textStickerEditVC() -> ADTextStickerEditable {
        return ADPhotoKitConfiguration.default.customTextStickerEditVC ?? ADTextStickerEditController()
    }
    
}
