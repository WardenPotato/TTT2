---
-- @class SWEP
-- @section weapon_ttt_cse

if SERVER then
	AddCSLuaFile()
end

SWEP.HoldType = "normal"

if CLIENT then
	SWEP.PrintName = "vis_name"
	SWEP.Slot = 6

	SWEP.ViewModelFOV = 10
	SWEP.ViewModelFlip = false
	SWEP.DrawCrosshair = false

	SWEP.EquipMenuData = {
		type = "item_weapon",
		desc = "vis_desc"
	}

	SWEP.Icon = "vgui/ttt/icon_cse"
end

SWEP.Base = "weapon_tttbase"

SWEP.ViewModel = Model("models/weapons/v_crowbar.mdl")
SWEP.WorldModel = Model("models/Items/battery.mdl")

SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 1.0

SWEP.Secondary.ClipSize = -1
SWEP.Secondary.DefaultClip = -1
SWEP.Secondary.Automatic = true
SWEP.Secondary.Ammo = "none"
SWEP.Secondary.Delay = 0.2

SWEP.Kind = WEAPON_EQUIP
SWEP.CanBuy = {ROLE_DETECTIVE} -- only detectives can buy
SWEP.WeaponID = AMMO_CSE
SWEP.builtin = true

SWEP.LimitedStock = true -- only buyable once
SWEP.NoSights = true
SWEP.AllowDrop = false

SWEP.DeathScanDelay = 15

---
-- @ignore
function SWEP:PrimaryAttack()
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	self:DropDevice()
end

---
-- @ignore
function SWEP:SecondaryAttack()
	self:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
	self:DropDevice()
end

---
-- @ignore
function SWEP:PreDrop(isdeath)
	if not isdeath then return end

	local cse = self:DropDevice()

	if not IsValid(cse) then return end

	cse:SetDetonateTimer(self.DeathScanDelay or 10)
end

---
-- @ignore
function SWEP:Reload()
	return false
end

---
-- @ignore
function SWEP:OnRemove()
	if SERVER then return end

	local owner = self:GetOwner()

	if IsValid(owner) and owner == LocalPlayer() and owner:Alive() then
		RunConsoleCommand("lastinv")
	end
end

local throwsound = Sound("Weapon_SLAM.SatchelThrow")

---
-- @realm shared
function SWEP:DropDevice()
	if CLIENT then return end

	self:EmitSound(throwsound)

	local cse = nil
	local ply = self:GetOwner()

	if not IsValid(ply) or self.Planted then return end

	local vsrc = ply:GetShootPos()
	local vang = ply:GetAimVector()
	local vvel = ply:GetVelocity()
	local vthrow = vvel + vang * 200

	cse = ents.Create("ttt_cse_proj")

	if not IsValid(cse) then return end

	cse:SetPos(vsrc + vang * 10)
	cse:SetOwner(ply)
	cse:SetThrower(ply)
	cse:Spawn()
	cse:PhysWake()

	local phys = cse:GetPhysicsObject()

	if IsValid(phys) then
		phys:SetVelocity(vthrow)
	end

	self:Remove()

	self.Planted = true

	return cse
end

if CLIENT then
	---
	-- @ignore
	function SWEP:Initialize()
		self:AddTTT2HUDHelp("vis_help_pri")

		return self.BaseClass.Initialize(self)
	end

	---
	-- @realm client
	function SWEP:DrawWorldModel()
		if IsValid(self:GetOwner()) then return end

		self:DrawModel()
	end

	---
	-- @realm client
	function SWEP:DrawWorldModelTranslucent()

	end
end
