import QtQuick 2.13
import QtQuick.Window 2.12
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQml 2.3
import QtQuick.Controls.Universal 2.3
import QtGraphicalEffects 1.13
import Qt.labs.settings 1.0
import myextension 1.0

Window
{
    id: window
    width: settings.width
    height: settings.height
    visible: true
    title: qsTr("Messenger")

    readonly property int defMargin: 10
    readonly property color panelColor: "#32B88E"
    readonly property color colorText: "#2E2E2E"
    property string username: "Unknown User"
    Settings
    {
        id: settings
        property int width: 640
        property int height: 480
    }
    Component.onDestruction:
    {
        settings.width = window.width
        settings.height = window.height
    }

    Connections
    {
        target: client
        onFriendsModelChanged:
        {
            messengerPage.visible = false
            friendsPage.visible = true
            drawer.close()
        }
        onAvatarChanged:
        {
            for(var i = 0; i < avatarCircleDrawer.children.length; ++i)
            {
                labelLetter.visible = false
                if (avatarCircleDrawer.children[i].objectName === "avatarImg")
                {
                    avatarCircleDrawer.children[i].image = client.avatar
                    avatarCircleDrawer.children[i].visible = true
                    return
                }
            }
            var avatar = avatarImage.createObject(avatarCircleDrawer, {objectName: "avatarImg",
                                                                       height: avatarCircleDrawer.height * 2,
                                                                       width: avatarCircleDrawer.width * 2,
                                                                       "anchors.centerIn": avatarCircleDrawer})
            avatar.image = client.avatar
        }
        onAvatarMissing:
        {
            for(var i = 0; i < avatarCircleDrawer.children.length; ++i)
            {
                if (avatarCircleDrawer.children[i].objectName === "avatarImg")
                    avatarCircleDrawer.children[i].visible = false
            }
            labelLetter.visible = true
        }
        onCurUserChanged: username = client.curUser
    }

    Component
    {
        id: avatarImage
        ImageItem {}
    }

    //HomePage
    FriendsPage
    {
        id: friendsPage
        visible: true
        username: window.username
        onOpenMessenger:
        {
            messengerPage.receiver = receiver
            messengerPage.username = window.username
            //Здесь запрашиваем данные у сервера
            client.sendMessageRequest(messengerPage.username, messengerPage.receiver)
            client.sendFriendAvatarRequest(messengerPage.receiver)
            friendsPage.visible = false
            messengerPage.visible = true
        }
        onOpenDrawer: drawer.open()
    }

    MessengerPage
    {
        id: messengerPage
        visible: false
        Connections
        {
            target: messengerPage
            onOpenFriendsPage:
            {
                client.clearFriendsModel()
                client.sendFriendsRequest()
                friendsPage.visible = true
                messengerPage.visible = false
            }
        }
        onVisibleChanged:
        {
            if (visible == false)
            {
                client.clearMessageModel()
            }
        }

        onSendMessage:
        {
            //отправляем сообщение на сервер (и локально сохраняем его в табличную модель)
            client.sendMessage(message)
            listview.positionViewAtEnd()
        }
    }

    Drawer
    {
        id: drawer
        Rectangle
        {
            anchors.fill: parent
            color: "white"
        }
        readonly property int fontSize: 12
        width: (window.width < 400) ? 0.6 * window.width : 240
        height: window.height

        ColumnLayout
        {
            width: parent.width
            Rectangle
            {
                Layout.fillWidth: true
                Layout.preferredHeight: 60
                color: panelColor
                RowLayout
                {
                    anchors.fill: parent
                    anchors.margins: defMargin
                    spacing: 10
                    Rectangle
                    {
                        id: avatarCircleDrawer
                        Layout.preferredHeight: 0.8 * parent.height
                        Layout.preferredWidth: Layout.preferredHeight
                        radius: Layout.preferredHeight / 2
                        color: "orange"
                        layer.enabled: true
                        layer.effect: OpacityMask
                        {
                            maskSource: Rectangle
                            {
                                height: avatarCircleDrawer.height
                                width: avatarCircleDrawer.width
                                radius: width / 2
                            }
                        }
                        //Первая буква в кружочке
                        Label
                        {
                            id: labelLetter
                            anchors.centerIn: parent
                            text: username[0]
                            font.bold: true
                            color: "white"
                            font.pointSize: 18
                        }
                    }
                    Label
                    {
                        Layout.fillWidth: true
                        font.pointSize: 14
                        font.bold: true
                        elide: Qt.ElideRight
                        color: "white"
                        text: username
                    }
                }
            }

            Rectangle
            {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                color: "white"
                Label
                {
                    anchors.bottom: parent.bottom
                    width: parent.width

                    horizontalAlignment: Text.AlignHCenter
                    font.pointSize: 12
                    //font.bold: true
                    elide: Qt.ElideRight
                    color: colorText
                    text: "Сменить пользователя:"
                }
            }

            ListView
            {
                id: listUsers
                Layout.fillWidth: true
                Layout.preferredHeight: contentHeight
                spacing: defMargin
                model: client.usersModel
                delegate: ItemDelegate
                {
                    height: 30
                    width: parent.width
                    text: model.display
                    font.pointSize: 12
                    contentItem: Text
                    {
                        text: parent.text
                        font: parent.font
                        horizontalAlignment: Text.AlignLeft
                        verticalAlignment: Text.AlignVCenter
                        color: colorText
                    }

                    onClicked:
                    {
                        client.onUserChosen(model.display)
                        //messengerPage.visible = false
                        //friendsPage.visible = true
                        //drawer.close()
                    }
                }
            }

            Rectangle
            {
                Layout.fillWidth: true
                Layout.preferredHeight: 0.5
                color: "#647687"
            }

            Rectangle
            {
                id: btnNewUser
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                Row
                {
                    anchors.fill: parent
                    anchors.margins: defMargin
                    spacing: 5
                    Image
                    {
                        source: "qrc:/images/icon_plus.png"
                        height: 0.6 * btnNewUser.height
                        mipmap: true
                        fillMode: Image.PreserveAspectFit
                        anchors.verticalCenter: parent.verticalCenter
                    }
                    Label
                    {
                        width: 0.8 * parent.width
                        text: "Добавить"
                        elide: Text.ElideRight
                        font.pointSize: 12
                        anchors.verticalCenter: parent.verticalCenter
                    }
                }
                MouseArea
                {
                    anchors.fill: parent
                    onPressed: parent.color = "#e4e4e4"
                    onClicked:
                    {
                        dialogNewUser.open()
                    }
                    onReleased: parent.color = "transparent"
                }
            }
        }
    }

    Dialog
    {
        id: dialogNewUser
        anchors.centerIn: parent
        title: "Новый пользователь"
        width: (parent.width > 300) ? 300 : parent.width
        height: (parent.height > 200) ? 200 : parent.height
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        TextField
        {
            id: inputName
            anchors.centerIn: parent
            width: parent.width
            font.pointSize: 11
            selectByMouse: true
            placeholderText: "Введите имя"
        }
        onAccepted:
        {
            client.onNewUser(inputName.text)
            inputName.clear()
        }
    }

    Dialog
    {
        id: dialogUserExists
        anchors.centerIn: parent
        title: "Пользователь уже существует"
        modal: true
        width: (parent.width > 200) ? 200 : parent.width
        height: (parent.height > 150) ? 150 : parent.height
        Label
        {
            anchors.centerIn: parent
            width: parent.width
            text: "Введите другое имя"
            elide: Text.ElideRight
            font.pointSize: 11
        }
        standardButtons: Dialog.Ok
        onClosed: dialogNewUser.open()
    }
    Connections
    {
        target: client
        onUserAlreadyExists: dialogUserExists.open()
    }

}
