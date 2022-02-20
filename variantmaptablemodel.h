#ifndef VARIANTMAPTABLEMODEL_H
#define VARIANTMAPTABLEMODEL_H

#include <QObject>
#include <QAbstractTableModel>
#include <QModelIndex>

class AbstractColumn
{
public:
    AbstractColumn(QString name);
    QString name() { return m_name; }
    virtual QVariant colData(const QVariantMap& row_data, int role = Qt::DisplayRole) = 0; //извлечение данных
private:
    QString m_name;
};

//Default column implemantation
class SimpleColumn : public AbstractColumn
{
public:
    SimpleColumn(QString name);

    //AbstractColumn interface
    virtual QVariant colData(const QVariantMap& row_data, int role = Qt::DisplayRole);
};


class VariantMapTableModel : public QAbstractTableModel
{
    Q_OBJECT

public:
    VariantMapTableModel(QObject *parent = nullptr);
    ~VariantMapTableModel();

    void registerColumn(AbstractColumn* column);
    void addRow(QVariantMap row_data);
    void deleteRow(const int id);
    void clearHash();

    //Convenience methods
    int colByName(QString name) const;
    QString nameByCol(int  col) const;
    int rowById(const int id) const;

    //QAbstractItemModel interface
    virtual int columnCount(const QModelIndex &parent = QModelIndex()) const;
    virtual int rowCount(const QModelIndex &parent = QModelIndex()) const;
    virtual QVariant data(const QModelIndex &index, int role = Qt::DisplayRole) const;
    virtual QHash<int, QByteArray> roleNames() const;

private:
    //Хранение данных
    QVector<int> m_id_by_row; //индекс (номер строки) по id (идентификатору) из БД
    QHash<int, QVariantMap> m_data_hash; //таблица (номер строки - ассоциативный массив "название столбца - значение")
    //QVector<QVariantMap> m_data;
    QList<AbstractColumn*> m_columns; //для удобства обращения к колонкам не по индексу, а по имени колонки

};
#endif // VARIANTMAPTABLEMODEL_H
