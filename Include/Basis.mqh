//+------------------------------------------------------------------+
//|                                                        Basis.mqh |
//|                    Copyright 2023, Manuel Alejandro Cercos Perez |
//|                                  https://www.mql5.com/alexcercos |
//+------------------------------------------------------------------+
#include <PanelX\Inputs.mqh>
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CProgram;
#define TIMER_STEP_MSC (16)

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CElement
{
private:
   //Variable to generate names, but it's better to control that in the program
   static int        m_element_count;

   //void              AddChild(CElement* child);

   bool              m_dragging;
   bool              m_occluded;

   bool              m_hidden;
   bool              m_hidden_parent;

   void              HideObject();
   void              HideByParent();
   void              HideChildren();

   void              ShowObject();
   void              ShowByParent();
   void              ShowChildren();
   
public:              // Добавьте эту строку
   void              AddChild(CElement* child);
   void SetZOrder(int zorder) {
   ObjectSetInteger(0, m_name, OBJPROP_ZORDER, zorder);
}

protected:
   //Chart object name
   string            m_name;

   //Element relations
   CElement*         m_parent;
   CElement*         m_children[];
   int               m_child_count;

   //Position and size
   int               m_x;
   int               m_y;
   int               m_size_x;
   int               m_size_y;

   //Events
   CInputs*          m_inputs;
   CProgram*         m_program;

   virtual bool      OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
   {
      return IsMouseHovering();
   }
   bool              IsMouseHovering();
   bool              IsMouseDragging();

public:
   CElement();
   ~CElement();

   bool              OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);
   bool              CheckHovers();

   void              SetPosition(int x, int y);
   void              SetSize(int x, int y);
   void              SetParent(CElement* parent);
   void              SetProgram(CProgram* prg);
   void              SetInputs(CInputs* inputs);
   void              UpdatePosition();

   void              SetOccluded(bool occluded)
   {
      m_occluded = occluded;
   }
   bool              IsOccluded()
   {
      return m_occluded;
   }

   int               GetGlobalX();
   int               GetGlobalY();

   void              CreateChildren();
   virtual void      Create() {}

   void              Hide();
   void              Show();
   bool              IsHidden()
   {
      return m_hidden || m_hidden_parent;
   }
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CProgram
{
private:
   bool              m_needs_redraw;

protected:
   CInputs           m_inputs;
   CElement          m_element_holder;

   void              EnableControls(bool enable);

public:
   CProgram();

   void              OnTimer();
   void              OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam);

   void              CreateGUI();
   void              AddMainElement(CElement* element);
   void              RequestRedraw()
   {
      m_needs_redraw = true;
   }
};

int CElement::m_element_count = 0;

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CElement::CElement(void) : m_child_count(0), m_x(0), m_y(0), m_size_x(100), m_size_y(100),
   m_dragging(false), m_occluded(false), m_hidden(false), m_hidden_parent(false)
{
   m_name = "element_" + IntegerToString(m_element_count++);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CElement::~CElement(void)
{
   for (int i = 0; i < m_child_count; i++)
      delete m_children[i];
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CElement::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   for (int i = m_child_count - 1; i >= 0; i--)
   {
      m_children[i].SetOccluded(IsOccluded());
      if (m_children[i].OnChartEvent(id, lparam, dparam, sparam))
         SetOccluded(true);
   }
   //Check dragging start
   if (id == CHARTEVENT_MOUSE_MOVE && !IsOccluded())
   {
      if (IsMouseHovering() && m_inputs.GetLeftMouseState() == INPUT_STATE_DOWN)
         m_dragging = true;

      else if (m_dragging && m_inputs.GetLeftMouseState() == INPUT_STATE_UP)
         m_dragging = false;
   }

   return OnEvent(id, lparam, dparam, sparam) || IsMouseDragging() || IsOccluded();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CElement::CheckHovers(void)
{
   EInputState state = m_inputs.GetLeftMouseState();
   bool state_check = state != INPUT_STATE_ACTIVE; //Filter drags that start in chart

   for (int i = 0; i < m_child_count; i++)
   {
      if ((m_children[i].IsMouseHovering() && state_check)
            || m_children[i].IsMouseDragging())
         return true;
   }
   return false;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CElement::IsMouseHovering()
{
   int x = m_inputs.X();
   int y = m_inputs.Y();

   int px = GetGlobalX();
   int py = GetGlobalY();

   return x >= px && x < px + m_size_x &&
          y >= py && y < py + m_size_y;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
bool CElement::IsMouseDragging(void)
{
   return m_dragging;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CElement::SetSize(int x, int y)
{
   m_size_x = x;
   m_size_y = y;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CElement::SetPosition(int x, int y)
{
   m_x = x;
   m_y = y;
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CElement::Show(void)
{
   if (!IsHidden())
      return;

   m_hidden = false;
   ShowObject();

   if (CheckPointer(m_program) != POINTER_INVALID)
      m_program.RequestRedraw();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CElement::Hide(void)
{
   m_hidden = true;

   if (m_hidden_parent)
      return;

   HideObject();

   if (CheckPointer(m_program) != POINTER_INVALID)
      m_program.RequestRedraw();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CElement::ShowObject(void)
{
   if (IsHidden()) //Parent or self
      return;

   ObjectSetInteger(0, m_name, OBJPROP_TIMEFRAMES, OBJ_ALL_PERIODS);
   ShowChildren();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CElement::ShowByParent(void)
{
   m_hidden_parent = false;
   ShowObject();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CElement::ShowChildren(void)
{
   for (int i = 0; i < m_child_count; i++)
      m_children[i].ShowByParent();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CElement::HideObject(void)
{
   ObjectSetInteger(0, m_name, OBJPROP_TIMEFRAMES, OBJ_NO_PERIODS);
   HideChildren();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CElement::HideByParent(void)
{
   m_hidden_parent = true;
   if (m_hidden)
      return;

   HideObject();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CElement::HideChildren(void)
{
   for (int i = 0; i < m_child_count; i++)
      m_children[i].HideByParent();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CElement::UpdatePosition(void)
{
   ObjectSetInteger(0, m_name, OBJPROP_XDISTANCE, GetGlobalX());
   ObjectSetInteger(0, m_name, OBJPROP_YDISTANCE, GetGlobalY());

   for (int i = 0; i < m_child_count; i++)
      m_children[i].UpdatePosition();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CElement::SetInputs(CInputs* inputs)
{
   m_inputs = inputs;

   for (int i = 0; i < m_child_count; i++)
      m_children[i].SetInputs(inputs);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CElement::SetParent(CElement *parent)
{
   m_parent = parent;
   parent.AddChild(GetPointer(this));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CElement::SetProgram(CProgram *prg)
{
   m_program = prg;

   for (int i = 0; i < m_child_count; i++)
      m_children[i].SetProgram(prg);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CElement::AddChild(CElement *child)
{
   if (CheckPointer(child) == POINTER_INVALID)
      return;

   ArrayResize(m_children, m_child_count + 1);
   m_children[m_child_count] = child;
   m_child_count++;

   child.SetInputs(m_inputs);
   child.SetProgram(m_program);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CElement::GetGlobalX(void)
{
   if (CheckPointer(m_parent) == POINTER_INVALID)
      return m_x;

   return m_x + m_parent.GetGlobalX();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
int CElement::GetGlobalY(void)
{
   if (CheckPointer(m_parent) == POINTER_INVALID)
      return m_y;

   return m_y + m_parent.GetGlobalY();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CElement::CreateChildren(void)
{
   for (int i = 0; i < m_child_count; i++)
   {
      m_children[i].Create();
      m_children[i].CreateChildren();
   }

   if (m_hidden) HideChildren();
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CProgram::CProgram(void)
{
   m_element_holder.SetInputs(GetPointer(m_inputs));
   m_element_holder.SetProgram(GetPointer(this));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProgram::OnTimer(void)
{
   if (m_needs_redraw)
   {
      ChartRedraw(0);
      m_needs_redraw = false;
   }
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProgram::OnChartEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   m_inputs.OnEvent(id, lparam, dparam, sparam);

   if (id == CHARTEVENT_MOUSE_MOVE)
      EnableControls(!m_element_holder.CheckHovers());

   m_element_holder.SetOccluded(false);
   m_element_holder.OnChartEvent(id, lparam, dparam, sparam);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProgram::CreateGUI(void)
{
   ::ChartSetInteger(0, CHART_EVENT_MOUSE_MOVE, true);
   m_element_holder.CreateChildren();
   ::EventSetMillisecondTimer(TIMER_STEP_MSC);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProgram::EnableControls(bool enable)
{
   //Allow or disallow displacing chart
   ::ChartSetInteger(0, CHART_MOUSE_SCROLL, enable);
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CProgram::AddMainElement(CElement *element)
{
   element.SetParent(GetPointer(m_element_holder));
}
//+------------------------------------------------------------------+
