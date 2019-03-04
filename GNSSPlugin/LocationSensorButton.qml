/* Copyright 2018 Esri
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *    http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 *
 */

import QtQuick 2.9
import QtQuick.Controls 2.1
import QtQuick.Layouts 1.1

import ArcGIS.AppFramework 1.0

import "./controls"

StyledImageButton {
    id: button

    //--------------------------------------------------------------------------

    property StackView stackView
    property PositionSourceManager positionSourceManager

    readonly property bool isConnecting: positionSourceManager && positionSourceManager.isConnecting
    readonly property bool isConnected: positionSourceManager && positionSourceManager.isConnected
    readonly property bool isWarmingUp: positionSourceManager && positionSourceManager.isWarmingUp

    property bool blinkTrigger: false
    property bool blinkState: false

    // set these to provide access to location settings
    property var settingsTabContainer
    property var settingsTabLocation

    //--------------------------------------------------------------------------

    color: "black"
    source: isConnecting
            ? (blinkState ? "./images/satellite-link.png" : "./images/satellite-0.png")
            : isWarmingUp
              ? "./images/satellite-%1.png".arg(positionSourceManager.positionCount % 4)
              : isConnected
                ? (blinkState ? "./images/satellite-f.png" : "./images/satellite.png")
                : ""

    visible: positionSourceManager && !positionSourceManager.onDetailedSettingsPage && (positionSourceManager.active || isConnecting)
    enabled: visible && source > ""

    //--------------------------------------------------------------------------

    Timer {
        interval: 250
        repeat: true
        running: button.visible

        onTriggered: {
            if (blinkTrigger || isConnecting) {
                blinkState = !blinkState;
                blinkTrigger = false;
            }
        }
    }

    //--------------------------------------------------------------------------

    Connections {
        target: positionSourceManager

        onNewPosition: {
            Qt.callLater(activity);
        }
    }

    function activity() {
        blinkTrigger = true;
    }

    //--------------------------------------------------------------------------

    onClicked: {
        forceActiveFocus();
        Qt.inputMethod.hide();

        stackView.push(positionSourceManager.isGNSS ? gnssInfoPage : locationInfoPage);
    }

    //--------------------------------------------------------------------------

    Component {
        id: locationInfoPage

        LocationInfoPage {
            positionSourceManager: button.positionSourceManager

            stackView: button.stackView
            settingsTabContainer: button.settingsTabContainer
            settingsTabLocation: button.settingsTabLocation
        }
    }

    //--------------------------------------------------------------------------

    Component {
        id: gnssInfoPage

        GNSSInfoPage {
            positionSourceManager: button.positionSourceManager

            stackView: button.stackView
            settingsTabContainer: button.settingsTabContainer
            settingsTabLocation: button.settingsTabLocation
        }
    }

    //--------------------------------------------------------------------------
}