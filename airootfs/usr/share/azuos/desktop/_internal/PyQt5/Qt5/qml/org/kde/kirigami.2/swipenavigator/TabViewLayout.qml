import QtQuick 2.12
import QtQuick.Layouts 1.12
import QtQuick.Controls 2.12 as QQC2
import org.kde.kirigami 2.12 as Kirigami

/**
 * Control for dynamically moving a bar above or below a content item,
 * e.g. to move tabs to the bottom on mobile.
 *
 * @inherit QtQuick.Item
 */
Item {
    id: __root

    /**
     * @brief Position options for TabViewLayout.
     */
    enum Position {
        Top,
        Bottom
    }

    /**
     * @brief The position of the bar in relation to the contentItem.
     *
     * default: `Position.Bottom on mobile, and Position.Top otherwise`
     *
     * @see ::Position
     */
    property int position: Kirigami.Settings.isMobile ? TabViewLayout.Position.Bottom : TabViewLayout.Position.Top

    required property Item bar
    onBarChanged: {
        bar.parent = __grid
        bar.Layout.row = Qt.binding(() => (__root.position === TabViewLayout.Position.Bottom) ? 1 : 0)
        bar.Layout.fillWidth = true
        if (bar instanceof QQC2.ToolBar) {
            bar.position = Qt.binding(() => (__root.position === TabViewLayout.Position.Bottom) ? QQC2.ToolBar.Footer : QQC2.ToolBar.Header)
        }
    }

    required property Item contentItem
    onContentItemChanged: {
        contentItem.parent = __grid
        contentItem.Layout.row = Qt.binding(() => (__root.position === TabViewLayout.Position.Bottom) ? 0 : 1)
        contentItem.Layout.fillWidth = true
        contentItem.Layout.fillHeight = true
    }

    implicitWidth: __grid.implicitWidth
    implicitHeight: __grid.implicitHeight

    GridLayout {
        id: __grid
        children: [__root.bar, __root.contentItem]

        rowSpacing: 0
        columns: 1

        anchors.fill: parent
    }
}
