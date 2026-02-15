/*
 *  SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Controls 2.4 as QQC2
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.20 as Kirigami

//TODO: Kf6: move somewhere else which can depend from KAboutData?
/**
 * @brief This component is an "About" item that displays data about the application.
 *
 * It allows showing the defind copyright notice of the application together
 * with the contributors and some information of which platform it's running on.
 *
 * @see <a href="https://develop.kde.org/docs/getting-started/kirigami/advanced-add_about_page">About Page in Kirigami</a>
 * @see <a href="https://develop.kde.org/hig/components/assistance/aboutview">KDE Human Interface Guidelines on Application Information</a>
 * @see kirigami::AboutPage
 * @since KDE Frameworks 5.87
 * @since org.kde.kirigami 2.19
 */
Item {
    id: aboutItem
    /**
     * @brief This property holds information that this component displays.
     *
     * The stored JSON information object has the same structure as KAboutData.
     *
     * Example usage:
     * @code{.json}
     * aboutData: {
     *    "displayName" : "KirigamiApp",
     *    "productName" : "kirigami/app",
     *    "componentName" : "kirigamiapp",
     *    "shortDescription" : "A Kirigami example",
     *    "homepage" : "",
     *    "bugAddress" : "submit@bugs.kde.org",
     *    "version" : "5.14.80",
     *    "otherText" : "",
     *    "authors" : [
     *        {
     *            "name" : "...",
     *            "task" : "",
     *            "emailAddress" : "somebody@kde.org",
     *            "webAddress" : "",
     *            "ocsUsername" : ""
     *        }
     *    ],
     *    "credits" : [],
     *    "translators" : [],
     *    "licenses" : [
     *        {
     *            "name" : "GPL v2",
     *            "text" : "long, boring, license text",
     *            "spdx" : "GPL-2.0"
     *        }
     *    ],
     *    "copyrightStatement" : "© 2010-2018 Plasma Development Team",
     *    "desktopFileName" : "org.kde.kirigamiapp"
     * }
     * @endcode
     *
     * @see KAboutData
     */
    property var aboutData

    /**
     * @brief This property holds a link to a "Get Involved" page.
     *
     * default: `"https://community.kde.org/Get_Involved" when application id starts with "org.kde.", otherwise it is empty.`
     */
    property url getInvolvedUrl: aboutData.desktopFileName.startsWith("org.kde.") ? "https://community.kde.org/Get_Involved" : ""

    /**
     * @brief This property holds a link to a "Donate" page.
     *
     * default: `"https://kde.org/community/donations" when application id starts with "org.kde.", otherwise it is empty.`
     */
    property url donateUrl: aboutData.desktopFileName.startsWith("org.kde.") ? "https://kde.org/community/donations" : ""

    /** @internal */
    property bool _usePageStack: false

    /**
     * @brief This property specifies whether about item is in wide mode.
     * @see kirigami::FormLayout::wideMode
     * @property bool wideMode
     */
    property alias wideMode: form.wideMode

    /** @internal */
    default property alias _content: form.data

    implicitHeight: form.implicitHeight
    implicitWidth: form.implicitWidth

    Component {
        id: personDelegate

        RowLayout {
            Layout.fillWidth: true
            property bool hasRemoteAvatar: (typeof(modelData.ocsUsername) !== "undefined" && modelData.ocsUsername.length > 0)

            spacing: Kirigami.Units.smallSpacing * 2

            Kirigami.Icon {
                id: avatarIcon

                implicitWidth: Kirigami.Units.iconSizes.medium
                implicitHeight: implicitWidth

                fallback: "user"
                source: hasRemoteAvatar && remoteAvatars.checked ? "https://store.kde.org/avatar/%1?s=%2".arg(modelData.ocsUsername).arg(width) : "user"
                visible: status !== Kirigami.Icon.Loading
            }

            // So it's clear that something is happening while avatar images are loaded
            QQC2.BusyIndicator {
                implicitWidth: Kirigami.Units.iconSizes.medium
                implicitHeight: implicitWidth

                visible: avatarIcon.status === Kirigami.Icon.Loading
                running: visible
            }

            QQC2.Label {
                Layout.fillWidth: true
                readonly property bool withTask: typeof(modelData.task) !== "undefined" && modelData.task.length > 0
                text: withTask ? qsTr("%1 (%2)").arg(modelData.name).arg(modelData.task) : modelData.name
                wrapMode: Text.WordWrap
            }

            QQC2.ToolButton {
                visible: typeof(modelData.ocsUsername) !== "undefined" && modelData.ocsUsername.length > 0
                icon.name: "get-hot-new-stuff"
                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: qsTr("Visit %1's KDE Store page").arg(modelData.name)
                onClicked: Qt.openUrlExternally("https://store.kde.org/u/%1".arg(modelData.ocsUsername))
            }

            QQC2.ToolButton {
                visible: typeof(modelData.emailAddress) !== "undefined" && modelData.emailAddress.length > 0
                icon.name: "mail-sent"
                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: qsTr("Send an email to %1").arg(modelData.emailAddress)
                onClicked: Qt.openUrlExternally("mailto:%1".arg(modelData.emailAddress))
            }

            QQC2.ToolButton {
                visible: typeof(modelData.webAddress) !== "undefined" && modelData.webAddress.length > 0
                icon.name: "globe"
                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                QQC2.ToolTip.visible: hovered
                QQC2.ToolTip.text: (typeof(modelData.webAddress) === "undefined" && modelData.webAddress.length > 0) ? "" : modelData.webAddress
                onClicked: Qt.openUrlExternally(modelData.webAddress)
            }
        }
    }

    Kirigami.FormLayout {
        id: form

        anchors.fill: parent

        GridLayout {
            columns: 2
            Layout.fillWidth: true

            Kirigami.Icon {
                Layout.rowSpan: 3
                Layout.preferredHeight: Kirigami.Units.iconSizes.huge
                Layout.preferredWidth: height
                Layout.maximumWidth: aboutItem.width / 3;
                Layout.rightMargin: Kirigami.Units.largeSpacing
                source: Kirigami.Settings.applicationWindowIcon || aboutItem.aboutData.programLogo || aboutItem.aboutData.programIconName || aboutItem.aboutData.componentName
            }

            Kirigami.Heading {
                Layout.fillWidth: true
                text: aboutItem.aboutData.displayName + " " + aboutItem.aboutData.version
                wrapMode: Text.WordWrap
            }

            Kirigami.Heading {
                Layout.fillWidth: true
                level: 2
                wrapMode: Text.WordWrap
                text: aboutItem.aboutData.shortDescription
            }

            RowLayout {
                spacing: Kirigami.Units.largeSpacing * 2

                UrlButton {
                    text: qsTr("Get Involved")
                    url: aboutItem.getInvolvedUrl
                    visible: url !== ""
                }

                UrlButton {
                    text: qsTr("Donate")
                    url: aboutItem.donateUrl
                    visible: url !== ""
                }

                UrlButton {
                    readonly property string theUrl: {
                        if (page.aboutData.bugAddress !== "submit@bugs.kde.org") {
                            return page.aboutData.bugAddress
                        }
                        const elements = page.aboutData.productName.split('/');
                        let url = `https://bugs.kde.org/enter_bug.cgi?format=guided&product=${elements[0]}&version=${page.aboutData.version}`;
                        if (elements.length === 2) {
                            url += "&component=" + elements[1];
                        }
                        return url;
                    }
                    text: qsTr("Report a Bug")
                    url: theUrl
                    visible: theUrl !== ""
                }
            }
        }

        Separator {
            Layout.fillWidth: true
        }

        Kirigami.Heading {
            Kirigami.FormData.isSection: true
            text: qsTr("Copyright")
        }

        QQC2.Label {
            Layout.leftMargin: Kirigami.Units.gridUnit
            text: aboutData.otherText
            visible: text.length > 0
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        QQC2.Label {
            Layout.leftMargin: Kirigami.Units.gridUnit
            text: aboutData.copyrightStatement
            visible: text.length > 0
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        UrlButton {
            Layout.leftMargin: Kirigami.Units.gridUnit
            url: aboutData.homepage
            visible: url.length > 0
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        OverlaySheet {
            id: licenseSheet
            property alias text: bodyLabel.text

            contentItem: SelectableLabel {
                id: bodyLabel
                text: licenseSheet.text
                wrapMode: Text.Wrap
            }
        }

        Component {
            id: licenseLinkButton

            RowLayout {
                Layout.leftMargin: Kirigami.Units.smallSpacing

                QQC2.Label { text: qsTr("License:") }

                LinkButton {
                    Layout.fillWidth: true
                    wrapMode: Text.WordWrap
                    text: modelData.name
                    onClicked: mouse => {
                        licenseSheet.text = modelData.text
                        licenseSheet.title = modelData.name
                        licenseSheet.open()
                    }
                }
            }
        }

        Component {
            id: licenseTextItem

            QQC2.Label {
                Layout.leftMargin: Kirigami.Units.smallSpacing
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                text: qsTr("License: %1").arg(modelData.name)
            }
        }

        Repeater {
            model: aboutData.licenses
            delegate: _usePageStack ? licenseLinkButton : licenseTextItem
        }

        Kirigami.Heading {
            Kirigami.FormData.isSection: visible
            text: qsTr("Libraries in use")
            Layout.fillWidth: true
            wrapMode: Text.WordWrap
            visible: Kirigami.Settings.information
        }

        Repeater {
            model: Kirigami.Settings.information
            delegate: QQC2.Label {
                Layout.leftMargin: Kirigami.Units.gridUnit
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                id: libraries
                text: modelData
            }
        }

        Repeater {
            model: aboutData.components
            delegate: QQC2.Label {
                Layout.fillWidth: true
                wrapMode: Text.WordWrap
                Layout.leftMargin: Kirigami.Units.gridUnit
                text: modelData.name + (modelData.version === "" ? "" : " %1".arg(modelData.version))
            }
        }

        Kirigami.Heading {
            Layout.fillWidth: true
            Kirigami.FormData.isSection: visible
            text: qsTr("Authors")
            wrapMode: Text.WordWrap
            visible: aboutData.authors.length > 0
        }

        QQC2.CheckBox {
            id: remoteAvatars
            visible: authorsRepeater.hasAnyRemoteAvatars
            checked: false
            text: qsTr("Show author photos")

            Timer {
                id: remotesThrottle
                repeat: false
                interval: 1
                onTriggered: {
                    let hasAnyRemotes = false;
                    for (let i = 0; i < authorsRepeater.count; ++i) {
                        const itm = authorsRepeater.itemAt(i);
                        if (itm.hasRemoteAvatar) {
                            hasAnyRemotes = true;
                            break;
                        }
                    }
                    authorsRepeater.hasAnyRemoteAvatars = hasAnyRemotes;
                }
            }
        }

        Repeater {
            id: authorsRepeater
            model: aboutData.authors
            property bool hasAnyRemoteAvatars
            delegate: personDelegate
            onCountChanged: remotesThrottle.start()
        }

        Kirigami.Heading {
            height: visible ? implicitHeight : 0
            Kirigami.FormData.isSection: visible
            text: qsTr("Credits")
            visible: repCredits.count > 0
        }

        Repeater {
            id: repCredits
            model: aboutData.credits
            delegate: personDelegate
        }

        Kirigami.Heading {
            height: visible ? implicitHeight : 0
            Kirigami.FormData.isSection: visible
            text: qsTr("Translators")
            visible: repTranslators.count > 0
        }

        Repeater {
            id: repTranslators
            model: aboutData.translators
            delegate: personDelegate
        }
    }
}
