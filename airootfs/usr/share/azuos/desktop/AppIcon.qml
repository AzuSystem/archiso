import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.12


    	Button {

    		property QtObject launcher: null
    	
    		width: 95 + 20
    		height: 95 + 20

    		property string src: "assets/config.svg" // app icon
    		property string name: "App Name"
    		property string path: ""
    		// property var launchr


    		background: Rectangle {
    			width: parent.width - 20
    			height: parent.height - 20
	    		color: "#00ffffff"
    			anchors.centerIn: parent
	    		radius: 8
    		}

    		Item {
    			id: desktopIcon
    			anchors.fill: parent

    			// layer.enabled: true
    			// layer.smooth: true
	    		Rectangle {
	    			id: desktopIconBackground
	    			width: parent.width - 20
	    			height: parent.height - 20
		    		color: "#00000000"
		    		border.color: "#12ffffff"
		    		border.width: 1
	    			anchors.centerIn: parent
		    		radius: 8

		    		MouseArea {
		    			width: parent.width
		    			height: parent.height
		    			hoverEnabled: true

		    			onEntered: parent.color = "#12ffffff", parent.border.color = "#20ffffff", console.log(src)
		    			onExited: parent.color = "#01ffffff", parent.border.color = "#12ffffff"
		    			onClicked: {
		    				console.log(path)
		    				launcher.launch_item(path, "")
		    			}
		    		}
	    		}

	    		Column {
	    			width: parent.width
	    			// height: parent.height
	    			anchors.centerIn: parent

		    		Image {
		    			source: src
		    			width: 64
		    			height: 64
		    			anchors.horizontalCenter: parent.horizontalCenter
		    		}

		   			Text {
		   				text: name
		   				width: 64
		   				color: "#ffffff"
		   				anchors.horizontalCenter: parent.horizontalCenter
		   				horizontalAlignment: Text.AlignHCenter
		   				elide: Text.ElideRight
		   			}
		   		}
		   	}
	   		// layer.enabled: true
	        // layer.effect: DropShadow {
	        //     anchors.centerIn: parent
	        //     source: parent
	        //     color: "#80000000"
	        //     radius: 35
	        //     spread: 0.0
	        //     samples: 64
	        //     horizontalOffset: 0
	        //     verticalOffset: 12
	        // }
	      
	        DropShadow {
	            anchors.fill: desktopIcon
	            source: desktopIcon
	            color: "#4b000000"
	            radius: 7
	            samples: 64 
	            horizontalOffset: 0
	            verticalOffset: 2
	        }
    	}