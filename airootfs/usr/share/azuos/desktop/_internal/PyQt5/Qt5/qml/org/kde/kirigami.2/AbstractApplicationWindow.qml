/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQml 2.15
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Window 2.5
import org.kde.kirigami 2.4 as Kirigami
import "templates/private" as TP
/**
 * @brief A window that provides some basic features needed for all apps.
 *
 * An abstract application window is a top-level component that provides
 * several utilities for convenience such as:
 * * ::applicationWindow()
 * * ::globalDrawer
 * * ::pageStack
 * * ::wideScreen
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
 *  [...]
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
 *         actions.contextualActions: [
 *             Kirigami.Action {
 *                 text: "context action 1"
 *             },
 *             Kirigami.Action {
 *                 text: "context action 2"
 *             },
 *             Kirigami.Action {
 *                 text: "context action 3"
 *             }
 *         ]
 *     }
 *  [...]
 * }
 * @endcode
 * @inherit QtQuick.Controls.ApplicationWindow
 */
QQC2.ApplicationWindow {
    id: root

//BEGIN properties
    /**
     * @brief This property holds the stack used to allocate the pages and to
     * manage the transitions between them.
     *
     * Put a container here, such as QtQuick.Controls.StackView or PageRow.
     */
    property Item pageStack

    /**
     * @brief This property sets whether the standard chrome of the app is
     * visible.
     *
     * These are the action button, the drawer handles, and the application
     * header.
     *
     * default: ``true``
     */
    property bool controlsVisible: true

    /**
     * @brief This property holds the drawer for global actions.
     *
     * This drawer can be opened by sliding from the left screen edge
     * or by either pressing on the handle or sliding it to the right.
     *
     * @note It is recommended to use the GlobalDrawer here.
     * @property kirigami::OverlayDrawer globalDrawer
     */
    property OverlayDrawer globalDrawer

    /**
     * @brief This property specifies whether the application is in "widescreen" mode.
     *
     * This is enabled on desktops or horizontal tablets.
     *
     * @note Different styles can have their own logic for deciding this.
     */
    property bool wideScreen: width >= Kirigami.Units.gridUnit * 60

    /**
     * @brief This property holds the drawer for context-dependent actions.
     *
     * The drawer that will be opened by sliding from the right screen edge
     * or by dragging the ActionButton to the left.
     *
     * @note It is recommended to use the ContextDrawer class here.
     *
     * The context drawer will display the previously defined contextual
     * actions of the page that is currently active in the pageStack.
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
     *     // setting the contextual actions
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
     *
     * @property kirigami::ContextDrawer contextDrawer
     */
    property OverlayDrawer contextDrawer

    /**
     * @brief This property specifies whether the application is in reachable
     * mode for single hand use.
     *
     * The whole content of the application is moved down the screen to be
     * reachable with the thumb. If wideScreen is true, or reachableModeEnabled
     * is false, this property has no effect.
     *
     * @warning This property should be treated as readonly. Use
     * ``reachableModeEnabled`` instead.
     *
     * default: ``false``
     */
    property bool reachableMode: false

    /**
     * @brief This property sets whether reachable mode can be used.
     */
    property bool reachableModeEnabled: true

    /**
     * @brief This property holds a Kirigami action that will quit the
     * application when triggered.
     *
     * @since KDE Frameworks 5.76
     */
    readonly property Kirigami.Action quitAction: Kirigami.Action {
        text: qsTr("Quit")
        icon.name: "application-exit";
        shortcut: StandardKey.Quit
        onTriggered: source => root.close();
    }
//END properties

//BEGIN functions
    /**
     * @brief This function shows a passive notification at the bottom of the
     * app window lasting for few seconds, with an optional action button.
     *
     * @param message Notification's text message that is shown to the user.
     * @param timeout Notification's visibility duration. Possible values are:
     * "short", "long" or the number of milliseconds. Default is ``7000``.
     * @param actionText Notification's action button's text.
     * @param callBack A JavaScript function that will be executed when the user
     * clicks the button.
     */
    function showPassiveNotification(message, timeout, actionText, callBack) {
        notificationsObject.showNotification(message, timeout, actionText, callBack);
    }

   /**
    * @brief This function hides the passive notification at specified index,
    * if any is shown.
    *
    * @param index Index of the notification to hide. Default is 0
    * (oldest notification).
    */
    function hidePassiveNotification(index = 0) {
        notificationsObject.hideNotification(index);
    }

    /**
     * @brief This property returns a pointer
     * to the main instance of AbstractApplicationWindow.
     * 
     * This is available to any children of this window,
     * including those instantiated from separate QML files,
     * making interoperation with multiple files easier.
     * 
     * Use this whenever you need access to properties
     * that are available to the main AbstractApplicationWindow,
     * such as its ::pageStack or ::globalDrawer.
     * 
     * @see AbstractApplicationItem::applicationWindow()
     * @returns a pointer to the instantiated AbstractApplicationWindow.
     */
    function applicationWindow() {
        return root;
    }
//END functions

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    color: Kirigami.Theme.backgroundColor

    TP.PassiveNotificationsManager {
        id: notificationsObject
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        z: 1
    }

    MouseArea {
        parent: contentItem.parent
        z: 0
        anchors.fill: parent
        onClicked: mouse => {
            root.reachableMode = false;
        }
        visible: root.reachableMode && root.reachableModeEnabled
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.3)
            opacity: 0.15
            Kirigami.Icon {
                anchors.horizontalCenter: parent.horizontalCenter
                y: x
                width: Kirigami.Units.iconSizes.large
                height: width
                source: "go-up"
            }
        }
    }

    contentItem.z: 1
    contentItem.anchors.left: contentItem.parent.left
    contentItem.anchors.right: contentItem.parent.right
    contentItem.anchors.topMargin: root.wideScreen && header && controlsVisible ? header.height : 0
    contentItem.anchors.leftMargin: root.globalDrawer && root.globalDrawer.modal === false && (!root.pageStack || root.pageStack.leftSidebar !== root.globalDrawer) ? root.globalDrawer.width * root.globalDrawer.position : 0
    contentItem.anchors.rightMargin: root.contextDrawer && root.contextDrawer.modal === false ? root.contextDrawer.width * root.contextDrawer.position : 0

    Binding {
        when: menuBar !== undefined
        target: menuBar
        property: "x"
        value: -contentItem.x
        restoreMode: Binding.RestoreBinding
    }
    Binding {
        when: header !== undefined
        target: header
        property: "x"
        value: -contentItem.x
        restoreMode: Binding.RestoreBinding
    }
    Binding {
        when: footer !== undefined
        target: footer
        property: "x"
        value: -contentItem.x
        restoreMode: Binding.RestoreBinding
    }

    contentItem.transform: Translate {
        Behavior on y {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        y: root.reachableMode && root.reachableModeEnabled && !root.wideScreen ? root.height/2 : 0
        x: root.globalDrawer && root.globalDrawer.modal === true && root.globalDrawer.toString().indexOf("SplitDrawer") === 0 ? root.globalDrawer.contentItem.width * root.globalDrawer.position : 0
    }
    //Don't want overscroll in landscape mode
    onWidthChanged: {
        if (width > height) {
            root.reachableMode = false;
        }
    }
    Binding {
        when: globalDrawer !== undefined && root.visible
        target: globalDrawer
        property: "parent"
        value: overlay
        restoreMode: Binding.RestoreBinding
    }
    Binding {
        when: contextDrawer !== undefined && root.visible
        target: contextDrawer
        property: "parent"
        value: overlay
        restoreMode: Binding.RestoreBinding
    }
    onPageStackChanged: pageStack.parent = contentItem;

    width: Kirigami.Settings.isMobile ? Kirigami.Units.gridUnit * 30 : Kirigami.Units.gridUnit * 55
    height: Kirigami.Settings.isMobile ? Kirigami.Units.gridUnit * 45 : Kirigami.Units.gridUnit * 40
    visible: true

    Component.onCompleted: {
        // Explicitly break the binding as we need this to be set only at startup.
        // if the bindings are active, after this the window is resized by the
        // compositor and then the bindings are reevaluated, then the window
        // size would reset ignoring what the compositor asked.
        // see BUG 433849
        root.width = root.width;
        root.height = root.height;
    }

    // This is needed because discover in mobile mode does not
    // close with the global drawer open.
    Shortcut {
        sequence: root.quitAction.shortcut
        context: Qt.ApplicationShortcut
        onActivated: root.close();
    }
}
