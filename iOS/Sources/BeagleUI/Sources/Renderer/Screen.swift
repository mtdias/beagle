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

public struct Screen: AppearanceComponent, AutoInitiable {
    
    // MARK: - Public Properties
    
    public let identifier: String?
    public let appearance: Appearance?
    public let safeArea: SafeArea?
    public let navigationBar: NavigationBar?
    public let screenAnalyticsEvent: AnalyticsScreen?
    public let child: ServerDrivenComponent

// sourcery:inline:auto:Screen.Init
    public init(
        identifier: String? = nil,
        appearance: Appearance? = nil,
        safeArea: SafeArea? = nil,
        navigationBar: NavigationBar? = nil,
        screenAnalyticsEvent: AnalyticsScreen? = nil,
        child: ServerDrivenComponent
    ) {
        self.identifier = identifier
        self.appearance = appearance
        self.safeArea = safeArea
        self.navigationBar = navigationBar
        self.screenAnalyticsEvent = screenAnalyticsEvent
        self.child = child
    }
// sourcery:end
}

extension Screen {
   func toView(context: BeagleContext, dependencies: RenderableDependencies) -> UIView {
        return ScreenComponent(
            identifier: identifier,
            appearance: appearance,
            safeArea: safeArea,
            navigationBar: navigationBar,
            screenAnalyticsEvent: screenAnalyticsEvent,
            child: child
        ).toView(context: context, dependencies: dependencies)
    }
}
