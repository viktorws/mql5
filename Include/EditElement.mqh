//+------------------------------------------------------------------+
//|                                                  EditElement.mqh |
//|                    Copyright 2023, Manuel Alejandro Cercos Perez |
//|                                  https://www.mql5.com/alexcercos |
//+------------------------------------------------------------------+
#include "Basis.mqh"

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CEditElement : public CElement
{
public:
   ~CEditElement();

   virtual void      Create();

   string            GetEditText()
   {
      return ObjectGetString(0, m_name, OBJPROP_TEXT);
   }
   void              SetEditText(string text)
   {
      ObjectSetString(0, m_name, OBJPROP_TEXT, text);
   }

};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CEditElement::~CEditElement(void)
{
   ObjectDelete(0, m_name);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CEditElement::Create()
{
   CElement::Create();

   ObjectCreate(0, m_name, OBJ_EDIT, 0, 0, 0);

   ObjectSetInteger(0, m_name, OBJPROP_XDISTANCE, GetGlobalX());
   ObjectSetInteger(0, m_name, OBJPROP_YDISTANCE, GetGlobalY());
   ObjectSetInteger(0, m_name, OBJPROP_XSIZE, m_size_x);
   ObjectSetInteger(0, m_name, OBJPROP_YSIZE, m_size_y);
}
//+------------------------------------------------------------------+
