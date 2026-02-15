/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.5
import org.kde.kirigami 2.4 as Kirigami

/**
 * @brief A window that provides some basic features needed for all apps.
 *
 * An application window is a top-level component that provides
 * several utilities for convenience, such as:
 * * kirigami::AbstractApplicationWindow::applicationWindow()
 * * kirigami::AbstractApplicationWindow::globalDrawer
 * * kirigami::AbstractApplicationWindow::pageStack
 * * kirigami::AbstractApplicationWindow::wideScreen
 * 
 * @see kirigami::AbstractApplicationWindow
 * 
 * Use this class only if you need custom content for your application that is
 * different from the PageRow behavior recommended by the HIG and provided
 * by kirigami::AbstractApplicationWindow.
 *
 * Example usage:
 * @code{.qml}
 * import org.kde.kirigami 2.4 as Kirigami
 *
 * Kirigami.ApplicationWindow {
 *   [...]
 *     globalDrawer: Kirigami.GlobalDrawer {
 *         actions: [
 *            Kirigami.Action {
 *                text: "View"
 *                iconName: "view-list-icons"
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
 *                iconName: "folder-sync"
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
 *                 iconName: "edit"
 *                 onTriggered: {
 *                     // do stuff
 *                 }
 *             }
 *             contextualActions: [
 *                 Kirigami.Action {
 *                     iconName: "edit"
 *                     text: "Action text"
 *                     onTriggered: {
 *                         // do stuff
 *                     }
 *                 },
 *                 Kirigami.Action {
 *                     iconName: "edit"
 *                     text: "Action text"
 *                     onTriggered: {
 *                         // do stuff
 *                     }
 *                 }
 *             ]
 *         }
 *     }
 *   [...]
 * }
 * @endcode
*/
Kirigami.AbstractApplicationWindow {
    id: root

    /**
     * @brief This property holds the PageRow that is used to allocate the pages
     * and manage the transitions between them.
     *
     * It implements useful features to control then shown pages such as:
     * * kirigami::PageRow::initialPage
     * * kirigami::PageRow::push()
     * * kirigami::PageRow::pop()
     *
     * @see kirigami::PageRow
     * @warning This property is not currently readonly, but it should be treated like it is readonly.
     * @property Kirgiami.PageRow pageStack
     */
    property alias pageStack: __pageStack  // TODO KF6 make readonly

    // Redefined here as here we can know a pointer to PageRow.
    // We negate the canBeEnabled check because we don't want to factor in the automatic drawer provided by Kirigami for page actions for our calculations
    wideScreen: width >= (root.pageStack.defaultColumnWidth) + ((contextDrawer && !(contextDrawer instanceof Kirigami.ContextDrawer)) ? contextDrawer.width : 0) + (globalDrawer ? globalDrawer.width : 0)

    Component.onCompleted: {
        if (pageStack.currentItem) {
            pageStack.currentItem.forceActiveFocus()
        }
    }

    PageRow {
        id: __pageStack
        globalToolBar.style: Kirigami.ApplicationHeaderStyle.Auto
        anchors {
            fill: parent
            // HACK: workaround a bug in android iOS keyboard management
            bottomMargin: ((Qt.platform.os === "android" || Qt.platform.os === "ios") || !Qt.inputMethod.visible) ? 0 : Qt.inputMethod.keyboardRectangle.height
            onBottomMarginChanged: {
                if (__pageStack.anchors.bottomMargin > 0) {
                    root.reachableMode = false;
                }
            }
        }
        // FIXME
        onCurrentIndexChanged: root.reachableMode = false;

        focus: true
    }
}
