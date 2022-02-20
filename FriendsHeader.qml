import QtQuick 2.13
import QtQuick.Controls 2.5
import QtQuick.Dialogs 1.3
import Qt.labs.settings 1.0
import QtQuick.Layouts 1.3

Rectangle
{
    id: root
    height: 60
    signal headerButtonClicked()
    signal avatarSelected(string avatarUrl)
    RowLayout
    {
        anchors.fill: parent
        ToolButton
        {
            id: btnDrawer
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            text: "<font color='white'>\u2261</font>"
            font.pixelSize: 0.6 * root.height
            //bottomPadding: 10
            onClicked:
            {
                headerButtonClicked()
            }
        }
        Label
        {
            Layout.alignment: Qt.AlignCenter
            //Layout.fillWidth: true
            //anchors.centerIn: parent
            text: "Друзья"
            color: "white"
            font.pixelSize: root.height * 0.35
        }
        ToolButton
        {
            id: btnSettings
            Layout.alignment: Qt.AlignRight
            text: "<font color='white'>\u22ee</font>"
            font.pixelSize: 0.6 * root.height
            font.bold: true
            onClicked:
            {
                optionsMenu.open()
            }
            Menu
            {
                id: optionsMenu
                font.pointSize: 12
                width: 300
                MenuItem
                {
                    text: "Изменить изображение профиля"
                    onTriggered: fileDialog.open()
                }
                MenuItem
                {
                    text: "О приложении"
                    //onTriggered: settingsDialog.open()
                }
            }
        }
    }

    FileDialog
    {
        id: fileDialog
        title: "Выберите изображение"
        selectMultiple: false
        selectFolder: false
        nameFilters: ["Jpg files (*.jpg *.jpeg)", "Png files (*.png)"]
        folder: shortcuts.pictures
        onAccepted:
        {
            console.log("Chosen file: ", fileDialog.fileUrl)
            avatarSelected(fileDialog.fileUrl)
        }
    }

}
