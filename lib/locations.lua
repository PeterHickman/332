local locations = {
  loaded = false,
  max_images = 0,
  images = {},
  current_location = 1,
  menu_base = 0
}

-- Audio levels
local audio_silent = 0.0
local audio_muted = 0.02
local audio_normal = 0.3

local audio_sources = {}

local location_images = {
  { birdsong = audio_silent, traffic = audio_normal, image = 'front.jpg' },
  { birdsong = audio_muted,  traffic = audio_silent, image = 'bathroom.jpg' },
  { birdsong = audio_silent, traffic = audio_muted,  image = 'box_room.jpg' },
  { birdsong = audio_muted,  traffic = audio_silent, image = 'conservatory.jpg' },
  { birdsong = audio_silent, traffic = audio_muted,  image = 'dining_room_arch_end.jpg' },
  { birdsong = audio_silent, traffic = audio_muted,  image = 'dining_room_window_end.jpg' },
  { birdsong = audio_silent, traffic = audio_muted,  image = 'front_bedroom_door_end.jpg' },
  { birdsong = audio_silent, traffic = audio_muted,  image = 'front_bedroom_window_end.jpg' },
  { birdsong = audio_normal, traffic = audio_silent, image = 'garden_back_left.jpg' },
  { birdsong = audio_normal, traffic = audio_silent, image = 'garden_back_right.jpg' },
  { birdsong = audio_normal, traffic = audio_silent, image = 'garden_middle.jpg' },
  { birdsong = audio_normal, traffic = audio_silent, image = 'garden_patio_end.jpg' },
  { birdsong = audio_silent, traffic = audio_muted,  image = 'hall.jpg' },
  { birdsong = audio_muted,  traffic = audio_silent, image = 'kitchen.jpg' },
  { birdsong = audio_silent, traffic = audio_silent, image = 'landing.jpg' },
  { birdsong = audio_silent, traffic = audio_muted,  image = 'living_room_arch_end.jpg' },
  { birdsong = audio_silent, traffic = audio_muted,  image = 'living_room_window_end.jpg' },
  { birdsong = audio_normal, traffic = audio_silent, image = 'patio.jpg' },
  { birdsong = audio_silent, traffic = audio_muted,  image = 'rear_bedroom_door_end.jpg' },
  { birdsong = audio_muted,  traffic = audio_muted,  image = 'rear_bedroom_window_end.jpg' }
}

local navigation = {
  -- Front
  [1]  = { size = 1, options = { { location = 13, text = "Inside" }, }, },

  -- Bathroom
  [2]  = { size = 1, options = { { location = 15, text = "Landing" }, }, },

  -- Box room
  [3]  = { size = 1, options = { { location = 15, text = "Landing" }, }, },

  -- Conservatory
  [4]  = { size = 2, options = { 
                                  { location = 14, text = "Kitchen" },
                                  { location = 18, text = "Patio" },
                                },
         },

  -- Dining Room Arch End
  [5]  = { size = 3, options = {
                                  { location = 6, text = "Window end" },
                                  { location = 16, text = "Living room" },
                                  { location = 13, text = "Hall" },
                               },
         },

  -- Dining Room Window End
  [6]  = { size = 1, options = { { location = 5, text = "Arch end" }, }, },

  -- Front Bedroom Door End
  [7]  = { size = 2, options = {
                                  { location = 8, text = "Window end" },
                                  { location = 15, text = "Landing" },
                               },
         },

  -- Front Bedroom Window End
  [8]  = { size = 1, options = { { location = 7, text = "Door end" }, }, },

  -- Garden Back Left
  [9]  = { size = 2, options = {
                                  { location = 10, text = "Right" },
                                  { location = 11, text = "Middle" },
                               },
         },

  -- Garden Back Right
  [10] = { size = 2, options = {
                                  { location = 9, text = "Left" },
                                  { location = 11, text = "Middle" },
                               },
         },

  -- Garden Middle
  [11] = { size = 3, options = {
                                  { location = 9, text = "Left" },
                                  { location = 10, text = "Right" },
                                  { location = 12, text = "House end" },
                               },
         },

  -- Garden Patio End
  [12] = { size = 2, options = {
                                  { location = 18, text = "Patio" },
                                  { location = 11, text = "Middle" },
                               },
         },

  -- Hall
  [13] = { size = 5, options = {
                                  { location = 16, text = "Living room" },
                                  { location = 5, text = "Dining room" },
                                  { location = 14, text = "Kitchen" },
                                  { location = 15, text = "Upstairs" },
                                  { location = 1, text = "Outside" },
                               },
         },

  -- Kitchen
  [14] = { size = 2, options = {
                                  { location = 4, text = "Conservatory" },
                                  { location = 13, text = "Hall" },
                               },
         },

  -- Landing
  [15] = { size = 5, options = {
                                  { location = 7, text = "Front bedroom" },
                                  { location = 19, text = "Rear bedroom" },
                                  { location = 2, text = "Bathroom" },
                                  { location = 3, text = "Box room" },
                                  { location = 13, text = "Downstairs" },
                               },
         },

  -- Living Room Arch End
  [16] = { size = 3, options = {
                                  { location = 17, text = "Window end" },
                                  { location = 5, text = "Dining room" },
                                  { location = 13, text = "Hall" },
                               },
         },

  -- Living Room Window End
  [17] = { size = 1, options = { { location = 16, text = "Door end" }, }, },

  -- Patio
  [18] = { size = 2, options = {
                                  { location = 4, text = "Conservatory" },
                                  { location = 12, text = "Garden" },
                               },
         },

  -- Rear Bedroom Door End
  [19] = { size = 2, options = {
                                  { location = 20, text = "Window end" },
                                  { location = 15, text = "Landing" },
                               },
         },

  -- Rear Bedroom Window End
  [20] = { size = 1, options = { { location = 19, text = "Door end" }, }, },
}

local function load_audio(name)
  audio_sources[name] = lovr.audio.newSource('audio/' .. name .. '.ogg', 'static')
  audio_sources[name]:setLooping(true)
  audio_sources[name]:play()
end

local function load_images()
  for i=1,#location_images do
    locations.images[i] = lovr.graphics.newTexture('images/' .. location_images[i].image, { mipmaps = false })
  end
end

function locations.options_for_location()
  return navigation[locations.current_location].options
end

function locations.enter_location(index)
  locations.current_location = index
  audio_sources['birdsong']:setVolume(location_images[index].birdsong)
  audio_sources['traffic']:setVolume(location_images[index].traffic)
  locations.menu_base = navigation[index].size
end

function locations.load()
  load_images()
  load_audio('birdsong')
  load_audio('traffic')

  locations.enter_location(locations.current_location)

  locations.max_images = #location_images
  locations.loaded = true
end

return locations
