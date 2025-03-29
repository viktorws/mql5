//+------------------------------------------------------------------+
//|                                                       Inputs.mqh |
//|                    Copyright 2023, Manuel Alejandro Cercos Perez |
//|                                  https://www.mql5.com/alexcercos |
//+------------------------------------------------------------------+
enum EInputState
{
   INPUT_STATE_INACTIVE = 0,
   INPUT_STATE_UP = 1,
   INPUT_STATE_DOWN = 2,
   INPUT_STATE_ACTIVE = 3
};
//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
class CInputs
{
private:
   EInputState m_left_mouse_state;
   EInputState m_ctrl_state;
   EInputState m_shift_state;

   int m_pos_x;
   int m_pos_y;

   void UpdateState(EInputState &state, bool current);

public:
   CInputs();

   void OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam);

   EInputState GetLeftMouseState()
   {
      return m_left_mouse_state;
   }
   EInputState GetCtrlState()
   {
      return m_ctrl_state;
   }
   EInputState GetShiftState()
   {
      return m_shift_state;
   }

   int X()
   {
      return m_pos_x;
   }
   int Y()
   {
      return m_pos_y;
   }
};

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
CInputs::CInputs(void) : m_left_mouse_state(INPUT_STATE_INACTIVE), m_ctrl_state(INPUT_STATE_INACTIVE),
   m_shift_state(INPUT_STATE_INACTIVE), m_pos_x(0), m_pos_y(0)
{
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CInputs::OnEvent(const int id, const long &lparam, const double &dparam, const string &sparam)
{
   if(id != CHARTEVENT_MOUSE_MOVE)
      return;

   m_pos_x = (int)lparam;
   m_pos_y = (int)dparam;

   uint state = uint(sparam);

   UpdateState(m_left_mouse_state, ((state & 1) == 1));
   UpdateState(m_ctrl_state, ((state & 8) == 8));
   UpdateState(m_shift_state, ((state & 4) == 4));
}

//+------------------------------------------------------------------+
//|                                                                  |
//+------------------------------------------------------------------+
void CInputs::UpdateState(EInputState &state, bool current)
{
   if (current)
      state = (state >= INPUT_STATE_DOWN) ? INPUT_STATE_ACTIVE : INPUT_STATE_DOWN;
   else
      state = (state >= INPUT_STATE_DOWN) ? INPUT_STATE_UP : INPUT_STATE_INACTIVE;
}
//+------------------------------------------------------------------+
