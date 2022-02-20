import QtQuick 2.13
import QtQuick.Controls 2.5
import QtQml 2.3

Label
{
    id: root

    signal removeMessage()

    property alias time: labelTime.text
    property alias colorText: root.color
    property alias colorTime: labelTime.color
    property alias colorBubble: bgRect.color
    property alias rectHeight: bgRect.height
    property int marginWidth
    property int maxWidth

    width: (text.length <= 50) ? (textMetrics.boundingRect.width + 40) : maxWidth

    font.pointSize: 11

    leftInset: -20
    rightInset: -10
    topInset: -10
    bottomInset: -10

    wrapMode: Text.WordWrap
    background: Rectangle
    {
        id: bgRect
        radius: 20
        Label
        {
            id: labelTime
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: 0.5 * marginWidth
            font.pointSize: 8
        }
        MouseArea
        {
            anchors.fill: parent
            onPressed:
            {
                optionsMenu.open()
                parent.color = "lightgray"
            }
            Menu
            {
                id: optionsMenu
                font.pointSize: 12
                width: 200
                x: parent.x
                y: parent.y + 20
                modal: true
                MenuItem
                {
                    text: "Копировать"
                    onTriggered:
                    {
                        textEdit.text = root.text
                        textEdit.selectAll()
                        textEdit.copy()
                    }
                }
                MenuItem
                {
                    text: "Удалить"
                    onTriggered: removeMessage()
                }
                onClosed: bgRect.color = "white"
            }
        }
    }

    TextMetrics
    {
        id: textMetrics
        font: root.font
        text: root.text
    }
    TextEdit
    {
        id: textEdit
        visible: false
    }
}

