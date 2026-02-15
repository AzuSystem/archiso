// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import QtQuick 2.15
import QtQuick.Templates 2.15 as T

/**
 * @brief AbstractChip is a visual object based on QtQuick.Controls.AbstractButton
 * that provides a friendly way to display predetermined elements
 * with the visual styling of "tags" or "tokens."
 *
 * @see kirigami::Chip
 * @since org.kde.kirigami 2.19
 * @inherit QtQuick.Controls.AbstractButton
 */
T.AbstractButton {
    id: chip

    /**
     * @brief This property holds whether or not to display a close button.
     *
     * default: ``true``
     */
    property bool closable: true

    /**
     * @brief This signal is emitted when the close button has been clicked.
     */
    signal removed()
}
