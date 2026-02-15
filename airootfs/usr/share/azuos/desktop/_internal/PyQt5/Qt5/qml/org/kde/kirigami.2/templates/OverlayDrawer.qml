/*
 *  SPDX-FileCopyrightText: 2012 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Templates 2.15 as T2
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.11 as Kirigami
import "private" as P

/**
 * @brief Overlay drawers are used to expose additional UI elements needed for
 * small secondary tasks for which the main UI elements are not needed.
 *
 * Overlay drawers can be used to create two kinds of components, a modal drawer
 * and an inline drawer. A modal drawer darkens the rest of the application and
 * grabs focus until confirmed, whereas an inline drawer does not.
 *
 * Unlike an OverlaySheet that appears in the center of the application, an OverlayDrawer
 * can be attached to an edge of the application, usually the top or the bottom edges.
 *
 * @see Visit https://develop.kde.org/docs/getting-started/kirigami/components-drawers to read more
 * about modal and non-modal drawers.
 *
 * Example usage:
 * @include overlaydrawer.qml
 *
 * @inherit QtQuick.Controls.Drawer
 */
T2.Drawer {
    id: root

    z: modal ? 0 : 1

//BEGIN properties
    /**
     * @brief This property specifies whether the drawer is open and visible.
     *
     * default: ``false``
     */
    property bool drawerOpen: false

    /**
     * @brief This property specifies whether the drawer is in a state between open
     * and closed.
     *
     * The drawer is visible but not completely open. This is usually the case when
     * the user is dragging the drawer from a screen edge, so the user is "peeking"
     * at what's in the drawer.
     *
     * default: ``false``
     */
    property bool peeking: false

    /**
     * @brief This property specifies whether the drawer is currently opening or closing itself.
     */
    readonly property bool animating : enterAnimation.animating || exitAnimation.animating || positionResetAnim.running

    /**
     * @brief This property holds whether the drawer can be collapsed to a
     * very thin, usually icon only sidebar.
     *
     * Only modal drawers are collapsible. Collapsible is not supported in
     * the mobile mode.
     *
     * @since org.kde.kirigami 2.5
     */
    property bool collapsible: false

    /**
     * @brief This property specifies whether the drawer is collapsed to a
     * very thin sidebar, usually icon only.
     *
     * When true, the drawer will be collapsed to a very thin sidebar,
     * usually icon only.
     *
     * default: ``false``
     *
     * @see collapsible
     */
    property bool collapsed: false

    /**
     * @brief This property holds the size of the collapsed drawer.
     *
     * For vertical drawers this will be the width of the drawer and for horizontal
     * drawers this will be the height of the drawer.
     *
     * default: @link Kirigami.Units.iconSizes Kirigami.Units.iconSizes.medium @endlink,
     * just enough to accommodate medium sized icons
     */
    property int collapsedSize: Kirigami.Units.iconSizes.medium

    /**
     * @brief This property holds the options for handle's open icon.
     *
     * This grouped property has the following sub-properties:
     * * ``source: var``: A Freedesktop standard icon name. The icon is pulled from system's icon theme.
     * * ``color: color``: An optional tint color for the icon.
     *
     * If no custom icon is set, a menu icon is shown for the
     * @link ApplicationWindow::globalDrawer globalDrawer @endlink
     * and an overflow menu icon is shown for the @link ApplicationWindow::contextDrawer contextDrawer @endlink.
     * That's the default for the GlobalDrawer and ContextDrawer components respectively.
     *
     * For OverlayDrawer the default is view-right-close or view-left-close depending on
     * the drawer location.
     *
     * @since org.kde.kirigami 2.5
     */
    readonly property P.IconPropertiesGroup handleOpenIcon: P.IconPropertiesGroup {
        source: root.edge === Qt.RightEdge ? "view-right-close" : "view-left-close"
    }

    /**
     * @brief This property holds the options for the handle's close icon.
     *
     * This grouped property has the following sub-properties:
     * * ``source: var``: A Freedesktop standard icon name. The icon is pulled from system's icon theme.
     * * ``color: color``: An optional tint color for the icon.
     *
     * If no custom icon is set, an X icon is shown,
     * which will morph into the Menu or overflow icons.
     *
     * For OverlayDrawer the default is view-right-new or view-left-new depending on
     * the drawer location.
     *
     * @since org.kde.kirigami 2.5
     */
    property P.IconPropertiesGroup handleClosedIcon: P.IconPropertiesGroup {
        source: root.edge === Qt.RightEdge ? "view-right-new" : "view-left-new"
    }

    /**
     * @brief This property holds the tooltip displayed when the drawer is open.
     * @since org.kde.kirigami 2.15
     */
    property string handleOpenToolTip: qsTr("Close drawer")

    /**
     * @brief This property holds the tooltip displayed when the drawer is closed.
     * @since org.kde.kirigami 2.15
     */
    property string handleClosedToolTip: qsTr("Open drawer")

    /**
     * @brief This property holds whether the handle is visible, to make opening the
     * drawer easier.
     *
     * Currently supported only on left and right drawers.
     */
    property bool handleVisible: typeof(applicationWindow)===typeof(Function) && applicationWindow() ? applicationWindow().controlsVisible : true

    /**
     * @brief Readonly property that points to the item that will act as a physical
     * handle for the drawer.
     * @property MouseArea handle
     **/
    readonly property Item handle: MouseArea {
        id: drawerHandle

        /*
         * This property is used to set when the tooltip is visible.
         * It exists because the text is changed while the tooltip is still visible.
         */
        property bool displayToolTip: true

        z: root.modal ? applicationWindow().overlay.z + (root.position > 0 ? +1 : -1) : root.background.parent.z + 1
        preventStealing: true
        hoverEnabled: handleAnchor && handleAnchor.visible
        parent: applicationWindow().overlay.parent

        QQC2.ToolButton {
            anchors.centerIn: parent
            width: parent.height - Kirigami.Units.smallSpacing * 1.5
            height: parent.height - Kirigami.Units.smallSpacing * 1.5
            onClicked: {
                drawerHandle.displayToolTip = false
                Qt.callLater(() => root.drawerOpen = !root.drawerOpen)
            }
            Accessible.name: root.drawerOpen ? root.handleOpenToolTip : root.handleClosedToolTip
            visible: !Kirigami.Settings.tabletMode && !Kirigami.Settings.hasTransientTouchInput
        }
        T2.ToolTip.visible: drawerHandle.displayToolTip && containsMouse
        T2.ToolTip.text: root.drawerOpen ? handleOpenToolTip : handleClosedToolTip
        T2.ToolTip.delay: Kirigami.Units.toolTipDelay

        property Item handleAnchor: (applicationWindow().pageStack && applicationWindow().pageStack.globalToolBar)
                ? ((root.edge === Qt.LeftEdge && Qt.application.layoutDirection === Qt.LeftToRight)
                   || (root.edge === Qt.RightEdge && Qt.application.layoutDirection === Qt.RightToLeft)
                   ? applicationWindow().pageStack.globalToolBar.leftHandleAnchor
                   : applicationWindow().pageStack.globalToolBar.rightHandleAnchor)
                : (applicationWindow().header && applicationWindow().header.toString().indexOf("ToolBarApplicationHeader") !== -1 ? applicationWindow().header : null)

        property int startX
        property int mappedStartX

        enabled: root.handleVisible

        onPressed: mouse => {
            root.peeking = true;
            startX = mouse.x;
            mappedStartX = mapToItem(parent, startX, 0).x
        }
        onPositionChanged: mouse => {
            if (!pressed) {
                return;
            }
            const pos = mapToItem(parent, mouse.x - startX, mouse.y);
            switch(root.edge) {
            case Qt.LeftEdge:
                root.position = pos.x/root.contentItem.width;
                break;
            case Qt.RightEdge:
                root.position = (root.parent.width - pos.x - width)/root.contentItem.width;
                break;
            default:
            }
        }
        onReleased: mouse => {
            root.peeking = false;
            if (Math.abs(mapToItem(parent, mouse.x, 0).x - mappedStartX) < Qt.styleHints.startDragDistance) {
                if (!root.drawerOpen) {
                    root.close();
                }
                root.drawerOpen = !root.drawerOpen;
            }
        }
        onCanceled: {
            root.peeking = false
        }
        x: {
            switch(root.edge) {
            case Qt.LeftEdge:
                return root.background.width * root.position + Kirigami.Units.smallSpacing;
            case Qt.RightEdge:
                return drawerHandle.parent.width - (root.background.width * root.position) - width - Kirigami.Units.smallSpacing;
            default:
                return 0;
            }
        }
        y: handleAnchor && anchors.bottom ? handleAnchor.Kirigami.ScenePosition.y : 0

        anchors {
            bottom: drawerHandle.handleAnchor && drawerHandle.handleAnchor.visible ? undefined : parent.bottom
            bottomMargin: {
                if (typeof applicationWindow === "undefined") {
                    return;
                }

                let margin = Kirigami.Units.smallSpacing;
                if (applicationWindow().footer) {
                    margin = applicationWindow().footer.height + Kirigami.Units.smallSpacing;
                }

                if(root.parent && root.height < root.parent.height) {
                    margin = root.parent.height - root.height - root.y + Kirigami.Units.smallSpacing;
                }

                if (!applicationWindow() || !applicationWindow().pageStack ||
                    !applicationWindow().pageStack.contentItem ||
                    !applicationWindow().pageStack.contentItem.itemAt) {
                    return margin;
                }

                let item;
                if (applicationWindow().pageStack.layers.depth > 1) {
                    item = applicationWindow().pageStack.layers.currentItem;
                } else {
                    item = applicationWindow().pageStack.contentItem.itemAt(applicationWindow().pageStack.contentItem.contentX + drawerHandle.x, 0);
                }

                // try to take the last item
                if (!item) {
                    item = applicationWindow().pageStack.lastItem;
                }

                let pageFooter = item && item.page ? item.page.footer : (item ? item.footer : undefined);
                if (pageFooter && root.parent) {
                    margin = root.height < root.parent.height ? margin : margin + pageFooter.height
                }

                return margin;
            }
            Behavior on bottomMargin {
                NumberAnimation {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }

        visible: root.enabled && (root.edge === Qt.LeftEdge || root.edge === Qt.RightEdge) && opacity > 0
        width: handleAnchor && handleAnchor.visible ? handleAnchor.width : Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.smallSpacing*2
        height: handleAnchor && handleAnchor.visible ? handleAnchor.height : width
        opacity: root.handleVisible ? 1 : 0
        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        transform: Translate {
            id: translateTransform
            x: root.handleVisible ? 0 : (root.edge === Qt.LeftEdge ? -drawerHandle.width : drawerHandle.width)
            Behavior on x {
                NumberAnimation {
                    duration: Kirigami.Units.longDuration
                    easing.type: !root.handleVisible ? Easing.OutQuad : Easing.InQuad
                }
            }
        }
    }
//END properties

    interactive: modal

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: modal ? Kirigami.Theme.View : Kirigami.Theme.Window
    Kirigami.Theme.onColorSetChanged: {
        contentItem.Kirigami.Theme.colorSet = Kirigami.Theme.colorSet
        background.Kirigami.Theme.colorSet = Kirigami.Theme.colorSet
    }

//BEGIN reassign properties
    //default paddings
    leftPadding: Kirigami.Units.smallSpacing
    topPadding: Kirigami.Units.smallSpacing
    rightPadding: Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing

    y: modal ? 0 : ((T2.ApplicationWindow.menuBar ? T2.ApplicationWindow.menuBar.height : 0) + (T2.ApplicationWindow.header ? T2.ApplicationWindow.header.height : 0))

    height: parent && (root.edge === Qt.LeftEdge || root.edge === Qt.RightEdge) ? (modal ? parent.height : (parent.height - y - (T2.ApplicationWindow.footer ? T2.ApplicationWindow.footer.height : 0))) : implicitHeight

    parent: modal || edge === Qt.LeftEdge || edge === Qt.RightEdge ? T2.ApplicationWindow.overlay : T2.ApplicationWindow.contentItem

    edge: Qt.LeftEdge
    modal: true

    dragMargin: enabled && (edge === Qt.LeftEdge || edge === Qt.RightEdge) ? Math.min(Kirigami.Units.gridUnit, Qt.styleHints.startDragDistance) : 0

    contentWidth: contentItem.implicitWidth || (contentChildren.length === 1 ? contentChildren[0].implicitWidth : 0)
    contentHeight: contentItem.implicitHeight || (contentChildren.length === 1 ? contentChildren[0].implicitHeight : 0)

    implicitWidth: contentWidth + leftPadding + rightPadding
    implicitHeight: contentHeight + topPadding + bottomPadding

    enter: Transition {
        SequentialAnimation {
            id: enterAnimation
            /* NOTE: why this? the running status of the enter transition is not relaible and
             * the SmoothedAnimation is always marked as non running,
             * so the only way to get to a reliable animating status is with this
             */
            property bool animating
            ScriptAction {
                script: {
                    enterAnimation.animating = true
                    // on non modal dialog we don't want drawers in the overlay
                    if (!root.modal) {
                        root.background.parent.parent = applicationWindow().overlay.parent
                    }
                }
            }
            SmoothedAnimation {
                velocity: 5
            }
            ScriptAction {
                script: enterAnimation.animating = false
            }
        }
    }

    exit: Transition {
        SequentialAnimation {
            id: exitAnimation
            property bool animating
            ScriptAction {
                script: exitAnimation.animating = true
            }
            SmoothedAnimation {
                velocity: 5
            }
            ScriptAction {
                script: exitAnimation.animating = false
            }
        }
    }
//END reassign properties


//BEGIN signal handlers
    onCollapsedChanged: {
        if (Kirigami.Settings.isMobile) {
            collapsed = false;
        }
        if (!__internal.completed) {
            return;
        }
        if ((!collapsible || modal) && collapsed) {
            collapsed = true;
        }
    }
    onCollapsibleChanged: {
        if (Kirigami.Settings.isMobile) {
            collapsible = false;
        }
        if (!__internal.completed) {
            return;
        }
        if (!collapsible) {
            collapsed = false;
        } else if (modal) {
            collapsible = false;
        }
    }
    onModalChanged: {
        if (!__internal.completed) {
            return;
        }
        if (modal) {
            collapsible = false;
        }
    }

    onPositionChanged: {
        if (peeking) {
            visible = true
        }
    }
    onVisibleChanged: {
        if (peeking) {
            visible = true
        } else {
            drawerOpen = visible;
        }
    }
    onPeekingChanged:  {
        if (peeking) {
            root.enter.enabled = false;
            root.exit.enabled = false;
        } else {
            drawerOpen = position > 0.5 ? 1 : 0;
            positionResetAnim.running = true
            root.enter.enabled = true;
            root.exit.enabled = true;
        }
    }
    onDrawerOpenChanged: {
        // sync this property only when the component is properly loaded
        if (!__internal.completed) {
            return;
        }
        positionResetAnim.running = false;
        if (drawerOpen) {
            open();
        } else {
            close();
        }
        Qt.callLater(() => drawerHandle.displayToolTip = true)
    }

    Component.onCompleted: {
        // if defined as drawerOpen by default in QML, don't animate
        if (root.drawerOpen) {
            root.enter.enabled = false;
            root.visible = true;
            root.position = 1;
            root.enter.enabled = true;
        }
        __internal.completed = true;
        contentItem.Kirigami.Theme.colorSet = Kirigami.Theme.colorSet;
        background.Kirigami.Theme.colorSet = Kirigami.Theme.colorSet;
    }
//END signal handlers

    // this is as hidden as it can get here
    /** @internal */
    property QtObject __internal: QtObject {
        //here in order to not be accessible from outside
        property bool completed: false
        property SequentialAnimation positionResetAnim: SequentialAnimation {
            id: positionResetAnim
            property alias to: internalAnim.to
            NumberAnimation {
                id: internalAnim
                target: root
                to: drawerOpen ? 1 : 0
                property: "position"
                duration: (root.position)*Kirigami.Units.longDuration
            }
            ScriptAction {
                script: {
                    root.drawerOpen = internalAnim.to !== 0;
                }
            }
        }
        readonly property Item statesItem: Item {
            states: [
                State {
                    when: root.collapsed
                    PropertyChanges {
                        target: root
                        implicitWidth: edge === Qt.TopEdge || edge === Qt.BottomEdge ? applicationWindow().width : Math.min(collapsedSize + leftPadding + rightPadding, Math.round(applicationWindow().width*0.8))

                        implicitHeight: edge === Qt.LeftEdge || edge === Qt.RightEdge ? applicationWindow().height : Math.min(collapsedSize + topPadding + bottomPadding, Math.round(applicationWindow().height*0.8))
                    }
                },
                State {
                    when: !root.collapsed
                    PropertyChanges {
                        target: root
                        implicitWidth: edge === Qt.TopEdge || edge === Qt.BottomEdge ? applicationWindow().width : Math.min(contentItem.implicitWidth, Math.round(applicationWindow().width*0.8))

                        implicitHeight: edge === Qt.LeftEdge || edge === Qt.RightEdge ? applicationWindow().height : Math.min(contentHeight + topPadding + bottomPadding, Math.round(applicationWindow().height*0.4))

                        contentWidth: contentItem.implicitWidth || (contentChildren.length === 1 ? contentChildren[0].implicitWidth : 0)
                        contentHeight: contentItem.implicitHeight || (contentChildren.length === 1 ? contentChildren[0].implicitHeight : 0)
                    }
                }
            ]
            transitions: Transition {
                reversible: true
                NumberAnimation {
                    properties: root.edge === Qt.TopEdge || root.edge === Qt.BottomEdge ? "implicitHeight" : "implicitWidth"
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }
    }
}
