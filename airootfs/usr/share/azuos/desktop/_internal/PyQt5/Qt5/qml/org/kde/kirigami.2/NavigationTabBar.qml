/*
 * Copyright 2021 Devin Lin <espidev@gmail.com>
 *
 * SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQml 2.15
import QtQuick.Layouts 1.15
import QtGraphicalEffects 1.12 as GE
import QtQuick.Templates 2.15 as T
import org.kde.kirigami 2.19 as Kirigami

/**
 * @brief Page navigation tab-bar, used as an alternative to sidebars for 3-5 elements.
 *
 * Can be combined with secondary toolbars above (if in the footer) to provide page actions.
 *
 * Example usage:
 * @code{.qml}
 * import QtQuick 2.15
 * import QtQuick.Controls 2.15
 * import QtQuick.Layouts 1.15
 * import org.kde.kirigami 2.20 as Kirigami
 *
 * Kirigami.ApplicationWindow {
 *     title: "Clock"
 *
 *     pageStack.initialPage: worldPage
 *     Kirigami.Page {
 *         id: worldPage
 *         title: "World"
 *         visible: false
 *     }
 *     Kirigami.Page {
 *         id: timersPage
 *         title: "Timers"
 *         visible: false
 *     }
 *     Kirigami.Page {
 *         id: stopwatchPage
 *         title: "Stopwatch"
 *         visible: false
 *     }
 *     Kirigami.Page {
 *         id: alarmsPage
 *         title: "Alarms"
 *         visible: false
 *     }
 *
 *
 *     footer: Kirigami.NavigationTabBar {
 *         actions: [
 *             Kirigami.Action {
 *                 iconName: "globe"
 *                 text: "World"
 *                 checked: worldPage.visible
 *                 onTriggered: {
 *                      if (!worldPage.visible) {
 *                          while (pageStack.depth > 0) {
 *                              pageStack.pop();
 *                          }
 *                          pageStack.push(worldPage);
 *                     }
 *                 }
 *             },
 *             Kirigami.Action {
 *                 iconName: "player-time"
 *                 text: "Timers"
 *                 checked: timersPage.visible
 *                 onTriggered: {
 *                     if (!timersPage.visible) {
 *                         while (pageStack.depth > 0) {
 *                             pageStack.pop();
 *                         }
 *                         pageStack.push(timersPage);
 *                     }
 *                 }
 *             },
 *             Kirigami.Action {
 *                 iconName: "chronometer"
 *                 text: "Stopwatch"
 *                 checked: stopwatchPage.visible
 *                 onTriggered: {
 *                     if (!stopwatchPage.visible) {
 *                         while (pageStack.depth > 0) {
 *                             pageStack.pop();
 *                         }
 *                         pageStack.push(stopwatchPage);
 *                     }
 *                 }
 *             },
 *             Kirigami.Action {
 *                 iconName: "notifications"
 *                 text: "Alarms"
 *                 checked: alarmsPage.visible
 *                 onTriggered: {
 *                     if (!alarmsPage.visible) {
 *                         while (pageStack.depth > 0) {
 *                             pageStack.pop();
 *                         }
 *                         pageStack.push(alarmsPage);
 *                     }
 *                 }
 *             }
 *         ]
 *     }
 * }
 * @endcode
 * @see kirigami::NavigationTabButton
 * @see <a href="https://develop.kde.org/hig/components/navigation/navigationtabbar">Human Interface Guidelines on Navigation Tab Bars</a>
 * @since KDE Frameworks 5.87
 * @since org.kde.kirigami 2.19
 * @inherit QtQuick.Templates.Toolbar
 */

T.ToolBar {
    id: root

//BEGIN properties
    /**
     * @brief This property holds the list of actions displayed in the toolbar.
     */
    property list<Kirigami.Action> actions

    /**
     * @brief The property holds the maximum width of the toolbar actions, before margins are added.
     */
    property real maximumContentWidth: {
        const minDelegateWidth = Kirigami.Units.gridUnit * 5;
        // Always have at least the width of 5 items, so that small amounts of actions look natural.
        return minDelegateWidth * Math.max(actions.length, 5);
    }

    /**
     * @brief This property holds the background color of the toolbar.
     *
     * default: @link Kirigami.PlatformTheme.highlightColor Kirigami.Theme.highlightColor @endlink
     */
    property color backgroundColor: Kirigami.Theme.backgroundColor

    /**
     * @brief This property holds the foreground color of the toolbar (text, icon).
     */
    property color foregroundColor: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.85)

    /**
     * @brief This property holds the highlight foreground color (text, icon when action is checked).
     */
    property color highlightForegroundColor: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.85)

    /**
     * @brief This property holds the color of the highlight bar when an action is checked.
     *
     * default: @link Kirigami.PlatformTheme.highlightColor Kirigami.Theme.highlightColor @endlink
     */
    property color highlightBarColor: Kirigami.Theme.highlightColor

    /**
     * @brief This property sets whether the toolbar should provide its own shadow.
     *
     * default: ``true``
     */
    property bool shadow: true

    /**
     * @brief This property holds the index of currently checked tab.
     *
     * If the index set is out of bounds, or the triggered signal did not change any checked property of an action, the index
     * will remain the same.
     */
    property int currentIndex: tabGroup.checkedButton && tabGroup.buttons.length > 0 ? tabGroup.checkedButton.tabIndex : -1

    /**
     * @brief This property holds the number of tab buttons.
     */
    readonly property int count: tabGroup.buttons.length

    /**
     * @brief This property holds the ButtonGroup used to manage the tabs.
     */
    readonly property T.ButtonGroup tabGroup: tabGroup

    /**
     * @brief This property sets whether the icon colors should be masked with a single color.
     *
     * This only applies to buttons generated by the actions property.
     *
     * default: ``true``
     *
     * @since KDE Frameworks 5.96
     */
    property bool recolorIcons: true

    /**
     * @brief This property holds the calculated width that buttons on the tab bar use.
     *
     * @since KDE Frameworks 5.102
     */
    property real buttonWidth: {
        // Counting buttons because Repeaters can be counted among visibleChildren
        let visibleButtonCount = 0;
        const minWidth = contentItem.height * 0.75;
        for (let i = 0; i < contentItem.visibleChildren.length; ++i) {
            if (contentItem.width / visibleButtonCount >= minWidth && // make buttons go off the screen if there is physically no room for them
                contentItem.visibleChildren[i] instanceof T.AbstractButton) { // Checking for AbstractButtons because any AbstractButton can act as a tab
                ++visibleButtonCount;
            }
        }

        return Math.round(contentItem.width / visibleButtonCount);
    }
//END properties

    onCurrentIndexChanged: {
        if (currentIndex === -1) {
            if (tabGroup.checkState !== Qt.Unchecked) {
                tabGroup.checkState = Qt.Unchecked;
            }
            return;
        }
        if (tabGroup.checkedButton.tabIndex !== currentIndex) {
            const buttonForCurrentIndex = tabGroup.buttons[currentIndex]
            if (buttonForCurrentIndex.action) {
                // trigger also toggles and causes clicked() to be emitted
                buttonForCurrentIndex.action.trigger();
            } else {
                // toggle() does not trigger the action,
                // so don't use it if you want to use an action.
                // It also doesn't cause clicked() to be emitted.
                buttonForCurrentIndex.toggle();
            }
        }
    }

    // Using Math.round() on horizontalPadding can cause the contentItem to jitter left and right when resizing the window.
    horizontalPadding: Math.floor(Math.max(0, width - root.maximumContentWidth) / 2)
    contentWidth: Math.ceil(Math.min(root.availableWidth, root.maximumContentWidth))
    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset, contentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset, contentHeight + topPadding + bottomPadding)

    Kirigami.Theme.colorSet: Kirigami.Theme.Window

    background: Rectangle { // color & shadow
        implicitHeight: Kirigami.Units.gridUnit * 3 + Kirigami.Units.smallSpacing * 2
        color: root.backgroundColor
        GE.RectangularGlow {
            anchors.fill: parent
            z: -1
            visible: root.shadow
            glowRadius: 5
            spread: 0.3
            color: Qt.rgba(0.0, 0.0, 0.0, 0.15)
        }
    }

    // Using Row because setting just width is more convenient than having to set Layout.minimumWidth and Layout.maximumWidth
    contentItem: Row {
        id: rowLayout
        spacing: root.spacing
    }

    // Used to manage which tab is checked and change the currentIndex
    T.ButtonGroup {
        id: tabGroup
        exclusive: true
        buttons: root.contentItem.children

        onCheckedButtonChanged: {
            if (!checkedButton) {
                return
            }
            if (root.currentIndex !== checkedButton.tabIndex) {
                root.currentIndex = checkedButton.tabIndex;
            }
        }
    }

    // Using a Repeater here because Instantiator was causing issues:
    // NavigationTabButtons that were supposed to be destroyed were still
    // registered as buttons in tabGroup.
    // NOTE: This will make Repeater show up as child through visibleChildren
    Repeater {
        id: instantiator
        model: root.actions
        delegate: NavigationTabButton {
            id: delegate
            parent: root.contentItem
            action: modelData
            visible: modelData.visible
            width: root.buttonWidth
            recolorIcon: root.recolorIcons
            T.ButtonGroup.group: tabGroup
            // Workaround setting the action when checkable is not explicitly set making tabs uncheckable
            onActionChanged: action.checkable = true

            foregroundColor: root.foregroundColor
            highlightForegroundColor: root.highlightForegroundColor
            highlightBarColor: root.highlightBarColor
        }
    }
}
