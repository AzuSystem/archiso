/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.5
import QtQuick.Layouts 1.2
import QtQuick.Templates 2.1 as T2
import QtQuick.Controls 2.1 as QQC2
import org.kde.kirigami 2.10 as Kirigami
import "private" as P

/**
 * Page is a container for all the app pages: everything pushed to the
 * @link ApplicationWindow::pageStack pageStack @endlink should be a Page.
 *
 * For content that should be scrollable, such as QtQuick.ListView, use ScrollablePage instead.
 * @inherit QtQuick.Controls.Page
 */
QQC2.Page {
    id: root

//BEGIN properties
    /**
     * @brief If the central element of the page is a Flickable
     * (ListView and Gridview as well) you can set it there.
     *
     * Normally, you wouldn't need to do that, but just use the
     * ScrollablePage element instead.
     *
     * Use this if your flickable has some non standard properties,
     * such as not covering the whole Page.
     *
     * @see kirigami::ScrollablePage
     */
    property Flickable flickable

    /**
     * @brief Defines the contextual actions for the page:
     * an easy way to assign actions in the right sliding panel
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
     * @warning This will be removed in KF6.
     * @property list<QtQml.QtObject> contextualActions
     */
    // TODO: remove
    property alias contextualActions: actionsGroup.contextualActions

    /**
     * @brief An optional single action for the action button.
     *
     * Example usage:
     * @code{.qml}
     * import org.kde.kirigami 2.4 as Kirigami
     * Kirigami.Page {
     *     actions.main: Kirigami.Action {
     *         icon.name: "edit"
     *         onTriggered: {
     *             // do stuff
     *         }
     *     }
     * }
     * @endcode
     * @warning This will be removed in KF6.
     * @property Action mainAction
     */
    //TODO: remove
    property alias mainAction: actionsGroup.main

    /**
     * @brief An optional extra action at the left of the main action button.
     *
     * Example usage:
     * @code{.qml}
     * import org.kde.kirigami 2.4 as Kirigami
     * Kirigami.Page {
     *     actions.left: Kirigami.Action {
     *         icon.name: "edit"
     *         onTriggered: {
     *             // do stuff
     *         }
     *     }
     * }
     * @endcode
     * @warning This will be removed in KF6.
     * @property Action leftAction
     */
    // TODO: remove
    property alias leftAction: actionsGroup.left

    /**
     * @brief An optional extra action at the right of the main action button.
     *
     * Example usage:
     * @code{.qml}
     * import org.kde.kirigami 2.4 as Kirigami
     * Kirigami.Page {
     *     actions.right: Kirigami.Action {
     *         icon.name: "edit"
     *         onTriggered: {
     *             // do stuff
     *         }
     *     }
     * }
     * @endcode
     * @warning This will be removed in KF6.
     * @property Action rightAction
     */
    // TODO: remove
    property alias rightAction: actionsGroup.right

    /**
     * @brief This property holds the actions group.
     * @code
     * import org.kde.kirigami 2.4 as Kirigami
     * Kirigami.Page {
     *     actions {
     *         main: Kirigami.Action {...}
     *         left: Kirigami.Action {...}
     *         right: Kirigami.Action {...}
     *         contextualActions: [
     *             Kirigami.Action {...},
     *             Kirigami.Action {...}
     *         ]
     *     }
     * }
     * @endcode
     * @see <a href="https://develop.kde.org/hig/components/navigation/actionbutton">KDE Human Interface Guidelines on Actions</a>
     * @property kirigami::private::PageActionPropertyGroup actions
     */
    readonly property alias actions: actionsGroup

    /**
     * @brief This property specifies us if it is the currently active page.
     *
     * Specifies if it's the currently selected page in the window's pages
     * row, or if layers are used whether this is the topmost item on the
     * layers stack. If the page is not attached to either a column view or
     * a stack view, expect this to be true.
     *
     * @since org.kde.kirigami 2.1
     */
    //TODO KF6: remove this or at least all the assumptions about the internal tree structure of items
    readonly property bool isCurrentPage: Kirigami.ColumnView.view
            ? (Kirigami.ColumnView.index === Kirigami.ColumnView.view.currentIndex && Kirigami.ColumnView.view.parent.parent.currentItem === Kirigami.ColumnView.view.parent)
            : (parent && parent instanceof QQC2.StackView
                ? parent.currentItem === root
                : true)

    /**
     * An item which stays on top of every other item in the page,
     * if you want to make sure some elements are completely in a
     * layer on top of the whole content, parent items to this one.
     * It's a "local" version of ApplicationWindow's overlay
     *
     * @property Item overlay
     * @since org.kde.kirigami 2.5
     */
    readonly property alias overlay: overlayItem

    /**
     * @brief This holds the icon that represents this page.
     */
    property P.ActionIconGroup icon: P.ActionIconGroup {}

    /**
     * @brief Whether this page needs user attention.
     */
    property bool needsAttention

    /**
     * @brief Progress of a task this page is doing.
     *
     * Set to undefined to indicate that there are no ongoing tasks.
     *
     * default: ``undefined``
     *
     * @property real progress
     */
    property var progress: undefined

    /**
     * @brief The delegate which will be used to draw the page title.
     *
     * It can be customized to put any kind of Item in there.
     *
     * @since org.kde.kirigami 2.7
     */
    property Component titleDelegate: Component {
        id: defaultTitleDelegate
        P.DefaultPageTitleDelegate {
            text: root.title
        }
    }

    /**
     * The item used as global toolbar for the page
     * present only if we are in a PageRow as a page or as a layer,
     * and the style is either Titles or ToolBar.
     *
     * @since org.kde.kirigami 2.5
     */
    readonly property Item globalToolBarItem: globalToolBar.item

    /**
     * @brief This property holds the style for the automatically generated
     * toolbar of the PageRow where the Page is inserted.
     *
     * By default, the Page's globalToolBarStyle determines the style used by
     * the PageRow where it is inserted, updating the PageRow's globalToolBar
     * style. This allows for a single page to override the application toolbar
     * style for itself.
     *
     * It is discouraged to use this, except in very specific cases, like a
     * chat application that can't have controls at the bottom except for a
     * text field. If the Page is not in a PageRow, by default, the toolbar
     * will be invisible, so Page::globalToolBarStyle has to be explicitly
     * set to ApplicationHeaderStyle.ToolBar to be used in that case.
     */
    property int globalToolBarStyle: {
        if (globalToolBar.row && !globalToolBar.stack) {
            return globalToolBar.row.globalToolBar.actualStyle;
        } else if (globalToolBar.stack) {
            return Kirigami.Settings.isMobile ? Kirigami.ApplicationHeaderStyle.Titles : Kirigami.ApplicationHeaderStyle.ToolBar;
        } else {
            return Kirigami.ApplicationHeaderStyle.None;
        }
    }
//END properties

//BEGIN signals and signal handlers
    /**
     * Emitted when a visualization for the actions is about to
     * be shown, such as the toolbar menu or the ContextDrawer.
     *
     * @since org.kde.kirigami 2.7
     */
    signal contextualActionsAboutToShow

    /**
     * @brief Emitted when the application requests a Back action.
     *
     * For instance a global "back" shortcut or the Android
     * Back button has been pressed.
     * The page can manage the back event by itself,
     * and if it set event.accepted = true, it will stop the main
     * application to manage the back event.
     */
    signal backRequested(var event);


    // Look for sheets and cose them
    // FIXME: port Sheets to Popup?
    onBackRequested: event => {
        let item;
        for (const i in root.resources) {
            item = root.resources[i];
            if (item.hasOwnProperty("close") && item.hasOwnProperty("sheetOpen") && item.sheetOpen) {
                item.close()
                event.accepted = true;
                return;
            }
        }
    }

    onHeaderChanged: {
        if (header) {
            header.anchors.top = Qt.binding(() => globalToolBar.visible ? globalToolBar.bottom : root.top);
        }
    }

    Component.onCompleted: {
        headerChanged();
        parentChanged(root.parent);
        globalToolBar.syncSource();
        actionButtons.pageComplete = true
    }

    onParentChanged: {
        if (!parent) {
            return;
        }
        globalToolBar.stack = null;
        globalToolBar.row = null;

        if (root.Kirigami.ColumnView.view) {
            globalToolBar.row = root.Kirigami.ColumnView.view.__pageRow;
        }
        if (root.T2.StackView.view) {
            globalToolBar.stack = root.T2.StackView.view;
            globalToolBar.row = root.T2.StackView.view ? root.T2.StackView.view.parent : null;
        }
        if (globalToolBar.row) {
            root.globalToolBarStyleChanged.connect(globalToolBar.syncSource);
            globalToolBar.syncSource();
        }
    }
//END signals and signal handlers

    // NOTE: contentItem will be created if not existing (and contentChildren of Page would become its children) This with anchors enforces the geometry we want, where globalToolBar is a super-header, on top of header
    contentItem: Item {
        anchors {
            top: (root.header && root.header.visible)
                    ? root.header.bottom
                    : (globalToolBar.visible ? globalToolBar.bottom : parent.top)
            topMargin: root.topPadding + root.spacing
            bottom: (root.footer && root.footer.visible) ? root.footer.top : parent.bottom
            bottomMargin: root.bottomPadding + root.spacing
        }
    }

    background: Rectangle {
        color: Kirigami.Theme.backgroundColor
    }

    implicitHeight: ((header && header.visible) ? header.implicitHeight : 0) + ((footer && footer.visible) ? footer.implicitHeight : 0) + contentItem.implicitHeight + topPadding + bottomPadding
    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding

    // FIXME: on material the shadow would bleed over
    clip: root.header !== null;

    padding: Kirigami.Units.gridUnit
    bottomPadding: actionButtons.item ? actionButtons.height : verticalPadding

    // in data in order for them to not be considered for contentItem, contentChildren, contentData
    data: [
        P.PageActionPropertyGroup {
            id: actionsGroup
        },

        Item {
            id: overlayItem
            parent: root
            z: 9997
            anchors {
                fill: parent
                topMargin: globalToolBar.height
            }
        },
        // global top toolbar if we are in a PageRow (in the row or as a layer)
        Loader {
            id: globalToolBar
            z: 9999
            height: item ? item.implicitHeight : 0
            anchors {
                left:  parent.left
                right: parent.right
                top: parent.top
            }
            property Kirigami.PageRow row
            property T2.StackView stack

            // don't load async so that on slower devices we don't have the page content height changing while loading in
            // otherwise, it looks unpolished and jumpy
            asynchronous: false

            visible: active
            active: (root.titleDelegate !== defaultTitleDelegate || root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar || root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.Titles)
            onActiveChanged: {
                if (active) {
                    syncSource();
                }
            }

            function syncSource() {
                if (root.globalToolBarStyle !== Kirigami.ApplicationHeaderStyle.ToolBar &&
                    root.globalToolBarStyle !== Kirigami.ApplicationHeaderStyle.Titles &&
                    root.titleDelegate !== defaultTitleDelegate) {
                    sourceComponent = root.titleDelegate;
                } else if (active) {
                    const url = root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar
                        ? "private/globaltoolbar/ToolBarPageHeader.qml"
                        : "private/globaltoolbar/TitlesPageHeader.qml";
                    // TODO: find container reliably, remove assumption
                    setSource(Qt.resolvedUrl(url), {
                        pageRow: Qt.binding(() => row),
                        page: root,
                        current: Qt.binding(() => {
                            if (!row && !stack) {
                                return true;
                            } else if (stack) {
                                return stack;
                            } else {
                                return row.currentIndex === root.Kirigami.ColumnView.level;
                            }
                        }),
                    });
                }
            }
        },
        // bottom action buttons
        Loader {
            id: actionButtons
            z: 9999
            parent: root
            anchors {
                left: parent.left
                right: parent.right
                bottom: parent.bottom
            }
            // if the page doesn't inherit, assume it has custom colors we want to use them here too
            Kirigami.Theme.inherit: !root.Kirigami.Theme.inherit
            Kirigami.Theme.colorSet: Kirigami.Theme.Button

            // It should be T2.Page, Qt 5.7 doesn't like it
            property Item page: root
            height: item ? item.implicitHeight : 0

            asynchronous: true

            property bool pageComplete: false

            active: {
                // Important! Do not do anything until the page has been
                // completed, so we are sure what the globalToolBarStyle is,
                // otherwise we risk creating the content and then discarding it.
                if (!pageComplete) {
                    return false;
                }

                if ((globalToolBar.row && globalToolBar.row.globalToolBar.actualStyle === Kirigami.ApplicationHeaderStyle.ToolBar)
                    || root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar
                    || root.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.None) {
                    return false;
                }

                if (!root.actions.main && !root.actions.left && !root.actions.right && root.actions.contextualActions.length === 0) {
                    return false;
                }

                // Legacy
                if (typeof applicationWindow === "undefined") {
                    return true;
                }

                if (applicationWindow().header && applicationWindow().header.toString().indexOf("ToolBarApplicationHeader") !== -1) {
                    return false;
                }

                if (applicationWindow().footer && applicationWindow().footer.toString().indexOf("ToolBarApplicationHeader") !== -1) {
                    return false;
                }

                return true;
            }

            source: Qt.resolvedUrl("./private/ActionButton.qml")
        }
    ]

    Layout.fillWidth: true
}
