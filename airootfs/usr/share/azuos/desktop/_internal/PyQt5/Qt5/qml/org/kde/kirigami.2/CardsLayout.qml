/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.6
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami

/**
 * @brief A QtQuick.Layouts.GridLayout optimized for showing a couple of columns
 * of cards, depending on the available space.
 *
 * This should be used when the cards to be displayed, are not instantiated by
 * a model or are instantiated by a model that always has very few items
 * (in the case of a big model, use CardsListView or CardsGridView instead).
 *
 * The cards are presented in a grid of at least one column, which will remain
 * centered. Note that the layout will automatically add and remove columns
 * depending on the size available.
 *
 * @note A CardsLayout should always be contained within a
 * QtQuick.Layouts.ColumnLayout.
 *
 * @since org.kde.kirigami 2.4
 * @inherit QtQuick.Layouts.GridLayout
 */
GridLayout {
    /**
     * @brief This property holds the maximum number of columns.
     *
     * default: ``2``
     *
     * @since org.kde.kirigami 2.5
     */
    property int maximumColumns: 2

    /**
     * @brief This property holds the maximum width the columns may have.
     *
     * If the default needs to be overridden for some reason,
     * it is advised to express this unit as a multiple
     * of Kirigami.Units.gridUnit.
     *
     * default: ``20 * Kirigami.Units.gridUnit``
     */
    property int maximumColumnWidth: Kirigami.Units.gridUnit * 20

    /**
     * @brief This property holds the minimum width the columns may have.
     *
     * default: ``12 * Kirigami.Units.gridUnit``
     *
     * @since org.kde.kirigami 2.5
     */
    property int minimumColumnWidth: Kirigami.Units.gridUnit * 12

    columns: Math.max(1, Math.min(maximumColumns > 0 ? maximumColumns : Infinity,
                                  Math.floor(width/minimumColumnWidth),
                                  Math.ceil(width/maximumColumnWidth)));

    rowSpacing: Kirigami.Units.largeSpacing * columns
    columnSpacing: Kirigami.Units.largeSpacing * columns


    // NOTE: this default width which defaults to 2 columns is just to remove a binding loop on columns
    width: maximumColumnWidth*2 + Kirigami.Units.largeSpacing
    // same computation of columns, but on the parent size
    Layout.preferredWidth: maximumColumnWidth * Math.max(1, Math.min(maximumColumns > 0 ? maximumColumns : Infinity,
                                  Math.floor(parent.width/minimumColumnWidth),
                                  Math.ceil(parent.width/maximumColumnWidth))) + Kirigami.Units.largeSpacing * (columns - 1)

    Layout.maximumWidth: Layout.preferredWidth
    Layout.alignment: Qt.AlignHCenter

    Component.onCompleted: childrenChanged()
    onChildrenChanged: {
        for (let i = 0; i < children.length; ++i) {
            children[i].Layout.fillHeight = true;
        }
    }
}
