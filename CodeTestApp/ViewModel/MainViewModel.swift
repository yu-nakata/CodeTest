//
//  MainViewModel.swift
//  CodeTestApp
//
//  Created by 中田祐稀 on 2021/01/26.
//

import Foundation
import RxSwift
import RxCocoa

class MainViewModel {
    var images: [UIImage?] = []
    // API
    let onCompletedFetchImageRelay = BehaviorRelay<Bool>(value: false)
    private(set) lazy var onCompletedFetchImage = onCompletedFetchImageRelay.asDriver()
    
    func fetchImage(disposeBag: DisposeBag) {
        Observable
            .of(APIClient().getImage(imageUrl: "https://contents.newspicks.us/users/100013/cover?circle=true"),
                APIClient().getImage(imageUrl: "https://contents.newspicks.us/users/100269/cover?circle=true"),
                APIClient().getImage(imageUrl: "https://contents.newspicks.us/users/100094/cover?circle=true"),
                APIClient().getImage(imageUrl: "https://contents.newspicks.us/users/100353/cover?circle=true"),
                APIClient().getImage(imageUrl: "https://contents.newspicks.us/users/100019/cover?circle=true"),
                APIClient().getImage(imageUrl: "https://contents.newspicks.us/users/100529/cover?circle=true"))
            .merge()
            .subscribe(onNext : {image in
                self.images.append(image)
            }, onError : { error in
            }, onCompleted: {
                self.onCompletedFetchImageRelay.accept(true)
            }).disposed(by : disposeBag)
    }
}
