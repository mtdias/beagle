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

package br.com.zup.beagle.sample.builder

import br.com.zup.beagle.action.ShowNativeDialog
import br.com.zup.beagle.ext.unitReal
import br.com.zup.beagle.sample.constants.BEACH_NETWORK_IMAGE
import br.com.zup.beagle.sample.constants.TEXT_NETWORK_IMAGE
import br.com.zup.beagle.widget.core.AlignSelf
import br.com.zup.beagle.widget.core.EdgeValue
import br.com.zup.beagle.widget.core.Flex
import br.com.zup.beagle.widget.core.ImageContentMode
import br.com.zup.beagle.widget.core.Size
import br.com.zup.beagle.widget.layout.Container
import br.com.zup.beagle.widget.layout.NavigationBar
import br.com.zup.beagle.widget.layout.NavigationBarItem
import br.com.zup.beagle.widget.layout.Screen
import br.com.zup.beagle.widget.layout.ScreenBuilder
import br.com.zup.beagle.widget.layout.ScrollAxis
import br.com.zup.beagle.widget.layout.ScrollView
import br.com.zup.beagle.widget.ui.NetworkImage
import br.com.zup.beagle.widget.ui.Text

object NetworkImageScreenBuilder : ScreenBuilder {
    override fun build() = Screen(
        navigationBar = NavigationBar(
            title = "Beagle NetworkImage",
            showBackButton = true,
            navigationBarItems = listOf(
                NavigationBarItem(
                    text = "",
                    image = "informationImage",
                    action = ShowNativeDialog(
                        title = "NetworkImage",
                        message = "It is a widget that implements an image with a URL.",
                        buttonText = "OK"
                    )
                )
            )
        ),
        child = ScrollView(
            scrollDirection = ScrollAxis.VERTICAL,
            children = listOf(buildImage(title = "NetworkImage")) +
                ImageContentMode.values().map { buildImage("NetworkImage with ImageContentMode.$it", it) }
        )
    )

    private fun buildImage(title: String, mode: ImageContentMode? = null) = Container(
        children = listOf(
            buildText(title),
            NetworkImage(
                path = BEACH_NETWORK_IMAGE,
                contentMode = mode
            ).applyFlex(
                flex = Flex(
                    size = Size(
                        width = 150.unitReal(),
                        height = 130.unitReal()
                    ),
                    alignSelf = AlignSelf.CENTER
                )
            )
        )
    )

    private fun buildText(text: String) = Text(
        text = text,
        style = TEXT_NETWORK_IMAGE
    ).applyFlex(
        flex = Flex(
            alignSelf = AlignSelf.CENTER,
            margin = EdgeValue(
                top = 8.unitReal()
            )
        )
    )
}
