import QtQuick 2.13
import QtQuick.Controls 2.5
import QtQml 2.3
import QtQuick.Layouts 1.3
import QtGraphicalEffects 1.13
import myextension 1.0

Rectangle
{
    id: root
    height: 60
    property alias receiverName: labelName.text
    property alias colorName: labelName.color
    property alias colorAvatarBg: rectAvatar.color
    property alias colorAvatarLetter: labelLetter.color
    property int marginWidth: 10
    property int letterFontSize: 18

    signal closeMessenger()

    RowLayout
    {
        anchors.fill: parent
        spacing: marginWidth
        ToolButton
        {
            id: toolButton
            Layout.alignment: Qt.AlignVCenter | Qt.AlignLeft
            text: "\u2190"
            font.pixelSize: 0.5 * root.height
            onClicked:
            {
                closeMessenger()
            }
        }

        //Аватар
        Rectangle
        {
            id: rectAvatar
            Layout.rightMargin: root.width / 50

            Layout.preferredHeight: 0.7 * root.height
            Layout.preferredWidth: Layout.preferredHeight
            radius: Layout.preferredHeight / 2

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
                text: receiverName[0]
                font.bold: true
                font.pointSize: letterFontSize
            }
        }

        //Имя
        Label
        {
            id: labelName
            Layout.alignment: Qt.AlignCenter
            Layout.fillWidth: true
            //anchors.centerIn: parent
            font.pixelSize: root.height * 0.35
        }
    }


    Component
    {
        id: avatarImage
        ImageItem {}
    }

    Connections
    {
        target: client
        onFriendAvatarChanged:
        {
            //Проверяем, создан ли уже аватар
            for(var i = 0; i < rectAvatar.children.length; ++i)
            {
                labelLetter.visible = false
                if (rectAvatar.children[i].objectName === "avatarImg")
                {
                    rectAvatar.children[i].image = client.friendAvatar
                    rectAvatar.children[i].visible = true
                    return
                }
            }
            //Cоздаём экземпляр компонента avatarImage
            var avatar = avatarImage.createObject(rectAvatar, {objectName: "avatarImg",
                                                               height: rectAvatar.height * 2,
                                                               width: rectAvatar.width * 2,
                                                               "anchors.centerIn": rectAvatar})
            //Инициализируем присланным изображением
            avatar.image = client.friendAvatar
        }
        onFriendAvatarMissing:
        {
            for(var i = 0; i < rectAvatar.children.length; ++i)
            {
                if (rectAvatar.children[i].objectName === "avatarImg")
                    rectAvatar.children[i].visible = false
            }
            labelLetter.visible = true
        }
    }
}
