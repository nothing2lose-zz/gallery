//
//  CameraView.swift
//  gallery
//
//  Created by nothing on 9/1/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

final class CameraView: UIView {
    private(set) var sessionManager: CaptureSessionManager!
    private lazy var cameraShutterButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Take", for: .normal)
        return btn
    }()
    private lazy var cameraToggleButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Flip", for: .normal)
        return btn
    }()
    private lazy var cameraFlashButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitle("Flash", for: .normal)
        return btn
    }()
    
    private var disposeBag = DisposeBag()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let preview = sessionManager.videoPreviewLayer {
            preview.frame = bounds
        }
    }
    
    private func setup() {
        
        // layout
        addSubview(cameraShutterButton)
        addSubview(cameraToggleButton)
        addSubview(cameraFlashButton)
        
        cameraShutterButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(self)
            make.centerX.equalTo(self)
            make.height.equalTo(90)
            make.width.equalTo(90)
        }
        cameraToggleButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.trailing.equalTo(self).offset(-20)
            make.width.equalTo(80)
            make.height.equalTo(50)
        }
        cameraFlashButton.snp.makeConstraints { (make) in
            make.top.equalTo(self).offset(20)
            make.leading.equalTo(self).offset(20)
            make.width.equalTo(80)
            make.height.equalTo(50)
        }
        
        
        // camera session binding
        sessionManager = CaptureSessionManager()
        if let preview = sessionManager.videoPreviewLayer {
            preview.zPosition = -1
            preview.frame = bounds
            layer.addSublayer(preview)
        }
        
        // TODO: refactor
        sessionManager.start()
        
        // event binding
        let longpressGesture = UILongPressGestureRecognizer()
        cameraShutterButton.addGestureRecognizer(longpressGesture)
        longpressGesture.rx.event
            .filter({ (e) -> Bool in
                return (UIGestureRecognizerState.began == e.state || UIGestureRecognizerState.ended == e.state)
            })
            .flatMapLatest({ [weak self] (e) -> Observable<Int64> in
                guard let `self` = self else { return Observable<Int64>.empty() }
                if e.state == .began {
                    // TODO: Enhance - snapshot has a performance issue.
                    return Observable<Int64>.interval(0.20, scheduler: MainScheduler.instance)
                        .takeUntil(self.cameraShutterButton.rx.controlEvent(.touchUpInside))
                } else {
                    return Observable<Int64>.empty()
                }
            })
            .bind { [weak self] (x) in
                guard let `self` = self else { return }
                self.sessionManager.takeSnapshot()
            }
            .addDisposableTo(disposeBag)
        
        cameraShutterButton.rx.tap
            .bind(onNext: { [weak self]  in
                guard let `self` = self else { return }
                self.sessionManager.takeSnapshot()
            })
            .addDisposableTo(disposeBag)
        
        
        cameraToggleButton.rx.tap
            .bind(onNext: { [weak self] () in
                guard let `self` = self else { return }
                self.sessionManager.flip()
            })
            .addDisposableTo(disposeBag)
        
        cameraFlashButton.rx.tap
            .bind(onNext: { [weak self] () in
                guard let `self` = self else { return }
                self.sessionManager.flash()
            })
            .addDisposableTo(disposeBag)
    }
}
