#include "imageitem.h"

ImageItem::ImageItem(QQuickItem* parent): QQuickPaintedItem(parent)
{
    m_image.load("C:/Qt/programs/QML/test_controls/test_controls/popart.jpg");
}

void ImageItem::paint(QPainter *painter)
{
    QRectF bounding_rect = boundingRect();
    QImage scaled_image = m_image.scaledToHeight(bounding_rect.height());

    QPointF center = bounding_rect.center() - scaled_image.rect().center();

    if(center.x() < 0)
        center.setX(0);
    if(center.y() < 0)
        center.setY(0);
    painter->drawImage(center, scaled_image);
}

void ImageItem::setImage(const QImage &image)
{
    m_image = image;
    update();
}

QImage ImageItem::image() const
{
    return m_image;
}


