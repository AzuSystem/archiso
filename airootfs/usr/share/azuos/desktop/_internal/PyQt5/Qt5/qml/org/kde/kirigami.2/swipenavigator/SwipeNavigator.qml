/*
 *  SPDX-FileCopyrightText: 2020 Carson Black <uhhadd@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12 as QQC2
import org.kde.kirigami 2.13 as Kirigami
import "." as SN


//TODO KF6: remove all of this?
/**
 * @brief SwipeNavigator is a control providing for lateral navigation.
 * @include swipenavigator/main.qml
 * @warning This might be removed in KF6.
 * @inherit QtQuick.Item
 */
Item {
    id: swipeNavigatorRoot

//BEGIN properties
    /**
     * @brief This property holds the pages to swipe between.
     */
    default property list<Kirigami.Page> pages

    /**
     * @brief This property holds the StackView that is holding the core item,
     * which allows users of SwipeNavigator to push pages on top of it.
     *
     * @property QtQuick.Controls.StackView stackView
     */
    property alias layers: stackView

    /**
     * @brief This property sets whether SwipeNavigator should be presented in large format,
     * which is suitable for televisions.
     *
     * default: ``false``
     */
    property bool big: false

    /**
     * @brief This property holds the item that will be displayed before the tabs.
     * @property Item header
     */
    property Component header: Item {visible: false}

    /**
     * @brief This property holds the item that will be displayed after the tabs.
     * @property Item footer
     */
    property Component footer: Item {visible: false}

    /**
     * @brief This property holds the initial tab index of the SwipeNavigator.
     *
     * default: ``0``
     */
    property int initialIndex: 0

    /**
     * @brief This property holds the currently displayed page in the SwipeNavigator.
     * @property int currentIndex
     */
    property alias currentIndex: columnView.currentIndex
//END properties

    /**
     * @brief Pushes a page as a new dialog on desktop and as a layer on mobile.
     * @param page The page can be defined as a component, item or string. If an item is
     *             used then the page will get re-parented. If a string is used then it
     *             is interpreted as a url that is used to load a page component.
     * @param properties The properties given when initializing the page.
     * @param windowProperties The properties given to the initialized window on desktop.
     * @return The newly created page
     */
    function pushDialogLayer(page, properties = {}, windowProperties = {}) {
        let item;
        if (Kirigami.Settings.isMobile) {
            item = layers.push(page, properties);
        } else {
            const windowComponent = Qt.createComponent(Qt.resolvedUrl("./ApplicationWindow.qml"));
            if (!windowProperties.modality) {
                windowProperties.modality = Qt.WindowModal;
            }
            if (!windowProperties.height) {
                windowProperties.height = Kirigami.Units.gridUnit * 30;
            }
            if (!windowProperties.width) {
                windowProperties.width = Kirigami.Units.gridUnit * 50;
            }
            if (!windowProperties.minimumWidth) {
                windowProperties.minimumWidth = Kirigami.Units.gridUnit * 20;
            }
            if (!windowProperties.minimumHeight) {
                windowProperties.minimumHeight = Kirigami.Units.gridUnit * 15;
            }
            if (!windowProperties.flags) {
                windowProperties.flags = Qt.Dialog | Qt.WindowCloseButtonHint;
            }
            const window = windowComponent.createObject(swipeNavigatorRoot, windowProperties);
            windowComponent.destroy();
            item = window.pageStack.push(page, properties);
        }
        item.Keys.escapePressed.connect(event => item.closeDialog());
        return item;
    }

    implicitWidth: stackView.implicitWidth
    implicitHeight: stackView.implicitHeight

    QtObject {
        id: _gridManager
        readonly property bool tall: (_header.width + __main.implicitWidth + Math.abs(__main.offset) + _footer.width) > swipeNavigatorRoot.width
        readonly property int rowOne: Kirigami.Settings.isMobile ? 1 : 0
        readonly property int rowTwo: Kirigami.Settings.isMobile ? 0 : 1
        readonly property int rowDirection: Kirigami.Settings.isMobile ? 1 : -1
        property Item item: Item {
            states: [
                State {
                    name: "small"
                    when: !_gridManager.tall
                },
                State {
                    name: "tall"
                    when: _gridManager.tall
                }
            ]
            transitions: [
                Transition {
                    to: "tall"
                    ScriptAction {
                        script: {
                            // Let's take these out of the layout first...
                            _dummyOne.visible = false
                            _dummyTwo.visible = false
                            // Now we move the header and footer up
                            _header.Layout.row += _gridManager.rowDirection
                            _footer.Layout.row += _gridManager.rowDirection
                            // Now that the header and footer are out of the way,
                            // let's expand the tabs
                            __main.Layout.column--
                            __main.Layout.columnSpan = 3
                        }
                    }
                },
                Transition {
                    to: "small"
                    ScriptAction {
                        script: {
                            // Let's move the tabs back to where they belong
                            __main.Layout.columnSpan = 1
                            __main.Layout.column++
                            // Move the header and footer down into the empty space
                            _header.Layout.row -= _gridManager.rowDirection
                            _footer.Layout.row -= _gridManager.rowDirection

                            // Now we can bring these guys back in
                            _dummyOne.visible = false
                            _dummyTwo.visible = false
                        }
                    }
                }
            ]
        }
    }


    QQC2.StackView {
        id: stackView

        anchors.fill: parent

        function clear() {
            // don't let it kill the main page row
            const d = stackView.depth;
            for (let i = 1; i < d; ++i) {
                pop();
            }
        }

        initialItem: SN.TabViewLayout {
            bar: QQC2.ToolBar {
                id: topToolBar

                padding: 0
                bottomPadding: 1

                GridLayout {
                    id: _grid

                    rowSpacing: 0
                    columnSpacing: 0
                    anchors.fill: parent
                    rows: 2
                    columns: 3

                    // Row one
                    Item {
                        id: _spacer
                        Layout.row: 0
                        Layout.column: 1
                        Layout.fillWidth: true
                    }
                    Item {
                        id: _dummyOne
                        Layout.row: 0
                        Layout.column: 0
                    }
                    Item {
                        id: _dummyTwo
                        Layout.row: 0
                        Layout.column: 2
                    }

                    // Row two
                    Loader {
                        id: _header
                        sourceComponent: swipeNavigatorRoot.header
                        Layout.row: 1
                        Layout.column: 0
                    }
                    SN.PrivateSwipeTabBar {
                        id: __main
                        readonly property int offset: _header.width - _footer.width
                        readonly property int effectiveOffset: _gridManager.tall ? 0 : offset
                        Layout.rightMargin: effectiveOffset > 0 ? effectiveOffset : 0
                        Layout.leftMargin: effectiveOffset < 0 ? -effectiveOffset : 0
                        Layout.fillHeight: true
                        Layout.fillWidth: true//Kirigami.Settings.isMobile && swipeNavigatorRoot.height > swipeNavigatorRoot.width
                        Layout.alignment: Qt.AlignHCenter
                        Layout.row: 1
                        Layout.column: 1

                    }
                    Loader {
                        id: _footer
                        sourceComponent: swipeNavigatorRoot.footer
                        Layout.row: 1
                        Layout.column: 2
                    }
                }

                Accessible.role: Accessible.PageTabList
            }
            contentItem: Kirigami.ColumnView {
                id: columnView
                Layout.fillWidth: true
                Layout.fillHeight: true
                Layout.row: Kirigami.Settings.isMobile ? 0 : 1

                columnResizeMode: Kirigami.ColumnView.SingleColumn

                contentChildren: swipeNavigatorRoot.pages

                Component.onCompleted: {
                    columnView.currentIndex = swipeNavigatorRoot.initialIndex
                }
                // We only want the current page to be focusable, so we
                // disable the inactive pages.
                onCurrentIndexChanged: {
                    Array.from(swipeNavigatorRoot.pages).forEach(item => item.enabled = false)
                    swipeNavigatorRoot.pages[currentIndex].enabled = true
                }
            }
        }
        popEnter: Transition {
            OpacityAnimator {
                from: 0
                to: 1
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }
        popExit: Transition {
            ParallelAnimation {
                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutCubic
                }
                YAnimator {
                    from: 0
                    to: height/2
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InCubic
                }
            }
        }

        pushEnter: Transition {
            ParallelAnimation {
                // NOTE: It's a PropertyAnimation instead of an Animator because with an animator the item will be visible for an instant before starting to fade
                PropertyAnimation {
                    property: "opacity"
                    from: 0
                    to: 1
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutCubic
                }
                YAnimator {
                    from: height/2
                    to: 0
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.OutCubic
                }
            }
        }


        pushExit: Transition {
            OpacityAnimator {
                from: 1
                to: 0
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutCubic
            }
        }

        replaceEnter: Transition {
            ParallelAnimation {
                OpacityAnimator {
                    from: 0
                    to: 1
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutCubic
                }
                YAnimator {
                    from: height/2
                    to: 0
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.OutCubic
                }
            }
        }

        replaceExit: Transition {
            ParallelAnimation {
                OpacityAnimator {
                    from: 1
                    to: 0
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InCubic
                }
                YAnimator {
                    from: 0
                    to: -height/2
                    duration: Kirigami.Units.longDuration
                    easing.type: Easing.InOutCubic
                }
            }
        }
    }
}
