/*
 *  SPDX-FileCopyrightText: 2018 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.10
import QtQuick.Layouts 1.2
import org.kde.kirigami 2.4 as Kirigami
import "private" as P


//TODO KF6: remove the whole class?
/**
 * @brief CardsGridView is used to display a grid of Cards generated from any model.
 *
 * The behavior is same as CardsLayout, and it allows cards to be put in one or two
 * columns depending on the available width.
 *
 * GridView has the limitation that every Card must have the same exact height,
 * so cellHeight must be manually set to a value in which the content fits
 * for every item.
 *
 * If possible use cards only when you don't need to instantiate a lot
 * and use CardsLayout instead.
 *
 * @see kirigami::CardsLayout
 * @see kirigami::CardsListView
 * @see <a href="https://develop.kde.org/hig/components/editing/grid">KDE Human Interface Guidelines on Grids</a>
 * @since org.kde.kirigami 2.4
 * @inherit QtQuick.GridView
 */
P.CardsGridViewPrivate {
    id: root

    /**
     * @brief This property sets whether the view should fill the first row with columns
     * even when there is not enough space.
     *
     * Set this to @c true if you want to stop the view from filling the first row with columns,
     * even when delegates can't even fill the first row.
     *
     * default: ``true``
     */
    property bool extraColumns: true

    /**
     * @brief This property holds the number of columns the gridview has.
     * @since org.kde.kirigami 2.5
     */
    readonly property int columns: {
        const minFromWidth = Math.floor(width / minimumColumnWidth)
        const maxFromWidth = Math.ceil(width / maximumColumnWidth)
        const maxColumns = extraColumns ? maximumColumns : count
        return Math.max(1,Math.min(minFromWidth,maxFromWidth,maxColumns))
    }

    /**
     * @brief This property holds the maximum number of columns the gridview may have.
     *
     * default: ``Kirigami.Units.maximumInteger()``
     *
     * @since org.kde.kirigami 2.5
     */
    property int maximumColumns: Kirigami.Units.maximumInteger

    /**
     * @brief This property holds the maximum width that the columns may have.
     *
     * The cards will never become wider than this size; when the GridView is wider
     * than maximumColumnWidth, it will switch from one to two columns.
     *
     * If the default needs to be overridden for some reason,
     * it is advised to express this unit as a multiple
     * of Kirigami.Units.gridUnit.
     *
     * default: ``20 * Kirigami.Units.gridUnit``
     */
    property int maximumColumnWidth: Kirigami.Units.gridUnit * 20

    /**
     * @brief This property holds the minimum width that the columns may have.
     *
     * The cards will never become thinner than this.
     *
     * If the default needs to be overridden for some reason,
     * it is advised to express this unit as a multiple
     * of Kirigami.Units.gridUnit.
     *
     * default: ``12 * Kirigami.Units.gridUnit``
     *
     * @since org.kde.kirigami 2.5
     */
    property int minimumColumnWidth: Kirigami.Units.gridUnit * 12

    cellWidth: Math.floor(width/columns)
    cellHeight: Math.max(Kirigami.Units.gridUnit * 15, Math.min(cellWidth, maximumColumnWidth) / 1.2)

    /**
     * @brief This property holds the delegate of the CardsGridView.
     * @see <a href="https://doc.qt.io/qt-5/qml-qtquick-gridview.html#delegate-prop">GridView.delegate</a>
     */
    default property alias delegate: root._delegateComponent

    topMargin: Kirigami.Units.largeSpacing * 2

    Keys.onPressed: event => {
        if (event.key === Qt.Key_Home) {
            positionViewAtBeginning();
            currentIndex = 0;
            event.accepted = true;
        }
        else if (event.key === Qt.Key_End) {
            positionViewAtEnd();
            currentIndex = count - 1;
            event.accepted = true;
        }
    }
}
