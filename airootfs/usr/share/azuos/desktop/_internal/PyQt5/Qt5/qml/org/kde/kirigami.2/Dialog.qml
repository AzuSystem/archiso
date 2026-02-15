/*
    SPDX-FileCopyrightText: 2021 Devin Lin <espidev@gmail.com>
    SPDX-FileCopyrightText: 2021 Noah Davis <noahadvs@gmail.com>
    SPDX-FileCopyrightText: 2022 ivan tkachenko <me@ratijas.tk>
    SPDX-License-Identifier: LGPL-2.1-only OR LGPL-3.0-only OR LicenseRef-KDE-Accepted-LGPL
*/

import QtQuick 2.15
import QtQml 2.15
import QtQuick.Layouts 1.15
import QtQuick.Templates 2.15 as T
import QtQuick.Controls 2.15 as QQC2
import org.kde.kirigami 2.12 as Kirigami
import QtGraphicalEffects 1.12 as GE

/**
 * @brief Popup dialog that is used for short tasks and user interaction.
 *
 * Dialog consists of three components:
 * the <a href="https://doc.qt.io/qt-5/qml-qtquick-controls2-dialog.html#header-prop">header</a>,
 * the <a href="https://doc.qt.io/qt-5/qml-qtquick-controls2-popup.html#contentItem-prop">contentItem</a>,
 * and the <a href="https://doc.qt.io/qt-5/qml-qtquick-controls2-dialog.html#footer-prop">footer</a>.
 *
 * By default, the header is a heading with text specified by the
 * <a href="https://doc.qt.io/qt-5/qml-qtquick-controls2-dialog.html#title-prop">title</a> property.
 *
 * By default, the footer consists of a row of buttons specified by
 * the <a href="https://doc.qt.io/qt-5/qml-qtquick-controls2-dialog.html#standardButtons-prop">standardButtons</a>
 * and ::customFooterActions properties.
 *
 * The `implicitHeight` and `implicitWidth` of the dialog contentItem is
 * the primary hint used for the dialog size. The dialog will be the
 * minimum size required for the header, footer and content unless
 * it is larger than `maximumHeight` and `maximumWidth`. Use
 * `preferredHeight` and `preferredWidth` in order to manually specify
 * a size for the dialog.
 *
 * If the content height exceeds the maximum height of the dialog, the
 * dialog's contents will become scrollable.
 *
 * If the contentItem is a QtQuick.ListView,
 * the dialog will take care of the necessary scrollbars and scrolling behaviour.
 * Do @b not attempt
 * to nest ListViews (it must be the top level item), as the scrolling
 * behaviour will not be handled. Use ListView's `header` and `footer` instead.
 *
 * Example for a selection dialog:
 * @code{.qml}
 * import QtQuick 2.15
 * import QtQuick.Layouts 1.15
 * import QtQuick.Controls 2.15 as Controls
 * import org.kde.kirigami 2.19 as Kirigami
 *
 * Kirigami.Dialog {
 *     title: i18n("Dialog")
 *     padding: 0
 *     preferredWidth: Kirigami.Units.gridUnit * 16
 *
 *     standardButtons: Kirigami.Dialog.Ok | Kirigami.Dialog.Cancel
 *
 *     onAccepted: console.log("OK button pressed")
 *     onRejected: console.log("Rejected")
 *
 *     ColumnLayout {
 *         spacing: 0
 *         Repeater {
 *             model: 5
 *             delegate: Controls.CheckDelegate {
 *                 topPadding: Kirigami.Units.smallSpacing * 2
 *                 bottomPadding: Kirigami.Units.smallSpacing * 2
 *                 Layout.fillWidth: true
 *                 text: modelData
 *             }
 *         }
 *     }
 * }
 * @endcode
 *
 * Example with scrolling (ListView scrolling behaviour is handled by the Dialog):
 * @code{.qml}
 * Kirigami.Dialog {
 *     id: scrollableDialog
 *     title: i18n("Select Number")
 *
 *     ListView {
 *         id: listView
 *         // hints for the dialog dimensions
 *         implicitWidth: Kirigami.Units.gridUnit * 16
 *         implicitHeight: Kirigami.Units.gridUnit * 16
 *
 *         model: 100
 *         delegate: Controls.RadioDelegate {
 *             topPadding: Kirigami.Units.smallSpacing * 2
 *             bottomPadding: Kirigami.Units.smallSpacing * 2
 *             implicitWidth: listView.width
 *             text: modelData
 *         }
 *     }
 * }
 * @endcode
 *
 * There are also sub-components of the Dialog that target specific usecases,
 * and can reduce boilerplate code if used:
 *
 * @see kirigami::PromptDialog
 * @see kirigami::MenuDialog
 * @see <a href="https://develop.kde.org/hig/components/navigation/dialog">Human Interface Guidelines on Dialogs</a>
 * @see <a href="https://develop.kde.org/hig/components/assistance/message">Human Interface Guidelines on Modal Message Dialogs</a>
 * @inherit QtQuick.QtObject
 */
T.Dialog {
    id: root

    // TODO KF6: remove this property
    /**
     * @deprecated This property will be removed in the next major frameworks release (KF6)
     */
    property Item mainItem: contentControl.contentChildren.length > 0 ? contentControl.contentChildren[0] : null

    /**
     * @brief This property holds the dialog's contents; includes Items and QtObjects.
     * @property list<QtObject> dialogData
     */
    default property alias dialogData: contentControl.contentData

    /**
     * @brief This property holds the content items of the dialog.
     *
     * The initial height and width of the dialog is calculated from the
     * `implicitWidth` and `implicitHeight` of the content.
     *
     * @property list<Item> dialogChildren
     */
    property alias dialogChildren: contentControl.contentChildren

    /**
     * @brief This property sets the absolute maximum height the dialog can have.
     *
     * The height restriction is solely applied on the content, so if the
     * maximum height given is not larger than the height of the header and
     * footer, it will be ignored.
     *
     * This is the window height, subtracted by Kirigami.Units.largeSpacing on both the top
     * and bottom.
     * 
     * @see maximumHeight
     */
    readonly property real absoluteMaximumHeight: parent.height - Kirigami.Units.largeSpacing * 2

    /**
     * @brief This property holds the absolute maximum width the dialog can have.
     *
     * By default, it is the window width, subtracted by Kirigami.Units.largeSpacing on both
     * the top and bottom.
     * 
     * @see maximumWidth
     */
    readonly property real absoluteMaximumWidth: parent.width - Kirigami.Units.largeSpacing * 2

    /**
     * @brief This property holds the maximum height the dialog can have
     * (including the header and footer).
     *
     * The height restriction is solely enforced on the content, so if the
     * maximum height given is not larger than the height of the header and
     * footer, it will be ignored.
     *
     * By default, this is ::absoluteMaximumHeight.
     */
    property real maximumHeight: absoluteMaximumHeight

    /**
     * @brief This property holds the maximum width the dialog can have.
     *
     * By default, this is ::absoluteMaximumWidth.
     */
    property real maximumWidth: absoluteMaximumWidth

    /**
     * @brief This property holds the preferred height of the dialog.
     *
     * The content will receive a hint for how tall it should be to have
     * the dialog to be this height.
     *
     * If the content, header or footer require more space, then the height
     * of the dialog will expand to the necessary amount of space.
     */
    property real preferredHeight: -1

    /**
     * @brief This property holds the preferred width of the dialog.
     *
     * The content will receive a hint for how wide it should be to have
     * the dialog be this wide.
     *
     * If the content, header or footer require more space, then the width
     * of the dialog will expand to the necessary amount of space.
     */
    property real preferredWidth: -1


    /**
     * @brief This property holds the component to the left of the footer buttons.
     */
    property Component footerLeadingComponent

    /**
     * @brief his property holds the component to the right of the footer buttons.
     */
    property Component footerTrailingComponent

    /**
     * @brief This property sets whether to show the close button in the header.
     */
    property bool showCloseButton: true

    /**
     * @brief This property sets whether the footer button style should be flat.
     */
    property bool flatFooterButtons: false

    /**
     * @brief This property holds the custom actions displayed in the footer.
     *
     * Example usage:
     * @code{.qml}
     * import QtQuick 2.15
     * import QtQuick.Controls 2.15 as Controls
     * import org.kde.kirigami 2.18 as Kirigami
     *
     * Kirigami.PromptDialog {
     *     id: dialog
     *     title: i18n("Confirm Playback")
     *     subtitle: i18n("Are you sure you want to play this song? It's really loud!")
     *
     *     standardButtons: Kirigami.Dialog.Cancel
     *     customFooterActions: [
     *         Kirigami.Action {
     *             text: i18n("Play")
     *             iconName: "media-playback-start"
     *             onTriggered: {
     *                 //...
     *                 dialog.close();
     *             }
     *         }
     *     ]
     * }
     * @endcode
     * @see kirigami::Action
     */
    property list<Kirigami.Action> customFooterActions

    // default standard button
    standardButtons: QQC2.Dialog.Close

    function standardButton(button): T.AbstractButton {
        // in case a footer is redefined
        if (footer instanceof T.DialogButtonBox) {
            return footer.standardButton(button);
        } else if (footer === footerToolBar) {
            return dialogButtonBox.standardButton(button);
        } else {
            return null;
        }
    }

    // calculate dimensions
    implicitWidth: contentItem.implicitWidth + leftPadding + rightPadding // maximum width enforced from our content (one source of truth) to avoid binding loops
    implicitHeight: contentItem.implicitHeight + topPadding + bottomPadding
                    + (implicitHeaderHeight > 0 ? implicitHeaderHeight + spacing : 0)
                    + (implicitFooterHeight > 0 ? implicitFooterHeight + spacing : 0);

    // misc. dialog settings
    closePolicy: QQC2.Popup.CloseOnEscape | QQC2.Popup.CloseOnReleaseOutside
    modal: true
    clip: false
    padding: 0

    // determine parent so that popup knows which window to popup in
    // we want to open the dialog in the center of the window, if possible
    Component.onCompleted: {
        if (typeof applicationWindow !== "undefined") {
            parent = applicationWindow().overlay;
        }
    }

    // center dialog
    x: Math.round((parent.width - width) / 2)
    y: Math.round((parent.height - height) / 2) + Kirigami.Units.gridUnit * 2 * (1 - opacity) // move animation

    // dialog enter and exit transitions
    enter: Transition {
        NumberAnimation { property: "opacity"; from: 0; to: 1; easing.type: Easing.InOutQuad; duration: Kirigami.Units.longDuration }
    }
    exit: Transition {
        NumberAnimation { property: "opacity"; from: 1; to: 0; easing.type: Easing.InOutQuad; duration: Kirigami.Units.longDuration }
    }

    // black background, fades in and out
    QQC2.Overlay.modal: Rectangle {
        color: Qt.rgba(0, 0, 0, 0.3)

        // the opacity of the item is changed internally by QQuickPopup on open/close
        Behavior on opacity {
            OpacityAnimator {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
    }

    // dialog view background
    background: Item {
        GE.RectangularGlow {
            anchors.fill: rect
            anchors.topMargin: 1
            cornerRadius: rect.radius * 2
            glowRadius: 2
            spread: 0.2
            color: Qt.rgba(0, 0, 0, 0.3)
        }

        Rectangle {
            id: rect
            anchors.fill: parent
            Kirigami.Theme.colorSet: Kirigami.Theme.View
            Kirigami.Theme.inherit: false
            color: Kirigami.Theme.backgroundColor
            radius: Kirigami.Units.smallSpacing
        }
    }

    // dialog content
    contentItem: ColumnLayout {
        QQC2.ScrollView {
            id: contentControl

            // ensure view colour scheme, and background color
            Kirigami.Theme.inherit: false
            Kirigami.Theme.colorSet: Kirigami.Theme.View

            QQC2.ScrollBar.horizontal.policy: QQC2.ScrollBar.AlwaysOff

            // height of everything else in the dialog other than the content
            property real otherHeights: root.header.height + root.footer.height + root.topPadding + root.bottomPadding;

            property real calculatedMaximumWidth: Math.min(root.absoluteMaximumWidth, root.maximumWidth) - root.leftPadding - root.rightPadding
            property real calculatedMaximumHeight: Math.min(root.absoluteMaximumHeight, root.maximumHeight) - root.topPadding - root.bottomPadding
            property real calculatedImplicitWidth: (contentChildren.length === 1 && contentChildren[0].implicitWidth > 0
                ? contentChildren[0].implicitWidth
                : (contentItem.implicitWidth > 0 ? contentItem.implicitWidth : contentItem.width)) + leftPadding + rightPadding
            property real calculatedImplicitHeight: (contentChildren.length === 1 && contentChildren[0].implicitHeight > 0
                ? contentChildren[0].implicitHeight
                : (contentItem.implicitHeight > 0 ? contentItem.implicitHeight : contentItem.height)) + topPadding + bottomPadding

            // how do we deal with the scrollbar width?
            // - case 1: the dialog itself has the preferredWidth set
            //   -> we hint a width to the content so it shrinks to give space to the scrollbar
            // - case 2: preferredWidth not set, so we are using the content's implicit width
            //   -> we expand the dialog's width to accommodate the scrollbar width (to respect the content's desired width)

            // don't enforce preferred width and height if not set
            Layout.preferredWidth: (root.preferredWidth >= 0 ? root.preferredWidth : calculatedImplicitWidth)
            Layout.preferredHeight: root.preferredHeight >= 0 ? root.preferredHeight - otherHeights : calculatedImplicitHeight

            Layout.fillWidth: true
            Layout.maximumWidth: calculatedMaximumWidth
            Layout.maximumHeight: calculatedMaximumHeight - otherHeights // we enforce maximum height solely from the content

            // give an implied width and height to the contentItem so that features like word wrapping/eliding work
            // cannot placed directly in contentControl as a child, so we must use a property
            property var widthHint: Binding {
                target: contentControl.contentChildren[0] || null
                property: "width"

                // we want to avoid horizontal scrolling, so we apply maximumWidth as a hint if necessary
                property real preferredWidthHint: contentControl.contentItem.width
                property real maximumWidthHint: contentControl.calculatedMaximumWidth - contentControl.leftPadding - contentControl.rightPadding

                value: Math.min(maximumWidthHint, preferredWidthHint)

                restoreMode: Binding.RestoreBinding
            }
        }
    }

    header: T.Control {
        implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                                implicitContentWidth + leftPadding + rightPadding)
        implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                                implicitContentHeight + topPadding + bottomPadding)

        padding: Kirigami.Units.largeSpacing
        bottomPadding: verticalPadding + headerSeparator.implicitHeight // add space for bottom separator

        contentItem: RowLayout {
            Kirigami.Heading {
                id: heading
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignVCenter
                level: 2
                text: root.title === "" ? " " : root.title // always have text to ensure header height
                elide: Text.ElideRight

                // use tooltip for long text that is elided
                QQC2.ToolTip.visible: truncated && titleHoverHandler.hovered
                QQC2.ToolTip.text: root.title
                HoverHandler { id: titleHoverHandler }
            }
            Kirigami.Icon {
                id: closeIcon
                visible: root.showCloseButton

                // We want to position the close button in the top-right
                // corner if the header is very tall, but we want to
                // vertically center it in a short header
                readonly property bool tallHeader: parent.height > (Kirigami.Units.iconSizes.smallMedium + Kirigami.Units.largeSpacing + Kirigami.Units.largeSpacing)
                Layout.alignment: tallHeader ? Qt.AlignRight | Qt.AlignTop : Qt.AlignRight | Qt.AlignVCenter
                Layout.topMargin: tallHeader ? Kirigami.Units.largeSpacing : 0
                implicitHeight: Kirigami.Units.iconSizes.smallMedium
                implicitWidth: implicitHeight

                source: closeMouseArea.containsMouse ? "window-close" : "window-close-symbolic"
                active: closeMouseArea.containsMouse
                MouseArea {
                    id: closeMouseArea
                    hoverEnabled: Qt.styleHints.useHoverEffects
                    anchors.fill: parent
                    onClicked: mouse => root.reject()
                }
            }
        }

        // header background
        background: Kirigami.ShadowedRectangle {
            corners.topLeftRadius: Kirigami.Units.smallSpacing
            corners.topRightRadius: Kirigami.Units.smallSpacing
            Kirigami.Theme.colorSet: Kirigami.Theme.Header
            Kirigami.Theme.inherit: false
            color: Kirigami.Theme.backgroundColor
            Kirigami.Separator {
                id: headerSeparator
                width: parent.width
                anchors.bottom: parent.bottom
            }
        }
    }

    // use top level control rather than toolbar, since toolbar causes button rendering glitches
    footer: T.Control {
        id: footerToolBar

        // if there is nothing in the footer, still maintain a height so that we can create a rounded bottom buffer for the dialog
        property bool bufferMode: contentItem.implicitHeight === 0
        implicitHeight: bufferMode ? Kirigami.Units.smallSpacing : contentItem.implicitHeight

        leftPadding: 0; rightPadding: 0; bottomPadding: 0
        topPadding: bufferMode ? 0 : footerSeparator.implicitHeight // add space for the separator above the footer

        contentItem: RowLayout {
            spacing: parent.spacing
            // Don't let user interact with footer during transitions
            enabled: root.opened

            Loader {
                id: leadingLoader
                sourceComponent: root.footerLeadingComponent
            }

            // footer buttons
            QQC2.DialogButtonBox {
                // we don't explicitly set padding, to let the style choose the padding
                id: dialogButtonBox
                standardButtons: root.standardButtons
                visible: count > 0

                Layout.fillWidth: true
                Layout.alignment: dialogButtonBox.alignment

                position: QQC2.DialogButtonBox.Footer

                // ensure themes don't add a background, since it can lead to visual inconsistencies
                // with the rest of the dialog
                background: null

                // we need to hook all of the buttonbox events to the dialog events
                onAccepted: root.accept()
                onRejected: root.reject()
                onApplied: root.applied()
                onDiscarded: root.discarded()
                onHelpRequested: root.helpRequested()
                onReset: root.reset()

                // add custom footer buttons
                Repeater {
                    model: root.customFooterActions
                    // we have to use Button instead of ToolButton, because ToolButton has no visual distinction when disabled
                    delegate: QQC2.Button {
                        flat: flatFooterButtons
                        action: modelData
                        visible: modelData.visible
                    }
                }
            }

            Loader {
                id: trailingLoader
                sourceComponent: root.footerTrailingComponent
            }
        }

        background: Kirigami.ShadowedRectangle {
            // curved footer bottom corners
            corners.bottomLeftRadius: Kirigami.Units.smallSpacing
            corners.bottomRightRadius: Kirigami.Units.smallSpacing

            // we act as a content buffer if nothing is in the footer
            Kirigami.Theme.colorSet: footerToolBar.bufferMode ? Kirigami.Theme.View : Kirigami.Theme.Window
            Kirigami.Theme.inherit: false
            color: Kirigami.Theme.backgroundColor

            // separator above footer
            Kirigami.Separator {
                id: footerSeparator
                visible: !footerToolBar.bufferMode
                width: parent.width
                anchors.top: parent.top
            }
        }
    }
}
