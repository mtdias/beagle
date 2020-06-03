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

public struct Form: ServerDrivenComponent, AutoInitiableAndDecodable {
    
    // MARK: - Public Properties

    public let action: Action
    public let child: ServerDrivenComponent
    public let group: String?
    public let additionalData: [String: String]?
    public var shouldStoreFields: Bool = false
    
// sourcery:inline:auto:Form.Init
    public init(
        action: Action,
        child: ServerDrivenComponent,
        group: String? = nil,
        additionalData: [String: String]? = nil,
        shouldStoreFields: Bool = false
    ) {
        self.action = action
        self.child = child
        self.group = group
        self.additionalData = additionalData
        self.shouldStoreFields = shouldStoreFields
    }
// sourcery:end
}

extension Form: Renderable {
    public func toView(controller: BeagleController) -> UIView {
        let childView = child.toView(controller: controller)
        var hasFormSubmit = false
        
        func registerFormSubmit(view: UIView) {
            if view.beagleFormElement is FormSubmit {
                hasFormSubmit = true
                register(form: self, formView: childView, submitView: view, controller: controller)
            }
            for subview in view.subviews {
                registerFormSubmit(view: subview)
            }
        }
        
        registerFormSubmit(view: childView)
        if !hasFormSubmit {
            controller.dependencies.logger.log(Log.form(.submitNotFound(form: self)))
        }
        return childView
    }
    
    private func register(form: Form, formView: UIView, submitView: UIView, controller: BeagleController) {
        let gestureRecognizer = SubmitFormGestureRecognizer(
            form: form,
            formView: formView,
            formSubmitView: submitView,
            controller: controller
        )
        if let control = submitView as? UIControl,
           let formSubmit = submitView.beagleFormElement as? FormSubmit,
           let enabled = formSubmit.enabled {
            control.isEnabled = enabled
        }

        submitView.addGestureRecognizer(gestureRecognizer)
        submitView.isUserInteractionEnabled = true
        gestureRecognizer.updateSubmitView()
    }
}

extension UIView {
    private struct AssociatedKeys {
        static var FormElement = "beagleUI_FormElement"
    }
    
    private class ObjectWrapper<T> {
        let object: T?
        
        init(_ object: T?) {
            self.object = object
        }
    }
    
    var beagleFormElement: ServerDrivenComponent? {
        // swiftlint:disable implicit_getter
        get {
            return (objc_getAssociatedObject(self, &AssociatedKeys.FormElement) as? ObjectWrapper)?.object
        }
        set {
            objc_setAssociatedObject(self, &AssociatedKeys.FormElement, ObjectWrapper(newValue), .OBJC_ASSOCIATION_RETAIN_NONATOMIC)
        }
    }
}
