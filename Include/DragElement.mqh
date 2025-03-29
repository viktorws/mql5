//+------------------------------------------------------------------+
//|                                                  DragElement.mqh |
//|                    Copyright 2023, Manuel Alejandro Cercos Perez |
//|                                  https://www.mql5.com/alexcercos |
//+------------------------------------------------------------------+
#include <PanelX\CanvasElement.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CDragElement : public CCanvasElement
{
private:
   int m_rel_mouse_x, m_rel_mouse_y;

protected:
   virtual void      DrawCanvas();

protected:
   virtual bool      OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CDragElement::OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if (IsOccluded()) return false;

   if (id != CHARTEVENT_MOUSE_MOVE)
      return false;

   if (!IsMouseDragging())
      return false;

   if (m_inputs.GetLeftMouseState() == INPUT_STATE_DOWN) //First click
   {
      m_rel_mouse_x = m_inputs.X() - m_x;
      m_rel_mouse_y = m_inputs.Y() - m_y;
      return true;
   }

   //Move object
   m_x = m_inputs.X() - m_rel_mouse_x;
   m_y = m_inputs.Y() - m_rel_mouse_y;
   UpdatePosition();
   m_program.RequestRedraw();

   return true;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CDragElement::DrawCanvas(void)
{
   m_canvas.Erase(ARGB(255, MathRand() % 256, MathRand() % 256, MathRand() % 256));
   m_canvas.Update(false);
}
//+------------------------------------------------------------------+
