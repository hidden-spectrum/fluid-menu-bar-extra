//
//  Copyright © 2023 Hidden Spectrum, LLC. All rights reserved.
//

import Combine
import SwiftUI


public final class FluidMenuBarExtraController: ObservableObject {
    
    // MARK: Public
    
    public var isWindowVisible: Bool { statusItem?.isWindowVisible ?? false }
    public var onVisibilityChangedHandler: ((Bool) -> Void)?
    
    // MARK: Internal
    
    weak var statusItem: FluidMenuBarExtraStatusItem? {
        didSet {
            removeObservers()
            addObservers()
        }
    }
    
    // MARK: Private
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: Subscriptions
    
    private func addObservers() {
        guard let statusItem = statusItem else {
            return
        }
        statusItem.windowWisibilitySubject
            .receive(on: DispatchQueue.main)
            .sink { [weak self] newValue in
                self?.onVisibilityChangedHandler?(newValue)
            }
            .store(in: &cancellables)
    }
    
    func removeObservers() {
        cancellables.removeAll()
    }

    // MARK: Visibility
    
    public func showWindow() {
        statusItem?.showWindow()
    }
    
    public func dismissWindow(animate: Bool = true, completionHandler: (() -> Void)? = nil) {
        guard let statusItem else {
            completionHandler?()
            return
        }
        statusItem.dismissWindow(animate: animate, completionHandler: completionHandler)
    }
    
    @MainActor
    public func dismissWindow(animate: Bool = true) async {
        await withCheckedContinuation { continuation in
            dismissWindow(animate: animate) {
                continuation.resume()
            }
        }
    }
    
    // MARK: Locking
    
    public func setLockWindowOpen(to lockEnabled: Bool) {
        statusItem?.preventDismissal = lockEnabled
    }
}
