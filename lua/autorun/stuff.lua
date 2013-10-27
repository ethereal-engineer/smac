resource.AddFile("sound/smacball_loop.mp3")
resource.AddFile("sound/smac_fire1.mp3")
resource.AddFile("sound/smac_fire2.mp3")
resource.AddFile("resource/fonts/smac_font.ttf")
resource.AddFile("resource/fonts/smac_font.txt")

SMACConVars = {}
SMACConVars["freq"] = {Dflt1=10, Dflt2=10}
SMACConVars["ang"] = {Dflt1=30, Dflt2=30}
SMACConVars["orb_vel"] = {Dflt1=500, Dflt2=500}
SMACConVars["fwd_vel"] = {Dflt1=1000, Dflt2=1000}
SMACConVars["rot_speed"] = {Dflt1=20, Dflt2=0}
SMACConVars["orb_func"] = {Dflt1="Cosine", Dflt2="Cosine"}
SMACConVars["flatmode"] = {Dflt1=0, Dflt2=1}

function SMACConVarName(indexName, primary)
  local strName = "cl_smac_"..indexName.."_"
  if primary then
    strName = strName.."1"
  else
    strName = strName.."2"
  end
  return strName
end

if SERVER then 
 
local DisintegrateSounds = {Sound("weapons/physcannon/energy_disintegrate4.wav"), Sound("weapons/physcannon/energy_disintegrate5.wav")}

function GetDisintegrateSound()
  return table.Random(DisintegrateSounds)
end
 
--server only - move this
--need to hook this because the inflictor is always
--a point hurt (can't derive, can't change class etc)
--so we set a little bool on it and if it comes back true
--over here then we fix up the killicon
function NPCKilledWithSMAC(ent, attacker, inflictor)
  if inflictor.IsSmacBall then
    ent:EmitSound(GetDisintegrateSound())
    GAMEMODE:OnNPCKilled(ent, attacker, attacker)
    return true
  end
end
hook.Add("OnNPCKilled", "NPCKilledWithSMAC", NPCKilledWithSMAC)

--as with OnNPCKilled
function PlayerKilledWithSMAC(ply, inflictor, killer)
  if inflictor.IsSmacBall then
    ply:EmitSound(GetDisintegrateSound())
    GAMEMODE:PlayerDeath(ply, killer, killer)
    return true
  end
end
hook.Add("PlayerDeath", "PlayerKilledWithSMAC", PlayerKilledWithSMAC)

return 
end
--client only stuff

for k,v in pairs(SMACConVars) do
  CreateClientConVar(SMACConVarName(k, true), v.Dflt1, true, true)
  CreateClientConVar(SMACConVarName(k, false), v.Dflt2, true, true) 
end

surface.CreateFont( "smac_font", ScreenScale( 20 ), 400, true, true, "smac_font")  
killicon.AddFont("weapon_smac", "smac_font", "0", Color( 255, 80, 0, 255 ))

