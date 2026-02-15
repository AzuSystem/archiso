/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.5
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami
import "private"


/**
 * @brief An item that can be used as a title for the application.
 *
 * Scrolling the main page will make it taller or shorter (through the point of going away)
 * It's a behavior similar to the typical mobile web browser addressbar
 * the minimum, preferred and maximum heights of the item can be controlled with
 * * ``minimumHeight``: Default is 0, i.e. hidden
 * * ``preferredHeight``: Default is Kirigami.Units.gridUnit * 1.6
 * * ``maximumHeight``: Default is Kirigami.Units.gridUnit * 3
 *
 * To achieve a titlebar that stays completely fixed just set the 3 sizes to the same value.
 *
 * @deprecated This will be removed in KF6.
 */
AbstractApplicationHeader {
    id: header

//BEGIN properties
    /**
     * @brief This property sets the way the separator between pages should be drawn in the header.
     *
     * The following values are allowed:
     * * ``Kirigami.ApplicationHeaderStyle.Breadcrumb``: The pages are hierarchical, separated by an arrow.
     * * ``Kirigami.ApplicationHeaderStyle.TabBar``: The pages are intended to behave like pages of a tabbed view.
     * and the separator will look limke a dot.
     *
     * When the header is in wide screen mode, no separator will be drawn.
     *
     * default: ``ApplicationHeaderStyle.Auto``
     */
    property int headerStyle: Kirigami.ApplicationHeaderStyle.Auto

    /**
     * @brief This property sets whether the back button is enabled.
     *
     * default: `when true, there will be a back button present that will make the pagerow scroll back when clicked`
     */
    property bool backButtonEnabled: (!titleList.isTabBar && (!Kirigami.Settings.isMobile || Qt.platform.os === "ios"))

    property Component pageDelegate: Component {
        Row {
            height: parent.height

            spacing: Kirigami.Units.smallSpacing

            x: Kirigami.Units.smallSpacing

            Kirigami.Icon {
                // in tabbar mode this is just a spacer
                visible: !titleList.wideMode && ((typeof modelData !== "undefined" && modelData > 0) || titleList.internalHeaderStyle === Kirigami.ApplicationHeaderStyle.TabBar)
                anchors.verticalCenter: parent.verticalCenter
                height: Kirigami.Units.iconSizes.small
                width: height
                selected: header.background && header.background.color && header.background.color === Kirigami.Theme.highlightColor
                source: titleList.isTabBar ? "" : (LayoutMirroring.enabled ? "go-next-symbolic-rtl" : "go-next-symbolic")
            }

            Kirigami.Heading {
                id: title
                width: Math.min(parent.width, Math.min(titleList.width, implicitWidth)) + Kirigami.Units.smallSpacing
                anchors.verticalCenter: parent.verticalCenter
                opacity: current ? 1 : 0.4
                // Scaling animate NativeRendering is too slow
                renderType: Text.QtRendering
                color: header.background && header.background.color && header.background.color === Kirigami.Theme.highlightColor ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                elide: Text.ElideRight
                text: page ? page.title : ""
                font.pointSize: -1
                font.pixelSize: Math.max(1, titleList.height * 0.7)
                verticalAlignment: Text.AlignVCenter
                wrapMode: Text.NoWrap
                Rectangle {
                    anchors {
                        bottom: parent.bottom
                        left: parent.left
                        right: parent.right
                    }
                    height: Kirigami.Units.smallSpacing
                    color: title.color
                    opacity: 0.6
                    visible: titleList.isTabBar && current
                }
            }
        }
    }
//END properties

//BEGIN signal handlers
    onBackButtonEnabledChanged: {
        if (backButtonEnabled && !titleList.backButton) {
            let component = Qt.createComponent(Qt.resolvedUrl("private/BackButton.qml"));
            titleList.backButton = component.createObject(navButtons);
            component.destroy();
            component = Qt.createComponent(Qt.resolvedUrl("private/ForwardButton.qml"));
            titleList.forwardButton = component.createObject(navButtons);
            component.destroy();
        } else if (titleList.backButton) {
            titleList.backButton.destroy();
            titleList.forwardButton.destroy();
        }
    }

    Component.onCompleted: print("Warning: ApplicationHeader is deprecated, remove and use the automatic internal toolbar instead.")
//END signal handlers

    Rectangle {
        anchors {
            verticalCenter: parent.verticalCenter
        }
        visible: titleList.x > 0 && !titleList.atXBeginning
        height: parent.height * 0.7
        color: Kirigami.Theme.highlightedTextColor
        width: Math.ceil(Kirigami.Units.smallSpacing / 6)
        opacity: 0.4
    }

    QQC2.StackView {
        id: stack
        anchors {
            fill: parent
            leftMargin: navButtons.width
            rightMargin: __appWindow.contextDrawer && __appWindow.contextDrawer.handleVisible && __appWindow.contextDrawer.handle && __appWindow.contextDrawer.handle.y === 0 ? __appWindow.contextDrawer.handle.width : 0
        }
        initialItem: titleList

        popEnter: Transition {
            YAnimator {
                from: -height
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }
        popExit: Transition {
            YAnimator {
                from: 0
                to: height
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }

        pushEnter: Transition {
            YAnimator {
                from: height
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }

        pushExit: Transition {
            YAnimator {
                from: 0
                to: -height
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }

        replaceEnter: Transition {
            YAnimator {
                from: height
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }

        replaceExit: Transition {
            YAnimator {
                from: 0
                to: -height
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutCubic
            }
        }
    }
    Kirigami.Separator {
        id: separator
        height: parent.height * 0.6
        visible: navButtons.width > 0
        anchors {
            verticalCenter: parent.verticalCenter
            left: navButtons.right
        }
    }
    Kirigami.Separator {
        height: parent.height * 0.6
        visible: stack.anchors.rightMargin > 0
        anchors {
            verticalCenter: parent.verticalCenter
            right: parent.right
            rightMargin: stack.anchors.rightMargin
        }
    }
    Repeater {
        model: pageRow.layers.depth -1
        delegate: Loader {
            // Don't load async to prevent jumpy behaviour on slower devices as it loads in.
            // If the title delegate really needs to load async, it should be its responsibility to do it itself.
            asynchronous: false
            sourceComponent: header.pageDelegate
            readonly property Kirigami.Page page: pageRow.layers.get(modelData+1)
            readonly property bool current: true;
            Component.onCompleted: stack.push(this)
            Component.onDestruction: stack.pop()
        }
    }

    Row {
        id: navButtons
        anchors {
            left: parent.left
            top: parent.top
            bottom: parent.bottom
            topMargin: Kirigami.Units.smallSpacing
            bottomMargin: Kirigami.Units.smallSpacing
        }
        Item {
            height: parent.height
            width: (applicationWindow().header && applicationWindow().header.toString().indexOf("ToolBarApplicationHeader") === 0) && __appWindow.globalDrawer && __appWindow.globalDrawer.handleVisible && __appWindow.globalDrawer.handle && __appWindow.globalDrawer.handle.y === 0 ? __appWindow.globalDrawer.handle.width : 0
        }
    }

    Flickable {
        id: titleList
        readonly property bool wideMode: pageRow.hasOwnProperty("wideMode") ? pageRow.wideMode : __appWindow.wideScreen
        property int internalHeaderStyle: header.headerStyle === Kirigami.ApplicationHeaderStyle.Auto ? (titleList.wideMode ? Kirigami.ApplicationHeaderStyle.Titles : Kirigami.ApplicationHeaderStyle.Breadcrumb) : header.headerStyle
        // if scrolling the titlebar should scroll also the pages and vice versa
        property bool scrollingLocked: (header.headerStyle === Kirigami.ApplicationHeaderStyle.Titles || titleList.wideMode)
        //uses this to have less strings comparisons
        property bool scrollMutex
        property bool isTabBar: header.headerStyle === Kirigami.ApplicationHeaderStyle.TabBar

        property Item backButton
        property Item forwardButton
        clip: true


        boundsBehavior: Flickable.StopAtBounds
        readonly property alias model: mainRepeater.model
        contentWidth: contentItem.width
        contentHeight: height

        readonly property int currentIndex: pageRow && pageRow.currentIndex !== undefined ? pageRow.currentIndex : 0
        readonly property int count: mainRepeater.count

        function gotoIndex(idx) {
            // don't actually scroll in widescreen mode
            if (titleList.wideMode || contentItem.children.length < 2) {
                return;
            }
            listScrollAnim.running = false
            const pos = titleList.contentX;
            let destPos;
            titleList.contentX = Math.max(((contentItem.children[idx] || {x: 0}).x + (contentItem.children[idx] || {width: 0}).width) - titleList.width, Math.min(titleList.contentX, (contentItem.children[idx] || {x: 0}).x));
            destPos = titleList.contentX;
            listScrollAnim.from = pos;
            listScrollAnim.to = destPos;
            listScrollAnim.running = true;
        }

        NumberAnimation {
            id: listScrollAnim
            target: titleList
            property: "contentX"
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }
        Timer {
            id: contentXSyncTimer
            interval: 0
            onTriggered: {
                titleList.contentX = pageRow.contentItem.contentX - pageRow.contentItem.originX + titleList.originX;
            }
        }
        onCountChanged: contentXSyncTimer.restart();
        onCurrentIndexChanged: gotoIndex(currentIndex);
        onModelChanged: gotoIndex(currentIndex);
        onContentWidthChanged: gotoIndex(currentIndex);

        onContentXChanged: {
            if (movingHorizontally && !titleList.scrollMutex && titleList.scrollingLocked && !pageRow.contentItem.moving) {
                titleList.scrollMutex = true;
                pageRow.contentItem.contentX = titleList.contentX - titleList.originX + pageRow.contentItem.originX;
                titleList.scrollMutex = false;
            }
        }
        onHeightChanged: {
            titleList.returnToBounds()
        }
        onMovementEnded: {
            if (titleList.scrollingLocked) {
                //this will trigger snap as well
                pageRow.contentItem.flick(0,0);
            }
        }
        onFlickEnded: movementEnded();

        NumberAnimation {
            id: scrollTopAnimation
            target: pageRow.currentItem && pageRow.currentItem.flickable ? pageRow.currentItem.flickable : null
            property: "contentY"
            to: 0
            duration: Kirigami.Units.longDuration
            easing.type: Easing.InOutQuad
        }

        Row {
            id: contentItem
            spacing: 0
            Repeater {
                id: mainRepeater
                model: pageRow.depth
                delegate: MouseArea {
                    id: delegate
                    readonly property int currentIndex: index
                    readonly property var currentModelData: modelData
                    clip: true

                    width: {
                        // more columns shown?
                        if (titleList.scrollingLocked && delegateLoader.page) {
                            return delegateLoader.page.width - (index === 0 ? navButtons.width : 0) - (index === pageRow.depth-1  ? stack.anchors.rightMargin : 0);
                        } else {
                            return Math.min(titleList.width, delegateLoader.implicitWidth + Kirigami.Units.smallSpacing);
                        }
                    }

                    height: titleList.height
                    onClicked: mouse => {
                        if (pageRow.currentIndex === modelData) {
                            // scroll up if current otherwise make current
                            if (!pageRow.currentItem.flickable) {
                                return;
                            }
                            if (pageRow.currentItem.flickable.contentY > -__appWindow.header.height) {
                                scrollTopAnimation.to = -pageRow.currentItem.flickable.topMargin;
                                scrollTopAnimation.running = true;
                            }

                        } else {
                            pageRow.currentIndex = modelData;
                        }
                    }

                    Loader {
                        id: delegateLoader
                        height: parent.height
                        x: titleList.wideMode || headerStyle === Kirigami.ApplicationHeaderStyle.Titles ? (Math.min(delegate.width - implicitWidth, Math.max(0, titleList.contentX - delegate.x))) : 0
                        width: parent.width - x

                        Connections {
                            target: delegateLoader.page.Component
                            function onDestruction() {
                                delegateLoader.sourceComponent = null;
                            }
                        }

                        sourceComponent: header.pageDelegate

                        readonly property Kirigami.Page page: pageRow.get(modelData)
                        // NOTE: why not use ListViewCurrentIndex? because listview itself resets
                        // currentIndex in some situations (since here we are using an int as a model,
                        // even more often) so the property binding gets broken
                        readonly property bool current: pageRow.currentIndex === index
                        readonly property int index: parent.currentIndex
                        readonly property var modelData: parent.currentModelData
                    }
                }
            }
        }
        Connections {
            target: titleList.scrollingLocked ? pageRow.contentItem : null
            function onContentXChanged() {
                if (!titleList.dragging && !titleList.movingHorizontally && !titleList.scrollMutex) {
                    titleList.contentX = pageRow.contentItem.contentX - pageRow.contentItem.originX + titleList.originX;
                }
            }
        }
    }
}
