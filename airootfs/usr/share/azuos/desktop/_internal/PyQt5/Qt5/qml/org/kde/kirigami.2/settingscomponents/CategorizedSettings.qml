/*
 *  SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
 *  SPDX-FileCopyrightText: 2021 Carl Schwan <carl@carlschwan.eu>
 *  SPDX-FileCopyrightText: 2021 Felipe Kinoshita <kinofhek@gmail.com>
 *  SPDX-FileCopyrightText: 2021 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Controls 2.15 as QQC2
import QtQuick.Layouts 1.15
import org.kde.kirigami 2.11 as Kirigami

/**
 * @brief This is a container for to show a list of actions in a list view and displaying
 * the actual page next to it.
 *
 * @see kirigami::SettingAction
 * @since KDE Frameworks 5.86
 * @since org.kde.kirigami 2.18
 * @inherit kirigami::PageRow
 */
Kirigami.PageRow {
    id: pageSettingStack

    /**
     * @brief The default page that will be shown when opened.
     *
     * This only applies when the categorized settings object is wide enough to
     * show multiple pages.
     *
     * @see @link actions @endlink
     */
    property string defaultPage

    property list<Kirigami.PagePoolAction> actions
    property alias stack: pageSettingStack
    property Kirigami.PagePool pool: Kirigami.PagePool {}

    readonly property string title: pageSettingStack.depth < 2 ? qsTr("Settings") : qsTr("Settings — %1").arg(pageSettingStack.get(1).title)

    property bool completed: false

    bottomPadding: 0
    leftPadding: 0
    rightPadding: 0
    topPadding: 0

    // With this, we get the longest word's width
    TextMetrics {
        id: maxWordMetrics
    }
    columnView.columnWidth: {
        if(!pageSettingStack.completed || actions.length === 0) {
            return Kirigami.Units.gridUnit * 6  // we return the min width if the component isn't completed
        }
        let maxWordWidth = 0;
        for (let i = 0; i < actions.length; i++) {
            const words = actions[i].text.split(" ");

            for (let j = 0; j < words.length; j++) {
                maxWordMetrics.text = words[j]
                const currWordWidth = Math.ceil(maxWordMetrics.advanceWidth)
                if (currWordWidth > maxWordWidth) {
                    maxWordWidth = currWordWidth
                }
            }
        }

        // fix words getting wrapped weirdly when the vertical scrollbar is shown
        const vScrollBarWidth = initialPage.contentItem.QQC2.ScrollBar.vertical.width;

        // sum maximum word width, ListView's delegate spacing, and vertical scrollbar width
        const calcWidth = maxWordWidth + Kirigami.Units.smallSpacing * 6 + vScrollBarWidth;
        const minWidth = Kirigami.Units.gridUnit * 6;
        const maxWidth = Kirigami.Units.gridUnit * 8.5;

        return Math.max(minWidth, Math.min(calcWidth, maxWidth));
    }
    globalToolBar.showNavigationButtons: Kirigami.ApplicationHeaderStyle.NoNavigationButtons
    globalToolBar.style: Kirigami.Settings.isMobile ? Kirigami.ApplicationHeaderStyle.Breadcrumb : Kirigami.ApplicationHeaderStyle.None

    signal backRequested(var event)
    onBackRequested: event => {
        if (pageSettingStack.depth > 1 && !pageSettingStack.wideMode && pageSettingStack.currentIndex !== 0) {
            event.accepted = true;
            pageSettingStack.pop();
        }
    }
    onWidthChanged: {
        if (pageSettingStack.depth < 2 && pageSettingStack.width >= Kirigami.Units.gridUnit * 40) {
            let defaultAction = getActionByName(defaultPage);
            if (defaultAction) {
                defaultAction.trigger();
                listview.currentIndex = indexOfAction(defaultAction);
            } else {
                actions[0].trigger();
                listview.currentIndex = 0;
            }
        }
    }

    initialPage: Kirigami.ScrollablePage {
        title: qsTr("Settings")
        bottomPadding: 0
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        Kirigami.Theme.colorSet: Kirigami.Theme.View
        ListView {
            id: listview
            Component.onCompleted: if (pageSettingStack.width >= Kirigami.Units.gridUnit * 40) {
                let defaultAction = getActionByName(defaultPage);
                if (defaultAction) {
                    defaultAction.trigger();
                    listview.currentIndex = indexOfAction(defaultAction);
                } else {
                    actions[0].trigger();
                    listview.currentIndex = 0;
                }
            } else {
                if (count > 0) {
                    listview.currentIndex = 0;
                } else {
                    listview.currentIndex = -1;
                }
            }
            model: pageSettingStack.actions
            delegate: pageSettingStack.wideMode ? desktopStyle : mobileStyle
        }
    }

    Component {
        id: desktopStyle

        QQC2.ItemDelegate {
            width: parent && parent.width > 0 ? parent.width : implicitWidth
            implicitWidth: contentItem.implicitWidth + Kirigami.Units.smallSpacing * 4
            implicitHeight: contentItem.implicitHeight + Kirigami.Units.smallSpacing * 2

            padding: Kirigami.Units.smallSpacing

            action: modelData
            highlighted: listview.currentIndex === index
            onClicked: listview.currentIndex = index
            contentItem: ColumnLayout {
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Icon {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.preferredWidth: Kirigami.Units.iconSizes.medium
                    Layout.preferredHeight: width
                    source: modelData.icon.name
                }

                QQC2.Label {
                    Layout.fillWidth: true
                    Layout.leftMargin: Kirigami.Units.smallSpacing
                    Layout.rightMargin: Kirigami.Units.smallSpacing
                    text: modelData.text
                    wrapMode: Text.Wrap
                    color: highlighted ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                    horizontalAlignment: Text.AlignHCenter
                }
            }

        }
    }

    Component {
        id: mobileStyle

        Kirigami.BasicListItem {
            action: modelData
            onClicked: {
                listview.currentIndex = index;
            }
        }
    }

    Component.onCompleted: {
        pageSettingStack.completed = true;
    }

    function getActionByName(actionName) {
        for (let i = 0; i < actions.length; i++) {
            if (actions[i].actionName == actionName) {
                return actions[i];
            }
        }
    }

    function indexOfAction(action) {
        for (let i = 0; i < actions.length; i++) {
            if (actions[i] == action) {
                return i;
            }
        }
    }
}

