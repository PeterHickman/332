package.path = './lib/?.lua;' .. package.path

require "strict"

local pollr = require "pollr"

local locations = require "locations"
local controls = require "controls"
local shader = require "shader"
local menu = require "menu"

function pollr.buttonpressed(device, button)
  if button == 'trigger' then
    if menu.active then
      if menu.inside then
        menu.select_option(locations)
      else
        menu.disable()
      end
    else
      menu.enable()
    end
  end
end

function lovr.load()
  controls.load()
  locations.load()
  menu.load()
  shader.load()
end

function lovr.update(dt)
  if locations.loaded then
    pollr.update()
    lovr.audio.update()
  end
end
  
function lovr.draw()
  if locations.loaded then
    menu.draw(locations)
    controls.draw(shader.light_source, menu)

    lovr.graphics.skybox(locations.images[locations.current_location])
  else
    lovr.graphics.print("332", 0, 1, -5)
    lovr.graphics.print("is loading...", 0, 0, -5)
  end
end
