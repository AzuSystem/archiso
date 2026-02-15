/*
 *  SPDX-FileCopyrightText: 2012 by Sebastian Kügler <sebas@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.0
import QtQuick.Controls 2.0 as QQC2
import org.kde.kirigami 2.4 as Kirigami

/**
 * @brief A heading label used for subsections of texts.
 *
 * The characteristics of the text will be automatically set according to the
 * Kirigami.PlatformTheme. Use this components for section titles or headings in your UI,
 * for example page or section titles.
 *
 * Example usage:
 * @code{.qml}
 * import org.kde.kirigami 2.4 as Kirigami
 * [...]
 * Column {
 *     Kirigami.Heading {
 *         text: "Apples in the sunlight"
 *         level: 2
 *     }
 *   [...]
 * }
 * @endcode
 *
 * @see QtQuick.Controls.Label
 * @see QtQuick.Text
 * @see <a href="https://develop.kde.org/docs/getting-started/kirigami/style-typography">Typography in Kirigami</a>
 * @see <a href="https://develop.kde.org/hig/style/typography">KDE Human Interface Guidelines on Typography</a>
 * @inherit QtQuick.Controls.Label
 */
QQC2.Label {
    id: heading

    /**
     * @brief This property holds the level of the heading, determining its font size.
     *
     * Acceptable values range from 1 (big) to 5 (small).
     *
     * default: ``1``
     */
    property int level: 1

    /**
     * @brief This property holds the point size between heading levels.
     *
     * default: ``0``
     *
     * @deprecated
     */
    property int step: 0

    /**
     * @brief This enumeration defines heading types.
     *
     * This enum helps with heading visibility (making it less or more important).
     */
    enum Type {
        Normal,
        Primary,
        Secondary
    }

    /**
     * @brief This property holds the heading type.
     *
     * The following values are allowed:
     * * ``Kirigami.Heading.Type.Normal``: Creates a normal heading (default).
     * * ``Kirigami.Heading.Type.Primary``: Makes the heading more prominent. Useful
     *   when making the heading bigger is not enough.
     * * ``Kirigami.Heading.Type.Secondary``: Makes the heading less prominent.
     *   Useful when an heading is for a less important section in an application.
     *
     * @since KDE Frameworks 5.82
     * @property Kirigami.Heading.Type type
     */
    property int type: Kirigami.Heading.Type.Normal

    font.pointSize: __headerPointSize(level)
    font.weight: type === Kirigami.Heading.Type.Primary ? Font.DemiBold : Font.Normal

    opacity: type === Kirigami.Heading.Type.Secondary ? 0.7 : 1

    Accessible.role: Accessible.Heading

    // TODO KF6: Remove this public method
    function headerPointSize(l) {
        console.warn("org.kde.plasma.extras/Heading::headerPointSize() is deprecated. Use font.pointSize directly instead");
        return __headerPointSize(l);
    }

    //
    //  W A R N I N G
    //  -------------
    //
    // This method is not part of the Kirigami API.  It exists purely as an
    // implementation detail.  It may change from version to
    // version without notice, or even be removed.
    //
    // We mean it.
    //
    function __headerPointSize(level) {
        const n = Kirigami.Theme.defaultFont.pointSize;
        switch (level) {
        case 1:
            return n * 1.35 + step;
        case 2:
            return n * 1.20 + step;
        case 3:
            return n * 1.15 + step;
        case 4:
            return n * 1.10 + step;
        default:
            return n + step;
        }
    }
}
