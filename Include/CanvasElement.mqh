//+------------------------------------------------------------------+
//|                                                CanvasElement.mqh |
//|                    Copyright 2023, Manuel Alejandro Cercos Perez |
//|                                  https://www.mql5.com/alexcercos |
//+------------------------------------------------------------------+
#include <PanelX\Basis.mqh>
#include <Canvas/Canvas.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CCanvasElement : public CElement
{
protected:
   CCanvas           m_canvas;

   virtual void      DrawCanvas() {}

public:
   ~CCanvasElement();

   virtual void      Create();
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CCanvasElement::~CCanvasElement(void)
{
   m_canvas.Destroy();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CCanvasElement::Create()
{
   CElement::Create();

   m_canvas.CreateBitmapLabel(0, 0, m_name, GetGlobalX(), GetGlobalY(), m_size_x, m_size_y, COLOR_FORMAT_ARGB_NORMALIZE);

   DrawCanvas();
}
//+------------------------------------------------------------------+
