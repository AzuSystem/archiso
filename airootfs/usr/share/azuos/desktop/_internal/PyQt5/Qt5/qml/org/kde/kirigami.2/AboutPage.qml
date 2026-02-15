/*
 *  SPDX-FileCopyrightText: 2018 Aleix Pol Gonzalez <aleixpol@blue-systems.com>
 *
 *  SPDX-License-Identifier: LGPL-2.0-or-later
 */

import QtQuick 2.1
import QtQuick.Controls 2.4 as QQC2
import QtQuick.Window 2.15
import QtQuick.Layouts 1.3
import org.kde.kirigami 2.19 as Kirigami

//TODO KF6: move somewhere else? kirigami addons?
/**
 * @brief This component is an "About" page that displays data about the application.
 *
 * It allows showing the defined copyright notice of the application together
 * with the contributors and some information of which platform it's running on.
 *
 * @see <a href="https://develop.kde.org/docs/getting-started/kirigami/advanced-add_about_page">About Page in Kirigami</a>
 * @see <a href="https://develop.kde.org/hig/components/assistance/aboutview">KDE Human Interface Guidelines on Application Information</a>
 * @see kirigami::AboutItem
 * @since KDE Frameworks 5.52
 * @since org.kde.kirigami 2.6
 * @inherit kirigami::ScrollablePage
 */
Kirigami.ScrollablePage {
    id: page

//BEGIN properties
    /**
     * @brief This property holds a JSON object with the structure of KAboutData
     * that will be displayed by the AboutPage.
     *
     * @see KAboutData
     *
     * Note that ``displayName``, ``version``, ``description``, and ``authors``
     * keys are mandatory, while the rest of the keys are optional. Make sure
     * to fill out as many optional keys as you can to provide more accurate
     * crediting information, especially ``copyrightStatement``, which
     * facilitates the management of the licenses used in your program.
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
     * @property KAboutData aboutData
     */
    property alias aboutData: aboutItem.aboutData

    /**
     * @brief This property holds a link to a "Get Involved" page.
     *
     * default: `"https://community.kde.org/Get_Involved" when your application id starts with "org.kde.", otherwise is empty`
     *
     * @property url getInvolvedUrl
     */
    property alias getInvolvedUrl: aboutItem.getInvolvedUrl

    /**
     * @brief This property holds a link to a "Donate" page.
     * @since KDE Frameworks 5.101
     *
     * default: `"https://kde.org/community/donations" when application id starts with "org.kde.", otherwise it is empty.`
     */
    property alias donateUrl: aboutItem.donateUrl

    /** @internal */
    default property alias _content: aboutItem._content
//END properties

    title: qsTr("About %1").arg(page.aboutData.displayName)

    Kirigami.AboutItem {
        id: aboutItem
        wideMode: page.width >= aboutItem.implicitWidth

        _usePageStack: applicationWindow().pageStack ? true : false
    }
}
