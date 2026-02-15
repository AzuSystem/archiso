/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import org.kde.kirigami 2.19 as Kirigami

QtObject {
    id: globalToolBar
    property int style: Kirigami.ApplicationHeaderStyle.None
    onStyleChanged: if (style === Kirigami.ApplicationHeaderStyle.TabBar) {
        console.warn("TabBar header style is deprecated.")
    }
    readonly property int actualStyle: {
        if (style === Kirigami.ApplicationHeaderStyle.Auto) {
            // TODO KF6
            // Legacy: if ApplicationHeader or ToolbarApplicationHeader are in the header or footer, disable the toolbar here
            if (typeof applicationWindow !== "undefined" && applicationWindow().header && applicationWindow().header.toString().indexOf("ApplicationHeader") !== -1) {
                return Kirigami.ApplicationHeaderStyle.None
            }

            //non legacy logic
            return (Kirigami.Settings.isMobile
                    ? (root.wideMode ? Kirigami.ApplicationHeaderStyle.Titles : Kirigami.ApplicationHeaderStyle.Breadcrumb)
                    : Kirigami.ApplicationHeaderStyle.ToolBar)
        }
        return style;
    }

    // TODO KF6: remove bool support.
    // Until then, `true` is considered as both `ShowBackButton | ShowForwardButton` together.
    property var/*flags<NavigationButtons> | bool*/ showNavigationButtons: (style !== Kirigami.ApplicationHeaderStyle.TabBar && (!Kirigami.Settings.isMobile || Qt.platform.os === "ios"))
        ? (Kirigami.ApplicationHeaderStyle.ShowBackButton | Kirigami.ApplicationHeaderStyle.ShowForwardButton)
        : Kirigami.ApplicationHeaderStyle.NoNavigationButtons
    property bool separatorVisible: true
    //Unfortunately we can't access pageRow.globalToolbar.Kirigami.Theme directly in a declarative way
    property int colorSet: Kirigami.Theme.Header
    // whether or not the header should be
    // "pushed" back when scrolling using the
    // touch screen
    property bool hideWhenTouchScrolling: false
    /**
     * If true, when any kind of toolbar is shown, the drawer handles will be shown inside the toolbar, if they're present
     */
    property bool canContainHandles: true
    property int toolbarActionAlignment: Qt.AlignRight
    property int toolbarActionHeightMode: Kirigami.ToolBarLayout.ConstrainIfLarger

    property int minimumHeight: 0
    // FIXME: Figure out the exact standard size of a Toolbar
    property int preferredHeight: (actualStyle === Kirigami.ApplicationHeaderStyle.ToolBar
                    ? Kirigami.Units.iconSizes.medium
                    : Kirigami.Units.gridUnit * 1.8) + Kirigami.Units.smallSpacing * 2
    property int maximumHeight: preferredHeight

    // Sets the minimum leading padding for the title in a page header
    property int titleLeftPadding: Kirigami.Units.gridUnit
}
