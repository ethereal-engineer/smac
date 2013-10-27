--server init file

--send these to the client
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

--include shared code
include('shared.lua')

--copied from Garry's example swep
SWEP.Weight = 5
SWEP.AutoSwitchTo = false
SWEP.AutoSwitchFrom = false 

--custom
SWEP.Reloading = false

--show the customisable dialog on reload
function SWEP:Reload()
  if self.Reloading then return end
  self.Reloading = true
  self.Weapon:CallOnClient("ShowCalibrateDialog", "")
  self.Reloading = false
end
