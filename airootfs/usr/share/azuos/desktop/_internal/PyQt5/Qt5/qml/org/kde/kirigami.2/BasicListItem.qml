/*
 *  SPDX-FileCopyrightText: 2010 Marco Martin <notmart@gmail.com>
 *  SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.15
import QtQuick.Layouts 1.15
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.12 as Kirigami

//TODO KF6: this needs to become a layout inside a Delegate rather than its own listItem
/**
 * @brief A BasicListItem provides a simple list item design that can handle the
 * most common list item usecases.
 *
 * @image html BasicListItemTypes.svg "The styles of the BasicListItem. From left to right top to bottom: light icon + title + subtitle, dark icon + title + subtitle, light icon + label, dark icon + label, light label, dark label." width=50%
 * @warning This will be reworked into a layout to be used inside a delegate.
 * @see <a href="https://develop.kde.org/hig/components/editing/list">KDE Human Interface Guidelines on List Views and List Items</a>
 */
Kirigami.AbstractListItem {
    id: listItem

//BEGIN properties
    /**
     * @brief This property holds the text of this list item's label.
     *
     * If a subtitle is provided, the label will behave as a title and will be styled
     * accordingly. Every list item should have a label.
     *
     * @property string label
     */
    property alias label: listItem.text

    /**
     * @brief This property holds an optional subtitle that can appear under the label.
     * @since KDE Frameworks 5.70
     * @since org.kde.kirigami 2.12
     */
    property alias subtitle: subtitleItem.text

    /**
     * @brief This property holds an item that will be displayed before the title and subtitle.
     * @note The leading item is allowed to expand infinitely horizontally, and should be bounded by the user.
     * @since org.kde.kirigami 2.15
     */
    property Item leading

    /**
     * @brief This property holds the padding after the leading item.
     * @since org.kde.kirigami 2.15
     */
    property real leadingPadding: Kirigami.Units.largeSpacing

    // TODO KF6: remove this property and instead implement leading and trailing
    // item positioning in such a way that they fill vertically, but a fixed
    // height can be manually specified without needing to wrap it in an Item
    /**
     * @brief This property sets whether or not to stretch the leading item to fit all available vertical space.
     *
     * If false, you will be responsible for setting a height for the
     * item or ensuring that its default height works.
     *
     * default: ``true``
     *
     * @warning This property will likely be removed in KF6
     * @since KDE Frameworks 5.83
     * @since org.kde.kirigami 2.15
     */
    property bool leadingFillVertically: true

    /**
     * @brief This property holds an item that will be displayed after the title and subtitle
     * @note The trailing item is allowed to expand infinitely horizontally, and should be bounded by the user.
     * @since org.kde.kirigami 2.15
     */
    property Item trailing

    /**
     * @brief This property holds the padding before the trailing item.
     * @since org.kde.kirigami 2.15
     */
    property real trailingPadding: Kirigami.Units.largeSpacing

    // TODO KF6: remove this property and instead implement leading and trailing
    // item positioning in such a way that they fill vertically, but a fixed
    // height can be manually specified without needing to wrap it in an Item
    /**
     * @brief This propery sets whether or not to stretch the trailing item to fit all available vertical space.
     *
     * If false, you will be responsible for setting a height for the
     * item or ensuring that its default height works.
     *
     * default: ``true``
     *
     * @warning This property will likely be removed in KF6
     * @since KDE Frameworks 5.83
     * @since org.kde.kirigami 2.15
     */
    property bool trailingFillVertically: true

    /**
     * @brief This property sets whether list item's text should render in bold.
     *
     * default: ``false``
     *
     * @since KDE Frameworks 5.71
     * @since org.kde.kirigami 2.13
     */
    property bool bold: false

    /**
     * @code ts
     * interface IconGroup {
     *     name:   string,
     *     source: string,
     *     width:  int,
     *     height: int,
     *     color:  color,
     * }
     *
     * type Icon = string | IconGroup | URL
     * @endcode
     *
     * The icon that will render on this list item.
     *
     * This can either be an icon name, a URL, or an object with the following properties:
     *
     * If the type of the icon is a string containing an icon name, the icon will be looked up from the
     * platform icon theme.
     *
     * Using an icon object allows you to specify more granular attributes of the icon,
     * such as its color and dimensions.
     *
     * If the icon is a URL, the icon will be attempted to be loaded from the
     * given URL.
     */
    property var icon

    /**
     * @brief This property sets the size at which the icon will render.
     *
     * This will not affect icon lookup, unlike the icon group's width and height properties, which will.
     *
     * @since org.kde.kirigami 2.5
     * @property int iconSize
     */
    property alias iconSize: iconItem.size

    /**
     * @brief This property holds the color of the icon.
     *
     * If the icon's original colors should be left intact, set this to the default value, "transparent".
     * Note that this colour will only be applied if the icon can be recoloured, (e.g. you can use Kirigami.Theme.foregroundColor to change the icon's colour.)
     *
     * @since org.kde.kirigami 2.7
     * @property color iconColor
     */
    property alias iconColor: iconItem.color

    /**
     * @brief This property sets whether or not the icon has a "selected" appearance.
     *
     * Can be used to override the icon coloration if the list item's background and
     * text are also being overridden, to ensure that the icon never becomes invisible.
     *
     * @since KDE Frameworks 5.91
     * @since org.kde.kirigami 2.19
     * @property bool iconSelected
     */
    property alias iconSelected: iconItem.selected

    /**
     * @brief This property sets whether or not to reserve space for the icon, even if there is no icon.
     * @image html BasicListItemReserve.svg "Left: reserveSpaceForIcon: false. Right: reserveSpaceForIcon: true" width=50%
     * @property bool reserveSpaceForIcon
     */
    property alias reserveSpaceForIcon: iconItem.visible

    /**
     * @brief This property sets whether or not the label of the list item should fill width.
     *
     * Setting this to @c false is useful if you have other items in the list item
     * that should fill width instead of the label.
     *
     * @property bool reserveSpaceForLabel
     */
    property alias reserveSpaceForLabel: labelItem.visible

    /**
     * @brief This property holds whether the list item's height should account for
     * the presence of a subtitle.
     *
     * default: ``false``
     *
     * @since KDE Frameworks 5.77
     * @since org.kde.kirigami 2.15
     */
    property bool reserveSpaceForSubtitle: false

    /**
     * @brief This property holds the spacing between the label row and subtitle row.
     * @since KDE Frameworks 5.83
     * @since org.kde.kirigami 2.15
     * @property real textSpacing
     */
    property alias textSpacing: labelColumn.spacing

    /**
     * @brief This property holds sets whether to make the icon and labels have a disabled look.
     *
     * This can be used to tweak whether the content elements are visually active
     * while preserving an active appearance for any leading or trailing items.
     *
     * default: ``false``
     *
     * @since KDE Frameworks 5.83
     * @since org.kde.kirigami 2.15
     */
    property bool fadeContent: false

    /**
     * @brief This property holds the label item, for accessing the usual QtQuick.Text properties.
     * @since KDE Frameworks 5.84
     * @since org.kde.kirigami 2.16
     * @property QtQuick.Controls.Label labelItem
     */
    property alias labelItem: labelItem

    /**
     * @brief This property holds the subtitle item, for accessing the usual QtQuick.Text properties.
     * @since KDE Frameworks 5.84
     * @since org.kde.kirigami 2.16
     * @property QtQuick.Controls.Label subtitleItem
     */
    property alias subtitleItem: subtitleItem

    /**
     * @brief This property holds whether the tooltip of the subtitle should be visible
     * @since 5.107
     */
    property bool toolTipVisible: false

    /** @internal */
    default property alias _basicDefault: layout.data
//END properties

//BEGIN signal handlers
    onLeadingChanged: {
        const item = leading;
        if (!!item) {
            item.parent = contItem
            item.anchors.left = item.parent.left
            item.anchors.top = leadingFillVertically ? item.parent.top : undefined
            item.anchors.bottom = leadingFillVertically ? item.parent.bottom : undefined
            item.anchors.verticalCenter = leadingFillVertically ? undefined : item.parent.verticalCenter
            layout.anchors.left = item.right
            layout.anchors.leftMargin = Qt.binding(() => leadingPadding)
        } else {
            layout.anchors.left = contentItem.left
            layout.anchors.leftMargin = 0
        }
    }

    onTrailingChanged: {
        const item = trailing;
        if (!!item) {
            item.parent = contItem
            item.anchors.right = item.parent.right
            item.anchors.top = trailingFillVertically ? item.parent.top : undefined
            item.anchors.bottom = trailingFillVertically ? item.parent.bottom : undefined
            item.anchors.verticalCenter = trailingFillVertically ? undefined : item.parent.verticalCenter
            layout.anchors.right = item.left
            layout.anchors.rightMargin = Qt.binding(() => trailingPadding)
        } else {
            layout.anchors.right = contentItem.right
            layout.anchors.rightMargin = 0
        }
    }

    Keys.onEnterPressed: event => action ? action.trigger() : clicked()
    Keys.onReturnPressed: event => action ? action.trigger() : clicked()
//END signal handlers

    icon: action ? action.icon.name || action.icon.source : undefined

    contentItem: Item {
        id: contItem

        implicitWidth: layout.implicitWidth
            + (listItem.leading !== null ? listItem.leading.implicitWidth : 0)
            + (listItem.trailing !== null ? listItem.trailing.implicitWidth : 0)

        Binding on implicitHeight {
            value: Math.max(iconItem.size, (!subtitleItem.visible && listItem.reserveSpaceForSubtitle ? (labelItem.implicitHeight + labelColumn.spacing + subtitleItem.implicitHeight): labelColumn.implicitHeight) )
            delayed: true
        }

        RowLayout {
            id: layout
            spacing: LayoutMirroring.enabled ? listItem.rightPadding : listItem.leftPadding
            anchors.left: contItem.left
            anchors.leftMargin: listItem.leading ? listItem.leadingPadding : 0
            anchors.right: contItem.right
            anchors.rightMargin: listItem.trailing ? listItem.trailingPadding : 0
            anchors.verticalCenter: parent.verticalCenter

            Kirigami.Icon {
                id: iconItem
                source: {
                    if (!listItem.icon) {
                        return undefined
                    }
                    if (listItem.icon.hasOwnProperty) {
                        if (listItem.icon.hasOwnProperty("name") && listItem.icon.name !== "")
                            return listItem.icon.name;
                        if (listItem.icon.hasOwnProperty("source"))
                            return listItem.icon.source;
                    }
                    return listItem.icon;
                }
                property int size: subtitleItem.visible || reserveSpaceForSubtitle ? Kirigami.Units.iconSizes.medium : Kirigami.Units.iconSizes.smallMedium
                Layout.minimumHeight: size
                Layout.maximumHeight: size
                Layout.minimumWidth: size
                Layout.maximumWidth: size
                selected: (listItem.highlighted || listItem.checked || listItem.down)
                opacity: listItem.fadeContent ? 0.6 : 1.0
                visible: source !== undefined
            }
            ColumnLayout {
                id: labelColumn
                spacing: 0
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                QQC2.Label {
                    id: labelItem
                    text: listItem.text
                    Layout.fillWidth: true
                    Layout.alignment: subtitleItem.visible ? Qt.AlignLeft | Qt.AlignBottom : Qt.AlignLeft | Qt.AlignVCenter
                    color: (listItem.highlighted || listItem.checked || listItem.down) ? listItem.activeTextColor : listItem.textColor
                    elide: Text.ElideRight
                    font.weight: listItem.bold ? Font.Bold : Font.Normal
                    opacity: listItem.fadeContent ? 0.6 : 1.0
                }
                QQC2.Label {
                    id: subtitleItem
                    Layout.fillWidth: true
                    Layout.alignment: subtitleItem.visible ? Qt.AlignLeft | Qt.AlignTop : Qt.AlignLeft | Qt.AlignVCenter
                    color: (listItem.highlighted || listItem.checked || listItem.down) ? listItem.activeTextColor : listItem.textColor
                    elide: Text.ElideRight
                    font: Kirigami.Theme.smallFont
                    opacity: listItem.fadeContent ? 0.6 : (listItem.bold ? 0.9 : 0.7)
                    visible: text.length > 0
                }
                QQC2.ToolTip.text: {
                    let txt = "";
                    if (labelItem.truncated) {
                        txt += labelItem.text;
                    }
                    if (subtitleItem.truncated) {
                        if (txt.length > 0) {
                            txt += "<br/><br/>";
                        }
                        txt += subtitleItem.text;
                    }
                    return txt;
                }
                QQC2.ToolTip.visible: toolTipVisible && QQC2.ToolTip.text.length > 0 && (Kirigami.Settings.tabletMode ? listItem.pressed : listItem.hovered)
                QQC2.ToolTip.delay: Kirigami.Settings.tabletMode ? Qt.styleHints.mousePressAndHoldInterval : Kirigami.Units.toolTipDelay
            }
        }
    }
}
