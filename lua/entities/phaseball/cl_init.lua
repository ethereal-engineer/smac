
include('shared.lua')

function ENT:Initialize()
  self.Entity:SetModelScale(Vector(0.25, 0.25, 0.25))
  self.trailEm = ParticleEmitter(self.Entity:GetPos())
end

function ENT:Draw()
  self.Entity:SetRenderAngles(LocalPlayer():EyeAngles())
  self.Entity:DrawModel()
end

function ENT:IsTranslucent()
	return true
end

function ENT:OnRemove()
  self.trailEm:Finish()
end

function ENT:Think()
  local Pos = self.Entity:GetPos()
	local particle = self.trailEm:Add( "sprites/strider_bluebeam", Pos)
	particle:SetLifeTime(0)
	particle:SetDieTime(1)
	particle:SetStartAlpha(255)
	particle:SetEndAlpha( 0 )
	particle:SetStartSize( 5 )
	particle:SetEndSize( 10 )
	particle:SetRoll( math.Rand(480,540) )
	particle:SetRollDelta( math.random(-1,1) )  self.Entity:NextThink(CurTime() + 0.2)
  return true
end
