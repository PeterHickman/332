#!/usr/bin/env ruby

# The test menu is 1000 x 1500. The ratio at least is good

require 'chunky_png'

MENU_WIDTH = 500
MENU_HEIGHT = 750

INSET = 10

# More harmonious colours would be nice

BACK = ChunkyPNG::Color.rgb( 82,  87,  93) # The menu background
PART = ChunkyPNG::Color.rgb(246, 244, 230) # The section container
HIGH = ChunkyPNG::Color.rgb(253, 219,  58) # The section highlighted

def box(png, x, y, w, h, i, c)
  png.circle(x + i + 1,     y + i + 1,     i, c, c)
  png.circle(x + i + 1,     y + h - i - 1, i, c, c)
  png.circle(x + w - i - 1, y + i + 1,     i, c, c)
  png.circle(x + w - i - 1, y + h - i - 1, i, c, c)

  png.rect(x + i + 1, y,         x + w - i - 1, y + h,     c, c)
  png.rect(x,         y + i + 1, x + w,         y + h - i, c, c)
end

def create(parts, highlight = nil)
  png = ChunkyPNG::Image.new(MENU_WIDTH, MENU_HEIGHT, ChunkyPNG::Color::TRANSPARENT)

  filename = highlight.nil? ? "menu_#{parts}" : "menu_#{parts}_#{highlight}"

  puts "#{filename}"

  box(png, 0, 0, MENU_WIDTH, MENU_HEIGHT, INSET, BACK)

  available_height = MENU_HEIGHT - (INSET * 2) - (INSET * (parts - 1))
  part_height = available_height / parts

  x1 = INSET
  x2 = MENU_WIDTH - INSET

  y1 = 0
  y2 = 0

  (1..parts).each do |p|
    y1 += INSET
    y2 = y1 + part_height

    c = highlight == p ? HIGH : PART
    box(png, x1, y1, x2 - x1, y2 - y1, INSET / 2, c)

    y1 = y2
  end

  png.save("assets/#{filename}.png")
end

menu_sizes = [1, 2, 3, 5]

menu_sizes.each do |l|
  create(l)

  (1..l).each do |i|
    create(l, i)
  end
end
