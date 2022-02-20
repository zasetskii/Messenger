#ifndef IMAGEITEM_H
#define IMAGEITEM_H

#include <QQuickPaintedItem>
#include <QImage>
#include <QPainter>

class ImageItem : public QQuickPaintedItem
{
    Q_OBJECT
    Q_PROPERTY(QImage image READ image WRITE setImage NOTIFY imageChanged)

public:
    ImageItem(QQuickItem* parent = nullptr);

    // QQuickPaintedItem interface
public:
    virtual void paint(QPainter *painter);

    void setImage(const QImage& image);
    QImage image() const;

signals:
    void imageChanged();

private:
    QImage m_image;
};

#endif // IMAGEITEM_H
