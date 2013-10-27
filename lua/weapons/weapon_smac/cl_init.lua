--client init file

--include shared code
include('shared.lua')

--SWEP details  
SWEP.PrintName = "SMAC"
SWEP.Slot = 3
SWEP.SlotPos = 1
SWEP.DrawAmmo = true
SWEP.DrawCrosshair = true

--custom
SWEP.CalibrateDialog = nil

function SWEP:Calibrating()
  return (self.CalibrateDialog != nil) and (self.CalibrateDialog != NULL) and self.CalibrateDialog:IsValid()
end

function SWEP:CreateFirePropertySheet(psController, title, hint, icon, convarSuffix)

  local pnlPrimary = vgui.Create("DPanel", psController)
  pnlPrimary.Paint = function()
    surface.SetDrawColor( 50, 50, 50, 255 )
    surface.DrawRect( 0, 0, pnlPrimary:GetWide(), pnlPrimary:GetTall() )
  end

  local yOffset = 10
  local yDelta = 60

  local nsSpin = vgui.Create("DNumSlider", pnlPrimary)
  nsSpin:SetText("Rotation Speed")
  nsSpin:SetMin(-359)
  nsSpin:SetMax(359)
  nsSpin:SetConVar("cl_smac_rot_speed_"..convarSuffix)
  nsSpin:SetPos(10, yOffset)
  yOffset = yOffset + yDelta - 20 --special case
  nsSpin:SetWidth(300)
  
  local lblFn = vgui.Create("DLabel", pnlPrimary)
  lblFn:SetText("Orb Function")
  lblFn:SetPos(10, yOffset)
  yOffset = yOffset + yDelta - 40 --special case
  lblFn:SizeToContents()

  local mcFormula = vgui.Create("DMultiChoice", pnlPrimary)
  mcFormula:AddChoice("Sine")
  mcFormula:AddChoice("Cosine")
  mcFormula:SetConVar("cl_smac_orb_func_"..convarSuffix)
  mcFormula:SetPos(10, yOffset)
  yOffset = yOffset + yDelta - 20 --special case
  mcFormula:SetWidth(300)

  local nsFreq = vgui.Create("DNumSlider", pnlPrimary)
  nsFreq:SetText("Sine/Cosine Frequency")
  nsFreq:SetMin(0)
  nsFreq:SetMax(10000)
  nsFreq:SetConVar("cl_smac_freq_"..convarSuffix)
  nsFreq:SetPos(10, yOffset)
  yOffset = yOffset + yDelta
  nsFreq:SetWidth(300)

  local nsAng = vgui.Create("DNumSlider", pnlPrimary)
  nsAng:SetText("Angle Variance")
  nsAng:SetMin(0)
  nsAng:SetMax(359)
  nsAng:SetConVar("cl_smac_ang_"..convarSuffix)
  nsAng:SetPos(10, yOffset)
  yOffset = yOffset + yDelta
  nsAng:SetWidth(300)

  local nsOrbVel = vgui.Create("DNumSlider", pnlPrimary)
  nsOrbVel:SetText("Orb Velocity")
  nsOrbVel:SetMin(0)
  nsOrbVel:SetMax(10000)
  nsOrbVel:SetConVar("cl_smac_orb_vel_"..convarSuffix)
  nsOrbVel:SetPos(10, yOffset)
  yOffset = yOffset + yDelta
  nsOrbVel:SetWidth(300)

  local nsFwdVel = vgui.Create("DNumSlider", pnlPrimary)
  nsFwdVel:SetText("Forward Velocity")
  nsFwdVel:SetMin(0)
  nsFwdVel:SetMax(10000)
  nsFwdVel:SetConVar("cl_smac_fwd_vel_"..convarSuffix)
  nsFwdVel:SetPos(10, yOffset)
  yOffset = yOffset + yDelta
  nsFwdVel:SetWidth(300)

  local cbFlatMode = vgui.Create("DCheckBoxLabel", pnlPrimary)
  cbFlatMode:SetText("Flatten Projectile Paths")
  cbFlatMode:SetPos(10, yOffset)
  yOffset = yOffset + yDelta
  cbFlatMode:SetConVar("cl_smac_flatmode_"..convarSuffix)
  cbFlatMode:SizeToContents()

  pnlPrimary:SizeToContents()

  psController:AddSheet(title, pnlPrimary, icon, false, false, hint ) 
end

--shows a dialog to customise the way the weapon fires
function SWEP:ShowCalibrateDialog()
  if not self:Calibrating() then

    self.CalibrateDialog = vgui.Create("DFrame")
    self.CalibrateDialog:SetSize(350, 500)
    self.CalibrateDialog:SetTitle('SMAC Calibration')
    self.CalibrateDialog:Center()

    local cbxProfile = vgui.Create("ControlPresets", self.CalibrateDialog)
    cbxProfile:SetPreset("smac")
    cbxProfile:SetPos(5, 30)
    cbxProfile:SetWidth(300)
    for k,v in pairs(SMACConVars) do
   		cbxProfile:AddConVar(SMACConVarName(k, true))
      cbxProfile:AddConVar(SMACConVarName(k, false)) 
   	end 

    local psController = vgui.Create("DPropertySheet", self.CalibrateDialog)
    psController:SetParent(self.CalibrateDialog)
    psController:SetPos(5, 60)    
    psController:SetSize(328, 425)

    self:CreateFirePropertySheet(psController, "Primary Fire", "Primary Fire Settings", "gui/silkicons/wrench", "1")
    self:CreateFirePropertySheet(psController, "Secondary Fire", "Secondary Fire Settings", "gui/silkicons/wrench", "2")    

    self.CalibrateDialog:SetMouseInputEnabled(true)
    self.CalibrateDialog:SetKeyboardInputEnabled(true)

    self.CalibrateDialog:MakePopup()
  end
end

