//
//  ADThumbnailListCell.swift
//  ADPhotoKit
//
//  Created by MAC on 2021/3/21.
//

import UIKit
import Photos

class ADThumbnailListCell: UICollectionViewCell {
    
    var identifier: String?
    
    var smallRequestID: PHImageRequestID?
    
    var bigRequestID: PHImageRequestID?
    
    var selectStatus: ADThumbnailSelectStatus = .select(index: nil) {
        didSet {
            selectStatusDidChange()
        }
    }
    
    var progressView: ADProgressableable!
    
    var selectAction: ((ADThumbnailListable,Bool)->Void)?
    
    var assetModel: ADAssetModel!
    
    var indexPath: IndexPath!
    
    // ui
    var imageView: UIImageView!
    var selectBtn: UIButton!
    var bottomMaskView: UIImageView!
    var tagImageView: UIImageView!
    var descLabel: UILabel!
    var indexLabel: UILabel!
    var coverView: UIView!
    
    override init(frame: CGRect) {
        super.init(frame: .zero)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupUI() {
        imageView = UIImageView(frame: .zero)
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        contentView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        coverView = UIView()
        coverView.isUserInteractionEnabled = false
        coverView.isHidden = true
        contentView.addSubview(coverView)
        coverView.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        selectBtn = UIButton(type: .custom)
        selectBtn.setBackgroundImage(Bundle.uiBundle?.image(name: "btn_unselected"), for: .normal)
        selectBtn.setBackgroundImage(Bundle.uiBundle?.image(name: "btn_selected"), for: .selected)
        selectBtn.addTarget(self, action: #selector(selectBtnAction(sender:)), for: .touchUpInside)
        contentView.addSubview(selectBtn)
        selectBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.right.equalToSuperview().offset(-7)
        }
        
        indexLabel = UILabel()
        indexLabel.backgroundColor = UIColor(hex: 0x50A938)
        indexLabel.layer.cornerRadius = 12
        indexLabel.layer.masksToBounds = true
        indexLabel.textColor = .white
        indexLabel.font = UIFont.systemFont(ofSize: 14)
        indexLabel.adjustsFontSizeToFitWidth = true
        indexLabel.minimumScaleFactor = 0.5
        indexLabel.textAlignment = .center
        selectBtn.addSubview(indexLabel)
        indexLabel.snp.makeConstraints { (make) in
            make.edges.equalToSuperview()
        }
        
        bottomMaskView = UIImageView(frame: .zero)
        bottomMaskView.image = Bundle.uiBundle?.image(name: "shadow")
        contentView.addSubview(bottomMaskView)
        bottomMaskView.snp.makeConstraints { (make) in
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(25)
        }
        
        tagImageView = UIImageView(frame: .zero)
        tagImageView.contentMode = .center
        bottomMaskView.addSubview(tagImageView)
        tagImageView.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(5)
            make.top.equalToSuperview().offset(1)
        }
        
        descLabel = UILabel()
        descLabel.font = UIFont.systemFont(ofSize: 13)
        descLabel.textAlignment = .right
        descLabel.textColor = .white
        bottomMaskView.addSubview(descLabel)
        descLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(1)
            make.right.equalToSuperview().offset(-5)
        }
        
        progressView = ADProgressView(frame: .zero)
        progressView.isHidden = true
        addSubview(progressView)
        progressView.snp.makeConstraints { (make) in
            make.size.equalTo(CGSize(width: 20, height: 20))
            make.center.equalToSuperview()
        }
    }
    
    func selectStatusDidChange() {
        if let id = bigRequestID {
            PHImageManager.default().cancelImageRequest(id)
        }
        switch selectStatus {
        case let .select(index):
            selectBtn.isEnabled = true
            if let idx = index {
                coverView.isHidden = false
                coverView.backgroundColor = UIColor(white: 0, alpha: 0.2)
                selectBtn.isSelected = true
                indexLabel.isHidden = false
                indexLabel.text = "\(idx)"
                bigRequestID = ADPhotoManager.fetch(for: assetModel.asset, type: .originImageData, progress: { [weak self] (progress, err, _, _) in
                    if self?.selectStatus.isSelect == true {
                        self?.progressView.isHidden = false
                        self?.progressView.progress = max(0.1, CGFloat(progress))
                        self?.imageView.alpha = 0.5
                        if progress >= 1 {
                            self?.progressView.isHidden = true
                            self?.imageView.alpha = 1
                        }
                    } else {
                        if let id = self?.bigRequestID {
                            PHImageManager.default().cancelImageRequest(id)
                        }
                    }
                }, completion: { [weak self] (_, _, _) in
                    self?.progressView.isHidden = true
                    self?.imageView.alpha = 1
                })
            }else{
                coverView.isHidden = true
                indexLabel.isHidden = true
                selectBtn.isSelected = false
            }
        case .deselect:
            coverView.isHidden = false
            coverView.backgroundColor = UIColor(white: 1, alpha: 0.5)
            indexLabel.isHidden = true
            selectBtn.isSelected = false
            selectBtn.isEnabled = false
        }
    }
    
    @objc
    func selectBtnAction(sender: UIButton) {
        selectBtn.layer.removeAllAnimations()
        if !selectBtn.isSelected {
            selectBtn.layer.add(ADPhotoKitUI.springAnimation(), forKey: nil)
        }
        selectAction?(self,!sender.isSelected)
    }
}

extension ADThumbnailListCell: ADThumbnailListConfigurable {
    
    func configure(with model: ADAssetModel, indexPath: IndexPath? = nil) {
        if let index = indexPath {
            self.indexPath = index
        }
        assetModel = model
        identifier = model.identifier
        selectStatus = model.selectStatus
        selectBtn.isHidden = !(ADPhotoKitUI.internalModel?.displaySelectBtn(model: model) ?? true)
        
        switch model.type {
        case .unknown:
            bottomMaskView.isHidden = true
        case .image:
            bottomMaskView.isHidden = true
        case .gif:
            bottomMaskView.isHidden = !(ADPhotoKitUI.internalModel?.assetOpts.contains(.selectAsGif) ?? true)
            tagImageView.image = nil
            descLabel.text = "GIF"
        case .livePhoto:
            bottomMaskView.isHidden = !(ADPhotoKitUI.internalModel?.assetOpts.contains(.selectAsLivePhoto) ?? true)
            tagImageView.image = Bundle.uiBundle?.image(name: "livePhoto")
            descLabel.text = "Live"
        case let .video(_, format):
            tagImageView.image = Bundle.uiBundle?.image(name: "video")
            bottomMaskView.isHidden = false
            descLabel.text = format
        }
        
        if let id = smallRequestID {
            PHImageManager.default().cancelImageRequest(id)
        }
        //imageView.image = Bundle.uiBundle?.image(name: "defaultphoto")
        smallRequestID = ADPhotoManager.fetch(for: model.asset, type: .image(size: bounds.size), progress: nil) { [weak self] (image, _, _) in
            if self?.identifier == self?.assetModel.identifier {
                self?.imageView?.image =  image as? UIImage
            }
        }
    }
    
    func cellSelectAction() {
        selectBtnAction(sender: selectBtn)
    }
    
}

extension ADPhotoKitInternal {
    
    fileprivate func displaySelectBtn(model: ADAssetModel) -> Bool {
        if let max = params.maxCount {
            if max > 1 {
                if !assetOpts.contains(.mixSelect) {
                    let type = selectMediaImage
                    return model.type.isImage == type
                }else{
                    return true
                }
            }else{
                return false
            }
        }
        return true
    }
    
}
