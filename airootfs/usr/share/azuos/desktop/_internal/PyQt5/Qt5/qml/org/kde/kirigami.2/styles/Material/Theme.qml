/*
 *  SPDX-FileCopyrightText: 2015 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.7
import QtQuick.Controls.Material 2.0
import org.kde.kirigami 2.16 as Kirigami

/**
 * \internal
 */
Kirigami.BasicThemeDefinition {
    id: theme
    //NOTE: this is useless per se, but it forces the Material attached property to be created
    Material.elevation: 2

    textColor: theme.Material.foreground
    disabledTextColor: Qt.rgba(theme.textColor.r, theme.textColor.g, theme.textColor.b, 0.6)

    highlightColor: theme.Material.accent
    //FIXME: something better?
    highlightedTextColor: theme.Material.background
    backgroundColor: theme.Material.background
    alternateBackgroundColor: Qt.darker(theme.Material.background, 1.05)

    hoverColor: theme.Material.highlightedButtonColor
    focusColor: theme.Material.highlightedButtonColor

    activeTextColor: theme.Material.primary
    activeBackgroundColor: theme.Material.primary
    linkColor: "#2980B9"
    linkBackgroundColor: "#2980B9"
    visitedLinkColor: "#7F8C8D"
    visitedLinkBackgroundColor: "#7F8C8D"
    negativeTextColor: "#DA4453"
    negativeBackgroundColor: "#DA4453"
    neutralTextColor: "#F67400"
    neutralBackgroundColor: "#F67400"
    positiveTextColor: "#27AE60"
    positiveBackgroundColor: "#27AE60"

    buttonTextColor: theme.Material.foreground
    buttonBackgroundColor: theme.Material.buttonColor
    buttonAlternateBackgroundColor: Qt.darker(theme.Material.buttonColor, 1.05)
    buttonHoverColor: theme.Material.highlightedButtonColor
    buttonFocusColor: theme.Material.highlightedButtonColor

    viewTextColor: theme.Material.foreground
    viewBackgroundColor: theme.Material.dialogColor
    viewAlternateBackgroundColor: Qt.darker(theme.Material.dialogColor, 1.05)
    viewHoverColor: theme.Material.listHighlightColor
    viewFocusColor: theme.Material.listHighlightColor

    selectionTextColor: theme.Material.primaryHighlightedTextColor
    selectionBackgroundColor: theme.Material.textSelectionColor
    selectionAlternateBackgroundColor: Qt.darker(theme.Material.textSelectionColor, 1.05)
    selectionHoverColor: theme.Material.highlightedButtonColor
    selectionFocusColor: theme.Material.highlightedButtonColor

    tooltipTextColor: fontMetrics.Material.foreground
    tooltipBackgroundColor: fontMetrics.Material.tooltipColor
    tooltipAlternateBackgroundColor: Qt.darker(theme.Material.tooltipColor, 1.05)
    tooltipHoverColor: fontMetrics.Material.highlightedButtonColor
    tooltipFocusColor: fontMetrics.Material.highlightedButtonColor

    complementaryTextColor: fontMetrics.Material.foreground
    complementaryBackgroundColor: fontMetrics.Material.background
    complementaryAlternateBackgroundColor: Qt.lighter(fontMetrics.Material.background, 1.05)
    complementaryHoverColor: theme.Material.highlightedButtonColor
    complementaryFocusColor: theme.Material.highlightedButtonColor

    headerTextColor: fontMetrics.Material.primaryTextColor
    headerBackgroundColor: fontMetrics.Material.primaryColor
    headerAlternateBackgroundColor: Qt.lighter(fontMetrics.Material.primaryColor, 1.05)
    headerHoverColor: theme.Material.highlightedButtonColor
    headerFocusColor: theme.Material.highlightedButtonColor

    defaultFont: fontMetrics.font

    property list<QtObject> children: [
        TextMetrics {
            id: fontMetrics
            //this is to get a source of dark colors
            Material.theme: Material.Dark
        }
    ]

    onSync: object => {
        //TODO: actually check if it's a dark or light color
        if (object.Kirigami.Theme.colorSet === Kirigami.Theme.Complementary) {
            object.Material.theme = Material.Dark
        } else {
            object.Material.theme = Material.Light
        }

        object.Material.foreground = object.Kirigami.Theme.textColor
        object.Material.background = object.Kirigami.Theme.backgroundColor
        object.Material.primary = object.Kirigami.Theme.highlightColor
        object.Material.accent = object.Kirigami.Theme.highlightColor
    }
}
