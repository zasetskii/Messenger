#ifndef VARIANTMAPTABLEMODEL_H
#define VARIANTMAPTABLEMODEL_H

#include <QObject>
#include <QAbstractTableModel>
#include <QModelIndex>

class Column
{
public:
    Column(QString name);
    QString name() { return m_name; }

    virtual QVariant colData(const QVariantMap& row_data, int role = Qt::DisplayRole);
private:
    QString m_name;
};


class VariantMapTableModel : public QAbstractTableModel
{
    Q_OBJECT

public:
    VariantMapTableModel(QObject *parent = nullptr);
    ~VariantMapTableModel();

    void registerColumn(Column* column);

    //Convenience methods
    int colByName(QString name) const;
    QString nameByCol(int  col) const;

    //QAbstractItemModel interface
    virtual int columnCount(const QModelIndex &parent = QModelIndex()) const;
    virtual QHash<int, QByteArray> roleNames() const;

protected:
    //Хранение данных
    QList<Column*> m_columns; //для удобства обращения к колонкам не по индексу, а по имени колонки

};


class VariantMapIdTableModel : public VariantMapTableModel
{
    Q_OBJECT

public:
    VariantMapIdTableModel(QObject *parent = nullptr);

    void addRow(const QVariantMap& row_data);
    void deleteRow(const int id);
    void clearHash();

    int rowById(const int id) const;

    //VariantMapTableModel interface
    virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;

private:
    //Хранение данных
    QVector<int> m_id_by_row; //индекс (номер строки) по id (идентификатору) из БД
    QHash<int, QVariantMap> m_data_hash; //таблица (номер строки - ассоциативный массив "название столбца - значение")
};


class FriendsTableModel : public VariantMapTableModel
{
    Q_OBJECT

public:
    FriendsTableModel(QObject *parent = nullptr);

    void addRow(const QVariantMap& row_data);
    void clear();
    bool containsFriend(const QString& key_name, const QString& friend_name) const;

    //VariantMapTableModel interface
    virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;

private:
    //Хранение данных
    QVector<QVariantMap> m_data;
};

#endif // VARIANTMAPTABLEMODEL_H
