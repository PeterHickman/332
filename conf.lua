function lovr.conf(t)
  local path, cpath = lovr.filesystem.getRequirePath()
  lovr.filesystem.setRequirePath(path .. ';lib/?.lua', cpath)
end
