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

package br.com.zup.beagle.view.viewmodel

import androidx.lifecycle.LiveData
import androidx.lifecycle.MutableLiveData
import androidx.lifecycle.ViewModel
import br.com.zup.beagle.action.Action
import br.com.zup.beagle.core.ServerDrivenComponent
import br.com.zup.beagle.data.ActionRequester
import br.com.zup.beagle.data.ComponentRequester
import br.com.zup.beagle.exception.BeagleException
import br.com.zup.beagle.logger.BeagleLogger
import br.com.zup.beagle.utils.CoroutineDispatchers
import br.com.zup.beagle.view.ScreenRequest
import br.com.zup.beagle.widget.layout.ScreenComponent
import kotlinx.coroutines.CoroutineScope
import kotlinx.coroutines.Job
import kotlinx.coroutines.cancel
import kotlinx.coroutines.launch
import java.util.Observable
import java.util.concurrent.atomic.AtomicReference

sealed class ViewState {
    data class Error(val throwable: Throwable) : ViewState()
    class Loading(val value: Boolean) : ViewState()
    class DoRender(val screenId: String?, val component: ServerDrivenComponent) : ViewState()
    class DoAction(val action: Action) : ViewState()
}

internal class BeagleViewModel(
    private val componentRequester: ComponentRequester = ComponentRequester()
) : ViewModel(), CoroutineScope {

    private val job = Job()
    override val coroutineContext = job + CoroutineDispatchers.Main

    private val urlObservableReference = AtomicReference(UrlObservable())

    fun fetchComponent(screenRequest: ScreenRequest, screen: ScreenComponent? = null): LiveData<ViewState> {
        val state = MutableLiveData<ViewState>()
        launch {
            if (screenRequest.url.isNotEmpty()) {
                try {
                    if (hasFetchInProgress(screenRequest.url)) {
                        waitFetchProcess(screenRequest.url, state)
                    } else {
                        setLoading(screenRequest.url, true, state)
                        val component = componentRequester.fetchComponent(screenRequest)
                        state.value = ViewState.DoRender(screenRequest.url, component)
                    }
                } catch (exception: BeagleException) {
                    if (screen != null) {
                        state.value = ViewState.DoRender(screen.identifier, screen)
                    } else {
                        state.value = ViewState.Error(exception)
                    }
                }
                setLoading(screenRequest.url, false, state)
            } else if (screen != null) {
                state.value = ViewState.DoRender(screen.identifier, screen)
            }
        }

        return state
    }

    private fun setLoading(url: String, loading: Boolean, state: MutableLiveData<ViewState>) {
        urlObservableReference.get().setLoading(url, loading)
        state.value = ViewState.Loading(loading)
    }

    fun fetchForCache(url: String) = launch {
        try {
            urlObservableReference.get().setLoading(url, true)
            val component = componentRequester.fetchComponent(ScreenRequest(url))
            urlObservableReference.get().notifyLoaded(url, component)
        } catch (exception: BeagleException) {
            BeagleLogger.warning(exception.message)
        }

        urlObservableReference.get().setLoading(url, false)
    }

    @Suppress("UNCHECKED_CAST")
    private fun waitFetchProcess(url: String, state: MutableLiveData<ViewState>) {
        urlObservableReference.get().deleteObservers()
        urlObservableReference.get().addObserver { _, arg ->
            (arg as? Pair<String, ServerDrivenComponent>)?.let {
                urlObservableReference.get().setLoading(url, false)
                if (url == it.first)
                    state.value = ViewState.DoRender(url, it.second)
            }
        }
    }

    private fun hasFetchInProgress(url: String) =
        urlObservableReference.get().hasUrl(url)

    public override fun onCleared() {
        cancel()
    }

    //TODO Refactor this to use coroutines flow
    private class UrlObservable : Observable() {
        private var urlInLoadList = mutableListOf<String>()

        fun hasUrl(url: String) = urlInLoadList.contains(url)

        fun setLoading(url: String, loading: Boolean) {
            if (loading)
                urlInLoadList.add(url)
            else
                urlInLoadList.remove(url)
        }

        fun notifyLoaded(url: String, component: ServerDrivenComponent) {
            urlInLoadList.remove(url)
            val pair = url to component
            notifyObservers(pair)
        }
    }
}


