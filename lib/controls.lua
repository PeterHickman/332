require "calc"

local controls = {
  beam_length = 7,
  points = {}
}

local controller_models = {}

function controls.load()
  controller_models = {
    ["hand/left"] = lovr.graphics.newModel('assets/oculus-go-controller.glb'),
    ["hand/right"] = lovr.graphics.newModel('assets/oculus-go-controller.glb')
  }
end

function controls.draw(shader, menu)
  for _, device in ipairs(lovr.headset.getHands()) do
    if lovr.headset.isTracked(device) then
      local x, y, z, angle, ax, ay, az = lovr.headset.getPose(device)

      lovr.graphics.setShader(shader)
      controller_models[device]:draw(x, y, z, 0.01, angle, ax, ay, az)
      lovr.graphics.setShader()

      if menu.active then
        local nx, ny, nz = mat4(x, y, z, angle, ax, ay, az):mul(0, 0, -controls.beam_length / 2)

        -- The first point is the source of beam (the controller)
        -- and the second point is the end of the beam

        controls.points = {
          {x = x,  y = y,  z = z},
          {x = nx, y = ny, z = nz}
        }

        local inside, i, rel = intersects(controls.points, menu.corners)
        menu.inside = inside

        local r, g, b = 0.0, 0.0, 1.0
        if menu.inside then
          -- Here is where we should tell the menu where we are pointing!
          menu.highlight(rel)
          r, g, b = 0.0, 1.0, 0.0
        else
          menu.highlighted_option = nil
        end

        lovr.graphics.setColor(r, g, b, 1.0)
        lovr.graphics.cylinder(nx, ny, nz, controls.beam_length, angle, ax, ay, az, 0.01, 0.002)
      end
      lovr.graphics.setColor(1.0, 1.0, 1.0, 1.0)

      break
    end
  end
end

return controls
