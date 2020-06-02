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
import Schema

final class FormTests: XCTestCase {

    private lazy var form: Form = {
        let action = FormRemoteAction(path: "submit", method: .post)
        let form = Form(action: action, child: Container(children: [
            FormInput(name: "name", child: InputComponent(value: "John Doe")),
            FormSubmit(child: Button(text: "Add"), enabled: true)
        ]))
        return form
    }()

    private lazy var dependencies = BeagleScreenDependencies()
    
    func test_buildView_shouldRegisterFormSubmit() throws {
        // Given
<<<<<<< HEAD:iOS/Sources/BeagleUI/Sources/Components/Form+Renderable/Tests/FormTests.swift
        let context = BeagleContextSpy()
        let renderer = BeagleRenderer(context: context, dependencies: dependencies)
=======
        let formManager = FormManagerSpy()
        let context = BeagleContextSpy(formManager: formManager)
>>>>>>> master:iOS/Sources/BeagleUI/Sources/Components/Form/Tests/FormTests.swift
                
        // When
        _ = renderer.render(form)
        
        // Then
        XCTAssertTrue(formManager.didCallRegisterFormSubmit)
    }
<<<<<<< HEAD:iOS/Sources/BeagleUI/Sources/Components/Form+Renderable/Tests/FormTests.swift

    func test_registerForm_shouldAddGestureRecognizer() throws {
        // Given
        let form = Form(action: ActionDummy(), child: ComponentDummy())
        let formView = UIView()
        let submitView = UILabel()

        // When
        screen.register(form: form, formView: formView, submitView: submitView, validatorHandler: nil)

        // Then
        XCTAssertEqual(1, submitView.gestureRecognizers?.count)
        XCTAssertTrue(submitView.isUserInteractionEnabled)
    }

    let validator1 = "valid"
    let validator2 = "invalid"

    func test_formSubmit_shouldValidateInputs() throws {
        // Given
        var validationCount = 0
        validator[validator1] = { _ in
            validationCount += 1
            return true
        }
        validator[validator2] = { _ in
            validationCount += 1
            return false
        }

        let form = Form(action: ActionDummy(), child: Container(children: [
            FormInput(name: "name", required: true, validator: validator1, child: InputComponent(value: "John Doe")),
            FormInput(name: "password", required: true, validator: validator2, child: InputComponent(value: "password")),
            FormSubmit(child: Button(text: "Add"))
        ]))
        let view = renderer.render(form)

        let gesture = submitGesture(in: view)

        // When
        screen.handleSubmitFormGesture(gesture)

        // Then
        XCTAssert(validationCount == 2)
    }

    func test_formSubmit_shouldExecuteResponseAction() throws {
        // Given
        repositoryStub.formResult = .success(CustomAction(name: "custom", data: [:]))
        let gesture = submitGesture(in: formView)

        // When
        screen.handleSubmitFormGesture(gesture)

        // Then
        XCTAssert(actionExecutorSpy.didCallDoAction)
    }

    func test_formSubmit_shouldPassRightDataToBeSubmitted() throws {
        // Given
        let gesture = submitGesture(in: formView)

        // When
        screen.handleSubmitFormGesture(gesture)

        // Then
        let submittedData = repositoryStub.formData

        XCTAssert(repositoryStub.didCallDispatch)
        assertSnapshot(matching: submittedData, as: .dump)
    }

    func test_formSubmitError_shouldNotExecuteAction() throws {
        // Given
        let gesture = submitGesture(in: formView)

        // When
        screen.handleSubmitFormGesture(gesture)

        // Then
        XCTAssertFalse(actionExecutorSpy.didCallDoAction)
    }

    private lazy var formView = renderer.render(form)

    private lazy var renderer = BeagleRenderer(context: screen, dependencies: dependencies)

    private lazy var screen = BeagleScreenViewController(viewModel: .init(
        screenType: .declarative(SimpleComponent().content.toScreen()),
        dependencies: dependencies
    ))

    private lazy var dependencies = BeagleScreenDependencies(
        actionExecutor: actionExecutorSpy,
        repository: repositoryStub,
        validatorProvider: validator
    )

    private lazy var repositoryStub = RepositoryStub()
    private lazy var actionExecutorSpy = ActionExecutorSpy()
    private lazy var validator = ValidatorProviding()

    private func submitGesture(in formView: UIView) -> SubmitFormGestureRecognizer {
        // swiftlint:disable force_unwrapping force_cast
        let submit = findSubmitView(in: formView)!
        return submit.childView.gestureRecognizers!.first as! SubmitFormGestureRecognizer
    }

    private func findSubmitView(in view: UIView) -> FormSubmit.FormSubmitView? {
        if let submit = view as? FormSubmit.FormSubmitView {
            return submit
        } else {
            return view.subviews.first { findSubmitView(in: $0) != nil } as? FormSubmit.FormSubmitView
        }
=======
    
    func test_whenDecodingJson_thenItShouldReturnAForm() throws {
        let component: Form = try componentFromJsonFile(fileName: "formComponent")
        assertSnapshot(matching: component, as: .dump)
>>>>>>> master:iOS/Sources/BeagleUI/Sources/Components/Form/Tests/FormTests.swift
    }
}

// MARK: - Stubs

private struct InputComponent: BeagleUI.ServerDrivenComponent {
    let value: String

    func toView(renderer: BeagleRenderer) -> UIView {
        return InputStub(value: value)
    }
}

private class InputStub: UIView, InputValue, ValidationErrorListener, WidgetStateObservable {
    var observable = Observable<WidgetState>(value: WidgetState(value: false))

    let value: String

    init(value: String = "") {
        self.value = value
        super.init(frame: .zero)
    }

    required init?(coder: NSCoder) {
        BeagleUI.fatalError("init(coder:) has not been implemented")
    }

    func getValue() -> Any {
        return value
    }
    func onValidationError(message: String?) {
    }
}