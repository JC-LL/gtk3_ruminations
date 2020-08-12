require 'gtk3'
require_relative 'force_directed_graph_drawer'

class Canvas < Gtk::DrawingArea
  attr_accessor :running
  def initialize
    super()

    @running=false
    set_size_request(800,100)
    signal_connect('draw') do
      redraw @graph #if @running
    end
  end

  def clear cr
    cr.set_source_rgb(0.1, 0.1, 0.1)
    cr.paint
  end

  def redraw graph=nil
    @graph=graph
    cr = window.create_cairo_context
    cr.set_line_width(0.8)

    w = allocation.width
    h = allocation.height

    cr.translate(w/2, h/2)

    clear cr

    if graph
      cr.set_source_rgb(0.4, 0.4, 0.4)
      @graph.edges.each do |edge|
        n1,n2=*edge
        cr.move_to(n1.x,n1.y)
        cr.line_to(n2.x,n2.y)
        cr.stroke
      end

      cr.set_source_rgb(0.9, 0.5, 0.2)
      @graph.nodes.each do |node|
        cr.arc(node.x, node.y, 10, 0, 2.0 * Math::PI)
        cr.fill_preserve()
        cr.stroke
      end
    end

  end
end

class Window < Gtk::Window

  def initialize args={} # I want to show it's possible to pass some args
    super()              # mandatory parenthesis ! otherwise : wrong arguments: Gtk::Window#initialize({})
    set_title 'jcll_3'
    set_default_size 900,600
    set_border_width 10
    set_window_position :center
    set_destroy_callback
    @algorithm=ForceDirectedGraphDrawer.new

    hbox = Gtk::Box.new(:horizontal, spacing=6)
    add hbox
    @canvas = Canvas.new
    hbox.pack_start(@canvas,:expand=>true,:fill=> true)
    #...instead of :
    # hbox.add canvas

    vbox   = Gtk::Box.new(:vertical,spacing=6)
    hbox.add vbox

    button = Gtk::Button.new(label:"open")
    button.signal_connect("clicked"){on_open_clicked(button)}
    vbox.pack_start(button,:expand => false, :fill => false, :padding => 0)

    button = Gtk::Button.new(label:"random")
    button.signal_connect("clicked"){on_random_clicked(button)}
    vbox.pack_start(button,:expand => false, :fill => false, :padding => 0)

    button = Gtk::Button.new(:label => "run")
    button.signal_connect("clicked"){on_run_clicked(button)}
    vbox.pack_start(button,:expand => false, :fill => false, :padding => 0)

    button = Gtk::Button.new(:label => "stop")
    button.signal_connect("clicked"){on_stop_clicked(button)}
    vbox.pack_start(button,:expand => false, :fill => false, :padding => 0)

    button = Gtk::Button.new(:label => "step")
    button.signal_connect("clicked"){on_step_clicked(button)}
    vbox.pack_start(button,:expand => false, :fill => false, :padding => 0)

    button = Gtk::Button.new(:label => "save")
    button.signal_connect("clicked"){on_save_clicked(button)}
    vbox.pack_start(button,:expand => false, :fill => false, :padding => 0)

    button = Gtk::Button.new(:label => "quit")
    button.signal_connect("clicked"){on_quit_clicked(button)}
    vbox.pack_start(button,:expand => false, :fill => false, :padding => 0)
    show_all
  end

  def on_open_clicked button
    puts '"open" button was clicked'
    dialog=Gtk::FileChooserDialog.new(
             :title => "choose",
             :parent => self,
             :action => Gtk::FileChooserAction::OPEN,
				     :buttons => [[Gtk::Stock::OPEN, Gtk::ResponseType::ACCEPT],
				                  [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]])
    filter_sexp = Gtk::FileFilter.new
    filter_sexp.name = "s-expr filter"
    filter_sexp.add_pattern("*.sexp")
    filter_sexp.add_pattern("*.sxp")
    dialog.add_filter(filter_sexp)

    filter_rb = Gtk::FileFilter.new
    filter_rb.name = "ruby filter"
    filter_rb.add_pattern("*.rb")
    dialog.add_filter(filter_rb)

    dialog.show_all

    case dialog.run
    when Gtk::ResponseType::ACCEPT
      puts "filename = #{dialog.filename}"
      #puts "uri = #{dialog.uri}"
      dialog.destroy
    else
      dialog.destroy
    end
  end

  def on_random_clicked button
    puts 'button "random" clicked'
    @graph=Graph.random(40)
    @canvas.running=true
    @canvas.redraw @graph
  end

  def on_run_clicked button
    puts 'button "run" clicked'
    @canvas.running=true
    @algorithm.graph=@graph
    @algorithm.run(iter=1000){@canvas.redraw @graph}
  end

  def on_stop_clicked button
    puts 'button "stop" clicked'
  end

  def on_step_clicked button
    puts '"step" button was clicked'
  end

  def on_save_clicked button
    puts 'button "save" clicked'
  end

  def on_quit_clicked button
    puts "Closing application"
    Gtk.main_quit
  end

  def set_destroy_callback
    signal_connect("destroy"){Gtk.main_quit}
  end

end

window=Window.new
Gtk.main
