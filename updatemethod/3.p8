pico-8 cartridge // http://www.pico-8.com
version 18
__lua__
-- gotcha: objects are not 
--  truly concurrent

function _init()
	entities = {}
	add(entities, _face:new({x=32,y=55}))
	add(entities, _face:new({x=32,y=73}))
end

function _update()
	cls(1)
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
	y = 64,
	vx = 0, -- velocity
	vy = 0,
	f = 0.98, -- friction
	g = 0.1,  -- gravity
	r = 4,    -- radius (collision)
	id = 0,    -- identifier
	typ = "entity" -- used to check entities types
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
	if e.id == self.id then
		return false
	end
	local x = dx or 0
	local y = dy or 0
	x = self.x + x
	y = self.y + y
	local dist2 = 
		(e.x - x)^2 + (e.y - y)^2
	return dist2 < (self.r+e.r)^2	
end

-->8
-- the smiley face class

_face = _entity:new({
	mood = "happy",
 r    = 8
})

function _face:update()
	for e in all(entities) do
		if e.typ == "saw"
		and self:collides(e)
		and self.mood == "happy" 
		then
			self.mood = "sad"
			del(entities, e)
		end
	end
end

function _face:draw()
	if self.mood == "happy" then
		spr(4,self.x-8,self.y-8,2,2)
	else
		spr(6,self.x-8,self.y-8,2,2)
	end
	
	-- draws collision box
	-- circ(self.x,self.y,self.r,7)
end
-->8
-- the saw blade class

_saw = _entity:new({
	g = 0,
	r = 7,
	typ = "saw"
})

function _saw:update()
	
	self:physics()
end

function _saw:draw()
	spr(8,self.x-8,self.y-8,2,2)
	
	-- draws collision shape
 --	circ(self.x,self.y,self.r,7)
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
	
	if _mb1_p == true then
		add(entities, _saw:new({
			x=_mx,vx=-2
		}))
	end
end

function draw_mouse()
	spr(0,_mx-4, _my-4)
end
__gfx__
0000000006777760006666000000800000000aaaaaa0000000000dddddd000000000700700700070000000000000000000000000000000000000000000000000
00000000777777770066660008800090000aaaaaaaaaa000000dddddddddd0000707707707707700000000000000000000000000000000000000000000000000
0000000071166117001661000898800000aaaaaaaaaaaa0000dddddddddddd000076666666666700000000000000000000000000000000000000000000000000
0008800075577557006666000008a8800aaaaaaaaaaaaaa00dddddddddddddd07766666666666670000000000000000000000000000000000000000000000000
000880007771177700611600088aaa000aaaaaaaaaaaaaa00dddddddddddddd00766655555566677000000000000000000000000000000000000000000000000
00000000667557660006600000007080aaaaa0aaaa0aaaaaddddd0dddd0ddddd0066555555556600000000000000000000000000000000000000000000000000
000000000067760000dddd000a088980aaaaaaaaaaaaaaaadddddddddddddddd7766555555556670000000000000000000000000000000000000000000000000
00000000005656000dddddd000000000aaaaaaaaaaaaaaaadddddddddddddddd0766555555556677000000000000000000000000000000000000000000000000
00000000000000000000000000000000aaaaaaaaaaaaaaaadddddddddddddddd0066555555556600000000000000000000000000000000000000000000000000
00000000000000000000000000000000aaa0aaaaaaaa0aaadddddd0000dddddd7766555555556670000000000000000000000000000000000000000000000000
00000000000000000000000000000000aaaa0aaaaaa0aaaaddddd0dddd0ddddd0766555555556677000000000000000000000000000000000000000000000000
000000000000000000000000000000000aaaa0aaaa0aaaa00ddd0dddddd0ddd00066655555566600000000000000000000000000000000000000000000000000
000000000000000000000000000000000aaaaa0000aaaaa00dd0dddddddd0dd00766666666666670000000000000000000000000000000000000000000000000
0000000000000000000000000000000000aaaaaaaaaaaa0000dddddddddddd000776666666666770000000000000000000000000000000000000000000000000
00000000000000000000000000000000000aaaaaaaaaa000000dddddddddd0007000770770770007000000000000000000000000000000000000000000000000
0000000000000000000000000000000000000aaaaaa0000000000dddddd000000000700700700000000000000000000000000000000000000000000000000000
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
