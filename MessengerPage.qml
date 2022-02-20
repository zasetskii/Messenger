import QtQuick 2.13
import QtQuick.Controls 2.5
import QtQml 2.3

Page
{
    id: page
    anchors.fill: parent

    Connections
    {
        target: pageHeader
        onCloseMessenger:
        {
            openFriendsPage()
        }
    }

    readonly property int defMargin: 10
    readonly property int messageHeight: 50
    readonly property color panelColor: "#32B88E"
    readonly property color messageColor: "white"
    readonly property color backgroundColor: "#F5EFDC"
    readonly property color textColor: "black"
    readonly property color timeColor: "lightgray"

    signal sendMessage(var message)
    signal openFriendsPage()

    property string username
    property alias receiver: pageHeader.receiverName
    property alias listmodel: listView.model
    property alias listview: listView

    property int scrollHeight: 0

    //The header item is positioned to the top, and resized to the width of the page.
    header: PageHeader
    {
        id: pageHeader
        receiverName: "Receiver Name"
        color: panelColor
        colorAvatarBg: "white"
        colorAvatarLetter: "cyan"
        colorName: "white"
    }

    background: Rectangle { color: backgroundColor }

    footer: MessageEditor
    {
        color: "lightgray"
        colorBtnSend: panelColor
        onSubmitMessage:
        {
            var newMessage = {}
            newMessage.text = text
            newMessage.time = Qt.formatTime(new Date(), "hh:mm")
            newMessage.sender = username
            newMessage.receiver = receiver
            var newDate = Qt.formatDate(new Date(), "yyyy-MM-dd") + "-" + newMessage.time
            newMessage.date = newDate
            sendMessage(newMessage)
            //listView.contentY = listView.contentHeight //contentY - координата верхнего левого угла содержимого в отображении
        }
    }

    //Сообщения
    ListView
    {
        id: listView
        anchors.fill: parent
        anchors.topMargin: defMargin * 2
        anchors.bottomMargin: defMargin * 2
        anchors.leftMargin: defMargin * 3
        spacing: 3 * defMargin
        ScrollBar.vertical: ScrollBar {}
        //contentY: contentHeight - height
        //model: listModel
        delegate: MessageItem
        {
            anchors.left: (model.sender === receiver) ? parent.left : undefined
            anchors.right: (model.sender === username) ? parent.right : undefined
            anchors.rightMargin: defMargin * 2
            maxWidth: 0.7 * parent.width
            colorBubble: "white"
            colorText: textColor
            colorTime: timeColor
            text: model.text
            time: model.time
            marginWidth: defMargin
            Component.onCompleted:
            {
                scrollHeight += rectHeight + 60
            }
            onRemoveMessage:
            {
                client.sendRemoveMessage(id)
                client.removeMessageLocally(id)
            }
        }
        onCountChanged:
        {
            contentY = scrollHeight
        }

    }
}
