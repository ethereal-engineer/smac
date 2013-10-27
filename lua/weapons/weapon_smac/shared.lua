SWEP.Author = "ancientevil"
SWEP.Contact = "facepunch.com"
SWEP.Purpose = "destruction"
SWEP.Instructions = "Hit reload to bring up the configuration screen.  Play with the settings until you have what you want.  Presets save/load both primary and secondary settings.  Go hurt something! -ae"
 
SWEP.Spawnable = true
SWEP.AdminSpawnable = true
  
SWEP.ViewModel = "models/weapons/v_shotgun.mdl"
--SWEP.WorldModel = "models/weapons/w_smac.mdl" --still has bugs
SWEP.WorldModel = "models/weapons/w_shotgun.mdl"

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "ar2"
 
SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = false
SWEP.Secondary.Ammo = "None"

local ShootSounds = {"smac_fire1.mp3", "smac_fire2.mp3"}

function SWEP:Initialize()
end

function SWEP:Think()
end

--return one of two shoot sounds
function GetShootSound()
  return table.Random(ShootSounds)
end

function SWEP:FirePhaseOrbs(primary)
  if !SERVER then 
    return true 
  end
  if primary then
    self.Weapon:SetNextPrimaryFire(CurTime()+0.1)
  else
    self.Weapon:SetNextSecondaryFire(CurTime()+0.1)
  end 
  self.BaseClass.ShootEffects(self)
  for i = 1, 3 do
    if self.Weapon:Ammo1() == 0 then return end
    local phaseball = ents.Create("phaseball")
    phaseball:SetOwner(self.Weapon:GetOwner())
    phaseball:PhaseAttack(self.Owner:EyePos() + (self.Owner:GetAimVector() * i*20), self.Owner:GetAimVector(), (i-2)*60, primary)   
    self.Weapon:TakePrimaryAmmo(1)
  end
end

function SWEP:DoAttack(primary)
  self.Weapon:SetNextPrimaryFire(CurTime() + 0.5)
  self.Weapon:SetNextSecondaryFire(CurTime() + 0.5)
  self.Weapon:EmitSound(GetShootSound())
  timer.Simple(0.5, function() self:FirePhaseOrbs(primary) end)  
end

function SWEP:PrimaryAttack()
  if self.Weapon:Ammo1() == 0 then return end
  self:DoAttack(true)
end

function SWEP:SecondaryAttack()
  if self.Weapon:Ammo1() == 0 then return end
  self:DoAttack(false)
end 
