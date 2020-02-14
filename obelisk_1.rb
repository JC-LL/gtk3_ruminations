#!/usr/bin/env ruby
require "gtk2"

class GUI < Gtk::Window
  def initialize
    super("File Search")
    set_width_request(400)
    set_resizable(false)
    @file_name = Dir.pwd

    @box = Gtk::VBox.new
    add(@box)

    set_box1
    set_box2

    signal_connect("destroy") {Gtk.main_quit}
    show_all
  end

  def set_box1
    box1 = Gtk::HBox.new
    box1.set_height_request(35)
    @box.pack_start(box1, false, false, 1)

    button = Gtk::Button.new("ディレクトリ選択")
    button.signal_connect("clicked") do
      dialog = Gtk::FileChooserDialog.new("ディレクトリ",
        nil, Gtk::FileChooser::ACTION_SELECT_FOLDER, nil,
        [Gtk::Stock::CANCEL, Gtk::Dialog::RESPONSE_CANCEL],
        [Gtk::Stock::OPEN  , Gtk::Dialog::RESPONSE_ACCEPT])
      if dialog.run == Gtk::Dialog::RESPONSE_ACCEPT
        @folder_name = dialog.filename
      end
      dialog.destroy
    end
    box1.pack_start(button, true, true, 2)

    @check_button = Gtk::CheckButton.new("ディレクトリ?")
    box1.pack_start(@check_button, true, true, 2)

    @box.pack_start(Gtk::HSeparator.new, false, false, 5)
  end

  def set_box2
    box2 = Gtk::VBox.new
    @box.pack_start(box2, false, false, 1)

    label = Gtk::Label.new("探すファイルのファイル名に含まれる文字列を入力して下さい")

    name_search = Gtk::Entry.new
    name_search.signal_connect("activate") do
      @name = name_search.text
      execute
    end

    [label, name_search].each do |widget|
      box2.pack_start(widget, true, false, 3)
    end
  end

  def execute
    option = @check_button.active? ? "-type d" : "-type f"
    puts `find "#{@folder_name}" -name "*#{@name}*" #{option}`
    puts
  end
end

GUI.new
Gtk.main
