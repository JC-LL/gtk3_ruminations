require 'gtk3'
# the objective of this code is to experiment with :
# - adding buttons triggering various commands
# - file chooser (with extension filters)

class Window < Gtk::Window

  def initialize args={} # I want to show it's possible to pass some args
    super()              # mandatory parenthesis ! otherwise : wrong arguments: Gtk::Window#initialize({})
    set_title 'jcll_3'
    set_default_size 900,600
    set_border_width 10
    set_window_position :center
    
    set_destroy_callback
    hbox = Gtk::Box.new(:horizontal, spacing=6)
    add hbox

    vbox = Gtk::Box.new(:vertical,spacing=6)
    hbox.add vbox

    button = Gtk::Button.new(label:"open")
    button.signal_connect("clicked"){on_open_clicked(button)}
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

  def on_run_clicked button
    puts '"run" button was clicked'
  end

  def on_stop_clicked button
    puts '"stop" button was clicked'
  end

  def on_step_clicked button
    puts '"step" button was clicked'
  end

  def on_save_clicked button
    puts '"save" button was clicked'
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
