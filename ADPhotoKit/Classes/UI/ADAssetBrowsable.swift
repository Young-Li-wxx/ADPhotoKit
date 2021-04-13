//
//  ADAssetBrowsable.swift
//  ADPhotoKit
//
//  Created by xu on 2021/4/2.
//

import Foundation
import Kingfisher
import Photos

public protocol ADAssetBrowsable {
    var browseAsset: ADAsset { get }
}

public enum ADImageSource {
    case network(URL)
    case album(PHAsset)
    case local(UIImage)
    
    var identifier: String {
        switch self {
        case let .network(url):
            return url.absoluteString
        case let .album(asset):
            return asset.localIdentifier
        case .local(_):
            return UUID().uuidString
        }
    }
    
}

public enum ADVideoSource {
    case network(URL)
    case album(PHAsset)
    case local(URL)
    
    var identifier: String {
        switch self {
        case let .network(url):
            return url.absoluteString
        case let .album(asset):
            return asset.localIdentifier
        case let .local(url):
            return url.absoluteString
        }
    }
}

public enum ADAsset: Equatable {
    
    case image(ADImageSource)
    case video(ADVideoSource)
    
    var identifier: String {
        switch self {
        case let .image(source):
            return source.identifier
        case let .video(source):
            return source.identifier
        }
    }
    
    public static func == (lhs: ADAsset, rhs: ADAsset) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}

extension ADAssetModel: ADAssetBrowsable {
    public var browseAsset: ADAsset {
        if type.isImage  {
            return .image(.album(asset))
        }else{
            return .video(.album(asset))
        }
    }
}

extension PHAsset: ADAssetBrowsable {
    public var browseAsset: ADAsset {
        switch self.mediaType {
        case .video:
            return .video(.album(self))
        case .image:
            return .image(.album(self))
        default:
            return .image(.album(self))
        }
    }
}

extension UIImage: ADAssetBrowsable {
    public var browseAsset: ADAsset {
        return .image(.local(self))
    }
}
