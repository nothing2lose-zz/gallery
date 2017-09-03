//
//  ImagePresentableProtocol.swift
//  gallery
//
//  Created by nothing on 9/3/17.
//  Copyright © 2017 nothing. All rights reserved.
//

import UIKit

import FSImageViewer

protocol ImagePresentableProtocol: class {
    var images: [UIImage]? { get }
}

extension ImagePresentableProtocol where Self: UIViewController {
    func showImagesInFullViewController(at index: Int) {
        guard let images = images, images.count > 0  else { return }
        let source = FSBasicImageSource(images: images.map { FSBasicImage(image: $0) })
        let vc = FSImageViewerViewController(imageSource: source, imageIndex: index)
        navigationController?.pushViewController(vc, animated: true)
    }
}
