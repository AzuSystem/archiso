/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Controls 2.2 as QQC2
import org.kde.kirigami 2.4 as Kirigami
import "private" as P

/**
 * A specialized type of drawer that will show a list of actions
 * relevant to the application's current page.
 *
 * Example usage:
 * @code{.qml}
 * import org.kde.kirigami 2.4 as Kirigami
 *
 * Kirigami.ApplicationWindow {
 *  [...]
 *     contextDrawer: Kirigami.ContextDrawer {
 *         id: contextDrawer
 *     }
 *  [...]
 * }
 * @endcode
 *
 * @code{.qml}
 * import org.kde.kirigami 2.4 as Kirigami
 *
 * Kirigami.Page {
 *   [...]
 *     actions.contextualActions: [
 *         Kirigami.Action {
 *             icon.name: "edit"
 *             text: "Action text"
 *             onTriggered: {
 *                 // do stuff
 *             }
 *         },
 *         Kirigami.Action {
 *             icon.name: "edit"
 *             text: "Action text"
 *             onTriggered: {
 *                 // do stuff
 *             }
 *         }
 *     ]
 *   [...]
 * }
 * @endcode
 * @see <a href="https://develop.kde.org/hig/components/navigation/contextdrawer">Human Interface Guidelines on Context Drawers</a>
 * @see <a href="https://develop.kde.org/hig/patterns-command/drawer/#context-drawer">KDE Human Interface Guidelines' Short Introduction of Context Drawers</a>
 * @inherit OverlayDrawer
 */
Kirigami.OverlayDrawer {
    id: root
    handleClosedIcon.source: null
    handleOpenIcon.source: null

    /**
     * @brief A title for the action list that will be shown to the user when opens the drawer
     *
     * default: ``qsTr("Actions")``
     */
    property string title: qsTr("Actions")

    /**
     * This can be any type of object that a ListView can accept as model.
     * It expects items compatible with either QtQuick.Controls.Action or
     * Kirigami.Action.
     *
     * @see QtQuick.Controls.Action
     * @see kirigami::Action
     * @property list<Action> actions
     */
    property var actions: page ? page.contextualActions : []

    /**
     * @brief Arbitrary content to show above the list view.
     *
     * default: `an Item containing a Kirigami.Heading that displays a title whose text is
     * controlled by the title property.`
     *
     * @property Component header
     * @since org.kde.kirigami 2.7
     */
    property alias header: menu.header

    /**
     * @brief Arbitrary content to show below the list view.
     * @property Component footer
     * @since org.kde.kirigami 2.7
     */
    property alias footer: menu.footer

    property Page page: {
        if (applicationWindow().pageStack.layers && applicationWindow().pageStack.layers.depth > 1 && applicationWindow().pageStack.layers.currentItem.hasOwnProperty("contextualActions")) {
            return applicationWindow().pageStack.layers.currentItem;
        }
        else if ((applicationWindow().pageStack.currentItem || {}).hasOwnProperty("contextualActions")) {
            return applicationWindow().pageStack.currentItem;
        }
        else {
            return applicationWindow().pageStack.lastVisibleItem;
        }
    }

    // Disable for empty menus or when we have a global toolbar
    enabled: menu.count > 0 &&
            (typeof applicationWindow() === "undefined" || !applicationWindow().pageStack.globalToolBar ||
            (applicationWindow().pageStack.lastVisibleItem && applicationWindow().pageStack.lastVisibleItem.globalToolBarStyle !== Kirigami.ApplicationHeaderStyle.ToolBar) ||
            (applicationWindow().pageStack.layers && applicationWindow().pageStack.layers.depth > 1 && applicationWindow().pageStack.layers.currentItem && applicationWindow().pageStack.layers.currentItem.globalToolBarStyle !== Kirigami.ApplicationHeaderStyle.ToolBar))
    edge: Qt.application.layoutDirection === Qt.RightToLeft ? Qt.LeftEdge : Qt.RightEdge
    drawerOpen: false

    // list items go to edges, have their own padding
    topPadding: 0
    leftPadding: 0
    rightPadding: 0
    bottomPadding: 0

    handleVisible: applicationWindow === undefined ? false : applicationWindow().controlsVisible

    onPeekingChanged: {
        if (page) {
            page.contextualActionsAboutToShow();
        }
    }
    contentItem: QQC2.ScrollView {
        // this just to create the attached property
        Kirigami.Theme.inherit: true
        implicitWidth: Kirigami.Units.gridUnit * 20
        ListView {
            id: menu
            interactive: contentHeight > height
            model: {
                if (typeof root.actions === "undefined") {
                    return null;
                }
                if (root.actions.length === 0) {
                    return null;
                } else {

                    // Check if at least one action is visible
                    let somethingVisible = false;
                    for (let i = 0; i < root.actions.length; i++) {
                        if (root.actions[i].visible) {
                            somethingVisible = true;
                            break;
                        }
                    }

                    if (!somethingVisible) {
                        return null;
                    }

                    return root.actions[0].text !== undefined &&
                        root.actions[0].trigger !== undefined ?
                            root.actions :
                            root.actions[0];
                }
            }
            topMargin: root.handle.y > 0 ? menu.height - menu.contentHeight : 0
            header: Item {
                height: heading.height
                width: menu.width
                Kirigami.Heading {
                    id: heading
                    anchors {
                        left: parent.left
                        right: parent.right
                        margins: Kirigami.Units.largeSpacing
                    }
                    elide: Text.ElideRight
                    level: 2
                    text: root.title
                }
            }
            delegate: Column {
                width: parent.width
                P.ContextDrawerActionItem {
                    width: parent.width
                }
                Repeater {
                    model: modelData.hasOwnProperty("expandible") && modelData.expandible ? modelData.children : null
                    delegate: P.ContextDrawerActionItem {
                        width: parent.width
                        leftPadding: Kirigami.Units.largeSpacing * 2
                        opacity: !root.collapsed
                    }
                }
            }
        }
    }
}
