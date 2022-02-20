import QtQuick 2.0
import QtQuick.Controls 2.5
import QtQuick.Layouts 1.3
import QtQml 2.3

//Список друзей
Page
{
    id: page
    anchors.fill: parent
    property string username
    property alias friendsModel: friendsList.model
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
            delegate: Rectangle
            {
                id: rectDelegate
                anchors.margins: defMargin
                width: parent.width
                height: 30
                color: backgroundColor
                Text
                {
                    id: friend
                    anchors.centerIn: parent
                    font.pointSize: 14
                    text: model.display
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
        font.family: "Times"

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
        width: (parent.width > 300) ? 300 : parent.width
        height: (parent.height > 200) ? 200 : parent.height
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
        width: (parent.width > 300) ? 300 : parent.width
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
        title: "Нельзя добавлять в друзья себя"
        modal: true
        width: (parent.width > 300) ? 300 : parent.width
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
        onClosed: dialogAddFriend.open()
    }
}
