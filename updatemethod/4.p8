pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- the basic update method

entities = {}

function _init()
	rebuild_active()
end

function _update()
	cls(1)
	update_mouse()
	
	rebuild_active()
	
	for a in all(active) do
		entities[a]:update()
	end
end

function _draw()
	map()
	for k, v in pairs(entities) do
		v:draw()
	end
	draw_mouse()
	print("cpu: "..stat(1), 0,0,7)
end

function rebuild_active()
	active = {}
	if _mhalf == 0 then
		for k, e in pairs(entities) do
			if e.x < 64 then
				add(active, e.id)
			end
		end
	else
		for k, e in pairs(entities) do
			if e.x >= 64 then
				add(active, e.id)
			end
		end
	end
end
-->8
-- the entity class

_entity = {
	x = 64, -- position
	y = 24,
	vx = 0, -- velocity
	vy = 0,
	f = 0.98, -- friction
	g = 0.1,  -- gravity
	r = 4,    -- radius (collision)
	id = 0    -- identifier
}

_id = 0

function _entity:new(o)
 --[[
 	this is just how you set up
 	class stuff in lua
 ]]-- 
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.id = _id
	_id += 1
	return o
end

--------------------------------

function _entity:update()
	-- do nothing by default
end

function _entity:draw()
	-- do nothing by default
end

--------------------------------

function _entity:physics()
	self.vy += self.g
	
	if self:map_collision(0,self.vy) then
		local d = 0
		while not self:map_collision(0,d) do
			d += 0.25 * sgn(self.vy)
		end
		d -= 0.25 * sgn(self.vy)
		
		self.y = self.y + d
		self.vy = 0
	end
	
	if self:map_collision(self.vx,0) then
		local d = 0
		while not self:map_collision(d,0) do
			d += 0.25 * sgn(self.vx)
		end
		d -= 0.25 * sgn(self.vx)
		
		self.x = self.x + d
		self.vx = 0
	end
	
	self.vx *= self.f
	self.vy *= self.f
	
	self.x += self.vx
	self.y += self.vy
end

function _entity:map_collision(ox,oy)
	x = ox or 0
	y = oy or 0
	
	x = x+self.x-4
	y = y+self.y-4

	if (x<0) return true
	if (x+7>1024) return true
	if (y<0) return true
	if (y+7>512) return true
	nw = mget((x)/8, (y)/8)
	ne = mget((x+7)/8, (y)/8)
	sw = mget((x)/8, (y+7)/8)
	se = mget((x+7)/8, (y+7)/8)
	return fget(nw, 0) == true
				 or fget(ne, 0) == true
				 or fget(sw, 0) == true
				 or fget(se, 0) == true
end

function _entity:collides(e,dx,dy)
	local x = dx or 0
	local y = dy or 0
	x = self.x + x
	y = self.y + y
	local dist2 = 
		(e.x - x)^2 + (e.y - y)^2
	return dist2 < (self.r+e.r)^2	
end

-->8
-- the skeleton class

_skel = _entity:new({
	going_left = false
})

function _skel:spawn(x,y)
	local s = _skel:new({x=x,y=y})
	entities[s.id] = s
	add(active,s.id)
	return s
end

function _skel:update()
	if self.going_left == true then
		self.vx = -0.4
		if self.x <= 5 then
			self.going_left = false
		end
	else
		self.vx = 0.4
		if self.x >= 124 then
			self.going_left = true
		end
	end
	
	self:physics()
end

function _skel:draw()
	spr(1,self.x-4,self.y-4)
	
	-- these draw collision boxes
	-- rect(self.x-4,self.y-4,self.x+3,self.y+3,9)
	-- circ(self.x,self.y,self.r,8)
end

-->8
-- the statue class

_statue = _entity:new({
	frame = 0,
	delay = 45
})

function _statue:spawn(x,y)
	local s = _statue:new({x=x,y=y})
	entities[s.id] = s
	add(active,s.id)
	return s
end

function _statue:update()
	self.frame += 1
	if self.frame == self.delay then
		_fireball:spawn(self.x,self.y)
		self.frame = 0
	end
	
	self:physics()
end

function _statue:draw()
	spr(2,self.x-4,self.y-4)
end
-->8
-- the fireball class

_fireball = _entity:new({
	lifetime = 20,
	g = 0
})

function _fireball:spawn(x,y)
	local f = _fireball:new({x=x,y=y})
	f.vx = 2 * sgn(rnd(2)-1)
	entities[f.id] = f
	add(active, f.id)
	return f
end

function _fireball:update()
	self.lifetime -= 1
	if self.lifetime == 0 then
		del(active, self.id)
		entities[self.id] = nil
	end
	self:physics()
end

function _fireball:draw()
	spr(3,self.x-4,self.y-4)
end
-->8
-- other stuff

poke(0x5f2d, 1)

function update_mouse()
	_mx = stat(32)
	_my = stat(33)
	_mb = stat(34)
	_mb1_pf = _mb1 or false
	_mb2_pf = _mb2 or false
	_mb1 = band(_mb, 1) != 0
	_mb2 = band(_mb, 2) != 0
	_mmb = band(_mb, 4) != 0
	_mb1_p = _mb1 and not _mb1_pf
	_mb2_p = _mb2 and not _mb2_pf
	_mhalf_pf = _mhalf or 0
	_mhalf = _mx < 64 and 0 or 1
	_mswitch = _mhalf != _mhalf_pf
	
	if _mb1_p == true then
		_skel:spawn(_mx, _my)
	end
	
	if _mb2_p == true then
		_statue:spawn(_mx, _my)
	end
end

function draw_mouse()
	spr(0,_mx-4, _my-4)
	
	if _mhalf == 0 then
		rect(0,0,63,127,11)
	else
		rect(64,0,127,127,11)
	end
end
__gfx__
00000000067777600066660000008000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000777777770066660008800090000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000711661170016610008988000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0008800075577557006666000008a880000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000880007771177700611600088aaa00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000667557660006600000007080000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
000000000067760000dddd000a088980000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000005656000dddddd000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
22222222555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
55555555555555550000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__map__
0000000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202020000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212121212121000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2020202020202020202020202020202021000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
2121212121212121212121212121212100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000