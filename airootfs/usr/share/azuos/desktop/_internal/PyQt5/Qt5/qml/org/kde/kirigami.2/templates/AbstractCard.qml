/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.6
import QtQuick.Layouts 1.2
import QtQuick.Templates 2.0 as T
import org.kde.kirigami 2.4 as Kirigami

/**
 * AbstractCard is the base type for cards. A Card is a visual object that serves
 * as an entry point for more detailed information. An AbstractCard is empty,
 * providing just the look and the base properties and signals for a QtQuick.Controls.ItemDelegate.
 * It can be filled with any custom layout of items, its content is organized
 * into 3 properties: ::header, contentItem and ::footer.
 * Use this only when you need custom contents.
 * For cards with a standard layout, use the Card component.
 *
 * @see kirigami::Card
 * @since org.kde.kirigami 2.4
 * @inherit QtQuick.Controls.ItemDelegate
 */
T.ItemDelegate {
    id: root

//BEGIN properties
    /**
     * @brief This property holds an item that serves as a header.
     *
     * This item will be positioned on top if headerOrientation is
     * ``Qt.Vertical`` or on the left if it is ``Qt.Horizontal``.
     */
    property Item header

    /**
     * @brief This property sets the card's orientation.
     *
     * The following values are allowed:
     * * ``Qt.Vertical``: the header will be positioned on top.
     * * ``Qt.Horizontal``: the header will be positioned on the
     * left (or right if an RTL layout is used).
     *
     * default: ``Qt.Vertical``
     *
     * @property Qt::Orientation headerOrientation
     */
    property int headerOrientation: Qt.Vertical

    /**
     * @brief This property holds an Item that serves as a footer.
     *
     * This item will be positioned at the bottom if headerOrientation
     * is ``Qt.Vertical`` or on the right if it is ``Qt.Horizontal``.
     */
    property Item footer

    /**
     * @brief This property sets whether clicking or tapping on the
     * card area shows a visual click feedback.
     *
     * Use this if you want to do an action in the onClicked signal
     * handler of the card.
     *
     * default: ``false``
     */
    property bool showClickFeedback: false
//END properties

    Layout.fillWidth: true

    implicitWidth: Math.max(background.implicitWidth, mainLayout.implicitWidth) + leftPadding + rightPadding
    implicitHeight: mainLayout.implicitHeight + topPadding + bottomPadding

    hoverEnabled: !Kirigami.Settings.tabletMode && showClickFeedback
    // if it's in a CardLayout, try to expand horizontal cards to both columns
    Layout.columnSpan: headerOrientation === Qt.Horizontal && parent.hasOwnProperty("columns") ? parent.columns : 1

    Kirigami.Theme.inherit: false
    Kirigami.Theme.colorSet: Kirigami.Theme.View

    topPadding: contentItemParent.children.length > 0 ? Kirigami.Units.largeSpacing : 0
    leftPadding: Kirigami.Units.largeSpacing
    bottomPadding: contentItemParent.children.length > 0 ? Kirigami.Units.largeSpacing : 0
    rightPadding: Kirigami.Units.largeSpacing

    width: ListView.view ? ListView.view.width - ListView.view.leftMargin - ListView.view.rightMargin : undefined

    GridLayout {
        id: mainLayout
        rowSpacing: root.topPadding
        columnSpacing: root.leftPadding
        anchors {
            top: parent.top
            left: parent.left
            right: parent.right
            leftMargin: root.leftPadding
            topMargin: root.topPadding
            rightMargin: root.rightPadding
            bottom: parent.bottom
            bottomMargin: root.bottomPadding
        }
        columns: headerOrientation === Qt.Vertical ? 1 : 2
        function preferredHeight(item) {
            if (!item) {
                return 0;
            }
            if (item.Layout.preferredHeight > 0) {
                return item.Layout.preferredHeight;
            }
            return item.implicitHeight
        }
        Item {
            id: headerParent
            Layout.fillWidth: true
            Layout.fillHeight: root.headerOrientation === Qt.Horizontal
            Layout.rowSpan: root.headerOrientation === Qt.Vertical ? 1 : 2
            Layout.preferredWidth: header ? header.implicitWidth : 0
            Layout.preferredHeight: root.headerOrientation === Qt.Vertical ? mainLayout.preferredHeight(header) : -1
            visible: children.length > 0
        }
        Item {
            id: contentItemParent
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: root.topPadding
            Layout.bottomMargin: root.bottomPadding
            Layout.preferredWidth: contentItem ? contentItem.implicitWidth : 0
            Layout.preferredHeight: mainLayout.preferredHeight(contentItem)
            visible: children.length > 0
        }
        Item {
            id: footerParent
            Layout.fillWidth: true
            Layout.preferredWidth: footer ? footer.implicitWidth : 0
            Layout.preferredHeight: mainLayout.preferredHeight(footer)
            visible: children.length > 0
        }
    }

//BEGIN signal handlers
    onContentItemChanged: {
        if (!contentItem) {
            return;
        }

        contentItem.parent = contentItemParent;
        contentItem.anchors.fill = contentItemParent;
    }
    onHeaderChanged: {
        if (!header) {
            return;
        }

        header.parent = headerParent;
        header.anchors.fill = headerParent;
    }
    onFooterChanged: {
        if (!footer) {
            return;
        }

        //make the footer always looking it's at the bottom of the card
        footer.parent = footerParent;
        footer.anchors.left = footerParent.left;
        footer.anchors.top = footerParent.top;
        footer.anchors.right = footerParent.right;
        footer.anchors.topMargin = Qt.binding(() =>
            (root.height - root.bottomPadding - root.topPadding) - (footerParent.y + footerParent.height));
    }
    Component.onCompleted: {
        contentItemChanged();
    }
//END signal handlers
}
