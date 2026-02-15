/*
 *  SPDX-FileCopyrightText: 2016-2020 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */


import QtQuick 2.12
import QtQuick.Layouts 1.2
import QtQuick.Window 2.2
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.14 as Kirigami
import QtQuick.Templates 2.0 as T2
import "private" as P
import "../private" as PP

/**
 * @brief An overlay sheet that covers the current Page content.
 *
 * Its contents can be scrolled up or down, scrolling all the way up or
 * all the way down, dismisses it.
 * Use this for big, modal dialogs or information display, that can't be
 * logically done as a new separate Page, even if potentially
 * are taller than the screen space.
 *
 * @since org.kde.kirigami 2.0
 * @inherit QtQuick.QtObject
 */
QtObject {
    id: root

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    /**
     * @brief This property holds the visual content item.
     * @note The content item is automatically resized to fill the
     * sheet's view area.
     *
     * Conversely, the Sheet will be sized based on the size hints
     * of the contentItem, so if you need a custom size sheet,
     * redefine contentWidth and contentHeight of your contentItem
     */
    default property Item contentItem

    /**
     * @brief This property specifies whether the sheet is open and displaying its contents.
     */
    property bool sheetOpen

    /**
     * @brief This property holds the left padding.
     *
     * default: ``Kirigami.Units.largeSpacing``
     */
    property int leftPadding: Kirigami.Units.largeSpacing

    /**
     * @brief This property holds the top padding.
     *
     * default: ``Kirigami.Units.largeSpacing``
     */
    property int topPadding: Kirigami.Units.largeSpacing

    /**
     * @brief This property holds the right padding.
     *
     * default: ``Kirigami.Units.largeSpacing``
     */
    property int rightPadding: Kirigami.Units.largeSpacing

    /**
     * @brief This property holds the bottom padding.
     *
     * default: ``Kirigami.Units.largeSpacing``
     */
    property int bottomPadding: Kirigami.Units.largeSpacing

    /**
     * @brief This property holds the left inset for the background.
     *
     * The inset gets applied to both the content and the background.
     *
     * default: ``0``
     *
     * @since org.kde.kirigami 2.12
     */
    property real leftInset: 0

    /**
     * @brief This property holds the top inset for the background.
     *
     * The inset gets applied to both the content and the background.
     *
     * default: ``0``
     *
     * @since org.kde.kirigami 2.12
     */
    property real topInset: 0

    /**
     * @brief This property holds the right inset for the background.
     *
     * The inset gets applied to both the content and the background.
     *
     * default: ``0``
     *
     * @since org.kde.kirigami 2.12
     */
    property real rightInset: 0

    /**
     * @brief This property holds the bottom inset for the background.
     *
     * The inset gets applied to both the content and the background.
     *
     * default: ``0``
     *
     * @since org.kde.kirigami 2.12
     */
    property real bottomInset: 0

    /**
     * @brief This property holds an optional item which will be used as the sheet's header,
     * and will always be displayed.
     * @since KDE Frameworks 5.43
     */
    property Item header: Kirigami.Heading {
        level: 2
        text: root.title
        elide: Text.ElideRight

        // use tooltip for long text that is elided
        QQC2.ToolTip.visible: truncated && titleHoverHandler.hovered
        QQC2.ToolTip.text: root.title
        HoverHandler {
            id: titleHoverHandler
        }
    }

    /**
     * @brief An optional item which will be used as the sheet's footer,
     * always kept on screen.
     * @since KDE Frameworks 5.43
     */
    property Item footer

    /**
     * @brief This property holds the background item.
     *
     * @note If the background item has no explicit size specified,
     * it automatically follows the control's size. In most cases,
     * there is no need to specify width or height for a background item.
     */
    property Item background

    /**
     * @brief This property sets the visibility of the close button in the top-right corner.
     *
     * default: `Only shown in desktop mode`
     *
     * @since KDE Frameworks 5.44
     */
    property bool showCloseButton: !Kirigami.Settings.isMobile

    /**
     * @brief This property holds the sheet's title.
     * @note If the header property is set, this will have no effect as the heading will be replaced by the header.
     * @since KDE Frameworks 5.84
     */
    property string title

    property Item parent

    /**
     * @brief This function opens the overlay sheet.
     */
    function open() {
        openAnimation.running = true;
        root.sheetOpen = true;
        contentLayout.initialHeight = contentLayout.height
        mainItem.visible = true;
        mainItem.forceActiveFocus();
    }

    /**
     * @brief This function closes the overlay sheet.
     */
    function close() {
        if (root.sheetOpen) {
            root.sheetOpen = false;
        }
    }

    onBackgroundChanged: {
        background.parent = contentLayout.parent;
        background.anchors.fill = contentLayout;
        background.anchors.margins = -1
        background.z = -1;
    }
    onContentItemChanged: {
        if (contentItem instanceof Flickable) {
            scrollView.flickableItem = contentItem;
            contentItem.parent = scrollView;
            scrollView.contentItem = contentItem;
            scrollView.viewContent = contentItem.contentItem;
        } else {
            contentItem.parent = contentItemParent;
            flickableContents.parent = scrollView.flickableItem.contentItem;
            flickableContents.anchors.top = scrollView.flickableItem.contentItem.top;
            flickableContents.anchors.left = scrollView.flickableItem.contentItem.left;
            flickableContents.anchors.right = scrollView.flickableItem.contentItem.right;
            scrollView.viewContent = flickableContents;
            contentItem.anchors.left = contentItemParent.left;
            contentItem.anchors.right = contentItemParent.right;
        }
        scrollView.flickableItem.interactive = false;
        scrollView.flickableItem.flickableDirection = Flickable.VerticalFlick;
    }
    onSheetOpenChanged: {
        if (sheetOpen) {
            open();
        } else {
            closeAnimation.restart()
            Qt.inputMethod.hide();
            root.parent.forceActiveFocus();
        }
    }
    onHeaderChanged: headerItem.initHeader()
    onFooterChanged: {
        footer.parent = footerParent;
        footer.anchors.fill = footerParent;
    }

    Component.onCompleted: {
        // ScrollablePage must do things related to parenting of OverlaySheets in its conCompleted, so this must execute later
        // TODO KF6: port the root object to Popup template?
        Qt.callLater(() => {
            if (!root.parent && typeof applicationWindow !== "undefined") {
                root.parent = applicationWindow().overlay
            }
            headerItem.initHeader();
        });
    }

    readonly property Item rootItem: FocusScope {
        id: mainItem
        Kirigami.Theme.colorSet: root.Kirigami.Theme.colorSet
        Kirigami.Theme.inherit: root.Kirigami.Theme.inherit
        z: 101
        // we want to be over any possible OverlayDrawers, including handles
        parent: {
            if (root.parent && root.parent.Kirigami.ColumnView.view && (root.parent.Kirigami.ColumnView.view === root.parent || root.parent.Kirigami.ColumnView.view === root.parent.parent)) {
                return root.parent.Kirigami.ColumnView.view.parent;
            } else if (root.parent && root.parent.overlay) {
                return root.parent.overlay;
            } else {
                return root.parent;
            }
        }

        anchors.fill: parent

        visible: false
        clip: true

        // differentiate between mouse and touch
        HoverHandler {
            id: mouseHover
            acceptedDevices: PointerDevice.Mouse
        }

        Keys.onEscapePressed: event => {
            if (root.sheetOpen) {
                root.close();
            } else {
                event.accepted = false;
            }
        }

        readonly property int contentItemPreferredWidth: root.contentItem.Layout.preferredWidth > 0 ? root.contentItem.Layout.preferredWidth : root.contentItem.implicitWidth

        readonly property int absoluteContentItemMaximumWidth: width <= 0 ? contentItemPreferredWidth : Math.round(width - Kirigami.Units.largeSpacing * 2)
        readonly property int contentItemMaximumWidth: root.contentItem.Layout.maximumWidth > 0 ? Math.min(root.contentItem.Layout.maximumWidth, absoluteContentItemMaximumWidth) : width > Kirigami.Units.gridUnit * 30 ? width * 0.95 : absoluteContentItemMaximumWidth

        onHeightChanged: {
            const focusItem = Window.activeFocusItem;

            if (!focusItem) {
                return;
            }

            // NOTE: there is no function to know if an item is descended from another,
            // so we have to walk the parent hierarchy by hand
            let isDescendent = false;
            let candidate = focusItem.parent;
            while (candidate) {
                if (candidate === root) {
                    isDescendent = true;
                    break;
                }
                candidate = candidate.parent;
            }
            if (!isDescendent) {
                return;
            }

            let cursorY = 0;
            if (focusItem.cursorPosition !== undefined) {
                cursorY = focusItem.positionToRectangle(focusItem.cursorPosition).y;
            }


            const pos = focusItem.mapToItem(flickableContents, 0, cursorY - Units.gridUnit*3);
            // focused item already visible? add some margin for the space of the action buttons
            if (pos.y >= scrollView.flickableItem.contentY && pos.y <= scrollView.flickableItem.contentY + scrollView.flickableItem.height - Kirigami.Units.gridUnit * 8) {
                return;
            }
            scrollView.flickableItem.contentY = pos.y;
        }

        ParallelAnimation {
            id: openAnimation
            property int margins: Kirigami.Units.gridUnit * 5
            NumberAnimation {
                target: outerFlickable
                properties: "contentY"
                from: -outerFlickable.height
                to: outerFlickable.openPosition
                duration: Kirigami.Units.longDuration
                easing.type: Easing.OutQuad
            }
            OpacityAnimator {
                target: mainItem
                from: 0
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InQuad
            }
        }

        NumberAnimation {
            id: resetAnimation
            target: outerFlickable
            properties: "contentY"
            from: outerFlickable.contentY
            to: outerFlickable.visibleArea.yPosition < (1 - outerFlickable.visibleArea.heightRatio)/2 || scrollView.flickableItem.contentHeight < outerFlickable.height
                ? outerFlickable.openPosition
                : outerFlickable.contentHeight - outerFlickable.height + outerFlickable.topEmptyArea + headerItem.height + footerItem.height
            duration: Kirigami.Units.longDuration
            easing.type: Easing.OutQuad
        }

        SequentialAnimation {
            id: closeAnimation
            ParallelAnimation {
                NumberAnimation {
                    target: outerFlickable
                    properties: "contentY"
                    from: outerFlickable.contentY + (contentLayout.initialHeight - contentLayout.height)
                    to: outerFlickable.visibleArea.yPosition < (1 - outerFlickable.visibleArea.heightRatio)/2 ? -mainItem.height : outerFlickable.contentHeight
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InQuad
                }
                OpacityAnimator {
                    target: mainItem
                    from: 1
                    to: 0
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InQuad
                }
            }
            ScriptAction {
                script: {
                    contentLayout.initialHeight = 0
                    scrollView.flickableItem.contentY = -mainItem.height;
                    mainItem.visible = false;
                }
            }
        }
        Rectangle {
            anchors.fill: parent
            color: "black"
            opacity: 0.3 * Math.min(
                (Math.min(outerFlickable.contentY + outerFlickable.height, outerFlickable.height) / outerFlickable.height),
                (2 + (outerFlickable.contentHeight - outerFlickable.contentY - outerFlickable.topMargin - outerFlickable.bottomMargin)/outerFlickable.height))
        }

        MouseArea {
            anchors.fill: parent
            drag.filterChildren: true
            hoverEnabled: true

            onPressed: mouse => {
                const pos = mapToItem(contentLayout, mouse.x, mouse.y);
                if (contentLayout.contains(pos) && mouseHover.hovered) { // only on mouse event, not touch
                    // disable dragging the sheet with a mouse
                    outerFlickable.interactive = false
                }
            }
            onReleased: mouse => {
                const pos = mapToItem(contentLayout, mouse.x, mouse.y);
                if (!contentLayout.contains(pos)) {
                    root.close();
                }
                // enable dragging of sheet once mouse is not clicked
                outerFlickable.interactive = true
            }


            Item {
                id: flickableContents

                readonly property real listHeaderHeight: scrollView.flickableItem ? -scrollView.flickableItem.originY : 0

                y: (scrollView.contentItem !== flickableContents ? -scrollView.flickableItem.contentY - listHeaderHeight  - (headerItem.visible ? headerItem.height : 0): 0)

                width: mainItem.contentItemPreferredWidth <= 0 ? mainItem.width : (mainItem.contentItemMaximumWidth > 0 ? Math.min( mainItem.contentItemMaximumWidth, Math.max( mainItem.width/2, mainItem.contentItemPreferredWidth ) ) : Math.max( mainItem.width / 2, mainItem.contentItemPreferredWidth ) ) + leftPadding + rightPadding


                implicitHeight: scrollView.viewContent === flickableContents ? root.contentItem.height + topPadding + bottomPadding : 0

                Connections {
                    target: enabled ? flickableContents.Window.activeFocusItem : null
                    enabled: flickableContents.focus && flickableContents.Window.activeFocusItem && flickableContents.Window.activeFocusItem.hasOwnProperty("text")
                    function onTextChanged() {
                        if (Qt.inputMethod.cursorRectangle.y + Qt.inputMethod.cursorRectangle.height > mainItem.Window.height) {
                            scrollView.flickableItem.contentY += (Qt.inputMethod.cursorRectangle.y + Qt.inputMethod.cursorRectangle.height) - mainItem.Window.height
                        }
                    }
                }

                Item {
                    id: contentItemParent
                    anchors {
                        fill: parent
                        leftMargin: leftPadding
                        topMargin: topPadding
                        rightMargin: rightPadding
                        bottomMargin: bottomPadding
                    }
                }
            }

            Connections {
                target: scrollView.flickableItem
                property real oldContentHeight: 0
                function onContentHeightChanged() {
                    if (openAnimation.running) {
                        openAnimation.running = false;
                        open();
                    } else {
                        // repositioning is relevant only when the content height is less than the viewport height.
                        // In that case the sheet looks like a dialog and should be centered. there is also a corner case when now is bigger then the viewport but prior to the
                        // resize event it was smaller, also in this case we need repositioning
                        if (scrollView.animatedContentHeight < outerFlickable.height
                            || scrollView.flickableItem.oldContentHeight < outerFlickable.height
                        ) {
                            outerFlickable.adjustPosition();
                        }
                        oldContentHeight = scrollView.animatedContentHeight
                    }
                }
            }

            Flickable {
                id: outerFlickable
                anchors.fill: parent
                contentWidth: width
                topMargin: height
                bottomMargin: height
                // +1: we need the flickable to be always interactive
                contentHeight: Math.max(height+1, scrollView.animatedContentHeight + topEmptyArea)

                // readonly property int topEmptyArea: Math.max(height-scrollView.animatedContentHeight, Kirigami.Units.gridUnit * 3)
                readonly property int topEmptyArea: Math.max(height-scrollView.animatedContentHeight, Kirigami.Units.gridUnit * 3)

                readonly property real openPosition: Math.max(0, outerFlickable.height - outerFlickable.contentHeight + headerItem.height + footerItem.height) + height/2 - contentLayout.height/2;

                onOpenPositionChanged: {
                    if (openAnimation.running) {
                        openAnimation.running = false;
                        root.open();
                    } else if (root.sheetOpen) {
                        adjustPosition();
                    }
                }

                property real oldContentY: NaN
                property real oldContentHeight: 0
                property bool lastMovementWasDown: false
                property real startDraggingPos
                property bool layoutMovingGuard: false
                Kirigami.WheelHandler {
                    target: outerFlickable
                    scrollFlickableTarget: false
                }

                function adjustPosition() {
                    if(layoutMovingGuard) return;

                    if (openAnimation.running) {
                        openAnimation.running = false;
                        open()
                    } else {
                        resetAnimation.running = false;
                        contentY = openPosition;
                    }
                }

                // disable dragging the sheet with a mouse on header bar
                MouseArea {
                    anchors.fill: parent
                    onPressed: mouse => {
                        if (mouseHover.hovered) { // only on mouse event, not touch
                            outerFlickable.interactive = false
                        }
                    }
                    onReleased: mouse => {
                        outerFlickable.interactive = true
                    }
                }

                onContentYChanged: {
                    if (scrollView.userInteracting) {
                        return;
                    }

                    const startPos = -scrollView.flickableItem.topMargin - flickableContents.listHeaderHeight;
                    const pos = contentY - topEmptyArea - flickableContents.listHeaderHeight;
                    const endPos = scrollView.animatedContentHeight - scrollView.flickableItem.height + scrollView.flickableItem.bottomMargin - flickableContents.listHeaderHeight;

                    layoutMovingGuard = true;
                    if (endPos - pos > 0) {
                        contentLayout.y = Math.round(Math.max(root.topInset, scrollView.flickableItem.topMargin - pos - flickableContents.listHeaderHeight));
                    } else if (scrollView.flickableItem.topMargin - pos < 0) {
                        contentLayout.y = Math.round(endPos - pos + root.topInset);
                    }
                    layoutMovingGuard = false;

                    scrollView.flickableItem.contentY = Math.max(
                        startPos, Math.min(pos, endPos));

                    lastMovementWasDown = contentY < oldContentY;
                    oldContentY = contentY;
                }

                onFlickEnded: {
                    if (openAnimation.running || closeAnimation.running) {
                        return;
                    }
                    if (scrollView.flickableItem.atYBeginning ||scrollView.flickableItem.atYEnd) {
                        resetAnimation.restart();
                    }
                }

                onDraggingChanged: {
                    if (dragging) {
                        startDraggingPos = contentY;
                        return;
                    }

                    let shouldClose = false;

                    // close
                    if (scrollView.flickableItem.atYBeginning) {
                        if (startDraggingPos - contentY > Kirigami.Units.gridUnit * 4 &&
                            contentY < -Kirigami.Units.gridUnit * 4 &&
                            lastMovementWasDown) {
                            shouldClose = true;
                        }
                    }

                    if (scrollView.flickableItem.atYEnd) {
                        if (contentY - startDraggingPos > Kirigami.Units.gridUnit * 4 &&
                            contentY > contentHeight - height + Kirigami.Units.gridUnit * 4  &&
                            !lastMovementWasDown) {
                            shouldClose = true;
                        }
                    }

                    if (shouldClose) {
                        root.sheetOpen = false
                    } else if (scrollView.flickableItem.atYBeginning || scrollView.flickableItem.atYEnd) {
                        resetAnimation.restart();
                    }
                }

                onHeightChanged: {
                    adjustPosition();
                }

                onContentHeightChanged: {
                    // repositioning is relevant only when the content height is less than the viewport height.
                    // In that case the sheet looks like a dialog and should be centered. there is also a corner case when now is bigger then the viewport but prior to the
                    // resize event it was smaller, also in this case we need repositioning
                    if (contentHeight < height || oldContentHeight < height) {
                        adjustPosition();
                    }
                    oldContentHeight = contentHeight;
                }

                ColumnLayout {
                    id: contentLayout
                    spacing: 0
                    // Its events should be filtered but not scrolled
                    parent: outerFlickable
                    anchors.horizontalCenter: parent.horizontalCenter
                    width: mainItem.contentItemPreferredWidth <= 0 ? mainItem.width : (mainItem.contentItemMaximumWidth > 0 ? Math.min( mainItem.contentItemMaximumWidth, Math.max( mainItem.width/2, mainItem.contentItemPreferredWidth ) ) : Math.max( mainItem.width / 2, mainItem.contentItemPreferredWidth ) ) - root.leftInset - root.rightInset + root.leftPadding + root.rightPadding
                    height: Math.min(implicitHeight, parent.height) - root.topInset - root.bottomInset
                    property real initialHeight

                    Behavior on height {
                        NumberAnimation {
                            duration: Kirigami.Units.shortDuration
                            easing.type: Easing.InOutCubic
                        }
                    }

                    // Even though we're not actually using any shadows here,
                    // we're using a ShadowedRectangle instead of a regular
                    // rectangle because it allows fine-grained control over which
                    // corners to round, which we need here
                    Kirigami.ShadowedRectangle {
                        id: headerItem
                        Layout.fillWidth: true
                        Layout.alignment: Qt.AlignTop
                        //Layout.margins: 1
                        visible: root.header || root.showCloseButton
                        implicitHeight: Math.max(headerParent.implicitHeight, closeIcon.height) + Kirigami.Units.smallSpacing * 2
                        z: 2
                        corners.topLeftRadius: Kirigami.Units.smallSpacing
                        corners.topRightRadius: Kirigami.Units.smallSpacing
                        Kirigami.Theme.colorSet: Kirigami.Theme.Header
                        Kirigami.Theme.inherit: false
                        color: Kirigami.Theme.backgroundColor

                        function initHeader() {
                            if (header) {
                                header.parent = headerParent;
                                header.anchors.fill = headerParent;

                                // TODO: special case for actual ListViews
                            }
                        }

                        Item {
                            id: headerParent
                            implicitHeight: header ? header.implicitHeight : 0
                            anchors {
                                fill: parent
                                leftMargin: Kirigami.Units.largeSpacing
                                margins: Kirigami.Units.smallSpacing
                                rightMargin: (root.showCloseButton ? closeIcon.width : 0) + Kirigami.Units.smallSpacing
                            }
                        }
                        Kirigami.Icon {
                            id: closeIcon

                            readonly property bool tallHeader: headerItem.height > (Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.largeSpacing + Kirigami.Units.largeSpacing)

                            anchors {
                                right: parent.right
                                rightMargin: Kirigami.Units.largeSpacing
                                verticalCenter: headerItem.verticalCenter
                                margins: Kirigami.Units.smallSpacing
                            }

                            // Apply the changes to the anchors imperatively, to first disable an anchor point
                            // before setting the new one, so the icon don't grow unexpectedly
                            onTallHeaderChanged: {
                                if (tallHeader) {
                                    // We want to position the close button in the top-right corner if the header is very tall
                                    anchors.verticalCenter = undefined
                                    anchors.topMargin = Kirigami.Units.largeSpacing
                                    anchors.top = headerItem.top
                                } else {
                                    // but we want to vertically center it in a short header
                                    anchors.top = undefined
                                    anchors.topMargin = undefined
                                    anchors.verticalCenter = headerItem.verticalCenter
                                }
                            }
                            Component.onCompleted: tallHeaderChanged()

                            z: 3
                            visible: root.showCloseButton
                            width: Kirigami.Units.iconSizes.smallMedium
                            height: width
                            source: closeMouseArea.containsMouse ? "window-close" : "window-close-symbolic"
                            active: closeMouseArea.containsMouse
                            MouseArea {
                                id: closeMouseArea
                                hoverEnabled: true
                                anchors.fill: parent
                                onClicked: mouse => root.close();
                            }
                        }
                        Kirigami.Separator {
                            anchors {
                                right: parent.right
                                left: parent.left
                                top: parent.bottom
                            }
                        }
                    }

                    QQC2.ScrollView {
                        id: scrollView

                        // Don't do the automatic interactive enable/disable
                        // canFlickWithMouse: true
                        property Item viewContent
                        property real animatedContentHeight: flickableItem.contentHeight
                        property bool userInteracting: false
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        property alias flickableItem: scrollView.contentItem

                        focus: false

                        implicitHeight: flickableItem.contentHeight
                        Layout.maximumHeight: flickableItem.contentHeight

                        Layout.alignment: Qt.AlignTop

                        // HACK: Hide unnecessary horizontal scrollbar (https://bugreports.qt.io/browse/QTBUG-83890)
                        QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

                        Behavior on animatedContentHeight {
                            NumberAnimation {
                                duration: Kirigami.Units.shortDuration
                                easing.type: Easing.InOutCubic
                            }
                        }
                    }

                    Item { Layout.fillHeight: true }

                    Connections {
                        target: scrollView.flickableItem
                        property real oldContentY: 0
                        function onContentYChanged() {
                            if (outerFlickable.moving) {
                                oldContentY = scrollView.flickableItem.contentY;
                                return;
                            }
                            scrollView.userInteracting = true;

                            const diff = scrollView.flickableItem.contentY - oldContentY

                            outerFlickable.contentY = outerFlickable.contentY + diff;

                            if (diff > 0) {
                                contentLayout.y = Math.max(root.topInset,  contentLayout.y - diff);
                            } else if (scrollView.flickableItem.contentY < outerFlickable.topEmptyArea + headerItem.height) {
                                contentLayout.y = Math.min(outerFlickable.topEmptyArea + root.topInset,  contentLayout.y - diff);
                            }
                            oldContentY = scrollView.flickableItem.contentY;
                            scrollView.userInteracting = false;
                        }
                    }
                    Item {
                        visible: footerItem.visible
                        implicitHeight: footerItem.height
                    }
                }

                // footer item is outside the layout as it should never scroll away

                // Even though we're not actually using any shadows here,
                // we're using a ShadowedRectangle instead of a regular
                // rectangle because it allows fine-grained control over which
                // corners to round, which we need here
                Kirigami.ShadowedRectangle {
                    id: footerItem
                    width: contentLayout.width
                    corners.bottomLeftRadius: Kirigami.Units.smallSpacing
                    corners.bottomRightRadius: Kirigami.Units.smallSpacing
                    parent: outerFlickable
                    x: contentLayout.x
                    y: Math.min(parent.height, contentLayout.y + contentLayout.height) - height
                    visible: root.footer
                    implicitHeight: footerParent.implicitHeight + Kirigami.Units.smallSpacing * 2 + extraMargin
                    Kirigami.Theme.colorSet: Kirigami.Theme.Window
                    Kirigami.Theme.inherit: false
                    color: Kirigami.Theme.backgroundColor

                    // Show an extra margin when:
                    // * the application is in mobile mode
                    // * it doesn't use toolbarapplicationheader
                    // * the bottom screen controls are visible
                    // * the sheet is displayed *under* the controls
                    property int extraMargin: (!root.parent ||
                        !Kirigami.Settings.isMobile ||
                        typeof applicationWindow === "undefined" ||
                        (root.parent === applicationWindow().overlay) ||
                        !applicationWindow().controlsVisible ||
                        (applicationWindow().pageStack && applicationWindow().pageStack.globalToolBar && applicationWindow().pageStack.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.ToolBar) ||
                        (applicationWindow().header && applicationWindow().header.toString().indexOf("ToolBarApplicationHeader") === 0))
                            ? 0 : Kirigami.Units.gridUnit * 3

                    z: 2
                    Item {
                        id: footerParent
                        implicitHeight: footer ? footer.implicitHeight : 0
                        anchors {
                            top: parent.top
                            left: parent.left
                            right: parent.right
                            margins: Kirigami.Units.smallSpacing
                        }
                    }

                    Kirigami.Separator {
                        anchors {
                            right: parent.right
                            left: parent.left
                            bottom: parent.top
                        }
                    }
                }
            }
        }
    }
}
