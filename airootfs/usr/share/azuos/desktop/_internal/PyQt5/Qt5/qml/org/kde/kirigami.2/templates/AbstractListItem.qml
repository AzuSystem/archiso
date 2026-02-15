/*
 *  SPDX-FileCopyrightText: 2010 Marco Martin <notmart@gmail.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.4 as Kirigami
// TODO KF6: This must stay at 2.2 until KF6 due to retrocompatibility of the "icon" property
import QtQuick.Templates 2.2 as T2
import QtQuick.Templates 2.4 as QQC2

/**
 * @brief An item delegate for the primitive ListView component.
 *
 * It's intended to make all listviews look coherent.
 *
 * @inherit QtQuick.Controls.ItemDelegate
 */
T2.ItemDelegate {
    id: listItem

//BEGIN properties
    /**
     * @brief This property sets whether the item should emit signals related to mouse interaction.
     *
     * default: ``true``
     *
     * @deprecated This will be removed in KF6.
     */
    property bool supportsMouseEvents: hoverEnabled

    /**
     * @brief This property specifies whether the cursor is currently hovering over the item.
     *
     * On mobile touch devices, this will be @c true only when pressed.
     *
     * @see QtQuick.Templates.ItemDelegate.hovered
     * @deprecated This will be removed in KF6; use the ``hovered``  property instead.
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
     * @brief This property sets whether this item is a section delegate.
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
     * The separator is a line between this and the item under it.
     *
     * default: ``false``
     */
    property bool separatorVisible: false

    /**
     * @brief This property holds list item's background color.
     *
     * It is advised to use the default value.
     *
     * default: ``"transparent"``
     */
    property color backgroundColor: "transparent"

    /**
     * @brief This property holds the background color to be used when
     * background alternating is enabled.
     *
     * It is advised to use the default value.
     *
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
     *
     * default: @link Kirigami.PlatformTheme.highlightColor Kirigami.Theme.highlightColor @endlink
     */
    property color activeBackgroundColor: Kirigami.Theme.highlightColor

    /**
     * @brief This property holds the color of the text in the item.
     *
     * It is advised to use the default value.
     *
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
     *
     * default: @link Kirigami.PlatformTheme.highlightedTextColor Kirigami.Theme.highlightedTextColor @endlink
     *
     * If custom text elements are inserted in an AbstractListItem,
     * their color will have to be manually set with this property.
     */
    property color activeTextColor: Kirigami.Theme.highlightedTextColor

    /** @internal */
    default property alias _default: listItem.contentItem

    // NOTE: Overrides action property of newer import versions which we can't use
    /**
     * @brief This property holds the item action.
     * @property QtQuick.Controls.Action action
     */
    property QQC2.Action action
//END properties

    activeFocusOnTab: ListView.view ? false : true

    text: action ? action.text : undefined
    checked: action ? action.checked : false
    checkable: action ? action.checkable : false
    onClicked: {
        if (ListView.view && typeof index !== "undefined") {
            ListView.view.currentIndex = index;
        }
        if (!action) {
            return;
        }

        action.trigger();
        checked = Qt.binding(function() { return action.checked });
    }
    //Theme.inherit: false
    //Theme.colorSet: Kirigami.Theme.View

    padding: Kirigami.Settings.tabletMode ? Kirigami.Units.largeSpacing : Kirigami.Units.smallSpacing

    leftPadding: padding * 2
    topPadding: padding

    rightPadding: padding * 2
    bottomPadding: padding

    implicitWidth: contentItem ? contentItem.implicitWidth + leftPadding + rightPadding : Kirigami.Units.gridUnit * 12

    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding

    width: parent && parent.width > 0 ? parent.width : implicitWidth
    Layout.fillWidth: true

    opacity: enabled ? 1 : 0.6

    height: implicitHeight

    onVisibleChanged: {
        if (visible) {
            height = Qt.binding(() => implicitHeight);
        } else {
            if (ListView.view && ListView.view.visible) {
                height = 0;
            }
        }
    }

    hoverEnabled: true

    Accessible.role: Accessible.ListItem
    highlighted: focus && ListView.isCurrentItem && ListView.view && ListView.view.keyNavigationEnabled
}
