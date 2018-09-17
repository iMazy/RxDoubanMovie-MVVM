//
//  ESPullToRefresh+Ex.swift
//  GSAE
//
//  Created by Mazy on 2018/6/8.
//  Copyright © 2018年 GSAE. All rights reserved.
//

import UIKit
import SnapKit
import ESPullToRefresh

extension UIDevice {
    var isIPhoneX: Bool {
        return userInterfaceIdiom == .phone && UIScreen.main.nativeBounds.height == 2436
    }
}

/// header refresh
class GSRefreshHeaderAnimator: UIView, ESRefreshProtocol, ESRefreshAnimatorProtocol, ESRefreshImpactProtocol {
    
    var insets: UIEdgeInsets = UIEdgeInsets.zero
    var view: UIView { return self }
    var trigger: CGFloat = 80
    var executeIncremental: CGFloat = 80
    var state: ESRefreshViewState = .pullToRefresh
    
    let indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView.init(activityIndicatorStyle: .gray)
        indicatorView.hidesWhenStopped = true
        return indicatorView
    }()
    
    var imageView: UIImageView = UIImageView(image: #imageLiteral(resourceName: "refresh_animator_arrow"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.addSubview(indicatorView)
        
        if UIDevice.current.isIPhoneX {
            trigger = 70
            executeIncremental = 70
            indicatorView.snp.makeConstraints({
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview().offset(16)
            })
            
            imageView.sizeToFit()
            imageView.contentMode = .center
            self.addSubview(imageView)
            imageView.snp.makeConstraints({
                $0.centerX.equalToSuperview()
                $0.centerY.equalToSuperview().offset(16)
            })
        } else {
            indicatorView.snp.makeConstraints({
                $0.center.equalToSuperview()
            })
            
            imageView.sizeToFit()
            self.addSubview(imageView)        
            imageView.snp.makeConstraints({
                $0.center.equalToSuperview()
            })
        }
    }
    
    public required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public func refreshAnimationBegin(view: ESRefreshComponent) {
        indicatorView.startAnimating()
        imageView.isHidden = true
        imageView.transform = CGAffineTransform(rotationAngle: 0.000001 - CGFloat(Double.pi))
    }
    
    public func refreshAnimationEnd(view: ESRefreshComponent) {
        indicatorView.stopAnimating()
        imageView.isHidden = false
        imageView.transform = .identity
    }
    
    public func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {
        
    }

    public func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        guard self.state != state else {
            return
        }
        self.state = state
        
        switch state {
        case .pullToRefresh:
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.imageView.transform = .identity
            }
        case .releaseToRefresh:
            self.impact()
            UIView.animate(withDuration: 0.25) { [weak self] in
                self?.imageView.transform = CGAffineTransform(rotationAngle: 0.000001 - CGFloat(Double.pi))
            }
        default:
            break
        }
    }
}


/// footer refresh
class GSRefreshFooterAnimator: UIView, ESRefreshAnimatorProtocol {

    var view: UIView {
        return self
    }

    var insets: UIEdgeInsets = .zero
    var trigger: CGFloat = 48
    var executeIncremental: CGFloat = 48
    var state: ESRefreshViewState = .pullToRefresh

    private let titleLabel: UILabel = {
        let label = UILabel(frame: CGRect.zero)
        label.font = UIFont.systemFont(ofSize: 14.0)
        label.textColor = UIColor(white: 160.0 / 255.0, alpha: 1.0)
        label.textAlignment = .center
        return label
    }()

    private let indicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        indicatorView.isHidden = true
        return indicatorView
    }()

    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        titleLabel.text = nil
        addSubview(titleLabel)
        addSubview(indicatorView)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        titleLabel.frame = self.bounds
        indicatorView.center = center
    }
}

extension GSRefreshFooterAnimator: ESRefreshProtocol {

    func refreshAnimationBegin(view: ESRefreshComponent) {
        indicatorView.isHidden = false
        indicatorView.startAnimating()
    }

    func refreshAnimationEnd(view: ESRefreshComponent) {
        indicatorView.stopAnimating()
        indicatorView.isHidden = true
    }

    func refresh(view: ESRefreshComponent, progressDidChange progress: CGFloat) {

    }

    func refresh(view: ESRefreshComponent, stateDidChange state: ESRefreshViewState) {
        switch state {
        case .noMoreData:
            titleLabel.text = "没有更多了"
        default:
            titleLabel.text = nil
        }
    }
}
