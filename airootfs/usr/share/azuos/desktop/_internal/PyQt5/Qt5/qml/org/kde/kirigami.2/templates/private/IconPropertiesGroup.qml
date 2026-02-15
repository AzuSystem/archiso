/*
 *  SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQml 2.1

/**
 * @brief Group of icon properties.
 * 
 * This is a subset of those used in QQC2, Kirigami.Action still needs the full one as it needs 100% api compatibility.
 *
 * @note Depending on the implementation, if a Freedesktop standard icon with the
 * specified name is not found, the ::source property will be used instead.
 */
QtObject {
    /**
     * @brief This property holds a Freedesktop standard icon name.
     *
     * The icon will be loaded from the selected icon theme, which can be set
     * by the platform or included with the app.
     *
     * @see kirigami::Icon::source
     */
    property string name
    
    /**
     * @brief This property holds the icon source.
     *
     * The icon will be loaded as a regular image.
     *
     * @see kirigami::Icon::source
     */
    property var source

    /**
     * @brief This property holds the icon tint color.
     *
     * The icon is tinted with the specified color, unless the color is set to "transparent".
     *
     * default: ``transparent``
     *
     * @see kirigami::Icon::color
     */
    property color color: "transparent"
}

