/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQml 2.15
import QtQuick.Controls 2.15 as QQC2
import QtGraphicalEffects 1.0 as GE
import org.kde.kirigami 2.19 as Kirigami
import org.kde.kirigami.templates 2.2 as KT
import "private"


// TODO KF6: undo many workarounds to make existing code work?

/**
 * @brief ScrollablePage is a Page that holds scrollable content, such as a QtQuick.ListView.
 *
 * Scrolling and scrolling indicators will be automatically managed.
 *
 * Example usage:
 * @code{.qml}
 * ScrollablePage {
 *     id: root
 *     // The page will automatically be scrollable
 *     Rectangle {
 *         width: root.width
 *         height: 99999
 *     }
 * }
 * @endcode
 * @warning Do not put a QtQuick.Controls.ScrollView inside of a ScrollablePage;
 * children of a ScrollablePage are already inside a QtQuick.Controls.ScrollView.
 *
 * Another behavior added by this class is a "scroll down to refresh" behavior
 * It also can give the contents of the flickable to have more top margins in order
 * to make possible to scroll down the list to reach it with the thumb while using the
 * phone with a single hand.
 *
 * Implementations should handle the refresh themselves as follows
 *
 * Example usage:
 * @code{.qml}
 * Kirigami.ScrollablePage {
 *     id: view
 *     supportsRefreshing: true
 *     onRefreshingChanged: {
 *         if (refreshing) {
 *             myModel.refresh();
 *         }
 *     }
 *     ListView {
 *         // NOTE: MyModel doesn't come from the components,
 *         // it's purely an example on how it can be used together
 *         // some application logic that can update the list model
 *         // and signals when it's done.
 *         model: MyModel {
 *             onRefreshDone: view.refreshing = false;
 *         }
 *         delegate: BasicListItem {}
 *     }
 * }
 * [...]
 * @endcode
 */
Kirigami.Page {
    id: root

//BEGIN properties
    /**
     * @brief This property specifies whether the list is asking for a refresh.
     *
     * This property will automatically be set to @c true when the user pulls the list down enough,
     * which in return, shows a loading spinner. When this is set to true, it signals
     * the application logic to start its refresh procedure.
     *
     * default: ``false``
     *
     * @note The application itself will have to set back this property to @c false when done.
     */
    property bool refreshing: false

    /**
     * @brief This property sets whether scrollable page supports "pull down to refresh" behaviour.
     *
     * default: ``false``
     */
    property bool supportsRefreshing: false

    /**
     * @brief This property holds the main Flickable item of this page.
     * @deprecated here for compatibility; will be removed in KF6.
     */
    property Flickable flickable: Flickable {} // FIXME KF6: this empty flickable exists for compatibility reasons. some apps assume flickable exists right from the beginning but ScrollView internally assumes it does not
    onFlickableChanged: scrollView.contentItem = flickable;

    /**
     * @brief This property sets the vertical scrollbar policy.
     * @property Qt::ScrollBarPolicy verticalScrollBarPolicy
     */
    property int verticalScrollBarPolicy

    /**
     * @brief This property sets the horizontal scrollbar policy.
     * @property Qt::ScrollBarPolicy horizontalScrollBarPolicy
     */
    property int horizontalScrollBarPolicy: QQC2.ScrollBar.AlwaysOff

    default property alias scrollablePageData: itemsParent.data
    property alias scrollablePageChildren: itemsParent.children

    /*
     * @deprecated here for compatibility; will be removed in KF6.
     */
    property QtObject mainItem
    onMainItemChanged: {
        print("Warning: the mainItem property is deprecated");
        scrollablePageData.push(mainItem);
    }

    /**
     * @brief This property sets whether it is possible to navigate the items in a view that support it.
     *
     * If true, and if the QtQuick.Flickable is in an item view (e.g. QtQuick.ListView, QtQuick.GridView),
     * it will be possible to navigate the view current items with keyboard up/down arrow buttons.
     * Also, any key event will be forwarded to the current list item.
     *
     * default: ``true``
     */
    property bool keyboardNavigationEnabled: true
//END properties

    contentHeight: flickable ? flickable.contentHeight : 0
    implicitHeight: {
        let height = contentHeight + topPadding + bottomPadding;
        if (header && header.visible) {
            height += header.implicitHeight;
        }
        if (footer && footer.visible) {
            height += footer.implicitHeight;
        }
        return height;
    }

    implicitWidth: {
        if (flickable) {
            if (flickable.contentItem) {
                return flickable.contentItem.implicitWidth;
            } else {
                return contentItem.implicitWidth + leftPadding + rightPadding;
            }
        } else {
            return 0;
        }
    }

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: flickable && flickable.hasOwnProperty("model") ? Kirigami.Theme.View : Kirigami.Theme.Window

    Keys.forwardTo: {
        if (root.keyboardNavigationEnabled && root.flickable) {
            if (("currentItem" in root.flickable) && root.flickable.currentItem) {
                return [ root.flickable.currentItem, root.flickable ];
            } else {
                return [ root.flickable ];
            }
        } else {
            return [];
        }
    }

    contentItem: QQC2.ScrollView {
        id: scrollView
        anchors {
            top: (root.header && root.header.visible)
                    ? root.header.bottom
                    // FIXME: for now assuming globalToolBarItem is in a Loader, which needs to be get rid of
                    : (globalToolBarItem && globalToolBarItem.parent && globalToolBarItem.visible
                        ? globalToolBarItem.parent.bottom
                        : parent.top)
            bottom: (root.footer && root.footer.visible) ? root.footer.top : parent.bottom
            left: parent.left
            right: parent.right
            topMargin: root.refreshing ? busyIndicatorLoader.height : 0
            Behavior on topMargin {
                NumberAnimation {
                    easing.type: Easing.InOutQuad
                    duration: Kirigami.Units.longDuration
                }
            }
        }
        QQC2.ScrollBar.horizontal.policy: root.horizontalScrollBarPolicy
        QQC2.ScrollBar.vertical.policy: root.verticalScrollBarPolicy
    }

    data: [
        // Has to be a MouseArea that accepts events otherwise touch events on Wayland will get lost
        MouseArea {
            id: scrollingArea
            width: root.flickable.width
            height: Math.max(root.flickable.height, implicitHeight)
            implicitHeight: {
                let impl = 0;
                for (const i in itemsParent.visibleChildren) {
                    const child = itemsParent.visibleChildren[i];
                    if (child.implicitHeight <= 0) {
                        impl = Math.max(impl, child.height);
                    } else {
                        impl = Math.max(impl, child.implicitHeight);
                    }
                }
                return impl + itemsParent.anchors.topMargin + itemsParent.anchors.bottomMargin;
            }
            Item {
                id: itemsParent
                property Flickable flickable
                anchors {
                    fill: parent
                    leftMargin: root.leftPadding
                    topMargin: root.topPadding
                    rightMargin: root.rightPadding
                    bottomMargin: root.bottomPadding
                }
                onChildrenChanged: {
                    const child = children[children.length - 1];
                    if (child instanceof QQC2.ScrollView) {
                        print("Warning: it's not supported to have ScrollViews inside a ScrollablePage")
                    }
                }
            }
            Binding {
                target: root.flickable
                property: "bottomMargin"
                value: root.bottomPadding
                restoreMode: Binding.RestoreBinding
            }
        },

        Loader {
            id: busyIndicatorLoader
            z: 99
            y: root.flickable.verticalLayoutDirection === ListView.BottomToTop
                ? -root.flickable.contentY + root.flickable.originY + height
                : -root.flickable.contentY + root.flickable.originY - height
            width: root.flickable.width
            height: Kirigami.Units.gridUnit * 4
            active: root.supportsRefreshing

            sourceComponent: Item {
                id: busyIndicatorFrame

                QQC2.BusyIndicator {
                    id: busyIndicator
                    z: 1
                    anchors.centerIn: parent
                    running: root.refreshing
                    visible: root.refreshing
                    // Android busywidget QQC seems to be broken at custom sizes
                }
                Rectangle {
                    id: spinnerProgress
                    anchors {
                        fill: busyIndicator
                        margins: Kirigami.Units.smallSpacing
                    }
                    radius: width
                    visible: supportsRefreshing && !refreshing && progress > 0
                    color: "transparent"
                    opacity: 0.8
                    border.color: Kirigami.Theme.backgroundColor
                    border.width: Kirigami.Units.smallSpacing
                    property real progress: supportsRefreshing && !refreshing ? (busyIndicatorLoader.y / busyIndicatorFrame.height) : 0
                }
                GE.ConicalGradient {
                    source: spinnerProgress
                    visible: spinnerProgress.visible
                    anchors.fill: spinnerProgress
                    gradient: Gradient {
                        GradientStop { position: 0.00; color: Kirigami.Theme.highlightColor }
                        GradientStop { position: spinnerProgress.progress; color: Kirigami.Theme.highlightColor }
                        GradientStop { position: spinnerProgress.progress + 0.01; color: "transparent" }
                        GradientStop { position: 1.00; color: "transparent" }
                    }
                }

                Connections {
                    target: busyIndicatorLoader
                    function onYChanged() {
                        if (!supportsRefreshing) {
                            return;
                        }

                        if (!root.refreshing && busyIndicatorLoader.y > busyIndicatorFrame.height / 2 + topPadding) {
                            refreshTriggerTimer.running = true;
                        } else {
                            refreshTriggerTimer.running = false;
                        }
                    }
                }
                Timer {
                    id: refreshTriggerTimer
                    interval: 500
                    onTriggered: {
                        if (!root.refreshing && busyIndicatorLoader.y > busyIndicatorFrame.height / 2 + topPadding) {
                            root.refreshing = true;
                        }
                    }
                }
            }
        }
    ]

    Component.onCompleted: {
        let flickableFound = false;
        for (const i in itemsParent.data) {
            const child = itemsParent.data[i];
            if (child instanceof Flickable) {
                // If there were more flickable children, take the last one, as behavior compatibility
                // with old internal ScrollView
                child.activeFocusOnTab = true;
                root.flickable = child;
                flickableFound = true;
                if (child instanceof ListView) {
                    child.keyNavigationEnabled = true;
                    child.keyNavigationWraps = false;
                }
            } else if (child instanceof Item) {
                child.anchors.left = itemsParent.left;
                child.anchors.right = itemsParent.right;
            } else if (child instanceof KT.OverlaySheet) {
                // Reparent sheets, needs to be done before Component.onCompleted
                if (child.parent === itemsParent || child.parent === null) {
                    child.parent = root;
                }
            }
        }

        if (flickableFound) {
            scrollView.contentItem = root.flickable;
            root.flickable.parent = scrollView;
            // The flickable needs focus only if the page didn't already explicitly set focus to some other control (eg a text field in the header)
            Qt.callLater(() => {
                if (root.activeFocus) {
                    root.flickable.forceActiveFocus();
                }
            });
            // Some existing code incorrectly uses anchors
            root.flickable.anchors.fill = undefined;
            root.flickable.anchors.left = undefined;
            root.flickable.anchors.right = undefined;
            root.flickable.anchors.top = undefined;
            root.flickable.anchors.bottom = undefined;
            scrollingArea.visible = false;
        } else {
            scrollView.contentItem = root.flickable;
            scrollingArea.parent = root.flickable.contentItem;
            scrollingArea.visible = true;
            root.flickable.contentHeight = Qt.binding(() => scrollingArea.implicitHeight - root.flickable.topMargin - root.flickable.bottomMargin);
            root.flickable.contentWidth = Qt.binding(() => scrollingArea.implicitWidth);
        }
        root.flickable.flickableDirection = Flickable.VerticalFlick;
    }
}
