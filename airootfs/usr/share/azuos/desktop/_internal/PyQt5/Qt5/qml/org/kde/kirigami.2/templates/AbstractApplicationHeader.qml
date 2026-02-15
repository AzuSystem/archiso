/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Layouts 1.2
import QtQuick.Controls 2.4 as QQC2
import org.kde.kirigami 2.14 as Kirigami
import "private"

/**
 * @brief An item that can be used as a title for the application.
 *
 * Scrolling the main page will make it taller or shorter (through the point of going away)
 * It's a behavior similar to the typical mobile web browser addressbar
 * the minimum, preferred and maximum heights of the item can be controlled with
 * * minimumHeight: default is 0, i.e. hidden
 * * preferredHeight: default is Units.gridUnit * 1.6
 * * preferredHeight: default is Units.gridUnit * 3
 *
 * To achieve a titlebar that stays completely fixed just set the 3 sizes as the same
 *
 * @inherit QtQuick.Item
 */
Item {
    id: root
    z: 90
    property int minimumHeight: 0
    property int preferredHeight: Math.max(...(Array.from(mainItem.children).map(elm => elm.implicitHeight))) + topPadding + bottomPadding
    property int maximumHeight: Kirigami.Units.gridUnit * 3

    property int position: QQC2.ToolBar.Header

    property Kirigami.PageRow pageRow: __appWindow ? __appWindow.pageStack: null
    property Kirigami.Page page: pageRow ? pageRow.currentItem : null

    default property alias contentItem: mainItem.data
    readonly property int paintedHeight: headerItem.y + headerItem.height - 1

    property int leftPadding: 0
    property int topPadding: 0
    property int rightPadding: 0
    property int bottomPadding: 0
    property bool separatorVisible: true
    // whether or not the header should be
    // "pushed" back when scrolling using the
    // touch screen
    property bool hideWhenTouchScrolling: root.pageRow ? root.pageRow.globalToolBar.hideWhenTouchScrolling : false

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Kirigami.Theme.inherit: true

    // FIXME: remove
    /** @internal */
    property QtObject __appWindow: typeof applicationWindow !== "undefined" ? applicationWindow() : null;
    implicitHeight: preferredHeight
    height: Layout.preferredHeight

    /**
     * @brief This property holds the background item.
     * @note the background will be automatically sized to fill the whole control
     */
    property Item background

    onBackgroundChanged: {
        background.z = -1;
        background.parent = headerItem;
        background.anchors.fill = headerItem;
    }

    Component.onCompleted: AppHeaderSizeGroup.items.push(this)

    onMinimumHeightChanged: implicitHeight = preferredHeight;
    onPreferredHeightChanged: implicitHeight = preferredHeight;

    opacity: height > 0 ? 1 : 0

    onPageChanged: {
        // NOTE: The Connections object doesn't work with attached properties signals, so we have to do this by hand
        if (headerItem.oldPage) {
            headerItem.oldPage.Kirigami.ColumnView.scrollIntention.disconnect(headerItem.scrollIntentHandler);
        }
        if (root.page) {
            root.page.Kirigami.ColumnView.scrollIntention.connect(headerItem.scrollIntentHandler);
        }
        headerItem.oldPage = root.page;
    }
    Component.onDestruction: {
        if (root.page) {
            root.page.Kirigami.ColumnView.scrollIntention.disconnect(headerItem.scrollIntentHandler);
        }
    }

    NumberAnimation {
        id: heightAnim
        target: root
        property: "implicitHeight"
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InOutQuad
    }
    Connections {
        target: __appWindow
        function onControlsVisibleChanged() {
            heightAnim.from = root.implicitHeight
            heightAnim.to = __appWindow.controlsVisible ? root.preferredHeight : 0;
            heightAnim.restart();
        }
    }

    Item {
        id: headerItem
        anchors {
            left: parent.left
            right: parent.right
            bottom: !Kirigami.Settings.isMobile || root.position === QQC2.ToolBar.Header ? parent.bottom : undefined
            top: !Kirigami.Settings.isMobile || root.position === QQC2.ToolBar.Footer ? parent.top : undefined
        }

        height: __appWindow && __appWindow.reachableMode && __appWindow.reachableModeEnabled ? root.maximumHeight : (root.minimumHeight > 0 ? Math.max(root.height, root.minimumHeight) : Math.max(root.height, root.preferredHeight))

        function scrollIntentHandler(event) {
            if (!root.hideWhenTouchScrolling) {
                return
            }

            if (root.pageRow
                && root.pageRow.globalToolBar.actualStyle !== Kirigami.ApplicationHeaderStyle.TabBar
                && root.pageRow.globalToolBar.actualStyle !== Kirigami.ApplicationHeaderStyle.Breadcrumb) {
                return;
            }
            if (!root.page.flickable || (root.page.flickable.atYBeginning && root.page.flickable.atYEnd)) {
                return;
            }

            root.implicitHeight = Math.max(0, Math.min(root.preferredHeight, root.implicitHeight + event.delta.y))
            event.accepted = root.implicitHeight > 0 && root.implicitHeight < root.preferredHeight;
            slideResetTimer.restart();
            if ((root.page.flickable instanceof ListView) && root.page.flickable.verticalLayoutDirection === ListView.BottomToTop) {
                root.page.flickable.contentY -= event.delta.y;
            }
        }

        property Kirigami.Page oldPage

        Connections {
            target: root.page ? root.page.globalToolBarItem : null
            enabled: target
            function onImplicitHeightChanged() {
                root.implicitHeight = root.page.globalToolBarItem.implicitHeight;
            }
        }

        Timer {
           id: slideResetTimer
           interval: 500
           onTriggered: {
                if ((root.pageRow ? root.pageRow.wideMode : (__appWindow && __appWindow.wideScreen)) || !Kirigami.Settings.isMobile) {
                    return;
                }
                if (root.height > root.minimumHeight + (root.preferredHeight - root.minimumHeight)/2 ) {
                    heightAnim.to = root.preferredHeight;
                } else {
                    heightAnim.to = root.minimumHeight;
                }
                heightAnim.from = root.implicitHeight
                heightAnim.restart();
            }
        }

        Connections {
            target: pageRow
            function onCurrentItemChanged() {
                if (!root.page) {
                    return;
                }

                heightAnim.from = root.implicitHeight;
                heightAnim.to = root.preferredHeight;

                heightAnim.restart();
            }
        }

        Item {
            id: mainItem
            clip: childrenRect.width > width
            onChildrenChanged: {
                Array.from(children).forEach(item => {
                    item.anchors.verticalCenter = this.verticalCenter;
                })
            }
            anchors {
                fill: parent
                leftMargin: root.leftPadding
                topMargin: root.topPadding
                rightMargin: root.rightPadding
                bottomMargin: root.bottomPadding
            }
        }
    }
}
