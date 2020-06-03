/*
 * Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

import UIKit

 public struct LazyComponent: ServerDrivenComponent, AutoInitiableAndDecodable {
    
    // MARK: - Public Properties
    
    public let path: String
    public let initialState: ServerDrivenComponent

// sourcery:inline:auto:LazyComponent.Init
    public init(
        path: String,
        initialState: ServerDrivenComponent
    ) {
        self.path = path
        self.initialState = initialState
    }
// sourcery:end
}

extension LazyComponent: Renderable {
    
    public func toView(controller: BeagleController) -> UIView {
        let view = initialState.toView(controller: controller)
        lazyLoad(initialState: view, controller: controller)
        return view
    }
    
    private func lazyLoad(initialState view: UIView, controller: BeagleController) {
        controller.dependencies.repository.fetchComponent(url: path, additionalData: nil) {
            [weak view, weak controller] result in
            guard let view = view, let controller = controller else { return }
            switch result {
            case .success(let component):
                view.update(lazyLoaded: component, controller: controller)
            case .failure(let error):
                controller.serverDrivenState = .error(.lazyLoad(error))
            }
        }
    }
}

extension UIView {
    fileprivate func update(
        lazyLoaded: ServerDrivenComponent,
        controller: BeagleController
    ) {
        let finalView: UIView
        if let updatable = self as? OnStateUpdatable,
               updatable.onUpdateState(component: lazyLoaded) {
            finalView = self
        } else {
            finalView = replace(with: lazyLoaded, controller: controller)
        }
        controller.dependencies.flex(finalView).markDirty()
    }
    
    private func replace(
        with component: ServerDrivenComponent,
        controller: BeagleController
    ) -> UIView {
        guard let superview = superview else { return self }

        let newView = component.toView(controller: controller)
        newView.frame = frame
        superview.insertSubview(newView, belowSubview: self)
        removeFromSuperview()
        
        if controller.dependencies.flex(self).isEnabled {
           controller.dependencies.flex(newView).isEnabled = true
        }
        return newView
    }
}
