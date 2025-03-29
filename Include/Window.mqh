//+------------------------------------------------------------------+
//|                                                 RaiseElement.mqh |
//|                    Copyright 2023, Manuel Alejandro Cercos Perez |
//|                                  https://www.mql5.com/alexcercos |
//+------------------------------------------------------------------+
#include <PanelX\DragElement.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CRaiseElement : public CDragElement
{
private:
   int               key_id;
   int               header_height;
   int               padding;
   uint              header_color;
   uint              bg_color;
   bool              is_collapsed;
   int               btn_size;
   uint              btn_close_color;
   uint              btn_collapse_color;

protected:
   virtual void      DrawCanvas();
   void              DrawButtons();
   bool              IsCloseButtonHovered();
   bool              IsCollapseButtonHovered();

   // Добавляем реализацию OnEvent
   virtual bool      OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
   {
      // Обработка событий от родительского класса
      bool result = CDragElement::OnEvent(id, lparam, dparam, sparam);
      
      // Дополнительная обработка событий
      if(id == CHARTEVENT_MOUSE_MOVE && m_inputs.GetLeftMouseState() == INPUT_STATE_DOWN)
      {
         if(IsCloseButtonHovered())
         {
            ExpertRemove();
            return true;
         }
         else if(IsCollapseButtonHovered())
         {
            ToggleCollapse();
            return true;
         }
      }
      
      return result;
   }

public:
                     CRaiseElement(int id, int width, int height, int pad);
   void              ToggleCollapse();
};
//+------------------------------------------------------------------+
//| Конструктор                                                      |
//+------------------------------------------------------------------+
CRaiseElement::CRaiseElement(int id, int width, int height, int pad) : key_id(id)
{
   SetSize(width, height);
   padding = pad;
   
   header_height = 20;
   header_color = ColorToARGB(C'10,10,10', 255);
   bg_color = ColorToARGB(C'20,20,20', 255);
   
   is_collapsed = false;
   btn_size = 16;
   btn_close_color = ColorToARGB(clrRed, 255);
   btn_collapse_color = ColorToARGB(C'30,30,30', 255);
}
//+------------------------------------------------------------------+
//| Отрисовка элемента                                               |
//+------------------------------------------------------------------+
void CRaiseElement::DrawCanvas(void)
{
   m_canvas.Erase(bg_color);
   m_canvas.FillRectangle(0, 0, m_size_x, header_height, header_color);
   
   if(!is_collapsed)
   {
      int content_x = padding;
      int content_y = header_height + padding;
      int content_width = m_size_x - 2*padding;
      int content_height = m_size_y - header_height - 2*padding;
      
      m_canvas.FillRectangle(
         content_x,
         content_y,
         content_x + content_width,
         content_y + content_height,
         bg_color
      );
   }
   
   DrawButtons();
   m_canvas.Update(false);
}
//+------------------------------------------------------------------+
//| Отрисовка кнопок                                                 |
//+------------------------------------------------------------------+
void CRaiseElement::DrawButtons()
{
   int collapse_x = m_size_x - 2*btn_size - 4;
   m_canvas.FillRectangle(collapse_x, 2, collapse_x + btn_size, 2 + btn_size, btn_collapse_color);
   m_canvas.LineHorizontal(collapse_x + 4, collapse_x + btn_size - 4, 2 + btn_size/2, ColorToARGB(clrWhite));

   int close_x = m_size_x - btn_size - 2;
   m_canvas.FillRectangle(close_x, 2, close_x + btn_size, 2 + btn_size, btn_close_color);
   m_canvas.Line(close_x + 4, 2 + 4, close_x + btn_size - 4, 2 + btn_size - 4, ColorToARGB(clrWhite));
   m_canvas.Line(close_x + btn_size - 4, 2 + 4, close_x + 4, 2 + btn_size - 4, ColorToARGB(clrWhite));
}
//+------------------------------------------------------------------+
//| Проверка наведения на кнопку "Закрыть"                           |
//+------------------------------------------------------------------+
bool CRaiseElement::IsCloseButtonHovered()
{
   int mouse_x = m_inputs.X() - GetGlobalX();
   int mouse_y = m_inputs.Y() - GetGlobalY();
   int btn_x = m_size_x - btn_size - 2;
   int btn_y = 2;
   return (mouse_x >= btn_x && mouse_x <= btn_x + btn_size &&
           mouse_y >= btn_y && mouse_y <= btn_y + btn_size);
}
//+------------------------------------------------------------------+
//| Проверка наведения на кнопку "Свернуть"                          |
//+------------------------------------------------------------------+
bool CRaiseElement::IsCollapseButtonHovered()
{
   int mouse_x = m_inputs.X() - GetGlobalX();
   int mouse_y = m_inputs.Y() - GetGlobalY();
   int btn_x = m_size_x - 2*btn_size - 4;
   int btn_y = 2;
   return (mouse_x >= btn_x && mouse_x <= btn_x + btn_size &&
           mouse_y >= btn_y && mouse_y <= btn_y + btn_size);
}
//+------------------------------------------------------------------+
//| Свернуть/развернуть панель                                       |
//+------------------------------------------------------------------+
void CRaiseElement::ToggleCollapse()
{
   is_collapsed = !is_collapsed;
   m_canvas.Resize(m_size_x, is_collapsed ? header_height : m_size_y);
   DrawCanvas();
   if(CheckPointer(m_program) != POINTER_INVALID)
      m_program.RequestRedraw();
}
//+------------------------------------------------------------------+