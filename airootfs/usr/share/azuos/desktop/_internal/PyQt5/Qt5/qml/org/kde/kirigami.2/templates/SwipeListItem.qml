/*
 *  SPDX-FileCopyrightText: 2019 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.6
import QtQuick.Layouts 1.4
import QtQuick.Controls 2.4 as QQC2
import QtQuick.Templates 2.4 as T
import org.kde.kirigami 2.11 as Kirigami
import "../private"

/**
 * @brief An ItemDelegate intended to support extra actions.
 * 
 * On mobile, these actions can be uncovered by dragging a handle,
 * whereas with applications on tablet or desktop mode
 * these actions are always present on the right side of the delegate.
 *
 * Example usage:
 * @code{.qml}
 * ListView {
 *     model: myModel
 *     delegate: SwipeListItem {
 *         QQC2.Label {
 *             text: model.text
 *         }
 *         actions: [
 *              Action {
 *                  icon.name: "document-decrypt"
 *                  onTriggered: print("Action 1 clicked")
 *              },
 *              Action {
 *                  icon.name: model.action2Icon
 *                  onTriggered: //do something
 *              }
 *         ]
 *     }
 *
 * }
 * @endcode
 * @inherit QtQuick.Templates.SwipeDelegate
 */
T.SwipeDelegate {
    id: listItem

//BEGIN properties
    /**
     * @brief This property sets whether the item should emit signals related to mouse interaction.
     *
     * default: ``true``
     *
     * @deprecated Use hoverEnabled instead.
     * @property bool supportsMouseEvents
     */
    property alias supportsMouseEvents: listItem.hoverEnabled

    /**
     * @brief This property specifies whether the cursor is currently hovering over the item.
     *
     * On mobile touch devices, this will be @c true only when pressed.
     *
     * @see QtQuick.Templates.ItemDelegate.hovered
     * @deprecated This will be removed in KF6; use the ``hovered`` property instead.
     * @property bool containsMouse
     */
    property alias containsMouse: listItem.hovered

    /**
     * @brief This property sets whether instances of this list item will alternate
     * between two colors, helping readability.
     *
     * It is suggested to use this only when implementing a view with multiple columns.
     *
     * default: ``false``
     *
     * @since org.kde.kirigami 2.7
     */
    property bool alternatingBackground: false

    /**
     * @brief This property sets whether this Item is a section delegate.
     *
     * Setting this to @c true will make the list item look like a "title" for items under it.
     *
     * default: ``false``
     *
     * @see kirigami::ListSectionHeader
     */
    property bool sectionDelegate: false

    /**
     * @brief This property sets whether the separator is visible.
     *
     * The separator is a line between this and the Item under it.
     *
     * default: ``false``
     */
    property bool separatorVisible: false

    /**
     * @brief This property holds the background color of the list item.
     *
     * It is advised to use the default value.
     * default: @link Kirigami.PlatformTheme.backgroundColor Kirigami.Theme.backgroundColor @endlink
     */
    property color backgroundColor: Kirigami.Theme.backgroundColor

    /**
     * @brief This property holds the background color to be used when
     * background alternating is enabled.
     *
     * It is advised to use the default value.
     * default: @link Kirigami.PlatformTheme.alternateBackgroundColor Kirigami.Theme.alternateBackgroundColor @endlink
     *
     * @since org.kde.kirigami 2.7
     */
    property color alternateBackgroundColor: Kirigami.Theme.alternateBackgroundColor

    /**
     * @brief This property holds the color of the background
     * when the item is pressed or selected.
     *
     * It is advised to use the default value.
     * default: @link Kirigami.PlatformTheme.highlightColor Kirigami.Theme.highlightColor @endlink
     */
    property color activeBackgroundColor: Kirigami.Theme.highlightColor

    /**
     * @brief This property holds the color of the text in the item.
     *
     * It is advised to use the default value.
     * default: @link Kirigami.PlatformTheme.textColor Kirigami.Theme.textColor @endlink
     *
     * If custom text elements are inserted in an AbstractListItem,
     * their color will have to be manually set with this property.
     */
    property color textColor: Kirigami.Theme.textColor

    /**
     * @brief This property holds the color of the text when the item is pressed or selected.
     *
     * It is advised to use the default value.
     * default: @link Kirigami.PlatformTheme.highlightedTextColor Kirigami.Theme.highlightedTextColor @endlink
     *
     * If custom text elements are inserted in an AbstractListItem,
     * their color property will have to be manually bound with this property
     */
    property color activeTextColor: Kirigami.Theme.highlightedTextColor

    /**
     * @brief This property specifies whether actions are visible and interactive.
     *
     * True if it's possible to see and interact with the item's actions.
     *
     * Actions become hidden while editing of an item, for example.
     *
     * @since org.kde.kirigami 2.5
     */
    readonly property bool actionsVisible: actionsLayout.hasVisibleActions

    /**
     * @brief This property sets whether actions behind this SwipeListItem will always be visible.
     *
     * default: `true in desktop and tablet mode, @c false in mobile mode`
     *
     * @since org.kde.kirigami 2.15
     */
    property bool alwaysVisibleActions: !Kirigami.Settings.isMobile

    /**
     * @brief This property holds actions of the list item.
     *
     * At most 4 actions can be revealed when sliding away the list item;
     * others will be shown in the overflow menu.
     */
    property list<QQC2.Action> actions

    /**
     * @brief This property holds the width of the overlay.
     *
     * The value can represent the width of the handle component or the action layout.
     *
     * @since org.kde.kirigami 2.19
     * @property real overlayWidth
     */
    readonly property alias overlayWidth: overlayLoader.width

    // TODO KF6 remove this super wrong thing
    /**
     * @deprecated This property will be removed in KDE Framework 6. Use contentItem instead.
     * @internal
     */
    default property alias _default: listItem.contentItem
//END properties

    LayoutMirroring.childrenInherit: true

    hoverEnabled: true
    implicitWidth: contentItem ? contentItem.implicitWidth : Kirigami.Units.gridUnit * 12
    width: parent ? parent.width : implicitWidth
    implicitHeight: Math.max(Kirigami.Units.gridUnit * 2, contentItem.implicitHeight) + topPadding + bottomPadding

    padding: !listItem.alwaysVisibleActions && Kirigami.Settings.tabletMode ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing

    leftPadding: padding * 2 + (mirrored ? overlayLoader.paddingOffset : 0)
    rightPadding: padding * 2 + (mirrored ? 0 : overlayLoader.paddingOffset)

    topPadding: padding
    bottomPadding: padding

    contentItem: Item {}
    QtObject {
        id: internal

        property Flickable view: listItem.ListView.view || (listItem.parent ? (listItem.parent.ListView.view || (listItem.parent instanceof Flickable ? listItem.parent : null)) : null)

        function viewHasPropertySwipeFilter(): bool {
            return view && view.parent && view.parent.parent && "_swipeFilter" in view.parent.parent;
        }

        readonly property QtObject swipeFilterItem: (viewHasPropertySwipeFilter() && view.parent.parent._swipeFilter) ? view.parent.parent._swipeFilter : null

        readonly property bool edgeEnabled: swipeFilterItem ? swipeFilterItem.currentItem === listItem || swipeFilterItem.currentItem === listItem.parent : false

        // install the SwipeItemEventFilter
        onViewChanged: {
            if (listItem.alwaysVisibleActions || !Kirigami.Settings.tabletMode) {
                return;
            }
            if (viewHasPropertySwipeFilter() && Kirigami.Settings.tabletMode && !internal.view.parent.parent._swipeFilter) {
                const component = Qt.createComponent(Qt.resolvedUrl("../private/SwipeItemEventFilter.qml"));
                internal.view.parent.parent._swipeFilter = component.createObject(internal.view.parent.parent);
                component.destroy();
            }
        }
    }

    Connections {
        target: Kirigami.Settings
        function onTabletModeChanged() {
            if (!internal.viewHasPropertySwipeFilter()) {
                return;
            }
            if (Kirigami.Settings.tabletMode) {
                if (!internal.swipeFilterItem) {
                    const component = Qt.createComponent(Qt.resolvedUrl("../private/SwipeItemEventFilter.qml"));
                    listItem.ListView.view.parent.parent._swipeFilter = component.createObject(listItem.ListView.view.parent.parent);
                    component.destroy();
                }
            } else {
                if (listItem.ListView.view.parent.parent._swipeFilter) {
                    listItem.ListView.view.parent.parent._swipeFilter.destroy();
                    slideAnim.to = 0;
                    slideAnim.restart();
                }
            }
        }
    }

//BEGIN items
    Loader {
        id: overlayLoader
        readonly property int paddingOffset: (visible ? width : 0) + Kirigami.Units.smallSpacing
        readonly property var theAlias: anchors
        function validate(want, defaultValue) {
            const expectedLeftPadding = () => listItem.padding * 2 + (listItem.mirrored ? overlayLoader.paddingOffset : 0)
            const expectedRightPadding = () => listItem.padding * 2 + (listItem.mirrored ? 0 : overlayLoader.paddingOffset)

            const warningText =
                `Don't override the leftPadding or rightPadding on a SwipeListItem!\n` +
                `This makes it impossible for me to adjust my layout as I need to for various usecases.\n` +
                `I'll try to fix the mistake for you, but you should remove your overrides from your app's code entirely.\n` +
                `If I can't fix the paddings, I'll fall back to a default layout, but it'll be slightly incorrect and lacks\n` +
                `adaptations needed for touch screens and right-to-left languages, among other things.`

            if (listItem.leftPadding != expectedLeftPadding() || listItem.rightPadding != expectedRightPadding()) {
                listItem.leftPadding = Qt.binding(expectedLeftPadding)
                listItem.rightPadding = Qt.binding(expectedRightPadding)
                console.warn(warningText)
                return defaultValue
            }

            return want
        }
        anchors {
            right: validate((Qt.application.layoutDirection === Qt.RightToLeft) ? undefined : (contentItem ? contentItem.right : undefined), contentItem ? contentItem.right : undefined)
            rightMargin: validate(-paddingOffset, 0)
            left: validate((Qt.application.layoutDirection === Qt.LeftToRight) ? undefined : (contentItem ? contentItem.left : undefined), undefined)
            leftMargin: validate(-paddingOffset, 0)
            top: parent.top
            bottom: parent.bottom
        }
        LayoutMirroring.enabled: false

        parent: listItem
        z: contentItem ? contentItem.z + 1 : 0
        width: item ? item.implicitWidth : actionsLayout.implicitWidth
        active: !listItem.alwaysVisibleActions && Kirigami.Settings.tabletMode
        visible: listItem.actionsVisible && opacity > 0
        asynchronous: true
        sourceComponent: handleComponent
        opacity: listItem.alwaysVisibleActions || Kirigami.Settings.tabletMode || listItem.hovered ? 1 : 0
        Behavior on opacity {
            OpacityAnimator {
                id: opacityAnim
                duration: Kirigami.Units.veryShortDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    Component {
        id: handleComponent

        MouseArea {
            id: dragButton
            anchors {
                right: parent.right
            }
            implicitWidth: Kirigami.Units.iconSizes.smallMedium

            preventStealing: true
            readonly property real openPosition: (listItem.width - width - listItem.leftPadding * 2)/listItem.width
            property real startX: 0
            property real lastPosition: 0
            property bool openIntention

            onPressed: mouse => {
                startX = mapToItem(listItem, 0, 0).x;
            }
            onClicked: mouse => {
                if (Math.abs(mapToItem(listItem, 0, 0).x - startX) > Qt.styleHints.startDragDistance) {
                    return;
                }
                if (listItem.LayoutMirroring.enabled) {
                    if (listItem.swipe.position < 0.5) {
                        slideAnim.to = openPosition
                    } else {
                        slideAnim.to = 0
                    }
                } else {
                    if (listItem.swipe.position > -0.5) {
                        slideAnim.to = -openPosition
                    } else {
                        slideAnim.to = 0
                    }
                }
                slideAnim.restart();
            }
            onPositionChanged: mouse => {
                const pos = mapToItem(listItem, mouse.x, mouse.y);

                if (listItem.LayoutMirroring.enabled) {
                    listItem.swipe.position = Math.max(0, Math.min(openPosition, (pos.x / listItem.width)));
                    openIntention = listItem.swipe.position > lastPosition;
                } else {
                    listItem.swipe.position = Math.min(0, Math.max(-openPosition, (pos.x / (listItem.width -listItem.rightPadding) - 1)));
                    openIntention = listItem.swipe.position < lastPosition;
                }
                lastPosition = listItem.swipe.position;
            }
            onReleased: mouse => {
                if (listItem.LayoutMirroring.enabled) {
                    if (openIntention) {
                        slideAnim.to = openPosition
                    } else {
                        slideAnim.to = 0
                    }
                } else {
                    if (openIntention) {
                        slideAnim.to = -openPosition
                    } else {
                        slideAnim.to = 0
                    }
                }
                slideAnim.restart();
            }

            Kirigami.Icon {
                id: handleIcon
                anchors.fill: parent
                selected: listItem.checked || (listItem.down && !listItem.checked && !listItem.sectionDelegate)
                source: (LayoutMirroring.enabled ? (listItem.background.x < listItem.background.width/2 ? "overflow-menu-right" : "overflow-menu-left") : (listItem.background.x < -listItem.background.width/2 ? "overflow-menu-right" : "overflow-menu-left"))
            }

            Connections {
                id: swipeFilterConnection

                target: internal.edgeEnabled ? internal.swipeFilterItem : null
                function onPeekChanged() {
                    if (!listItem.actionsVisible) {
                        return;
                    }

                    if (listItem.LayoutMirroring.enabled) {
                        listItem.swipe.position = Math.max(0, Math.min(dragButton.openPosition, internal.swipeFilterItem.peek));
                        dragButton.openIntention = listItem.swipe.position > dragButton.lastPosition;

                    } else {
                        listItem.swipe.position = Math.min(0, Math.max(-dragButton.openPosition, -internal.swipeFilterItem.peek));
                        dragButton.openIntention = listItem.swipe.position < dragButton.lastPosition;
                    }

                    dragButton.lastPosition = listItem.swipe.position;
                }
                function onPressed(mouse) {
                    if (internal.edgeEnabled) {
                        dragButton.onPressed(mouse);
                    }
                }
                function onClicked(mouse) {
                    if (Math.abs(listItem.background.x) < Kirigami.Units.gridUnit && internal.edgeEnabled) {
                        dragButton.clicked(mouse);
                    }
                }
                function onReleased(mouse) {
                    if (internal.edgeEnabled) {
                        dragButton.released(mouse);
                    }
                }
                function onCurrentItemChanged() {
                    if (!internal.edgeEnabled) {
                        slideAnim.to = 0;
                        slideAnim.restart();
                    }
                }
            }
        }
    }

    // TODO: expose in API?
    Component {
        id: actionsBackgroundDelegate
        MouseArea {

            anchors.fill: parent

            // QQC2.SwipeDelegate.onPressedChanged is broken with touch
            onClicked: mouse => {
                    slideAnim.to = 0;
                    slideAnim.restart();
            }
            Rectangle {
                anchors.fill: parent
                color: parent.pressed ? Qt.darker(Kirigami.Theme.backgroundColor, 1.1) : Qt.darker(Kirigami.Theme.backgroundColor, 1.05)
            }

            visible: listItem.swipe.position != 0


            EdgeShadow {
                edge: Qt.TopEdge
                visible: background.x != 0
                anchors {
                    right: parent.right
                    left: parent.left
                    top: parent.top
                }
            }
            EdgeShadow {
                edge: LayoutMirroring.enabled ? Qt.RightEdge : Qt.LeftEdge
                x: LayoutMirroring.enabled ? listItem.background.x - width : (listItem.background.x + listItem.background.width)
                visible: background.x != 0
                anchors {
                    top: parent.top
                    bottom: parent.bottom
                }
            }
        }
    }


    RowLayout {
        id: actionsLayout
        anchors {
            right: parent.right
            top: parent.top
            bottom: parent.bottom
            rightMargin: Kirigami.Units.smallSpacing
        }
        visible: parent !== listItem
        parent: !listItem.alwaysVisibleActions && Kirigami.Settings.tabletMode
                ? listItem.swipe.leftItem || listItem.swipe.rightItem || listItem
                : overlayLoader

        property bool hasVisibleActions: false
        function updateVisibleActions(definitelyVisible) {
            if (definitelyVisible === undefined) {
                definitelyVisible = false
            }

            if (definitelyVisible) {
                hasVisibleActions = true;
            } else {
                const actionCount = listItem.actions.length;
                for (let i = 0; i < actionCount; i++) {
                    // Assuming that visible is only false if it is explicitly false, and not just falsy
                    if (listItem.actions[i].visible === false) {
                        continue;
                    }
                    hasVisibleActions = true;
                    break;
                }
            }
        }

        Repeater {
            model: {
                if (listItem.actions.length === 0) {
                    return null;
                } else {
                    return listItem.actions[0].text !== undefined &&
                        listItem.actions[0].trigger !== undefined ?
                            listItem.actions :
                            listItem.actions[0];
                }
            }
            delegate: QQC2.ToolButton {
                icon.name: modelData.iconName !== "" ? modelData.iconName : ""
                icon.source: modelData.iconSource !== "" ? modelData.iconSource : ""
                enabled: (modelData && modelData.enabled !== undefined) ? modelData.enabled : true;
                visible: (modelData && modelData.visible !== undefined) ? modelData.visible : true;
                onVisibleChanged: actionsLayout.updateVisibleActions(visible);
                Component.onCompleted: actionsLayout.updateVisibleActions(visible);
                Component.onDestruction: actionsLayout.updateVisibleActions(visible);
                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                QQC2.ToolTip.timeout: 5000
                QQC2.ToolTip.visible: listItem.visible && (Kirigami.Settings.tabletMode ? pressed : hovered) && QQC2.ToolTip.text.length > 0
                QQC2.ToolTip.text: modelData.tooltip || modelData.text

                onClicked: {
                    if (modelData && modelData.trigger !== undefined) {
                        modelData.trigger();
                    }
                    slideAnim.to = 0;
                    slideAnim.restart();
                }

                Accessible.name: modelData.text
                Accessible.description: modelData.tooltip
            }
        }
    }


    background: DefaultListItemBackground {}

    swipe {
        enabled: false
        right: listItem.alwaysVisibleActions || listItem.LayoutMirroring.enabled || !Kirigami.Settings.tabletMode ? null : actionsBackgroundDelegate
        left: listItem.alwaysVisibleActions || listItem.LayoutMirroring.enabled && Kirigami.Settings.tabletMode ? actionsBackgroundDelegate : null
    }
    NumberAnimation {
        id: slideAnim
        duration: Kirigami.Units.longDuration
        easing.type: Easing.InOutQuad
        target: listItem.swipe
        property: "position"
        from: listItem.swipe.position
    }
//END items
}
