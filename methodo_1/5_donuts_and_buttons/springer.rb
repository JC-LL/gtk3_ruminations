# -*- coding: utf-8 -*-
#require 'graph'
require 'pp'

# open class for [x,y]
class Array
  def x
    return self[0]
  end

  def y
    return self[1]
  end

  def +(other)
    res=[]
    self.each_with_index do |e,i|
      res[i]=e+other[i]
    end
    return res
  end

  def scale int
    res=[]
    self.each_with_index do |e,i|
      res[i]=e*int
    end
    return res
  end

  def squared
    res=0
    self.each do |e|
      res+=e*e
    end
    return res
  end

end

class Springer
  def initialize
    puts "springer : force-directed placer"
    @l0=80
    @c1=30
    @epsilon=10
    @damping=0.92
    @timestep=0.1
  end

  def place g,iter=1
    #puts "running placement of #{g.id}"
    algo(g,iter)
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

  def algo g, iter=2 #,l0=100,epsilon=10,damping=0.92,timestep=0.1
    step = 0
    total_kinetic_energy=1000
    next_pos={}

    until total_kinetic_energy < @epsilon or step==iter do

      step+=1
      total_kinetic_energy = 0

      for node in g.nodes
        net_force = [0, 0]

        for other in g.nodes-[node]
          rep = coulomb_repulsion( node, other)
          net_force += rep
        end

        for edge in g.edges.select{|e| e.first==node or e.last==node}
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

      for node in g.nodes
        #puts next_pos[node.pos]
        node.pos = next_pos[node.pos]
      end
    end
  end

end
