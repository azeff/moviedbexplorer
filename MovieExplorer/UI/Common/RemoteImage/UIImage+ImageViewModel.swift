//
//  UIImage+RemoteImage.swift
//  MovieExplorer
//
//  Created by Evgeny Kazakov on 16.06.2019.
//  Copyright © 2019 Evgeny Kazakov. All rights reserved.
//

import UIKit

extension MVE where Base: UIImageView {
  
  func setImage(_ image: ImageViewModelProtocol?) {
    
    guard let imageVM = image else {
      base.image = nil
      return
    }
    
    base.image = imageVM.image

    imageVM.onChanged = { [weak base, unowned imageVM] in
      guard let base = base else { return }
      
      self.crossDissolveTransition {
        base.image = imageVM.image
      }
    }
  }

}
