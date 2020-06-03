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

public struct Button: Widget, ClickedOnComponent, AutoInitiableAndDecodable {
    
    // MARK: - Public Properties
    public let text: String
    public let style: String?
    public let action: Action?
    public var clickAnalyticsEvent: AnalyticsClick?
    public var widgetProperties: WidgetProperties

// sourcery:inline:auto:Button.Init
    public init(
        text: String,
        style: String? = nil,
        action: Action? = nil,
        clickAnalyticsEvent: AnalyticsClick? = nil,
        widgetProperties: WidgetProperties = WidgetProperties()
    ) {
        self.text = text
        self.style = style
        self.action = action
        self.clickAnalyticsEvent = clickAnalyticsEvent
        self.widgetProperties = widgetProperties
    }
// sourcery:end
}

extension Button: Renderable {
    
    public func toView(controller: BeagleController) -> UIView {
        
        let button = BeagleUIButton.button(
            action: action,
            clickAnalyticsEvent: clickAnalyticsEvent,
            controller: controller
        )
        button.setTitle(text, for: .normal)
        
        if let newPath = (action as? Navigate)?.newPath {
            controller.dependencies.preFetchHelper.prefetchComponent(newPath: newPath)
        }
        
        button.style = style
        button.beagle.setup(self)
        
        return button
    }
    
    final class BeagleUIButton: UIButton {
        
        var style: String? {
            didSet { applyStyle() }
        }

        override var isEnabled: Bool {
            get { return super.isEnabled }
            set {
                super.isEnabled = newValue
                applyStyle()
            }
        }
        
        override var isSelected: Bool {
            get { return super.isSelected }
            set {
                super.isSelected = newValue
                applyStyle()
            }
        }
        
        override var isHighlighted: Bool {
            get { return super.isHighlighted }
            set {
                super.isHighlighted = newValue
                applyStyle()
            }
        }
        
        private var action: Action?
        private var clickAnalyticsEvent: AnalyticsClick?
        private weak var controller: BeagleController?
        
        static func button(
            action: Action?,
            clickAnalyticsEvent: AnalyticsClick? = nil,
            controller: BeagleController
        ) -> BeagleUIButton {
            let button = BeagleUIButton(type: .system)
            button.action = action
            button.clickAnalyticsEvent = clickAnalyticsEvent
            button.controller = controller
            button.addTarget(button, action: #selector(triggerTouchUpInsideActions), for: .touchUpInside)
            return button
        }
        
        @objc func triggerTouchUpInsideActions() {
            guard let controller = controller else { return }
            
            if let click = clickAnalyticsEvent {
                controller.dependencies.analytics?.trackEventOnClick(click)
            }
            action?.execute(controller: controller, sender: self)
        }
        
        private func applyStyle() {
            guard let style = style else { return }
            controller?.dependencies.theme.applyStyle(for: self as UIButton, withId: style)
        }
    }
}
