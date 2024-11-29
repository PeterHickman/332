require "calc"

local menu = {
  active = false,
  inside = false,
  position = nil,
  scale = 2.0,
  depth = 0,
  corners = {},
  rel = {},
  materials = {},
  highlighted_option = nil,
  base = nil
}

local menu_names = {
  'menu_1',
  'menu_1_1',
  'menu_2',
  'menu_2_1',
  'menu_2_2',
  'menu_3',
  'menu_3_1',
  'menu_3_2',
  'menu_3_3',
  'menu_5',
  'menu_5_1',
  'menu_5_2',
  'menu_5_3',
  'menu_5_4',
  'menu_5_5',
}

-- The selection comes from rel.x and rel.y which
-- are [0.0 .. 1.0] values for their relative
-- position within the menu. This is used to see
-- which point on the menu is selected

local options = {
  [1] = { 0.0 },
  [2] = { 0.5, 0.0 },
  [3] = { 0.66, 0.33, 0.0 },
  [4] = {},
  [5] = { 0.8, 0.6, 0.4, 0.2, 0.0 }
}

local text_offsets = {
  { 0.0 },
  { 0.7, -0.7 },
  { 0.9, 0.0, -0.9 },
  {}, -- No menus of size 4
  { 1.1, 0.55, 0.0, -0.55, -1.1 },
}

function menu.load()
  local first_one = true
  local texture = nil
  local textureWidth, textureHeight, aspect

  for _,file in pairs(menu_names) do
    texture = lovr.graphics.newTexture('assets/' .. file .. '.jpg')
    menu.materials[file] = lovr.graphics.newMaterial(texture)

    if first_one then
      -- All the menu images are the same size

      textureWidth, textureHeight = texture:getDimensions()
      menu.width = menu.scale
      aspect = textureHeight / textureWidth
      menu.height = menu.scale * aspect

      first_one = false
    end
  end
end

function menu.draw(locations)
  if menu.active then
    local x, y, z, angle, ax, ay, az = unpack(menu.position)

    menu.base = locations.menu_base
    local this_menu = 'menu_' .. menu.base

    if menu.highlighted_option ~= nil then
      this_menu = this_menu .. '_' .. menu.highlighted_option
    end

    lovr.graphics.plane(menu.materials[this_menu], x, y, z, menu.width, menu.height, angle, ax, ay, az)

    local ox, oy, oz, oangle, oax, oay, oaz = unpack(menu.origin)
    -- print('This is location ' .. locations.current_location)

    for i,v in pairs(locations.options_for_location()) do
      local nx, ny, nz = mat4(ox, oy, oz, oangle, oax, oay, oaz):mul(0, text_offsets[locations.menu_base][i], -2.8)
      if menu.highlighted_option == i then
        lovr.graphics.setColor(1, 1, 1)
      else
        lovr.graphics.setColor(0, 0, 0)
      end
      lovr.graphics.print(v.text, nx, ny, nz, 0.2, oangle, oax, oay, oaz)
    end

    lovr.graphics.setColor(1, 1, 1)
  end
end

-- When entering a room the menu needs to be removed and the
-- position unset as we have a new orientation

function menu.disable()
  menu.active = false
  menu.base = nil
  menu.corners = {}
  menu.highlighted_option = nil
  menu.inside = false
  menu.origin = {}
  menu.position = nil
  menu.rel = {}
end

function menu.highlight(rel)
  menu.rel = rel

  for i,v in pairs(options[menu.base]) do
    if rel.y > v then
      menu.highlighted_option = i
      break
    end
  end
end

function menu.select_option(locations)
  local x = locations.options_for_location()

  locations.enter_location(x[menu.highlighted_option].location)
  menu.disable()
end

local function makev(x, y, z)
  return { x = x, y = y, z = z }
end

function menu.enable()
  if menu.position == nil then
    local x, y, z, angle, ax, ay, az = lovr.headset.getPose()
    -- By setting these values to 0 the menu will remain
    -- upright ahead of the user regardless of how the
    -- head is angled
    ax = 0
    az = 0
    menu.origin = {x, y, z, angle, ax, ay, az}

    local nx, ny, nz = mat4(x, y, z, angle, ax, ay, az):mul(0, 0, -3)

    menu.position = {nx, ny, nz, angle, ax, ay, az}

    local hw = menu.width / 2
    local hh = menu.height / 2

    -- These points are there the corners of the menu will be
    -- in 3d space. In order top left, top right, bottom left
    -- and bottom right
    menu.corners = {
      makev(mat4(x, y, z, angle, ax, ay, az):mul( hw,  hh, -3.0)),
      makev(mat4(x, y, z, angle, ax, ay, az):mul(-hw,  hh, -3.0)),
      makev(mat4(x, y, z, angle, ax, ay, az):mul( hw, -hh, -3.0)),
      makev(mat4(x, y, z, angle, ax, ay, az):mul(-hw, -hh, -3.0)),
    }
  end

  menu.active = true
end

return menu
