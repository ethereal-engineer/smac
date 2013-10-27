
AddCSLuaFile( "cl_init.lua" )
AddCSLuaFile( "shared.lua" )

include('shared.lua')


/*---------------------------------------------------------
   Name: Initialize
---------------------------------------------------------*/
function ENT:Initialize()
  self.Entity:SetModel("models/effects/combineball.mdl")
	self.Entity:SetMoveType(MOVETYPE_VPHYSICS)
	self.Entity:SetSolid(SOLID_VPHYSICS)
	self.Entity:PhysicsInitSphere(5)
  self.Phys=self.Entity:GetPhysicsObject()
	self.Phys:Wake()
  self.Phys:EnableGravity(false)
end

--returns the time "t" on the sine wave
function ENT:GetAttackT()
  return CurTime() - self.AttackStartTime
end

function ENT:Explode()
  timer.Stop("tokill")
  timer.Remove("tokill")
  self.Entity:Remove()  
end

function ENT:PhaseAttack(startpos, aimvector, phaseoffset, primary)
  if primary then
    conSuffix = "1"
  else
    conSuffix = "2"
  end  
  self.Entity:SetPos(startpos)
  self.Entity:SetAngles(aimvector:Angle())
  self.Entity:Spawn()
  local ply = self.Entity:GetOwner()
  self.Phys:SetAngle(aimvector:Angle())
  self.AimVector = aimvector
  self.TimeOffset = timeoffset
  self.PhaseOffset = phaseoffset
  self.AttackStartTime = CurTime()
  self.WobbleMagnifier = 10000
  self.WobbleFrequency = tonumber(ply:GetInfo("cl_smac_freq_"..conSuffix))
  self.WobbleAng = tonumber(ply:GetInfo("cl_smac_ang_"..conSuffix))
  self.WobbleAmp = tonumber(ply:GetInfo("cl_smac_orb_vel_"..conSuffix))
  self.FreqAdjust = tonumber(ply:GetInfo("cl_smac_fwd_vel_"..conSuffix))
  self.RotSpeed = tonumber(ply:GetInfo("cl_smac_rot_speed_"..conSuffix))
  self.FlatMode = tonumber(ply:GetInfo("cl_smac_flatmode_"..conSuffix))
  if ply:GetInfo("cl_smac_orb_func_"..conSuffix) == "Cosine" then
    self.OrbFunc = math.cos
  else
    self.OrbFunc = math.sin
  end
  self.Entity:StartMotionController()
  timer.Create("tokill", 30, 1, function() self.Entity:Remove() end)
end

function ENT:PhysicsSimulate(phys, deltatime)
  forceLinear = Vector(0,0,0)
  forceAngle = Vector(0,0,0)
  return forceAngle, forceLinear, SIM_LOCAL_ACCELERATION
end

function ENT:PhysicsUpdate(phys)
  local aimang = self.AimVector:Angle()
  local rot = self.WobbleAng * self.OrbFunc(self.WobbleFrequency * self:GetAttackT() + self.PhaseOffset)
  aimang:RotateAroundAxis(self.AimVector:Angle():Up(), rot)
  if self.FlatMode == 0 then
    aimang:RotateAroundAxis(self.AimVector, math.fmod(self.RotSpeed * self:GetAttackT(),360) + self.PhaseOffset) 
  end
  phys:SetAngle(aimang)
  local fwd = (aimang:Forward() * self.WobbleAmp) + (self.AimVector * self.FreqAdjust)
  phys:SetVelocityInstantaneous(fwd)
end

--what happens when we hit things
function ENT:PhysicsCollide(data, phys)
  local touchEnt = data.HitEntity
  local ply = self.Entity:GetOwner()

  --print('collided with '..tostring(touchEnt))
  --print('maxhealth '..tostring(touchEnt:GetMaxHealth()))
  --print('health '..tostring(touchEnt:Health()))

  --if we hit our owner player
  --we pass right through
  if (touchEnt == ply) then
    return
  end
  
  --if we hit world, we just explode
  if touchEnt:IsWorld() then
    self:Explode()
    return
  end

  --if we hit an object that can't be destroyed
  --we punch it hard then explode
  --if we hit something we have already destroyed we pass through it
  if (touchEnt:Health() <= 0) and (touchEnt:GetName() == "") then
    local te = data.HitObject
    if (te != nil) and te:IsValid() then
      te:ApplyForceOffset(data.OurOldVelocity * 100, data.HitPos)
    end
    self:Explode() 
    return 
  end
  
  --if we hit a destroyable object (that is not in the process of being destroyed)
  --we destroy it spectacularly then explode
	if (touchEnt:Health() > 0) and ((touchEnt:GetName() == "") or (touchEnt:IsPlayer())) then
    touchEnt:SetName("isdoomedby"..self.Entity:EntIndex())
    local vaporizer = ents.Create("point_hurt")
  	vaporizer:SetKeyValue("Damage", 10000)
  	vaporizer:SetKeyValue("DamageTarget","isdoomedby"..self.Entity:EntIndex())
	  vaporizer:SetKeyValue("DamageType", DMG_DISSOLVE | DMG_BLAST)
  	vaporizer:SetPos(self.Entity:GetPos())
    vaporizer.IsSmacBall = true
  	vaporizer:Spawn()
  	vaporizer:Input("hurt", ply, ply, 0)
    touchEnt:SetName("itsover")
    timer.Simple(1, function() if touchEnt:IsValid() then touchEnt:SetName("") end end) --if by some unknown reason the ent is still alive, reset it to be hit again
  	vaporizer:Fire("kill","",0.1)
    self:Explode()
  end
end
