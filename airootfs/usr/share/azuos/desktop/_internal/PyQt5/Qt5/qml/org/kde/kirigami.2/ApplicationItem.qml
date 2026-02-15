/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import org.kde.kirigami 2.4 as Kirigami

/**
 * @brief An item that provides the features of ApplicationWindow without the window itself.
 *
 * This allows embedding into a larger application.
 * It's based around the PageRow component that allows adding/removing of pages.
 *
 * Example usage:
 * @code{.qml}
 * import org.kde.kirigami 2.4 as Kirigami
 *
 * Kirigami.ApplicationItem {
 *     globalDrawer: Kirigami.GlobalDrawer {
 *         actions: [
 *            Kirigami.Action {
 *                text: "View"
 *                icon.name: "view-list-icons"
 *                Kirigami.Action {
 *                        text: "action 1"
 *                }
 *                Kirigami.Action {
 *                        text: "action 2"
 *                }
 *                Kirigami.Action {
 *                        text: "action 3"
 *                }
 *            },
 *            Kirigami.Action {
 *                text: "Sync"
 *                icon.name: "folder-sync"
 *            }
 *         ]
 *     }
 *
 *     contextDrawer: Kirigami.ContextDrawer {
 *         id: contextDrawer
 *     }
 *
 *     pageStack.initialPage: Kirigami.Page {
 *         actions {
 *             main: Kirigami.Action {
 *                 icon.name: "edit"
 *                 onTriggered: {
 *                     // do stuff
 *                 }
 *             }
 *             contextualActions: [
 *                 Kirigami.Action {
 *                     icon.name: "edit"
 *                     text: "Action text"
 *                     onTriggered: {
 *                         // do stuff
 *                     }
 *                 },
 *                 Kirigami.Action {
 *                     icon.name: "edit"
 *                     text: "Action text"
 *                     onTriggered: {
 *                         // do stuff
 *                     }
 *                 }
 *             ]
 *           [...]
 *         }
 *     }
 * }
 * @endcode
*/
Kirigami.AbstractApplicationItem {
    id: root

    /**
     * @brief This property holds the PageRow that is used to allocate
     * the pages and manage the transitions between them.
     *
     * @see kirigami::PageRow
     * @warning This property is not currently readonly, but it should be treated like it is readonly.
     * @property Kirigami.PageRow pageStack
     */
    property alias pageStack: __pageStack // TODO KF6 make readonly

    // Redefines here as here we can know a pointer to PageRow
    wideScreen: width >= applicationWindow().pageStack.defaultColumnWidth * 2

    Component.onCompleted: {
        if (pageStack.currentItem) {
            pageStack.currentItem.forceActiveFocus();
        }
    }

    Kirigami.PageRow {
        id: __pageStack
        anchors {
            fill: parent
            // HACK: workaround a bug in android iOS keyboard management
            bottomMargin: ((Qt.platform.os === "android" || Qt.platform.os === "ios") || !Qt.inputMethod.visible) ? 0 : Qt.inputMethod.keyboardRectangle.height
            onBottomMarginChanged: {
                if (bottomMargin > 0) {
                    root.reachableMode = false;
                }
            }
        }
        // FIXME
        onCurrentIndexChanged: root.reachableMode = false;

        function goBack() {
            // NOTE: drawers are handling the back button by themselves
            const backEvent = {accepted: false}
            if (root.pageStack.currentIndex >= 1) {
                root.pageStack.currentItem.backRequested(backEvent);
                if (!backEvent.accepted) {
                    root.pageStack.flickBack();
                    backEvent.accepted = true;
                }
            }

            if (Kirigami.Settings.isMobile && !backEvent.accepted && Qt.platform.os !== "ios") {
                Qt.quit();
            }
        }
        function goForward() {
            root.pageStack.currentIndex = Math.min(root.pageStack.depth - 1, root.pageStack.currentIndex + 1);
        }
        Keys.onBackPressed: event => {
            goBack();
            event.accepted = true;
        }
        Shortcut {
            sequences: [StandardKey.Forward]
            onActivated: __pageStack.goForward();
        }
        Shortcut {
            sequences: [StandardKey.Back]
            onActivated: __pageStack.goBack();
        }

        background: Rectangle {
            color: root.color
        }

        focus: true
    }
}
