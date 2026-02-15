/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.0 as QQC2
import QtGraphicalEffects 1.0 as GE
import org.kde.kirigami 2.16 as Kirigami

Item {
    id: root

    anchors {
        left: parent.left
        right: parent.right
        bottom: parent.bottom
        bottomMargin: root.page.footer ? root.page.footer.height : 0
    }
    //smallSpacing for the shadow
    implicitHeight: button.height + Kirigami.Units.smallSpacing
    clip: true

    readonly property Kirigami.Page page: root.parent.page
    //either Action or QAction should work here

    function isActionAvailable(action) { return action && (action.hasOwnProperty("visible") ? action.visible === undefined || action.visible : !action.hasOwnProperty("visible")); }

    readonly property QtObject action: root.page && isActionAvailable(root.page.mainAction) ? root.page.mainAction : null
    readonly property QtObject leftAction: root.page && isActionAvailable(root.page.leftAction) ? root.page.leftAction : null
    readonly property QtObject rightAction: root.page && isActionAvailable(root.page.rightAction) ? root.page.rightAction : null

    readonly property bool hasApplicationWindow: typeof applicationWindow !== "undefined" && applicationWindow
    readonly property bool hasGlobalDrawer: typeof globalDrawer !== "undefined" && globalDrawer
    readonly property bool hasContextDrawer: typeof contextDrawer !== "undefined" && contextDrawer

    transform: Translate {
        id: translateTransform
    }

    states: [
        State {
            when: mouseArea.internalVisibility
            PropertyChanges {
                target: translateTransform
                y: 0
            }
            PropertyChanges {
                target: root
                opacity: 1
            }
            PropertyChanges {
                target: root
                visible: true
            }
        },
        State {
            when: !mouseArea.internalVisibility
            PropertyChanges {
                target: translateTransform
                y: button.height
            }
            PropertyChanges {
                target: root
                opacity: 0
            }
            PropertyChanges {
                target: root
                visible: false
            }
        }
    ]
    transitions: Transition {
        ParallelAnimation {
            NumberAnimation {
                target: translateTransform
                property: "y"
                duration: Kirigami.Units.longDuration
                easing.type: mouseArea.internalVisibility ? Easing.InQuad : Easing.OutQuad
            }
            OpacityAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    onWidthChanged: button.x = Qt.binding(() => (root.width / 2 - button.width / 2))
    Item {
        id: button
        x: root.width/2 - button.width/2

        property int mediumIconSizing: Kirigami.Units.iconSizes.medium
        property int largeIconSizing: Kirigami.Units.iconSizes.large

        anchors.bottom: edgeMouseArea.bottom

        implicitWidth: implicitHeight + mediumIconSizing*2 + Kirigami.Units.gridUnit
        implicitHeight: largeIconSizing + Kirigami.Units.largeSpacing*2


        onXChanged: {
            if (mouseArea.pressed || edgeMouseArea.pressed || fakeContextMenuButton.pressed) {
                if (root.hasGlobalDrawer && globalDrawer.enabled && globalDrawer.modal) {
                    globalDrawer.peeking = true;
                    globalDrawer.visible = true;
                    if (Qt.application.layoutDirection === Qt.LeftToRight) {
                        globalDrawer.position = Math.min(1, Math.max(0, (x - root.width/2 + button.width/2)/globalDrawer.contentItem.width + mouseArea.drawerShowAdjust));
                    } else {
                        globalDrawer.position = Math.min(1, Math.max(0, (root.width/2 - button.width/2 - x)/globalDrawer.contentItem.width + mouseArea.drawerShowAdjust));
                    }
                }
                if (root.hasContextDrawer && contextDrawer.enabled && contextDrawer.modal) {
                    contextDrawer.peeking = true;
                    contextDrawer.visible = true;
                    if (Qt.application.layoutDirection === Qt.LeftToRight) {
                        contextDrawer.position = Math.min(1, Math.max(0, (root.width/2 - button.width/2 - x)/contextDrawer.contentItem.width + mouseArea.drawerShowAdjust));
                    } else {
                        contextDrawer.position = Math.min(1, Math.max(0, (x - root.width/2 + button.width/2)/contextDrawer.contentItem.width + mouseArea.drawerShowAdjust));
                    }
                }
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent

            visible: action !== null || leftAction !== null || rightAction !== null
            property bool internalVisibility: (!root.hasApplicationWindow || (applicationWindow().controlsVisible && applicationWindow().height > root.height*2)) && (root.action === null || root.action.visible === undefined || root.action.visible)
            preventStealing: true

            drag {
                target: button
                //filterChildren: true
                axis: Drag.XAxis
                minimumX: root.hasContextDrawer && contextDrawer.enabled && contextDrawer.modal ? 0 : root.width/2 - button.width/2
                maximumX: root.hasGlobalDrawer && globalDrawer.enabled && globalDrawer.modal ? root.width : root.width/2 - button.width/2
            }

            property var downTimestamp;
            property int startX
            property int startMouseY
            property real drawerShowAdjust

            readonly property int currentThird: (3*mouseX)/width
            readonly property QtObject actionUnderMouse: {
                switch(currentThird) {
                    case 0: return leftAction;
                    case 1: return action;
                    case 2: return rightAction;
                    default: return null
                }
            }

            hoverEnabled: true

            QQC2.ToolTip.visible: containsMouse && !Kirigami.Settings.tabletMode && actionUnderMouse
            QQC2.ToolTip.text: actionUnderMouse ? actionUnderMouse.text : ""
            QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay

            onPressed: mouse => {
                // search if we have a page to set to current
                if (root.hasApplicationWindow && applicationWindow().pageStack.currentIndex !== undefined && root.page.Kirigami.ColumnView.level !== undefined) {
                    // search the button parent's parent, that is the page parent
                    // this will make the context drawer open for the proper page
                    applicationWindow().pageStack.currentIndex = root.page.Kirigami.ColumnView.level;
                }
                downTimestamp = (new Date()).getTime();
                startX = button.x + button.width/2;
                startMouseY = mouse.y;
                drawerShowAdjust = 0;
            }
            onReleased: mouse => {
                tooltipHider.restart();
                if (root.hasGlobalDrawer) globalDrawer.peeking = false;
                if (root.hasContextDrawer) contextDrawer.peeking = false;
                // pixel/second
                const x = button.x + button.width/2;
                const speed = ((x - startX) / ((new Date()).getTime() - downTimestamp) * 1000);
                drawerShowAdjust = 0;

                // project where it would be a full second in the future
                if (root.hasContextDrawer && root.hasGlobalDrawer && globalDrawer.modal && x + speed > Math.min(root.width/4*3, root.width/2 + globalDrawer.contentItem.width/2)) {
                    globalDrawer.open();
                    contextDrawer.close();
                } else if (root.hasContextDrawer && x + speed < Math.max(root.width/4, root.width/2 - contextDrawer.contentItem.width/2)) {
                    if (root.hasContextDrawer && contextDrawer.modal) {
                        contextDrawer.open();
                    }
                    if (root.hasGlobalDrawer && globalDrawer.modal) {
                        globalDrawer.close();
                    }
                } else {
                    if (root.hasGlobalDrawer && globalDrawer.modal) {
                        globalDrawer.close();
                    }
                    if (root.hasContextDrawer && contextDrawer.modal) {
                        contextDrawer.close();
                    }
                }
                // Don't rely on native onClicked, but fake it here:
                // Qt.startDragDistance is not adapted to devices dpi in case
                // of Android, so consider the button "clicked" when:
                // *the button has been dragged less than a gridunit
                // *the finger is still on the button
                if (Math.abs((button.x + button.width/2) - startX) < Kirigami.Units.gridUnit &&
                    mouse.y > 0) {

                    //if an action has been assigned, trigger it
                    if (actionUnderMouse && actionUnderMouse.trigger) {
                        actionUnderMouse.trigger();
                    }

                    if (actionUnderMouse && actionUnderMouse.hasOwnProperty("children") && actionUnderMouse.children.length > 0) {
                        let subMenuUnderMouse;
                        switch (actionUnderMouse) {
                        case leftAction:
                            subMenuUnderMouse = leftActionSubMenu;
                            break;
                        case mainAction:
                            subMenuUnderMouse = mainActionSubMenu;
                            break
                        case rightAction:
                            subMenuUnderMouse = rightActionSubMenu;
                            break;
                        }
                        if (subMenuUnderMouse && !subMenuUnderMouse.visible) {
                            subMenuUnderMouse.visible = true;
                        }
                    }
                }
            }

            onPositionChanged: mouse => {
                drawerShowAdjust = Math.min(0.3, Math.max(0, (startMouseY - mouse.y)/(Kirigami.Units.gridUnit*15)));
                button.xChanged();
            }
            onPressAndHold: mouse => {
                if (!actionUnderMouse) {
                    return;
                }

                // if an action has been assigned, show a message like a tooltip
                if (actionUnderMouse && actionUnderMouse.text && Kirigami.Settings.tabletMode) {
                    tooltipHider.stop();
                    QQC2.ToolTip.show(actionUnderMouse.text);
                    // The tooltip is shown perpetually while we are pressed and held, and
                    // we start tooltipHider below when the press is released. This ensures
                    // that the user can have as much time as they want to read the tooltip,
                    // and also that the tooltip is hidden in a pleasant manner that does
                    // not feel overly urgent.
                }
            }
            Timer {
                id: tooltipHider
                interval: Kirigami.Units.humanMoment
                onTriggered: {
                    mouseArea.QQC2.ToolTip.hide();
                }
            }
            Connections {
                target: root.hasGlobalDrawer ? globalDrawer : null
                function onPositionChanged() {
                    if ( globalDrawer && globalDrawer.modal && !mouseArea.pressed && !edgeMouseArea.pressed && !fakeContextMenuButton.pressed) {
                        if (Qt.application.layoutDirection === Qt.LeftToRight) {
                            button.x = globalDrawer.contentItem.width * globalDrawer.position + root.width/2 - button.width/2;
                        } else {
                            button.x = -globalDrawer.contentItem.width * globalDrawer.position + root.width/2 - button.width/2
                        }
                    }
                }
            }
            Connections {
                target: root.hasContextDrawer ? contextDrawer : null
                function onPositionChanged() {
                    if (contextDrawer && contextDrawer.modal && !mouseArea.pressed && !edgeMouseArea.pressed && !fakeContextMenuButton.pressed) {
                        if (Qt.application.layoutDirection === Qt.LeftToRight) {
                            button.x = root.width/2 - button.width/2 - contextDrawer.contentItem.width * contextDrawer.position;
                        } else {
                            button.x = root.width/2 - button.width/2 + contextDrawer.contentItem.width * contextDrawer.position;
                        }
                    }
                }
            }

            Item {
                id: background
                anchors {
                    fill: parent
                }

                Rectangle {
                    id: buttonGraphics
                    radius: width/2
                    anchors.centerIn: parent
                    height: parent.height - Kirigami.Units.smallSpacing*2
                    width: height
                    enabled: root.action && root.action.enabled
                    visible: root.action
                    readonly property bool pressed: root.action && root.action.enabled && ((root.action === mouseArea.actionUnderMouse && mouseArea.pressed) || root.action.checked)
                    property color baseColor: root.action && root.action.icon && root.action.icon.color && root.action.icon.color !== undefined && root.action.icon.color.a > 0 ? root.action.icon.color : Kirigami.Theme.highlightColor
                    color: pressed ? Qt.darker(baseColor, 1.3) : baseColor

                    ActionsMenu {
                        id: mainActionSubMenu
                        y: -height
                        x: -width/2 + parent.width/2
                        actions: root.action && root.action.hasOwnProperty("children") ? root.action.children : ""
                        submenuComponent: Component {
                            ActionsMenu {}
                        }
                    }
                    Kirigami.Icon {
                        id: icon
                        anchors.centerIn: parent
                        width: button.mediumIconSizing
                        height: width
                        source: root.action && root.action.icon.name ? root.action.icon.name : ""
                        selected: true
                        color: root.action && root.action.icon && root.action.icon.color && root.action.icon.color.a > 0 ? root.action.icon.color : (selected ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor)
                    }
                    Behavior on color {
                        ColorAnimation {
                            duration: Kirigami.Units.shortDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                    Behavior on x {
                        NumberAnimation {
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
                // left button
                Rectangle {
                    id: leftButtonGraphics
                    z: -1
                    anchors {
                        left: parent.left
                        bottom: parent.bottom
                        bottomMargin: Kirigami.Units.smallSpacing
                    }
                    enabled: root.leftAction && root.leftAction.enabled
                    radius: 2
                    height: button.mediumIconSizing + Kirigami.Units.smallSpacing * 2
                    width: height + (root.action ? Kirigami.Units.gridUnit*2 : 0)
                    visible: root.leftAction

                    readonly property bool pressed: root.leftAction && root.leftAction.enabled && ((mouseArea.actionUnderMouse === root.leftAction && mouseArea.pressed) || root.leftAction.checked)
                    property color baseColor: root.leftAction && root.leftAction.icon && root.leftAction.icon.color && root.leftAction.icon.color !== undefined && root.leftAction.icon.color.a > 0 ? root.leftAction.icon.color : Kirigami.Theme.highlightColor
                    color: pressed ? baseColor : Kirigami.Theme.backgroundColor
                    Behavior on color {
                        ColorAnimation {
                            duration: Kirigami.Units.shortDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                    ActionsMenu {
                        id: leftActionSubMenu
                        y: -height
                        x: -width/2 + parent.width/2
                        actions: root.leftAction && root.leftAction.hasOwnProperty("children") ? root.leftAction.children : ""
                        submenuComponent: Component {
                            ActionsMenu {}
                        }
                    }
                    Kirigami.Icon {
                        source: root.leftAction && root.leftAction.icon.name ? root.leftAction.icon.name : ""
                        width: button.mediumIconSizing
                        height: width
                        selected: leftButtonGraphics.pressed
                        color: root.leftAction && root.leftAction.icon && root.leftAction.icon.color && root.leftAction.icon.color.a > 0 ? root.leftAction.icon.color : (selected ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor)
                        anchors {
                            left: parent.left
                            verticalCenter: parent.verticalCenter
                            margins: root.action ? Kirigami.Units.smallSpacing * 2 : Kirigami.Units.smallSpacing
                        }
                    }
                }
                //right button
                Rectangle {
                    id: rightButtonGraphics
                    z: -1
                    anchors {
                        right: parent.right
                        // verticalCenter: parent.verticalCenter
                        bottom: parent.bottom
                        bottomMargin: Kirigami.Units.smallSpacing
                    }
                    enabled: root.rightAction && root.rightAction.enabled
                    radius: 2
                    height: button.mediumIconSizing + Kirigami.Units.smallSpacing * 2
                    width: height + (root.action ? Kirigami.Units.gridUnit*2 : 0)
                    visible: root.rightAction
                    readonly property bool pressed: root.rightAction && root.rightAction.enabled && ((mouseArea.actionUnderMouse === root.rightAction && mouseArea.pressed) || root.rightAction.checked)
                    property color baseColor: root.rightAction && root.rightAction.icon && root.rightAction.icon.color && root.rightAction.icon.color !== undefined && root.rightAction.icon.color.a > 0 ? root.rightAction.icon.color : Kirigami.Theme.highlightColor
                    color: pressed ? baseColor : Kirigami.Theme.backgroundColor
                    Behavior on color {
                        ColorAnimation {
                            duration: Kirigami.Units.shortDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                    ActionsMenu {
                        id: rightActionSubMenu
                        y: -height
                        x: -width/2 + parent.width/2
                        actions: root.rightAction && root.rightAction.hasOwnProperty("children") ? root.rightAction.children : ""
                        submenuComponent: Component {
                            ActionsMenu {}
                        }
                    }
                    Kirigami.Icon {
                        source: root.rightAction && root.rightAction.icon.name ? root.rightAction.icon.name : ""
                        width: button.mediumIconSizing
                        height: width
                        selected: rightButtonGraphics.pressed
                        color: root.rightAction && root.rightAction.icon && root.rightAction.icon.color && root.rightAction.icon.color.a > 0 ? root.rightAction.icon.color : (selected ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor)
                        anchors {
                            right: parent.right
                            verticalCenter: parent.verticalCenter
                            margins: root.action ? Kirigami.Units.smallSpacing * 2 : Kirigami.Units.smallSpacing
                        }
                    }
                }
            }

            GE.DropShadow {
                anchors.fill: background
                horizontalOffset: 0
                verticalOffset: 1
                radius: Kirigami.Units.gridUnit /2
                samples: 16
                color: Qt.rgba(0, 0, 0, mouseArea.pressed ? 0.6 : 0.4)
                source: background
            }
        }
    }

    MouseArea {
        id: fakeContextMenuButton
        anchors {
            right: edgeMouseArea.right
            bottom: parent.bottom
            margins: Kirigami.Units.smallSpacing
        }
        drag {
            target: button
            axis: Drag.XAxis
            minimumX: root.hasContextDrawer && contextDrawer.enabled && contextDrawer.modal ? 0 : root.width/2 - button.width/2
            maximumX: root.hasGlobalDrawer && globalDrawer.enabled && globalDrawer.modal ? root.width : root.width/2 - button.width/2
        }
        visible: root.page.actions && root.page.actions.contextualActions.length > 0 && ((typeof applicationWindow === "undefined") || applicationWindow().wideScreen)
            // using internal pagerow api
            && ((typeof applicationWindow !== "undefined") && root.page && root.page.parent ? root.page.Kirigami.ColumnView.level < applicationWindow().pageStack.depth-1 : (typeof applicationWindow === "undefined"))

        width: button.mediumIconSizing + Kirigami.Units.smallSpacing*2
        height: width


        GE.DropShadow {
            anchors.fill: handleGraphics
            horizontalOffset: 0
            verticalOffset: 1
            radius: Kirigami.Units.gridUnit /2
            samples: 16
            color: Qt.rgba(0, 0, 0, fakeContextMenuButton.pressed ? 0.6 : 0.4)
            source: handleGraphics
        }
        Rectangle {
            id: handleGraphics
            anchors.fill: parent
            color: fakeContextMenuButton.pressed ? Kirigami.Theme.highlightColor : Kirigami.Theme.backgroundColor
            radius: 1
            Kirigami.Icon {
                anchors.centerIn: parent
                width: button.mediumIconSizing
                selected: fakeContextMenuButton.pressed
                height: width
                source: "overflow-menu"
            }
            Behavior on color {
                ColorAnimation {
                    duration: Kirigami.Units.shortDuration
                    easing.type: Easing.InOutQuad
                }
            }
        }

        onPressed: mouse => {
            mouseArea.onPressed(mouse)
        }
        onReleased: mouse => {
            const pos = root.mapFromItem(fakeContextMenuButton, mouse.x, mouse.y);

            if ((typeof contextDrawer !== "undefined") && contextDrawer) {
                contextDrawer.peeking = false;

                if (pos.x < root.width/2) {
                    contextDrawer.open();
                } else if (contextDrawer.drawerOpen && mouse.x > 0 && mouse.x < width) {
                    contextDrawer.close();
                }
            }

            if ((typeof globalDrawer !== "undefined") && globalDrawer) {
                globalDrawer.peeking = false;

                if (globalDrawer.position > 0.5) {
                    globalDrawer.open();
                } else {
                    globalDrawer.close();
                }
            }
            if (containsMouse && ((typeof globalDrawer === "undefined") || !globalDrawer || !globalDrawer.drawerOpen || !globalDrawer.modal) &&
                ((typeof contextDrawer === "undefined") || !contextDrawer || !contextDrawer.drawerOpen || !contextDrawer.modal)) {
                contextMenu.visible = !contextMenu.visible;
            }
        }
        ActionsMenu {
            id: contextMenu
            x: parent.width - width
            y: -height
            actions: root.page.actions.contextualActions
            submenuComponent: Component {
                ActionsMenu {}
            }
        }
    }

    MouseArea {
        id: edgeMouseArea
        z:99
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
        }
        drag {
            target: button
            //filterChildren: true
            axis: Drag.XAxis
            minimumX: root.hasContextDrawer && contextDrawer.enabled && contextDrawer.modal ? 0 : root.width/2 - button.width/2
            maximumX: root.hasGlobalDrawer && globalDrawer.enabled && globalDrawer.modal ? root.width : root.width/2 - button.width/2
        }
        height: Kirigami.Units.smallSpacing * 3

        onPressed: mouse => mouseArea.onPressed(mouse)
        onPositionChanged: mouse => mouseArea.positionChanged(mouse)
        onReleased: mouse => mouseArea.released(mouse)
    }
}
