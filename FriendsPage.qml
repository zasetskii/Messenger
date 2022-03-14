import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQml 2.3
import QtGraphicalEffects 1.13
import myextension 1.0

//Список друзей
Page
{
    id: page
    anchors.fill: parent
    property string username
    readonly property color panelColor: "#32B88E"
    readonly property color backgroundColor: "white"

    signal openMessenger(string receiver)
    signal openDrawer()

    header: FriendsHeader
    {
        color: panelColor
        onHeaderButtonClicked:
        {
            openDrawer()
        }
        onAvatarSelected:
        {
            client.sendAvatar(username, avatarUrl)
        }
    }

    background: Rectangle { color: backgroundColor }

    ColumnLayout
    {
        anchors.fill: parent
        anchors.margins: defMargin
        spacing: 2 * defMargin
        Label
        {
            id: lblWelcome
            Layout.preferredWidth: parent.width
            elide: Qt.ElideRight
            font.pointSize: 14
            color: "#B02353"
            text: "Добро пожаловать, " + username
        }

        ListView
        {
            id: friendsList
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: 10
            model: client.friendsModel
            delegate: Rectangle
            {
                id: rectDelegate
                anchors.margins: defMargin
                width: parent.width
                height: 60
                color: backgroundColor
                RowLayout
                {
                    anchors.fill: parent
                    //Аватар
                    Rectangle
                    {
                        id: rectAvatar
                        Layout.preferredHeight: 0.7 * parent.height
                        Layout.preferredWidth: Layout.preferredHeight
                        Layout.rightMargin: 10
                        radius: Layout.preferredHeight / 2
                        color: "orange"

                        layer.enabled: true
                        layer.effect: OpacityMask
                        {
                            maskSource: Rectangle
                            {
                                height: rectAvatar.height
                                width: rectAvatar.width
                                radius: width / 2
                            }
                        }
                        //Первая буква в кружочке
                        Label
                        {
                            id: labelLetter
                            anchors.centerIn: parent
                            text: model.friend_name[0]
                            color: "white"
                            font.bold: true
                            font.pointSize: 18
                        }
                        Component
                        {
                            id: avatarImage
                            ImageItem {}
                        }
                        Component.onCompleted:
                        {
                            if (model.hasAvatar === false)
                            {
                                return
                            }
                            var avatar = avatarImage.createObject(rectAvatar, {height: rectAvatar.height * 2,
                                                                               width: rectAvatar.width * 2,
                                                                               "anchors.centerIn": rectAvatar})
                            avatar.image = model.avatar
                        }
                    }

                    ColumnLayout
                    {
                        Layout.fillHeight: true
                        Layout.fillWidth: true
                        spacing: 5
                        Label
                        {
                            id: friend
                            font.pointSize: 14
                            font.bold: true
                            text: model.friend_name
                        }
                        Label
                        {
                            Layout.fillWidth: true
                            font.pointSize: 12
                            text: ((page.username === model.sender) ? "<b>Вы</b>: " : "") + model.text
                            elide: Text.ElideRight
                        }
                    }
                    Label
                    {
                        Layout.fillHeight: true
                        Layout.preferredWidth: 40
                        Layout.topMargin: 10
                        font.pointSize: 9
                        text: model.time
                    }
                }
                MouseArea
                {
                    anchors.fill: parent
                    hoverEnabled: true
                    onClicked:
                    {
                        parent.color = "#93A397"
                        openMessenger(friend.text)
                    }
                    onEntered:
                    {
                        parent.color = "#C7DECD"
                    }
                    onExited:
                    {
                        parent.color = backgroundColor
                    }
                }
            }
        }
    }

    RoundButton
    {
        id: btnAddUser
        readonly property color colorHovered: "#248566"
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        width: 60
        height: 60
        anchors.margins: 20
        font.pointSize: 30

        text:  "<font color='black'>\u002b</font>"

        bottomPadding: 15

        background: Rectangle
        {
            id: bgRect
            color: panelColor
            radius: parent.width / 2
        }
        hoverEnabled: true
        onHoveredChanged: (hovered == true) ? bgRect.color = colorHovered : bgRect.color = panelColor
        onClicked: dialogAddFriend.open()
    }

    Dialog
    {
        id: dialogAddFriend
        anchors.centerIn: parent
        title: "Добавить в друзья"
        width: Math.min(parent.width, 300)
        height: Math.min(parent.height, 200)
        standardButtons: Dialog.Ok | Dialog.Cancel
        modal: true
        ComboBox
        {
            id: inputName
            anchors.centerIn: parent
            width: parent.width
            font.pointSize: 11
            editable: true
            model: client.usersModel
            textRole: "display"
        }

        onAccepted:
        {
            if (username == inputName.editText)
                dialogOwnName.open()
            else
                client.onNewFriend(username, inputName.editText)
            inputName.editText = ""
        }
    }

    Dialog
    {
        id: dialogUserDoesNotExist
        anchors.centerIn: parent
        title: "Пользователь не существует"
        modal: true
        width: Math.min(parent.width, 400)
        height: Math.min(parent.height, 150)
        Label
        {
            anchors.centerIn: parent
            width: parent.width
            text: "Введите другое имя"
            elide: Text.ElideRight
            font.pointSize: 11
        }
        standardButtons: Dialog.Ok
        onClosed: dialogAddFriend.open()
    }
    Connections
    {
        target: client
        onUserDoesNotExist: dialogUserDoesNotExist.open()
    }

    Dialog
    {
        id: dialogAlreadyFriend
        anchors.centerIn: parent
        title: "Пользователь уже у вас в друзьях"
        modal: true
        width: Math.min(parent.width, 400)
        height: Math.min(parent.height, 150)
        Label
        {
            anchors.centerIn: parent
            width: parent.width
            text: "Введите другое имя"
            elide: Text.ElideRight
            font.pointSize: 11
        }
        standardButtons: Dialog.Ok
        onClosed: dialogAddFriend.open()
    }
    Connections
    {
        target: client
        onAlreadyFriend: dialogAlreadyFriend.open()
    }

    Dialog
    {
        id: dialogOwnName
        anchors.centerIn: parent
        title: "Нельзя добавить в друзья себя"
        modal: true
        width: Math.min(parent.width, 400)
        height: Math.min(parent.height, 150)
        Label
        {
            anchors.centerIn: parent
            width: parent.width
            text: "Введите другое имя"
            elide: Text.ElideRight
            font.pointSize: 11
        }
        standardButtons: Dialog.Ok
        onClosed: dialogAddFriend.open()
    }
}
