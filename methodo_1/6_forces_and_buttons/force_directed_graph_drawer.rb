
require_relative 'graph'

# open class for [x,y]
require_relative 'my_array'

class ForceDirectedGraphDrawer

  attr_accessor :graph

  def initialize
    puts "FDGD: force-directed graph drawer"
    @l0=80
    @c1=30
    @epsilon=10
    @damping=0.92
    @timestep=0.1
  end

  def dist a,b
    res=Math.sqrt((a.x - b.x)**2 + (a.y - b.y)**2)
    #puts "distance(#{a.id},#{b.id})=#{res}"
    return res
  end

  def angle a,b
    #puts "pos #{a.id} = #{a.pos}"
    if dist(a,b)!=0
      if b.x > a.x
        angle = Math.asin((b.y-a.y)/dist(a,b))
      else
        angle = Math::PI - Math.asin((b.y-a.y)/dist(a,b))
      end
    else
      angle =0
    end
    return angle
  end

  def coulomb_repulsion a,b
    angle = angle(a,b)
    dab = dist(a,b)
    c= -0.2*(a.radius*b.radius)/Math.sqrt(dab)
    #puts "coulomb_repulsion(#{a.id},#{b.id})=#{c}"
    [c*Math.cos(angle),c*Math.sin(angle)]
  end

  def sign_minus(a,b)
    a>b ? 1 : -1
  end

  def hooke_attraction a,b #,c1=10#,l0=40
    angle = angle(a,b)
    dab = dist(a,b)
    c = @c1*Math.log((dab-@l0).abs)*sign_minus(dab,@l0)
    [c*Math.cos(angle),c*Math.sin(angle)]
  end

  def run iter=2
    return unless @graph

    step = 0
    total_kinetic_energy=1000
    next_pos={}

    until total_kinetic_energy < @epsilon or step==iter do

      step+=1
      total_kinetic_energy = 0

      for node in graph.nodes
        net_force = Vector.new(0, 0)

        for other in graph.nodes-[node]
          rep = coulomb_repulsion( node, other)
          net_force += rep
        end

        for edge in graph.edges.select{|e| e.first==node or e.last==node}
          other = edge.last==node ? edge.first : edge.last
          attr = hooke_attraction(node, other) #, c1=30,@l0)
          net_force += attr
        end

        # without damping, it moves forever
        node.velocity = (node.velocity + net_force.scale(@timestep)).scale(@damping)
        next_pos[node.pos] = node.pos + node.velocity.scale(@timestep)
        total_kinetic_energy += node.radius * node.velocity.squared
      end

      #puts total_kinetic_energy
      yield if block_given?
      for node in graph.nodes
        node.pos = next_pos[node.pos]
      end
    end
    puts "algorithm end"
    puts "reached epsilon" if total_kinetic_energy < @epsilon
    puts "reached max iterations" if step==iter
  end

end