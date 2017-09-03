//
//  CameraViewController.swift
//  gallery
//
//  Created by nothing on 9/1/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import UIKit

import SnapKit
import RxSwift
import RxCocoa

protocol CameraViewControllerDelegate: class {
    func cameraViewController(viewController: CameraViewController, didConfirmWith images: [UIImage])
    func cameraViewControllerDidCancel()
}

final class CameraViewController: UIViewController {
    private lazy var cameraView: CameraView = { CameraView() }()
    private lazy var confirmButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Save", for: .normal)
        return btn
    }()
    private lazy var closeButton: UIButton = {
        let btn = UIButton(type: .custom)
        btn.setTitleColor(.white, for: .normal)
        btn.setTitle("Cancel", for: .normal)
        return btn
    }()
    private var disposeBag = DisposeBag()
    
    weak var delegate: CameraViewControllerDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup() {
        
        // layout
        
        view.addSubview(cameraView)
        view.addSubview(confirmButton)
        view.addSubview(closeButton)
        
        cameraView.snp.makeConstraints { (make) in
            make.edges.equalTo(view)
        }
        confirmButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).offset(-20)
            make.trailing.equalTo(view).offset(-20)
            make.width.equalTo(80)
            make.height.equalTo(50)
        }
        closeButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(view).offset(-20)
            make.leading.equalTo(view).offset(20)
            make.width.equalTo(80)
            make.height.equalTo(50)
        }
        
        // event binding
        confirmButton.rx.tap
            .bind(onNext: { [weak self] in
                guard let `self` = self else { return }
                self.delegate?.cameraViewController(viewController: self, didConfirmWith: self.cameraView.sessionManager.images)
                self.dismiss(animated: true, completion: nil)
            })
            .addDisposableTo(disposeBag)
        
        closeButton.rx.tap
            .bind(onNext: { [weak self] () in
                guard let `self` = self else { return }
                self.delegate?.cameraViewControllerDidCancel()
                self.dismiss(animated: true, completion: nil)
            })
            .addDisposableTo(disposeBag)
        
        
        
    }
}
