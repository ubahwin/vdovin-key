import SwiftUI
import Foundation
import UIKit

class VC1: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        presentSheetVC()
    }

    private func presentSheetVC() {
        let vc2 = VC2()
        if let sheet = vc2.sheetPresentationController {
            sheet.detents = [
                .large(), // Полноэкранное отображение
                .custom(resolver: { context in
                    return context.maximumDetentValue * 0.75
                })
            ]
            sheet.prefersGrabberVisible = false
            sheet.prefersEdgeAttachedInCompactHeight = true
            sheet.widthFollowsPreferredContentSizeWhenEdgeAttached = true
        }
        vc2.modalPresentationStyle = .automatic
        vc2.isModalInPresentation = true
        present(vc2, animated: true, completion: nil)
    }
}

class VC2: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
    }
}

#Preview {
    VC1()
}
