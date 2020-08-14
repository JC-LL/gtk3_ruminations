require 'gtk3'

require_relative 'force_directed_graph_drawer'
require_relative 'canvas'

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

    label = Gtk::Label.new("number of nodes : ")

    vbox.pack_start(label,:expand => false, :fill => false, :padding => 0)

    spinner = Gtk::SpinButton.new(1,50,1)
    spinner.value= @nb_value || 20
    spinner.signal_connect("value-changed"){on_spin_changed(spinner)}
    vbox.pack_start(spinner,:expand => false, :fill => false, :padding => 0)

    button = Gtk::Button.new(:label => "run")
    button.signal_connect("clicked"){on_run_clicked(button)}
    vbox.pack_start(button,:expand => false, :fill => false, :padding => 0)

    button = Gtk::Button.new(:label => "stop")
    button.signal_connect("clicked"){on_stop_clicked(button)}
    vbox.pack_start(button,:expand => false, :fill => false, :padding => 0)

    button = Gtk::Button.new(:label => "step")
    button.signal_connect("clicked"){on_step_clicked(button)}
    vbox.pack_start(button,:expand => false, :fill => false, :padding => 0)

    button = Gtk::Button.new(:label => "shuffle")
    button.signal_connect("clicked"){on_shuffle_clicked(button)}
    vbox.pack_start(button,:expand => false, :fill => false, :padding => 0)

    button = Gtk::Button.new(:label => "fit")
    button.signal_connect("clicked"){on_fit_clicked(button)}
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

    dialog.show_all

    case dialog.run
    when Gtk::ResponseType::ACCEPT
      puts "filename = #{dialog.filename}"
      #puts "uri = #{dialog.uri}"
      @graph=Graph.read_file dialog.filename
      @canvas.redraw @graph
      dialog.destroy
    else
      dialog.destroy
    end
  end

  def on_random_clicked button
    puts 'button "random" clicked'
    @graph=Graph.random(@nb_nodes || 20)
    @canvas.running=true
    @canvas.redraw @graph
  end

  def on_spin_changed spinbutton
    value=spinbutton.value
    puts "spin button modified #{value}"
    @nb_nodes=value.to_i
    @graph=Graph.random(value.to_i)
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
    puts 'button "step" clicked'
  end

  def on_shuffle_clicked button
    puts 'button "shuffle" clicked'
    if @graph
      @graph.shuffle
      @canvas.redraw @graph
    end
  end

  def on_fit_clicked button
    puts 'button "fit" clicked'
    if @graph
    end
  end

  def on_save_clicked button
    puts 'button "save" clicked'
    # if @graph
    #   @graph.write_file @graph.id.to_s+".sexp"
    # end
    dialog=Gtk::FileChooserDialog.new(
             :title => "choose",
             :parent => self,
             :action => Gtk::FileChooserAction::SAVE,
				     :buttons => [[Gtk::Stock::SAVE, Gtk::ResponseType::ACCEPT],
				                  [Gtk::Stock::CANCEL, Gtk::ResponseType::CANCEL]])
    filter_sexp = Gtk::FileFilter.new
    filter_sexp.name = "s-expr filter"
    filter_sexp.add_pattern("*.sexp")
    filter_sexp.add_pattern("*.sxp")
    dialog.add_filter(filter_sexp)

    dialog.show_all

    case dialog.run
    when Gtk::ResponseType::ACCEPT
      puts "filename = #{dialog.filename}"
      #puts "uri = #{dialog.uri}"
      @graph.write_file dialog.filename
      dialog.destroy
    else
      dialog.destroy
    end
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
