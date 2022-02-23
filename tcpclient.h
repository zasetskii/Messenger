#ifndef TCPCLIENT_H
#define TCPCLIENT_H

#include <QTcpSocket>
#include <QTime>
#include <QDebug>
#include <QDataStream>
#include <QImage>
#include <QStringListModel>
#include "variantmaptablemodel.h"
#include "commands.h"

class TCPClient : public QObject
{
    Q_OBJECT

    Q_PROPERTY(VariantMapTableModel* messageModel READ getMessageModel NOTIFY messageModelChanged)
    Q_PROPERTY(QStringListModel* usersModel READ getUsersModel NOTIFY usersModelChanged)
    Q_PROPERTY(QStringListModel* friendsModel READ getFriendsModel NOTIFY friendsModelChanged)
    Q_PROPERTY(QString curUser READ getCurUser WRITE setCurUser NOTIFY curUserChanged)
    Q_PROPERTY(QImage avatar READ getAvatar NOTIFY avatarChanged)
    Q_PROPERTY(QImage friendAvatar READ getFriendAvatar NOTIFY friendAvatarChanged)

public:
    TCPClient(const QString& connecting_host, int port_num, QObject *parent = nullptr);
    ~TCPClient();

signals:
    void messageModelChanged();
    void usersModelChanged(); //при добавлении нового пользователя
    void friendsModelChanged();
    void curUserChanged();
    void avatarChanged();
    void friendAvatarChanged();
    void userAlreadyExists();
    void userDoesNotExist();
    void alreadyFriend();
    void avatarMissing();
    void friendAvatarMissing();

public slots:
    void sendMessage(const QVariantMap& message) const;
    void sendMessageRequest(const QString& sender, const QString& receiver) const;
    void sendFriendAvatarRequest(const QString& friend_name) const;
    void sendRemoveMessage(const int id) const;
    void removeMessageLocally(const int id);
    void addMessageLocally(const QVariantMap& message);
    void clear();
    void sendAvatar(const QString& username, QString image_url);
    void onUserChosen(const QString& username);
    void onNewUser(const QString& username);
    void onNewFriend(const QString& username, const QString& new_friend);

private slots:
    void onConnected() const;
    void slotReadServer();
    void slotError(QAbstractSocket::SocketError) const;

private:
    VariantMapTableModel* getMessageModel() const;
    QStringListModel* getUsersModel() const;
    QStringListModel* getFriendsModel() const;
    QString getCurUser() const;
    QImage getAvatar() const;
    QImage getFriendAvatar() const;

    void sendStringList(const QStringList& string_list) const; //вспомогательный метод, отправляет набор строк на сервер
    void sendCommand(const ServerCommand& command) const;
    void sendFriendsRequest() const;
    void sendAvatarRequest() const;
    void sendUsersRequest() const;
    void sendNewUser(const QString& username) const;
    void sendNewFriend(const QString& username, const QString& new_friend) const;

    void setCurUser(const QString& username);


private:
    QTcpSocket* m_tcp_socket;
    VariantMapTableModel* m_message_model; //модель сообщений
    QStringListModel* m_users_model;

    QStringListModel* m_friends_model;
    QString m_cur_user;
    QImage m_avatar;
    QImage m_friend_avatar;

    int m_next_block_size = 0;
    //QString m_command = "NO COMMAND";
    ClientCommand m_command = NO_COMMAND_CLIENT;
};
#endif // TCPCLIENT_H
