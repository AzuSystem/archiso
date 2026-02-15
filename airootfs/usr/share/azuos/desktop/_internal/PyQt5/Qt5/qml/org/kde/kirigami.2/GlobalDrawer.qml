/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Templates 2.3 as T2
import QtQuick.Controls 2.2 as QQC2
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.13 as Kirigami
import "private" as P

/**
 * A specialized form of the QtQuick.Controls.Drawer intended for showing an application's
 * always-available global actions. Think of it like a mobile version of
 * a desktop application's menubar.
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
 *  [...]
 * }
 * @endcode
 * @see <a href="https://develop.kde.org/docs/getting-started/kirigami/components-drawers/#global-drawer">Global Drawers in Kirigami</a>
 * @see <a href="https://develop.kde.org/hig/components/navigation/globaldrawer">Human Interface Guidelines on Global Drawers</a>
 * @see <a href="https://develop.kde.org/hig/patterns-command/drawer/#global-drawer">KDE Human Interface Guidelines' Short Introduction of Global Drawers</a>
 */
OverlayDrawer {
    id: root
    edge: Qt.application.layoutDirection === Qt.RightToLeft ? Qt.RightEdge : Qt.LeftEdge
    handleClosedIcon.source: null
    handleOpenIcon.source: null
    handleVisible: (modal || !drawerOpen) && (typeof(applicationWindow)===typeof(Function) && applicationWindow() ? applicationWindow().controlsVisible : true) && (!isMenu || Kirigami.Settings.isMobile)

    enabled: !isMenu || Kirigami.Settings.isMobile

//BEGIN properties
    /**
     * @brief This property holds the title displayed at the top of the drawer.
     * @see kirigami::private::BannerImage::title
     * @property string title
     */
    property alias title: bannerImage.title

    /**
     * @brief This property holds an icon to be displayed alongside the title.
     * @see kirigami::private::BannerImage::titleIcon
     * @see Icon::source
     * @property var titleIcon
     */
    property alias titleIcon: bannerImage.titleIcon

    /**
     * @brief This property holds the banner image source.
     * @see kirigami::ShadowedImage::source
     * @property url bannerImageSource
     */
    property alias bannerImageSource: bannerImage.source

    /**
     * @brief This property holds the actions displayed in the drawer.
     *
     * The list of actions can be nested having a tree structure.
     * A tree depth bigger than 2 is discouraged.
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
     *                    text: "action 1"
     *                }
     *                Kirigami.Action {
     *                    text: "action 2"
     *                }
     *                Kirigami.Action {
     *                    text: "action 3"
     *                }
     *            },
     *            Kirigami.Action {
     *                text: "Sync"
     *                icon.name: "folder-sync"
     *            }
     *         ]
     *     }
     *  [...]
     * }
     * @endcode
     * @property list<Action> actions
     */
    property list<QtObject> actions

    /**
     * @brief This property holds an item that will always be displayed at the top of the drawer.
     *
     * If the drawer contents can be scrolled, this item will stay still and won't scroll.
     *
     * @note This property is mainly intended for toolbars.
     * @since org.kde.kirigami 2.12
     */
    property Item header

    /**
     * @brief This property sets drawers banner visibility.
     *
     * If true, the banner area (which can contain an image,
     * an icon, and a title) will be visible.
     *
     * default: `the banner will be visible only on mobile platforms`
     *
     * @since org.kde.kirigami 2.12
     */
    property bool bannerVisible: Kirigami.Settings.isMobile

    /**
     * @brief This property holds items that are displayed above the actions.
     *
     * Example usage:
     * @code{.qml}
     * import org.kde.kirigami 2.4 as Kirigami
     *
     * Kirigami.ApplicationWindow {
     *  [...]
     *     globalDrawer: Kirigami.GlobalDrawer {
     *         actions: [...]
     *         topContent: [Button {
     *             text: "Button"
     *             onClicked: //do stuff
     *         }]
     *     }
     *  [...]
     * }
     * @endcode
     * @property list<QtObject> topContent
     */
    property alias topContent: topContent.data

    /**
     * @brief This property holds items that are displayed under the actions.
     *
     * Example usage:
     * @code{.qml}
     * import org.kde.kirigami 2.4 as Kirigami
     *
     * Kirigami.ApplicationWindow {
     *  [...]
     *     globalDrawer: Kirigami.GlobalDrawer {
     *         actions: [...]
     *         Button {
     *             text: "Button"
     *             onClicked: //do stuff
     *         }
     *     }
     *  [...]
     * }
     * @endcode
     * @note This is a `default` property.
     * @property list<QtObject> content
     */
    default property alias content: mainContent.data

    /**
     * @brief This property sets whether content items at the top should be shown.
     * when the drawer is collapsed as a sidebar.
     *
     * If you want to keep some items visible and some invisible, set this to
     * @c false and control the visibility/opacity of individual items,
     * binded to the OverlayDrawer.collapsed property.
     *
     * default: ``false``
     *
     * @since org.kde.kirigami 2.5
     */
    property bool showTopContentWhenCollapsed: false

    /**
     * @brief This property sets whether content items at the bottom should be shown.
     * when the drawer is collapsed as a sidebar.
     *
     * If you want to keep some items visible and some invisible, set this to
     * @c false and control the visibility/opacity of individual items,
     * binded to the collapsed property
     *
     * default: ``false``
     *
     * @see ::content
     * @since org.kde.kirigami 2.5
     */
    property bool showContentWhenCollapsed: false

    // TODO
    property bool showHeaderWhenCollapsed: false

    /**
     * @brief This property sets whether activating a leaf action resets the
     * menu to show leaf's parent actions.
     * 
     * A leaf action is an action without any child actions.
     *
     * default: ``true``
     */
    property bool resetMenuOnTriggered: true

    /**
     * @brief This property points to the action acting as a submenu
     */
    readonly property Action currentSubMenu: stackView.currentItem ? stackView.currentItem.current: null

    /**
     * @brief This property sets whether the drawer becomes a menu on the desktop.
     *
     * default: ``false``
     *
     * @since org.kde.kirigami 2.11
     */
    property bool isMenu: false

    /**
     * @brief This property sets the visibility of the collapse button
     * when the drawer collapsible.
     *
     * default: ``true``
     *
     * @since org.kde.kirigami 2.12
     */
    property bool collapseButtonVisible: true
//END properties

    /**
     * @brief This signal notifies that the banner has been clicked.
     */
    signal bannerClicked()

    /**
     * @brief This function reverts the menu back to its initial state
     */
    function resetMenu() {
        stackView.pop(stackView.get(0, T2.StackView.DontLoad));
        if (root.modal) {
            root.drawerOpen = false;
        }
    }

    // rightPadding: !Kirigami.Settings.isMobile && mainFlickable.contentHeight > mainFlickable.height ? Kirigami.Units.gridUnit : Kirigami.Units.smallSpacing

    Kirigami.Theme.colorSet: modal ? Kirigami.Theme.Window : Kirigami.Theme.View

    onHeaderChanged: {
        if (header) {
            header.parent = headerContainer
            header.Layout.fillWidth = true;
            if (header.z === undefined) {
                header.z = 1;
            }
            if (header instanceof T2.ToolBar) {
                header.position = T2.ToolBar.Header
            } else if (header instanceof T2.TabBar) {
                header.position = T2.TabBar.Header
            } else if (header instanceof T2.DialogButtonBox) {
                header.position = T2.DialogButtonBox.Header
            }
        }
    }

    contentItem: QQC2.ScrollView {
        id: scrollView
        //ensure the attached property exists
        Kirigami.Theme.inherit: true
        anchors.fill: parent
        implicitWidth: Math.min (Kirigami.Units.gridUnit * 20, root.parent.width * 0.8)
        QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff
        QQC2.ScrollBar.vertical.anchors {
            top: scrollView.top
            bottom: scrollView.bottom
            topMargin: headerParent.height + headerParent.y
        }

        Flickable {
            id: mainFlickable
            contentWidth: width
            contentHeight: mainColumn.Layout.minimumHeight
            topMargin: headerParent.height

            ColumnLayout {
                id: headerParent
                parent: mainFlickable
                anchors {
                    left: parent.left
                    right: parent.right
                    rightMargin: Math.min(0, -scrollView.width + mainFlickable.width)
                }
                spacing: 0
                y: bannerImage.visible ? Math.max(headerContainer.height, -mainFlickable.contentY) - height : 0

                Layout.fillWidth: true
                // visible: !bannerImage.empty || root.collapsible

                P.BannerImage {
                    id: bannerImage


                    visible: !bannerImage.empty && opacity > 0 && root.bannerVisible
                    opacity: !root.collapsed
                    fillMode: Image.PreserveAspectCrop

                    Behavior on opacity {
                        OpacityAnimator {
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                    // leftPadding: root.collapsible ? collapseButton.width + Kirigami.Units.smallSpacing*2 : topPadding
                    MouseArea {
                        anchors.fill: parent
                        onClicked: mouse => root.bannerClicked()
                    }
                    P.EdgeShadow {
                        edge: Qt.BottomEdge
                        visible: bannerImageSource != ""
                        anchors {
                            left: parent.left
                            right: parent.right
                            bottom: parent.top
                        }
                    }
                }
                RowLayout {
                    id: headerContainer
                    Kirigami.Theme.inherit: false
                    Kirigami.Theme.colorSet: Kirigami.Theme.Window

                    Layout.fillWidth: true
                    visible: opacity > 0
                    // Workaround for https://bugreports.qt.io/browse/QTBUG-90034
                    Layout.preferredHeight: {
                        if (children.length > 0 && children[0].visible) {
                            if (opacity === 1) {
                                return -1;
                            } else {
                                return implicitHeight * opacity;
                            }
                        } else {
                            return 0;
                        }
                    }
                    opacity: !root.collapsed || showHeaderWhenCollapsed
                    Behavior on opacity {
                        // not an animator as is binded
                        NumberAnimation {
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
            }


            ColumnLayout {
                id: mainColumn
                width: mainFlickable.width
                spacing: 0
                height: Math.max(root.height - headerParent.height, Layout.minimumHeight)

                ColumnLayout {
                    id: topContent
                    spacing: 0
                    Layout.alignment: Qt.AlignHCenter
                    Layout.leftMargin: root.leftPadding
                    Layout.rightMargin: root.rightPadding
                    Layout.bottomMargin: Kirigami.Units.smallSpacing
                    Layout.topMargin: root.topPadding
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    Layout.preferredHeight: implicitHeight * opacity
                    // NOTE: why this? just Layout.fillWidth: true doesn't seem sufficient
                    // as items are added only after this column creation
                    Layout.minimumWidth: parent.width - root.leftPadding - root.rightPadding
                    visible: children.length > 0 && childrenRect.height > 0 && opacity > 0
                    opacity: !root.collapsed || showTopContentWhenCollapsed
                    Behavior on opacity {
                        // not an animator as is binded
                        NumberAnimation {
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                }

                T2.StackView {
                    id: stackView
                    clip: true
                    Layout.fillWidth: true
                    Layout.minimumHeight: currentItem ? currentItem.implicitHeight : 0
                    Layout.maximumHeight: Layout.minimumHeight
                    property P.ActionsMenu openSubMenu
                    initialItem: menuComponent
                    // NOTE: it's important those are NumberAnimation and not XAnimators
                    // as while the animation is running the drawer may close, and
                    // the animator would stop when not drawing see BUG 381576
                    popEnter: Transition {
                        NumberAnimation { property: "x"; from: (stackView.mirrored ? -1 : 1) * -stackView.width; to: 0; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
                    }

                    popExit: Transition {
                        NumberAnimation { property: "x"; from: 0; to: (stackView.mirrored ? -1 : 1) * stackView.width; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
                    }

                    pushEnter: Transition {
                        NumberAnimation { property: "x"; from: (stackView.mirrored ? -1 : 1) * stackView.width; to: 0; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
                    }

                    pushExit: Transition {
                        NumberAnimation { property: "x"; from: 0; to: (stackView.mirrored ? -1 : 1) * -stackView.width; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
                    }

                    replaceEnter: Transition {
                        NumberAnimation { property: "x"; from: (stackView.mirrored ? -1 : 1) * stackView.width; to: 0; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
                    }

                    replaceExit: Transition {
                        NumberAnimation { property: "x"; from: 0; to: (stackView.mirrored ? -1 : 1) * -stackView.width; duration: Kirigami.Units.veryLongDuration; easing.type: Easing.OutCubic }
                    }
                }
                Item {
                    Layout.fillWidth: true
                    Layout.fillHeight: root.actions.length>0
                    Layout.minimumHeight: Kirigami.Units.smallSpacing
                }

                ColumnLayout {
                    id: mainContent
                    Layout.alignment: Qt.AlignHCenter
                    Layout.leftMargin: root.leftPadding
                    Layout.rightMargin: root.rightPadding
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    // NOTE: why this? just Layout.fillWidth: true doesn't seem sufficient
                    // as items are added only after this column creation
                    Layout.minimumWidth: parent.width - root.leftPadding - root.rightPadding
                    visible: children.length > 0 && (opacity > 0 || mainContentAnimator.running)
                    opacity: !root.collapsed || showContentWhenCollapsed
                    Behavior on opacity {
                        OpacityAnimator {
                            id: mainContentAnimator
                            duration: Kirigami.Units.longDuration
                            easing.type: Easing.InOutQuad
                        }
                    }
                }
                Item {
                    Layout.minimumWidth: Kirigami.Units.smallSpacing
                    Layout.minimumHeight: root.bottomPadding
                }

                Component {
                    id: menuComponent

                    Column {
                        spacing: 0
                        property alias model: actionsRepeater.model
                        property Action current

                        property int level: 0
                        Layout.maximumHeight: Layout.minimumHeight

                        BasicListItem {
                            id: backItem
                            visible: level > 0
                            icon: (LayoutMirroring.enabled ? "go-previous-symbolic-rtl" : "go-previous-symbolic")

                            label: Kirigami.MnemonicData.richTextLabel
                            Kirigami.MnemonicData.enabled: backItem.enabled && backItem.visible
                            Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.MenuItem
                            Kirigami.MnemonicData.label: qsTr("Back")

                            separatorVisible: false
                            onClicked: stackView.pop()

                            Keys.onEnterPressed: stackView.pop()
                            Keys.onReturnPressed: stackView.pop()

                            Keys.onDownPressed: nextItemInFocusChain().focus = true
                            Keys.onUpPressed: nextItemInFocusChain(false).focus = true
                        }
                        Shortcut {
                            sequence: backItem.Kirigami.MnemonicData.sequence
                            onActivated: backItem.clicked()
                        }

                        Repeater {
                            id: actionsRepeater

                            readonly property bool withSections: {
                                for (let i = 0; i < root.actions.length; i++) {
                                    const action = root.actions[i];
                                    if (!(action.hasOwnProperty("expandible") && action.expandible)) {
                                        return false;
                                    }
                                }
                                return true;
                            }

                            model: root.actions
                            delegate: Column {
                                width: parent.width
                                P.GlobalDrawerActionItem {
                                    id: drawerItem
                                    visible: (modelData.hasOwnProperty("visible") && modelData.visible) && (root.collapsed || !(modelData.hasOwnProperty("expandible") && modelData.expandible))
                                    width: parent.width
                                    onCheckedChanged: {
                                        // move every checked item into view
                                        if (checked && topContent.height + backItem.height + (model.index + 1) * height - mainFlickable.contentY > mainFlickable.height) {
                                            mainFlickable.contentY += height
                                        }
                                    }
                                    Kirigami.Theme.colorSet: drawerItem.visible && !root.modal && !root.collapsed && actionsRepeater.withSections ? Kirigami.Theme.Window : parent.Kirigami.Theme.colorSet
                                    backgroundColor: Kirigami.Theme.backgroundColor
                                }
                                Item {
                                    id: headerItem
                                    visible: !root.collapsed && (modelData.hasOwnProperty("expandible") && modelData.expandible && !!modelData.children && modelData.children.length > 0)
                                    height: sectionHeader.implicitHeight
                                    width: parent.width
                                    Kirigami.ListSectionHeader {
                                        id: sectionHeader
                                        anchors.fill: parent
                                        Kirigami.Theme.colorSet: root.modal ? Kirigami.Theme.View : Kirigami.Theme.Window
                                        contentItem: RowLayout {
                                            Kirigami.Icon {
                                                property int size: Kirigami.Units.iconSizes.smallMedium
                                                Layout.minimumHeight: size
                                                Layout.maximumHeight: size
                                                Layout.minimumWidth: size
                                                Layout.maximumWidth: size
                                                source: modelData.icon.name || modelData.icon.source
                                            }
                                            Heading {
                                                id: header
                                                level: 4
                                                text: modelData.text
                                            }
                                            Item {
                                                Layout.fillWidth: true
                                            }
                                        }
                                    }
                                }
                                Repeater {
                                    id: __repeater
                                    model: headerItem.visible ? modelData.children : null
                                    delegate: P.GlobalDrawerActionItem {
                                        width: parent.width
                                        opacity: !root.collapsed
                                        leftPadding: actionsRepeater.withSections && !root.collapsed && !root.modal ? padding * 2 : padding * 4
                                    }
                                }
                            }
                        }
                    }
                }

                QQC2.ToolButton {
                    icon.name: root.collapsed ? "view-right-new" : "view-right-close"
                    Layout.fillWidth: root.collapsed
                    onClicked: root.collapsed = !root.collapsed
                    visible: root.collapsible && root.collapseButtonVisible
                    text: root.collapsed ? "" : qsTr("Close Sidebar")

                    QQC2.ToolTip.visible: root.collapsed && hovered
                    QQC2.ToolTip.text: qsTr("Open Sidebar")
                    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                }
            }
        }
    }
}

