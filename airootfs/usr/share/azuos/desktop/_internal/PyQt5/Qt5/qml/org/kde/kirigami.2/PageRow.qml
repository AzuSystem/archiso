/*
 *  SPDX-FileCopyrightText: 2016 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.2
import QtQml.Models 2.2
import QtQuick.Templates 2.0 as QT
import QtQuick.Controls 2.0 as QQC2
import org.kde.kirigami 2.20 as Kirigami
import "private/globaltoolbar" as GlobalToolBar
import "templates" as KT

/**
 * PageRow implements a row-based navigation model, which can be used
 * with a set of interlinked information pages. Items are pushed in the
 * back of the row and the view scrolls until that row is visualized.
 * A PageRow can show a single Page or multple pages at the same time,
 * depending on the window width: on a phone a single column should be fullscreen,
 * while on a tablet or a desktop more than one column can be visible at the same time.
 *
 * Example usage:
 * @include pagerow.qml
 *
 * @see ColumnViewAttached
 * @inherit QtQuick.Templates.Control
 */
QT.Control {
    id: root

//BEGIN PROPERTIES
    /**
     * @brief This property holds the number of items currently pushed onto the view.
     * @property int depth
     */
    property alias depth: columnView.count

    /**
     * @brief This property holds the last page in the row.
     * @property Page lastItem
     */
    readonly property Item lastItem: columnView.contentChildren.length > 0 ?  columnView.contentChildren[columnView.contentChildren.length - 1] : null

    /**
     * @brief This property points to the currently active page.
     * @property Kirigami.Page currentItem
     */
    property alias currentItem: columnView.currentItem

    /**
     * @brief This property holds the index of the currently active page.
     * @see ::currentItem
     * @property int currentIndex
     */
    property alias currentIndex: columnView.currentIndex

    /**
     * @brief This property sets the initial page/s for this PageRow.
     * @note This can optionally be set to an array of pages by using the JavaScript array notation [].
     * @property Kirigami.Page initialPage
     */
    property variant initialPage

    /**
     * @brief This property holds the main ColumnView of this Row.
     * @see ColumnView
     * @property Kirigami.ColumnView contentItem
     */
    contentItem: columnView

    /**
     * @brief This property holds the ColumnView that this PageRow owns.
     *
     * Generally, you shouldn't need to change the value of this property.
     *
     * @property Kirigami.ColumnView columnView
     * @since org.kde.kirigami 2.12
     */
    property alias columnView: columnView

    /**
     * @brief This property holds a list of all pages in the PageRow.
     * @property list<Kirigami.Page> items
     * @since org.kde.kirigami 2.6
     */
    property alias items: columnView.contentChildren;

    /**
     * @brief This property holds all visible pages in the PageRow,
     * excluding those which are scrolled away.
     * @property list<Kirigami.Page> visibleItems
     * @since org.kde.kirigami 2.6
     */
    property alias visibleItems: columnView.visibleItems

    /**
     * @brief This property holds the first page in the PageRow that is at least partially visible.
     * @note Pages before that one (the one contained in the property) will be out of the viewport.
     * @see ColumnView::firstVisibleItem
     * @property Item firstVisibleItem
     * @since org.kde.kirigami 2.6
     */
    property alias firstVisibleItem: columnView.firstVisibleItem

    /**
     * @brief This property holds the last page in the PageRow that is at least partially visible.
     * @note Pages after that one (the one contained in the property) will be out of the viewport.
     * @see ColumnView::lastVisibleItem
     * @property Item lastVisibleItem
     * @since org.kde.kirigami 2.6
     */
    property alias lastVisibleItem: columnView.lastVisibleItem

    /**
     * @brief This property holds the default width for a column.
     *
     * default: ``20 * Kirigami.Units.gridUnit``
     *
     * @note Pages can override it using implicitWidth, Layout.fillWidth, Layout.minimumWidth etc.
     */
    property int defaultColumnWidth: Kirigami.Units.gridUnit * 20

    /**
     * @brief This property sets whether it is possible to go back/forward
     * by swiping with a gesture on the content view.
     *
     * default: ``true``
     *
     * @property bool interactive
     */
    property alias interactive: columnView.interactive

    /**
     * @brief This property specifies whether the PageRow is wide enough to show multiple pages.
     * @since KDE Frameworks 5.37
     */
    readonly property bool wideMode: root.width >= root.defaultColumnWidth*2 && depth >= 2

    /**
     * @brief This property sets whether the separators between pages should be displayed.
     *
     * default: ``true``
     *
     * @property bool separatorVisible
     * @since KDE Frameworks 5.38
     */
    property alias separatorVisible: columnView.separatorVisible

    /**
     * @brief This property sets the appearance of an optional global toolbar for the whole PageRow.
     *
     * This grouped property has the following sub-properties:
     * * ``style: ApplicationHeaderStyle::Status``: how the top bar controls should be represented to the user.
     * * ``actualStyle``: this property holds the currently used style. It can be different when ``style`` is set to ``ApplicationHeaderStyle.Auto``
     * * ``showNavigationButtons: ApplicationHeaderStyle::NavigationButton``: a
     * combination of flags that determines whether to show the back and forward
     * button.
     * * ``toolbarActionAlignment: Qt::Alignment``: how to horizontally align the actions when using the ``ApplicationHeaderStyle.ToolBar`` style. Note that anything but ``Qt.AlignRight`` will cause the title to be hidden (default: ``Qt.AlignRight``).
     * * ``minimumHeight: int`` Minimum height of the header, which will be resized when scrolling. Only in Mobile mode (default: ``preferredHeight``, sliding but no scaling).
     * * ``preferredHeight: int`` The height the toolbar will usually have.
     * * ``maximumHeight: int `` The height the toolbar will have in mobile mode when the app is in reachable mode (default: preferredHeight * 1.5).
     * * ``leftReservedSpace: int, readonly`` How many pixels of extra space are reserved at the left of the page toolbar (typically for navigation buttons or a drawer handle).
     * * ``rightReservedSpace: int, readonly`` How many pixels of extra space  are reserved at the right of the page toolbar (typically for a drawer handle).
     *
     * @property kirigami::private::globaltoolbar::PageRowGlobalToolBarStyleGroup globalToolBar
     * @since KDE Frameworks 5.48
     */
    readonly property alias globalToolBar: globalToolBar

    /**
     * @brief This property assigns a drawer as an internal left sidebar for this PageRow.
     *
     * In this case, when open and not modal, the drawer contents will be in the same layer as the base pagerow.
     * Pushing any other layer on top will cover the sidebar.
     *
     * @since KDE Frameworks 5.84
     */
    // TODO KF6: globaldrawer should use actions also used by this sidebar instead of reparenting globaldrawer contents?
    property OverlayDrawer leftSidebar

    /**
     * @brief This property holds the modal layers.
     *
     * Sometimes an application needs a modal page that always covers all the rows.
     * For instance the full screen image of an image viewer or a settings page.
     *
     * @property QtQuick.Controls.StackView layers
     * @since KDE Frameworks 5.38
     */
    property alias layers: layersStack

    /**
     * @brief This property holds whether to automatically pop pages at the top of the stack if they are not visible.
     *
     * If a user navigates to a previous page on the stack (ex. pressing back button) and pages above
     * it on the stack are not visible, they will be popped if this property is true.
     *
     * @since KDE Frameworks 5.101
     */
    property bool popHiddenPages: false
//END PROPERTIES

//BEGIN FUNCTIONS
    /**
     * @brief Pushes a page on the stack.
     *
     * The page can be defined as a component, item or string.
     * If an item is used then the page will get re-parented.
     * If a string is used then it is interpreted as a url that is used to load a page
     * component.
     * The last pushed page will become the current item.
     *
     * @param page The page can also be given as an array of pages.
     *     In this case all those pages will
     *     be pushed onto the stack. The items in the stack can be components, items or
     *     strings just like for single pages.
     *     Additionally an object can be used, which specifies a page and an optional
     *     properties property.
     *     This can be used to push multiple pages while still giving each of
     *     them properties.
     *     When an array is used the transition animation will only be to the last page.
     *
     * @param properties The properties argument is optional and allows defining a
     * map of properties to set on the page. If page is actually an array of pages, properties should also be an array of key/value maps
     * @return The new created page (or the last one if it was an array)
     */
    function push(page, properties) {
        const item = insertPage(depth, page, properties);
        currentIndex = depth - 1;
        return item;
    }

    /**
     * @brief Pushes a page as a new dialog on desktop and as a layer on mobile.
     * @param page The page can be defined as a component, item or string. If an item is
     *             used then the page will get re-parented. If a string is used then it
     *             is interpreted as a url that is used to load a page component. Once
     *             pushed the page gains the methods `closeDialog` allowing to close itself.
     *             Kirigami only supports calling `closeDialog` once.
     * @param properties The properties given when initializing the page.
     * @param windowProperties The properties given to the initialized window on desktop.
     * @return Returns a newly created page.
     */
    function pushDialogLayer(page, properties = {}, windowProperties = {}) {
        let item;
        if (Kirigami.Settings.isMobile) {
            if (QQC2.ApplicationWindow.window.width > Kirigami.Units.gridUnit * 40) {
                // open as a QQC2.Dialog
                const dialog = Qt.createQmlObject(`
                    import QtQuick 2.15;
                    import QtQuick.Controls 2.15;
                    import QtQuick.Layouts 1.15;
                    import org.kde.kirigami 2.20 as Kirigami;
                    Kirigami.Dialog {
                        id: dialog
                        modal: true;
                        leftPadding: 0; rightPadding: 0; topPadding: 0; bottomPadding: 0;
                        clip: true
                        header: Kirigami.AbstractApplicationHeader {
                            pageRow: null
                            page: null
                            minimumHeight: Kirigami.Units.gridUnit * 1.6
                            maximumHeight: Kirigami.Units.gridUnit * 1.6
                            preferredHeight: Kirigami.Units.gridUnit * 1.6

                            Keys.onEscapePressed: event => {
                                if (dialog.opened) {
                                    dialog.close();
                                } else {
                                    event.accepted = false;
                                }
                            }

                            contentItem: RowLayout {
                                width: parent.width
                                Kirigami.Heading {
                                    Layout.leftMargin: Kirigami.Units.largeSpacing
                                    text: dialog.title
                                    elide: Text.ElideRight
                                }
                                Item {
                                    Layout.fillWidth: true;
                                }
                                Kirigami.Icon {
                                    id: closeIcon
                                    Layout.alignment: Qt.AlignVCenter
                                    Layout.rightMargin: Kirigami.Units.largeSpacing
                                    Layout.preferredHeight: Kirigami.Units.iconSizes.smallMedium
                                    Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                                    source: closeMouseArea.containsMouse ? "window-close" : "window-close-symbolic"
                                    active: closeMouseArea.containsMouse
                                    MouseArea {
                                        id: closeMouseArea
                                        hoverEnabled: true
                                        anchors.fill: parent
                                        onClicked: mouse => dialog.close();
                                    }
                                }
                            }
                        }
                        contentItem: Control { topPadding: 0; leftPadding: 0; rightPadding: 0; bottomPadding: 0; }
                    }`, QQC2.ApplicationWindow.overlay);
                dialog.width = Qt.binding(() => QQC2.ApplicationWindow.window.width - Kirigami.Units.gridUnit * 5);
                dialog.height = Qt.binding(() => QQC2.ApplicationWindow.window.height - Kirigami.Units.gridUnit * 5);
                dialog.x = Kirigami.Units.gridUnit * 2.5;
                dialog.y = Kirigami.Units.gridUnit * 2.5;

                if (typeof page === "string") {
                    // url => load component and then load item from component
                    const component = Qt.createComponent(Qt.resolvedUrl(page));
                    item = component.createObject(dialog.contentItem, properties);
                    component.destroy();
                    dialog.contentItem.contentItem = item
                } else if (page instanceof Component) {
                    item = page.createObject(dialog.contentItem, properties);
                    dialog.contentItem.contentItem = item
                } else if (page instanceof Item) {
                    item = page;
                    page.parent = dialog.contentItem;
                }
                dialog.title = Qt.binding(() => item.title);

                // Pushing a PageRow is supported but without PageRow toolbar
                if (item.globalToolBar && item.globalToolBar.style) {
                    item.globalToolBar.style = Kirigami.ApplicationHeaderStyle.None
                }
                Object.defineProperty(item, 'closeDialog', {
                    value: function() {
                        dialog.close();
                    }
                });
                dialog.open();
            } else {
                // open as a layer
                item = layers.push(page, properties);
                Object.defineProperty(item, 'closeDialog', {
                    value: function() {
                        layers.pop();
                    }
                });
            }
        } else {
            // open as a new window
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
                windowProperties.flags = Qt.Dialog | Qt.CustomizeWindowHint | Qt.WindowTitleHint | Qt.WindowCloseButtonHint;
            }
            const windowComponent = Qt.createComponent(Qt.resolvedUrl("./ApplicationWindow.qml"));
            const window = windowComponent.createObject(root, windowProperties);
            windowComponent.destroy();
            item = window.pageStack.push(page, properties);
            Object.defineProperty(item, 'closeDialog', {
                value: function() {
                    window.close();
                }
            });
        }
        item.Keys.escapePressed.connect(event => item.closeDialog());
        return item;
    }

    /**
     * @brief Inserts a new page or a list of new pages at an arbitrary position.
     *
     * The page can be defined as a component, item or string.
     * If an item is used then the page will get re-parented.
     * If a string is used then it is interpreted as a url that is used to load a page
     * component.
     * The current Page will not be changed, currentIndex will be adjusted
     * accordingly if needed to keep the same current page.
     *
     * @param page The page can also be given as an array of pages.
     *     In this case all those pages will
     *     be pushed onto the stack. The items in the stack can be components, items or
     *     strings just like for single pages.
     *     Additionally an object can be used, which specifies a page and an optional
     *     properties property.
     *     This can be used to push multiple pages while still giving each of
     *     them properties.
     *     When an array is used the transition animation will only be to the last page.
     *
     * @param properties The properties argument is optional and allows defining a
     * map of properties to set on the page. If page is actually an array of pages, properties should also be an array of key/value maps
     * @return The new created page (or the last one if it was an array)
     * @since org.kde.kirigami 2.7
     */
    function insertPage(position, page, properties) {
        if (!page) {
            return null
        }
        //don't push again things already there
        if (page.createObject === undefined && typeof page !== "string" && columnView.containsItem(page)) {
            print("The item " + page + " is already in the PageRow");
            return null;
        }

        position = Math.max(0, Math.min(depth, position));

        columnView.pop(columnView.currentItem);

        // figure out if more than one page is being pushed
        let pages;
        let propsArray = [];
        if (page instanceof Array) {
            pages = page;
            page = pages.pop();
            //compatibility with pre-qqc1 api, can probably be removed
            if (page.createObject === undefined && page.parent === undefined && typeof page !== "string") {
                properties = properties || page.properties;
                page = page.page;
            }
        }
        if (properties instanceof Array) {
            propsArray = properties;
            properties = propsArray.pop();
        } else {
            propsArray = [properties];
        }

        // push any extra defined pages onto the stack
        if (pages) {
            for (let i = 0; i < pages.length; i++) {
                let tPage = pages[i];
                let tProps = propsArray[i];
                //compatibility with pre-qqc1 api, can probably be removed
                if (tPage.createObject === undefined && tPage.parent === undefined && typeof tPage !== "string") {
                    if (columnView.containsItem(tPage)) {
                        print("The item " + page + " is already in the PageRow");
                        continue;
                    }
                    tProps = tPage.properties;
                    tPage = tPage.page;
                }

                pagesLogic.initAndInsertPage(position, tPage, tProps);
                ++position;
            }
        }

        // initialize the page
        const pageItem = pagesLogic.initAndInsertPage(position, page, properties);

        pagePushed(pageItem);

        return pageItem;
    }

    /**
     * Move the page at position fromPos to the new position toPos
     * If needed, currentIndex will be adjusted
     * in order to keep the same current page.
     * @since org.kde.kirigami 2.7
     */
    function movePage(fromPos, toPos) {
        columnView.moveItem(fromPos, toPos);
    }

    /**
     * @brief Remove the given page.
     * @param page The page can be given both as integer position or by reference
     * @return The page that has just been removed
     * @since org.kde.kirigami 2.7
     */
    function removePage(page) {
        if (depth === 0) {
            return null;
        }

        return columnView.removeItem(page);
    }

    /**
     * @brief Pops a page off the stack and all the pages after it.
     * @param page If page is specified then the stack is unwound to that page,
     * to unwind to the first page specify page as null.
     * @return The page instance that was popped off the stack.
     */
    function pop(page) {
        if (depth === 0) {
            return null;
        }

        return columnView.pop(page);
    }

    /**
     * @brief Replaces a page on the stack.
     * @param page The page can also be given as an array of pages.
     *     In this case all those pages will
     *     be pushed onto the stack. The items in the stack can be components, items or
     *     strings just like for single pages.
     *     the current page and all pagest after it in the stack will be removed.
     *     Additionally an object can be used, which specifies a page and an optional
     *     properties property.
     *     This can be used to push multiple pages while still giving each of
     *     them properties.
     *     When an array is used the transition animation will only be to the last page.
     * @param properties The properties argument is optional and allows defining a
     * map of properties to set on the page.
     * @see ::push() for details.
     */
    function replace(page, properties) {
        if (!page) {
            return null;
        }

        // Remove all pages on top of the one being replaced.
        if (currentIndex >= 0) {
            columnView.pop(columnView.contentChildren[currentIndex]);
        } else {
            console.warn("There's no page to replace");
        }

        // Figure out if more than one page is being pushed.
        let pages;
        let propsArray = [];
        if (page instanceof Array) {
            pages = page;
            page = pages.shift();
        }
        if (properties instanceof Array) {
            propsArray = properties;
            properties = propsArray.shift();
        } else {
            propsArray = [properties];
        }

        // Replace topmost page.
        let pageItem = pagesLogic.initPage(page, properties);
        if (depth > 0)
            columnView.replaceItem(depth - 1, pageItem);
        else {
            console.log("Calling replace on empty PageRow", pageItem)
            columnView.addItem(pageItem)
        }
        pagePushed(pageItem);

        // Push any extra defined pages onto the stack.
        if (pages) {
            for (let i = 0; i < pages.length; i++) {
                const tPage = pages[i];
                const tProps = propsArray[i];

                pageItem = pagesLogic.initPage(tPage, tProps);
                columnView.addItem(pageItem);
                pagePushed(pageItem);
            }
        }

        currentIndex = depth - 1;
        return pageItem;
    }

    /**
     * @brief Clears the page stack.
     *
     * Destroy (or reparent) all the pages contained.
     */
    function clear() {
        return columnView.clear();
    }

    /**
     * @return the page at idx
     * @param idx the depth of the page we want
     */
    function get(idx) {
        return columnView.contentChildren[idx];
    }

    /**
     * Go back to the previous index and scroll to the left to show one more column.
     */
    function flickBack() {
        if (depth > 1) {
            currentIndex = Math.max(0, currentIndex - 1);
        }
    }

    /**
     * Acts as if you had pressed the "back" button on Android or did Alt-Left on desktop,
     * "going back" in the layers and page row. Results in a layer being popped if available,
     * or the currentIndex being set to currentIndex-1 if not available.
     *
     * @param event Optional, an event that will be accepted if a page is successfully
     * "backed" on
     */
    function goBack(event = null) {
        const backEvent = {accepted: false}

        if (layersStack.depth >= 1) {
            try { // app code might be screwy, but we still want to continue functioning if it throws an exception
                layersStack.currentItem.backRequested(backEvent)
            } catch (error) {}

            if (!backEvent.accepted) {
                if (layersStack.depth > 1) {
                    layersStack.pop()
                    if (event) event.accepted = true
                    return
                }
            }
        }

        if (root.currentIndex >= 1) {
            try { // app code might be screwy, but we still want to continue functioning if it throws an exception
                root.currentItem.backRequested(backEvent)
            } catch (error) {}

            if (!backEvent.accepted) {
                if (root.depth > 1) {
                    root.currentIndex = Math.max(0, root.currentIndex - 1)
                    if (event) event.accepted = true
                }
            }
        }
    }

    /**
     * Acts as if you had pressed the "forward" shortcut on desktop,
     * "going forward" in the page row. Results in the active page
     * becoming the next page in the row from the current active page,
     * i.e. currentIndex + 1.
     */
    function goForward() {
        root.currentIndex = Math.min(root.depth-1, root.currentIndex + 1)
    }
//END FUNCTIONS

//BEGIN signals & signal handlers
    /**
     * @brief Emitted when a page has been inserted anywhere.
     * @param position where the page has been inserted
     * @param page the new page
     * @since org.kde.kirigami 2.7
     */
    signal pageInserted(int position, Item page)

    /**
     * @brief Emitted when a page has been pushed to the bottom.
     * @param page the new page
     * @since org.kde.kirigami 2.5
     */
    signal pagePushed(Item page)

    /**
     * @brief Emitted when a page has been removed from the row.
     * @param page the page that has been removed: at this point it's still valid,
     *           but may be auto deleted soon.
     * @since org.kde.kirigami 2.5
     */
    signal pageRemoved(Item page)

    onLeftSidebarChanged: {
        if (leftSidebar && !leftSidebar.modal) {
            modalConnection.onModalChanged();
        }
    }

    Keys.onReleased: {
        if (event.key === Qt.Key_Back) {
            this.goBack(event)
        }
    }

    onInitialPageChanged: {
        if (initialPage) {
            clear();
            push(initialPage, null)
        }
    }
/*
    onActiveFocusChanged:  {
        if (activeFocus) {
            layersStack.currentItem.forceActiveFocus()
            if (columnView.activeFocus) {
                print("SSS"+columnView.currentItem)
                columnView.currentItem.forceActiveFocus();
            }
        }
    }
*/
//END signals & signal handlers

    Connections {
        id: modalConnection
        target: root.leftSidebar
        function onModalChanged() {
            if (leftSidebar.modal) {
                const sidebar = sidebarControl.contentItem;
                const background = sidebarControl.background;
                sidebarControl.contentItem = null;
                leftSidebar.contentItem = sidebar;
                sidebarControl.background = null;
                leftSidebar.background = background;

                sidebar.visible = true;
                background.visible = true;
            } else {
                const sidebar = leftSidebar.contentItem
                const background = leftSidebar.background
                leftSidebar.contentItem=null
                sidebarControl.contentItem = sidebar
                leftSidebar.background=null
                sidebarControl.background = background

                sidebar.visible = true;
                background.visible = true;
            }
        }
    }

    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding

    Shortcut {
        sequences: [ StandardKey.Back ]
        onActivated: root.goBack()
    }
    Shortcut {
        sequences: [ StandardKey.Forward ]
        onActivated: root.goForward()
    }

    Keys.forwardTo: [currentItem]

    GlobalToolBar.PageRowGlobalToolBarStyleGroup {
        id: globalToolBar
        readonly property int leftReservedSpace: globalToolBarUI.item ? globalToolBarUI.item.leftReservedSpace : 0
        readonly property int rightReservedSpace: globalToolBarUI.item ? globalToolBarUI.item.rightReservedSpace : 0
        readonly property int height: globalToolBarUI.height
        readonly property Item leftHandleAnchor: globalToolBarUI.item ? globalToolBarUI.item.leftHandleAnchor : null
        readonly property Item rightHandleAnchor: globalToolBarUI.item ? globalToolBarUI.item.rightHandleAnchor : null
    }

    QQC2.StackView {
        id: layersStack
        z: 99
        anchors {
            fill: parent
        }
        // placeholder as initial item
        initialItem: columnViewLayout

        function clear() {
            // don't let it kill the main page row
            const d = layersStack.depth;
            for (let i = 1; i < d; ++i) {
                pop();
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

    Loader {
        id: globalToolBarUI
        anchors {
            left: parent.left
            top: parent.top
            right: parent.right
        }
        z: 100
        property QT.Control pageRow: root
        active: (!firstVisibleItem || firstVisibleItem.globalToolBarStyle !== Kirigami.ApplicationHeaderStyle.None) &&
                (globalToolBar.actualStyle !== Kirigami.ApplicationHeaderStyle.None || (firstVisibleItem && firstVisibleItem.globalToolBarStyle === Kirigami.ApplicationHeaderStyle.ToolBar))
        visible: active
        height: active ? implicitHeight : 0
        // If load is asynchronous, it will fail to compute the initial implicitHeight
        // https://bugs.kde.org/show_bug.cgi?id=442660
        asynchronous: false
        source: Qt.resolvedUrl("private/globaltoolbar/PageRowGlobalToolBarUI.qml");
    }

    QtObject {
        id: pagesLogic
        readonly property var componentCache: new Array()

        function getPageComponent(page) {
            let pageComp;

            if (page.createObject) {
                // page defined as component
                pageComp = page;
            } else if (typeof page === "string") {
                // page defined as string (a url)
                pageComp = pagesLogic.componentCache[page];
                if (!pageComp) {
                    pageComp = pagesLogic.componentCache[page] = Qt.createComponent(page);
                }
            } else if (typeof page === "object" && !(page instanceof Item) && page.toString !== undefined) {
                // page defined as url (QML value type, not a string)
                pageComp = pagesLogic.componentCache[page.toString()];
                if (!pageComp) {
                    pageComp = pagesLogic.componentCache[page.toString()] = Qt.createComponent(page.toString());
                }
            }

            return pageComp
        }

        function initPage(page, properties) {
            const pageComp = getPageComponent(page, properties);

            if (pageComp) {
                // instantiate page from component
                // FIXME: parent directly to columnView or root?
                page = pageComp.createObject(null, properties || {});

                if (pageComp.status === Component.Error) {
                    throw new Error("Error while loading page: " + pageComp.errorString());
                }
            } else {
                // copy properties to the page
                for (const prop in properties) {
                    if (properties.hasOwnProperty(prop)) {
                        page[prop] = properties[prop];
                    }
                }
            }
            return page;
        }

        function initAndInsertPage(position, page, properties) {
            page = initPage(page, properties);
            columnView.insertItem(position, page);
            return page;
        }
    }

    RowLayout {
        id: columnViewLayout
        spacing: 1
        readonly property alias columnView: columnView
        QQC2.Control {
            id: sidebarControl
            Layout.fillHeight: true
            visible: contentItem !== null && root.leftDrawer && root.leftDrawer.visible
            leftPadding: root.leftSidebar ? root.leftSidebar.leftPadding : 0
            topPadding: root.leftSidebar ? root.leftSidebar.topPadding : 0
            rightPadding: root.leftSidebar ? root.leftSidebar.rightPadding : 0
            bottomPadding: root.leftSidebar ? root.leftSidebar.bottomPadding : 0
        }
        Kirigami.ColumnView {
            id: columnView
            Layout.fillWidth: true
            Layout.fillHeight: true

            topPadding: globalToolBarUI.item && globalToolBarUI.item.breadcrumbVisible
                        ? globalToolBarUI.height : 0

            // Internal hidden api for Page
            readonly property Item __pageRow: root
            acceptsMouse: Kirigami.Settings.isMobile
            columnResizeMode: root.wideMode ? Kirigami.ColumnView.FixedColumns : Kirigami.ColumnView.SingleColumn
            columnWidth: root.defaultColumnWidth

            onItemInserted: root.pageInserted(position, item);
            onItemRemoved: root.pageRemoved(item);

            onVisibleItemsChanged: {
                // implementation of `popHiddenPages` option
                if (root.popHiddenPages) {
                    // manually fetch lastItem here rather than use root.lastItem property, since that binding may not have updated yet
                    let lastItem = columnView.contentChildren[columnView.contentChildren.length - 1];
                    let lastVisibleItem = columnView.lastVisibleItem;
                    
                    // pop every page that isn't visible and at the top of the stack
                    while (lastItem && columnView.lastVisibleItem && 
                        lastItem !== columnView.lastVisibleItem && columnView.containsItem(lastItem)) {
                        root.pop();
                    }
                }
            }
        }
    }

    Rectangle {
        anchors.bottom: parent.bottom
        height: Kirigami.Units.smallSpacing
        x: (columnView.width - width) * (columnView.contentX / (columnView.contentWidth - columnView.width))
        width: columnView.width * (columnView.width/columnView.contentWidth)
        color: Kirigami.Theme.textColor
        opacity: 0
        onXChanged: {
            opacity = 0.3
            scrollIndicatorTimer.restart();
        }
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        Timer {
            id: scrollIndicatorTimer
            interval: Kirigami.Units.longDuration * 4
            onTriggered: parent.opacity = 0;
        }
    }
}
