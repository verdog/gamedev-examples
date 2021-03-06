pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- 

function _init()
	entities = {}
end

function _update()
	cls(0)
	update_mouse()
	for e in all(entities) do
		e:update()
	end
end

function _draw()
	map()
	for e in all(entities) do
		e:draw()
	end
	draw_mouse()
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

function _entity:new(o)
 --[[
 	this is just how you set up
 	class stuff in lua
 ]]-- 
	o = o or {}
	setmetatable(o, self)
	self.__index = self
	o.id = self.id
	self.id += 1
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
-- mouse

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
end

function draw_mouse()
	spr(0,_mx-4, _my-4)
end
__gfx__
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
00088000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
__gff__
0000000000000000000000000000000000000000000000000000000000000000010100000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000
