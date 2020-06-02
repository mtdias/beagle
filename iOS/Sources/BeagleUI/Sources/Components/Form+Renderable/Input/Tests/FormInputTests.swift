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
@testable import BeagleUI
import Schema

final class FormInputTests: XCTestCase {
    
    func test_buildView_shouldReturnTheExpectedView() {
        // Given
        let formInput = FormInput(name: "username", child: ComponentDummy())
        
        // When
        let formInputView = renderer.render(formInput)
        
        // Then
        XCTAssertTrue(formInputView.beagleFormElement is FormInput)
    }
<<<<<<< HEAD:iOS/Sources/BeagleUI/Sources/Components/Form+Renderable/Input/Tests/FormInputTests.swift
    
    func test_formInputHidenView_ShouldReturnExpectedValue() {
        // Given
        let name = "id"
        let value = "123123"
        let formInputHiden = FormInputHidden(name: name, value: value)
        
        // When
        let view = renderer.render(formInputHiden) as? InputValue
        
        // Then
        XCTAssert(view?.getValue() is String)
        XCTAssert(name == formInputHiden.name)
        XCTAssert(value == view?.getValue() as? String)
    }
=======
>>>>>>> master:iOS/Sources/BeagleUI/Sources/Components/Form/Input/Tests/FormInputTests.swift
}