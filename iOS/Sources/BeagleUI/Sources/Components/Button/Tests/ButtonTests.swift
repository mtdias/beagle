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

import XCTest
import SnapshotTesting
@testable import BeagleUI

final class ButtonTests: XCTestCase {

    private let dependencies = BeagleScreenDependencies()
    
    func test_toView_shouldSetRightButtonTitle() {
        //Given
        let buttonTitle = "title"
        let component = Button(text: buttonTitle)
        let controller = BeagleControllerStub()

        //When        
        guard let button = component.toView(controller: controller) as? UIButton else {
            XCTFail("Build View not returning UIButton")
            return
        }
        
        // Then
        XCTAssertEqual(button.titleLabel?.text, buttonTitle)
    }
    
    func test_toView_shouldApplyButtonStyle() {
        
        let theme = ThemeSpy()
        let controller = BeagleControllerStub()
        controller.dependencies = BeagleScreenDependencies(theme: theme)
        
        let style = "test.button.style"
        let button = Button(text: "apply style", style: style)
        
        let view = button.toView(controller: controller)
        
        XCTAssertEqual(view, theme.styledView)
        XCTAssertEqual(style, theme.styleApplied)
    }
    
    func test_toView_shouldPrefetchNavigateAction() {
        let prefetch = BeaglePrefetchHelpingSpy()
        let controller = BeagleControllerStub()
        controller.dependencies = BeagleScreenDependencies(preFetchHelper: prefetch)
        
        let navigatePath = "path-to-prefetch"
        let navigate = Navigate.pushStack(.remote(navigatePath))
        let button = Button(text: "prefetch", action: navigate)
        
        _ = button.toView(controller: controller)
        XCTAssertEqual([navigatePath], prefetch.prefetched)
    }
    
    func test_action_shouldBeTriggered() {
        
        let action = ActionSpy()
        let button = Button(text: "Trigger Action", action: action)
        let controller = BeagleControllerStub()
        
        let view = button.toView(controller: controller)
        (view as? Button.BeagleUIButton)?.triggerTouchUpInsideActions()
        
        XCTAssertEqual(action.executionCount, 1)
        XCTAssert(action.lastSender as AnyObject === view)
    }
    
    func test_analytics_click_shouldBeTriggered() {
        let analytics = AnalyticsExecutorSpy()
        let button = Button(text: "Trigger analytics click", clickAnalyticsEvent: .init(category: "some category"))
        let controller = BeagleControllerStub()
        controller.dependencies = BeagleScreenDependencies(analytics: analytics)
        let view = button.toView(controller: controller)
        (view as? Button.BeagleUIButton)?.triggerTouchUpInsideActions()
        
        XCTAssertTrue(analytics.didTrackEventOnClick)
    }
    
    func test_analytics_click_and_action_shouldBeTriggered() {
        let action = ActionSpy()
        let analytics = AnalyticsExecutorSpy()
        let button = Button(text: "Trigger analytics click", action: action, clickAnalyticsEvent: .init(category: "some category"))
        let controller = BeagleControllerStub()
        controller.dependencies = BeagleScreenDependencies(analytics: analytics)
        let view = button.toView(controller: controller)
        (view as? Button.BeagleUIButton)?.triggerTouchUpInsideActions()
        
        XCTAssertTrue(analytics.didTrackEventOnClick)
        XCTAssertEqual(action.executionCount, 1)
        XCTAssert(action.lastSender as AnyObject === view)
    }
    
    func test_whenDecodingJson_thenItShouldReturnAButton() throws {
        let component: Button = try componentFromJsonFile(fileName: "buttonComponent")
        assertSnapshot(matching: component, as: .dump)
    }
    
}

final class ThemeSpy: Theme {
    
    private(set) var styledView: UIView?
    private(set) var styleApplied: String?
    
    func applyStyle<T>(for view: T, withId id: String) where T: UIView {
        styledView = view
        styleApplied = id
    }
}

final class BeaglePrefetchHelpingSpy: BeaglePrefetchHelping {
    
    private(set) var prefetched: [String] = []
    private(set) var dequeued: [String] = []
    var maximumScreensCapacity = 30
    
    func prefetchComponent(newPath: Route.NewPath) {
        
        prefetched.append(newPath.route)
    }
    
    func dequeueComponent(path: String) -> ServerDrivenComponent? {
        dequeued.append(path)
        return nil
    }
}

class ActionSpy: Action {
    private(set) var executionCount = 0
    private(set) var lastController: BeagleController?
    private(set) var lastSender: Any?
    
    func execute(controller: BeagleController, sender: Any) {
        executionCount += 1
        lastController = controller
        lastSender = sender
    }
    
    init() {}
    required init(from decoder: Decoder) throws {}
}
