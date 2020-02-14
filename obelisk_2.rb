require 'numo/narray'
require 'gtk3'

include Numo

SPACE_GRID_SIZE = 256
VISUALIZATION_STEP = 8
Dx = 0.01
Du = 2e-5
Dv = 1e-5

def laplacian(ary, base)
  inflow_from_top    = base.reshape(SPACE_GRID_SIZE, SPACE_GRID_SIZE)
  inflow_from_bottom = base.reshape(SPACE_GRID_SIZE, SPACE_GRID_SIZE)
  inflow_from_left   = base.reshape(SPACE_GRID_SIZE, SPACE_GRID_SIZE)
  inflow_from_right  = base.reshape(SPACE_GRID_SIZE, SPACE_GRID_SIZE)
  outflow            = base.reshape(SPACE_GRID_SIZE, SPACE_GRID_SIZE)

  (SPACE_GRID_SIZE - 1).times do |i|
    inflow_from_top[i + 1, true]  = ary[i, true]
    inflow_from_bottom[i, true]   = ary[i + 1, true]
    inflow_from_left[true, i + 1] = ary[true, i]
    inflow_from_right[true, i]    = ary[true, i + 1]
  end
  outflow = ary * 4

  (inflow_from_top + inflow_from_bottom + inflow_from_left +
    inflow_from_right - outflow) / (Dx * Dx)
end

def calc(u, v, f, k)
  u_base = SFloat.ones(SPACE_GRID_SIZE, SPACE_GRID_SIZE)
  v_base = SFloat.zeros(SPACE_GRID_SIZE, SPACE_GRID_SIZE)
  VISUALIZATION_STEP.times do
    partial_u = laplacian(u, u_base) * Du - u * v * v + (1.0 - u) * f
    partial_v = laplacian(v, v_base) * Dv + u * v * v - (f + k) * v
    u += partial_u
    v += partial_v
  end
  [u, v]
end


window = Gtk::Window.new
window.set_size_request(SPACE_GRID_SIZE, SPACE_GRID_SIZE)
image = Gtk::Image.new

fixed = Gtk::Fixed.new
fixed.put(image, 0, 0)
window.add(fixed)

SQUARE_SIZE = 20

u = SFloat.ones(SPACE_GRID_SIZE, SPACE_GRID_SIZE)
v = SFloat.zeros(SPACE_GRID_SIZE, SPACE_GRID_SIZE)
square_start = SPACE_GRID_SIZE / 2 - SQUARE_SIZE / 2
square_end   = SPACE_GRID_SIZE / 2 + SQUARE_SIZE / 2
u[square_start..square_end, square_start..square_end] = 0.5
v[square_start..square_end, square_start..square_end] = 0.25


#GLib::Timeout.add(120)の120はアニメーションのウェイト時間（ミリ秒）
GLib::Timeout.add(120) do
  u, v = calc(u, v, 0.022, 0.051)    #このパラメータをいろいろ変える

  for_visualize = UInt8.cast(u * 255)
  data = UInt8.zeros(SPACE_GRID_SIZE, SPACE_GRID_SIZE, 3)
  data[true, true, 0] = for_visualize
  data[true, true, 1] = for_visualize
  data[true, true, 2] = for_visualize

  image.pixbuf = GdkPixbuf::Pixbuf.new(data: data.to_string,
                    width: SPACE_GRID_SIZE, height: SPACE_GRID_SIZE)
end


window.show_all
window.signal_connect("destroy") { Gtk.main_quit }
Gtk.main


#http://obelisk.hatenablog.com/entry/2019/11/14/231021
