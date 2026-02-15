import QtQuick 2.15
import QtQuick.Controls 2.15
import QtQuick.Window 2.15

Window {
	id: window
	title: "Azura Desktop"
	visible: true
	width: screen.width
	height: screen.height
	minimumWidth: width
    maximumWidth: width
    minimumHeight: height
    maximumHeight: height
    // flags: Qt.FramelessWindowHint
    flags: Qt.FramelessWindowHint | Qt.WindowStaysOnBottomHint
    // flags: Qt.FramelessWindowHint | Qt.X11BypassWindowManagerHint | Qt.WindowStaysOnBottomHint
    color: "transparent"

    property var launcherClass: launcher // ive been stuck for 3 WHOLE HOURS trying to get this into AppIcon.qml, this was the fix?????

    Rectangle {
    	width: parent.width - 20
    	height: parent.height - 20
    	color: "#00ffffff"
    	anchors.centerIn: parent

		// ListModel {
		// 	id: apps
    	// 	ListElement { name: "App Name" }
    	// 	ListElement { name: "App Name" }
    	// 	ListElement { name: "App Name" }
    	// 	ListElement { name: "App Name" }
    	// 	ListElement { name: "App Name" }
    	// }

    	GridView {
    		anchors.fill: parent
    		cellWidth: 95 + 20
    		cellHeight: 95 + 20
    		model: apps
    		// model: launcher.launch_item("vlc", "")

    		delegate: AppIcon {
    			// launcher: launcher
    			launcher: window.launcherClass // weird workaround i think, to get launcher function in the element 
    			name: apps[index].name
    			src: apps[index].icon.toString() // src is the app icon
    			path: apps[index].path
    		}
       	}
    }
}
