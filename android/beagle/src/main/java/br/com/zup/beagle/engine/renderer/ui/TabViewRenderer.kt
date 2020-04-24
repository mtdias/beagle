/*
 * Copyright 2020 ZUP IT SERVICOS EM TECNOLOGIA E INOVACAO SA
 *
 * This Source Code Form is subject to the terms of the Mozilla Public
 * License, v. 2.0. If a copy of the MPL was not distributed with this
 * file, You can obtain one at https://mozilla.org/MPL/2.0/.
 */

package br.com.zup.beagle.engine.renderer.ui

import android.content.Context
import android.graphics.Color
import android.graphics.drawable.Drawable
import android.support.design.widget.TabLayout
import android.view.View
import android.view.ViewGroup
import android.widget.FrameLayout
import android.support.v4.content.ContextCompat
import android.support.v4.view.PagerAdapter
import android.support.v4.view.ViewPager
import br.com.zup.beagle.R
import br.com.zup.beagle.engine.renderer.RootView
import br.com.zup.beagle.engine.renderer.UIViewRenderer
import br.com.zup.beagle.setup.BeagleEnvironment
import br.com.zup.beagle.utils.StyleManager
import br.com.zup.beagle.utils.dp
import br.com.zup.beagle.view.ViewFactory
import br.com.zup.beagle.widget.core.Flex
import br.com.zup.beagle.widget.ui.TabItem
import br.com.zup.beagle.widget.ui.TabView

private val TABBAR_HEIGHT = 48.dp()
internal var styleManagerFactory = StyleManager()

internal class TabViewRenderer(
    override val component: TabView,
    private val viewFactory: ViewFactory = ViewFactory()
) : UIViewRenderer<TabView>() {

    override fun buildView(rootView: RootView): View {
        val containerFlex = Flex(grow = 1.0)

        val container = viewFactory.makeBeagleFlexView(rootView.getContext(), containerFlex)

        val tabLayout = makeTabLayout(rootView.getContext())

        val viewPager = viewFactory.makeViewPager(rootView.getContext()).apply {
            adapter = ContentAdapter(
                rootView = rootView,
                viewFactory = viewFactory,
                tabList = component.tabItems
            )
        }

        val containerViewPager =
            viewFactory.makeBeagleFlexView(rootView.getContext()).apply {
                addView(viewPager)
            }

        tabLayout.addOnTabSelectedListener(getTabSelectedListener(viewPager))
        viewPager.addOnPageChangeListener(getViewPagerChangePageListener(tabLayout))

        container.addView(tabLayout)
        container.addView(containerViewPager)
        return container
    }

    private fun makeTabLayout(context: Context): TabLayout {
        return viewFactory.makeTabLayout(context).apply {
            layoutParams =
                viewFactory.makeFrameLayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    TABBAR_HEIGHT
                )

            tabMode = TabLayout.MODE_SCROLLABLE
            tabGravity = TabLayout.GRAVITY_FILL
            setData()
            addTabs(context)
        }
    }

    private fun TabLayout.setData() {
        val typedArray = styleManagerFactory.getTabBarTypedArray(context, component.style)
        typedArray?.let {
            setTabTextColors(
                it.getColor(R.styleable.BeagleTabBarStyle_tabTextColor, Color.BLACK),
                it.getColor(R.styleable.BeagleTabBarStyle_tabSelectedTextColor, Color.GRAY)
            )
            setSelectedTabIndicatorColor(
                it.getColor(
                    R.styleable.BeagleTabBarStyle_tabIndicatorColor,
                    styleManagerFactory.getTypedValueByResId(R.attr.colorAccent, context).data
                )
            )
            background = it.getDrawable(R.styleable.BeagleTabBarStyle_tabBackground)
            tabIconTint = it.getColorStateList(R.styleable.BeagleTabBarStyle_tabIconTint)
            it.recycle()
        }
    }

    private fun TabLayout.addTabs(context: Context) {
        for (i in component.tabItems.indices) {
            addTab(newTab().apply {
                text = component.tabItems[i].title
                component.tabItems[i].icon?.let {
                    icon = getIconFromResources(context, it)
                }
            })
        }
    }

    private fun getIconFromResources(context: Context, icon: String): Drawable? {
        return BeagleEnvironment.beagleSdk.designSystem?.image(icon)?.let {
            ContextCompat.getDrawable(context, it)
        }
    }

    private fun getTabSelectedListener(viewPager: ViewPager): TabLayout.OnTabSelectedListener {
        return object :
            TabLayout.OnTabSelectedListener {
            override fun onTabSelected(tab: TabLayout.Tab) {
                viewPager.currentItem = tab.position
            }

            override fun onTabUnselected(tab: TabLayout.Tab) {}

            override fun onTabReselected(tab: TabLayout.Tab) {}
        }
    }

    private fun getViewPagerChangePageListener(tabLayout: TabLayout): ViewPager.OnPageChangeListener {
        return object : ViewPager.OnPageChangeListener {
            override fun onPageScrollStateChanged(state: Int) {}

            override fun onPageScrolled(
                position: Int,
                positionOffset: Float,
                positionOffsetPixels: Int
            ) {
            }

            override fun onPageSelected(position: Int) {
                tabLayout.getTabAt(position)?.select()
            }
        }
    }
}

internal class ContentAdapter(
    private val tabList: List<TabItem>,
    private val viewFactory: ViewFactory,
    private val rootView: RootView
) : PagerAdapter() {

    override fun isViewFromObject(view: View, `object`: Any): Boolean = view === `object`

    override fun getCount(): Int = tabList.size

    override fun instantiateItem(container: ViewGroup, position: Int): Any {
        val view = viewFactory.makeBeagleFlexView(rootView.getContext()).also {
            it.addServerDrivenComponent(tabList[position].content, rootView)
        }
        container.addView(view)
        return view
    }

    override fun destroyItem(container: ViewGroup, position: Int, `object`: Any) {
        container.removeView(`object` as View)
    }
}