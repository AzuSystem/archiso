// SPDX-FileCopyrightText: 2022 Felipe Kinoshita <kinofhek@gmail.com>
// SPDX-License-Identifier: GPL-2.0-or-later

import "templates" as T
import "private" as P

/**
 * AbstractChip is a visual object based on QtQuick.Controls.AbstractButton
 * that provides a way to display predetermined elements
 * with the visual styling of "tags" or "tokens". It provides
 * the look, the base properties, and signals for an AbstractButton.
 *
 * You can control its visual feedback with the following properties:
 * * `down: bool`: whether the chip component has been presssed (click feedback)
 * * `hoverEnabled: bool`: whether the chip supports hover event (hover feedback)
 * * `checked: bool`: whether the chip is in a checked state (check feedback)
 *
 * @since org.kde.kirigami 2.19
 * @inherit kirigami::templates::AbstractChip
 */
T.AbstractChip {
    id: root

    background: P.DefaultChipBackground {}
}
