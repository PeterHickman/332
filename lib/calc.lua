-- https://www.geeksforgeeks.org/program-to-find-equation-of-a-plane-passing-through-3-points

-- Find the equation of a plane given three points on that plane. The three
-- points must not be colinear

function plane_from_points(corners)
  local a1 = corners[2].x - corners[1].x 
  local b1 = corners[2].y - corners[1].y 
  local c1 = corners[2].z - corners[1].z 
  local a2 = corners[3].x - corners[1].x 
  local b2 = corners[3].y - corners[1].y 
  local c2 = corners[3].z - corners[1].z 

  local a = b1 * c2 - b2 * c1 
  local b = a2 * c1 - a1 * c2 
  local c = a1 * b2 - b1 * a2 
  local d = (-a * corners[1].x - b * corners[1].y - c * corners[1].z) 

  return { a = a, b = b, c = c, d = d }
end

-- Return the minimum and maximum from a list of numbers

local function min_and_max(values, key)
  local min = values[1][key]
  local max = values[1][key]

  for _,v in pairs(values) do
    if v[key] < min then
      min = v[key]
    elseif v[key] > max then
      max = v[key]
    end
  end

  return min, max
end

-- http://www.ambrsoft.com/TrigoCalc/Plan3D/PlaneLineIntersection_.htm

-- Technically from the web page but in reality there are all sorts of
-- mistakes in the page and so I ignored the equations and looked at the
-- javascript until I got something to work correctly

function intersects(points, corners)
  -- Equation for the plane
  local pe = plane_from_points(corners)

  -- Parametric line equation
  local a = {points[1].x, points[2].x - points[1].x}
  local b = {points[1].y, points[2].y - points[1].y}
  local c = {points[1].z, points[2].z - points[1].z}

  local px = points[2].x
  local py = points[2].y
  local pz = points[2].z
  local tx = points[1].x - px
  local ty = points[1].y - py
  local tz = points[1].z - pz

  local t = (pe.a * px + pe.b * py + pe.c * pz + pe.d) / (pe.a * tx + pe.b * ty + pe.c * tz)

  local x = px - t * tx
  local y = py - t * ty
  local z = pz - t * tz

  -- At this point x, y and z represent where the beam
  -- intersects the infinite plane that the menu is part
  -- of and not necessarily the menu itself

  local inside = false
  local rel = {}
  local x1, x2 = min_and_max(corners, 'x')
  local y1, y2 = min_and_max(corners, 'y')
  local z1, z2 = min_and_max(corners, 'z')

  if x1 <= x and x <= x2 and y1 <= y and y <= y2 and z1 <= z and z <= z2 then
    inside = true

    -- The relative coordinates within the menu
    -- (0,0) is the bottom left and (1,1) is the
    -- top right. Just like a normal chart

    rel.x = math.abs(x - x1) / math.abs(x2 - x1)
    rel.y = math.abs(y - y1) / math.abs(y2 - y1)
  end

  -- We now know if the beam lies inside the menu. Note that this
  -- relies on the specific properties of the menu. In that it is
  -- flat and that it is a normal square

  -- Given that the player cannot move (3DOF) the controller is limited
  -- in its available positions and the menu is draw a fixed distance
  -- from the player and the beam is much longer that this distance then
  -- we can say that if it intersects it does indeed intersects. This
  -- approach will not work for generic object collisions
  -- or anything but plain rectangular menus

  return inside, { x = x, y = y, z = z }, rel
end
