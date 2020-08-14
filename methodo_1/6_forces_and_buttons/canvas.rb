
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
