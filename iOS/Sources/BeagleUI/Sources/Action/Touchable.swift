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

public struct Touchable: ServerDrivenComponent, ClickedOnComponent, AutoInitiableAndDecodable {
    // MARK: - Public Properties
    public let action: Action
    public let clickAnalyticsEvent: AnalyticsClick?
    public let child: ServerDrivenComponent

// sourcery:inline:auto:Touchable.Init
    public init(
        action: Action,
        clickAnalyticsEvent: AnalyticsClick? = nil,
        child: ServerDrivenComponent
    ) {
        self.action = action
        self.clickAnalyticsEvent = clickAnalyticsEvent
        self.child = child
    }
// sourcery:end
}

extension Touchable: Renderable {
    public func toView(controller: BeagleController) -> UIView {
        let childView = child.toView(controller: controller)
        var events: [Event] = [.action(action)]
        if let clickAnalyticsEvent = clickAnalyticsEvent {
            events.append(.analytics(clickAnalyticsEvent))
        }
        
        register(events: events, inView: childView, controller: controller)
        prefetchComponent(helper: controller.dependencies.preFetchHelper)
        return childView
    }
    
    private func register(events: [Event], inView view: UIView, controller: BeagleController) {
        let eventsGestureRecognizer = EventsGestureRecognizer(
            events: events,
            controller: controller
        )
        view.addGestureRecognizer(eventsGestureRecognizer)
    }
    
    private func prefetchComponent(helper: BeaglePrefetchHelping) {
        guard let newPath = (action as? Navigate)?.newPath else { return }
        helper.prefetchComponent(newPath: newPath)
    }
}

enum Event {
    case action(Action)
    case analytics(AnalyticsClick)
}
