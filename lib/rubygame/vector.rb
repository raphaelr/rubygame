#--
# Rubygame::Vector -- A realistic 2D Vector class
# Copyright (C) 2010  Raphael Robatsch
# 
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
# 
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
# 
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
#++

module Rubygame
	# Shortcut for Rubygame::Vector.new
	def Vector(*args)
		return Vector.new(*args)
	end
end

# A Math(tm)-compatible 2D Vector class.
# 
# == Features:
# formatting:: <tt>Vector#to_s</tt>, <tt>Vector#inspect</tt>
#              <tt>Vector(4, 3).to_s       # => "Vector(4/3)"
#              <tt>Vector(4, 3).inspect    # => "Vector(4/3); a=0.6435...; m=5.0"</tt>
# simplifying:: <tt>Vector#simplify</tt>, <tt>Vector#simplify!</tt>
#               <tt>Vector(10, 5).simplify    # => Vector(2, 1)</tt>
# unit vectors:: <tt>Vector#unit</tt>, <tt>Vector#unit!</tt>
#                Sets the vector's length to 1.
#                <tt>Vector(4, 3).unit    # => Vector(4/5, 3/5)</tt>
# adding, substracting:: <tt>Vector#+</tt>, <tt>Vector#-</tt>
#                        Basic vector math.
#                        <tt>Vector(4, 3) + Vector(2, 9)    # => Vector(6, 12)</tt>
# multiplication:: <tt>Vector#*</tt>
#                  Multiplicates a vector with a number.
#                  <tt>Vector(4, 3) * 5    # => Vector(20, 15)</tt>
# division:: <tt>Vector#/</tt>
#            Divides a vector by a number.
#            <tt>Vector(20, 16) / 2    # => Vector(10, 8)</tt>
# unary minus:: <tt>Vector#-@</tt>
#               <tt>-Vector(4, 3)    # => Vector(-4, -3)</tt>
# dot-product:: <tt>Vector#*</tt>
#               Calculated using the formula <tt>x0 * x1 + y0 * y1</tt>.
#               <tt>Vector(2, 3) * Vector(-1, 4)    # => 10</tt>
# cross-product:: <tt>Vector#cross</tt>
#                 Use it to get the area of a paralellogram enclosed by
#                 two vectors. Divide by two for a triangle.
#                 <tt>Vector(5, 1).cross(Vector(2, 8)).length    # => 40.0499...</tt>
# scaling:: <tt>Vector#scale</tt>, <tt>Vector#scale!</tt>
#           Scales a vector along the x- and y-Axis.
#           <tt>Vector(4, 8).scale(2, 3)    # => Vector(8, 24)</tt>
#           <tt>Vector(4, 9).scale(2)       # => Vector(8, 18)</tt>
# normal vectors:: <tt>Vector#normal</tt>
#                  Returns a vector that is normal at _self_.
#                  <tt>Vector(4, 8).normal    # => Vector(8, -4)</tt>
# normal at:: <tt>Vector#normal_at?</tt>
#             Checks if a vector is normal at _self_.
#             <tt>Vector(4, 8).normal_at?(Vector(8, -4))    # => true</tt>
# enclosed angle:: <tt>Vector#enclosed_angle</tt>
#                  Returns the angle enclosed by two vectors.
#                  <tt>Vector(10, 3).enclosed_angle(Vector(3, 7))    # => 0.8744...</tt>
# polar coordinates:: <tt>Vector#m</tt>, <tt>Vector#a</tt>, <tt>Vector#m=</tt>, <tt>Vector#a=</tt>
#                     Gets/Sets the angle and magnitude.
# phase:: <tt>Vector::phase</tt>, <tt>Vector::rubygame</tt>
#         Changes the way <tt>Vector#w</tt> and <tt>Vector#w=</tt> handles angles.
#         <tt>Vector::rubygame</tt> sets the phase to -PI/2, so the "top" will be at
#         zero rads.
#         *NOTE:* changing this value will affect *ALL* already created vectors too!
# 
# <tt>Vector#m</tt>, <tt>Vector#m=</tt>, <tt>Vector#a</tt>, <tt>Vector#a=</tt> are aliased
# as <tt>Vector#length</tt>, <tt>Vector#length=</tt>, <tt>Vector#angle</tt> and
# <tt>Vector#angle=</tt> for your convenience.
# 
# <tt>Vector#m</tt> and <tt>Vector#m=</tt> are also aliased as <tt>Vector#magnitude</tt> and
# <tt>Vector#magnitude=</tt> .
# 
# I want RDoc-Linebreaks. Now.
class Rubygame::Vector
	PI = Math::PI
	HALF_PI = PI / 2
	QUARTER_PI = PI / 4
	DOUBLE_PI = PI * 2
	FOUR_PI = PI * 4
	
	# Sets the phase to -PI/2.
	def self.rubygame
		@@phase = -HALF_PI
	end
	
	# Sets the phase to _pv_.
	# 
	# pv:: the new phase
	def self.phase(pv)
		@@phase = pv
	end
	
	# Initializes a new vector.
	# 
	# args are in one of the following formats:
	# * two ints, _x_ and _y_
	# * one array, [_x_, _y_]
	# * one vector
	# * three parameters, _:cartesian_, _x_, _y_
	# * three parameters, _:polar_, _angle_, _magnitude_
	def initialize(*args)
		@@phase ||= 0.0
		
		if args.size == 2
			@x = args[0]
			@y = args[1]
			_recalculate_polar
		elsif args.size == 1 && args[0].kind_of?(Array)
			@x = args[0][0]
			@y = args[0][1]
			_recalculate_polar
		elsif args.size == 1 && args[0].kind_of?(Vector)
			@x = args[0].x
			@y = args[0].y
			_recalculate_polar
		elsif args.size == 3 && args[0] == :cartesian
			@x = args[1]
			@y = args[2]
			_recalculate_polar
		elsif args.size == 3 && args[0] == :polar
			@a = args[1]
			@m = args[2]
			_recalculate_cartesian
		else
			raise ArgumentError.new("Invalid constructor parameters!")
		end
	end
	
	# Returns a string in the format "Vector(_x_/_y_)".
	def to_s
		return "Vector(#{x}/#{y})"
	end
	
	# Returns a string in the format "Vector(_x_/_y_); a=_angle_; m=_magnitude_".
	def inspect
		return "Vector(#{x}/#{y}); m=#{m}; a=#{a}"
	end
	
	# Checks if two vectors are the same.
	def ==(other)
		return x == other.x && y == other.y rescue false
	end
	
	# Simplifies the vector and returns _self_.
	def simplify!
		simp = Rational(x, y)
		self.x = simp.numerator
		self.y = simp.denominator
		_recalculate_polar
		return self
	end
	
	# Like _simplify!_, but doesn't change _self_.
	def simplify
		simp = Rational(x, y)
		return self.class.new(simp.numerator, simp.denominator)
	end
	
	def _recalculate_cartesian # :nodoc:
		@x = @m * Math.cos(@a - @@phase)
		@y = @m * Math.sin(@a - @@phase)
	end
	private :_recalculate_cartesian
	
	def _recalculate_polar # :nodoc:
		@m = Math.sqrt(@x * @x + @y * @y)
		@a = Math.atan2(@y, @x) + @@phase
	end
	private :_recalculate_polar
	
	# Sets the x-Coordinate of the vector to _other_.
	def x=(other)
		@x = other
		_recalculate_polar
	end
	
	# Gets the x-Coordinate of _self_.
	def x; return @x; end
	
	# Sets the y-Coordinate of the vector to _other_.
	def y=(other)
		@y = other
		_recalculate_polar
	end
	
	# Gets the y-Coordinate of _self_.
	def y; return @y; end
	
	# Sets the magnitude of the vector to _other_.
	def m=(other)
		@m = other
		_recalculate_cartesian
	end
	
	# Gets the length of _self_.
	def m; return @m; end
	
	alias :length= :m=
	alias :length :m
	alias :magnitude= :m=
	alias :magnitude :m
	
	# Sets the angle of the vector to _other_.
	def a=(other)
		@a = other
		_recalculate_cartesian
	end
	
	# Gets the angle of _self_.
	def a; return @a; end
	
	alias :angle= :a=
	alias :angle :a
	
	# Unary Minus.
	def -@
		return self.class.new(-x, -y)
	end
	
	# Adds the vector _other_ to _self_ and returns the result.
	def +(other)
		raise ArgumentError.new("You can only add vector + vector!") unless other.kind_of? Vector
		return self.class.new(x + other.x, y + other.y)
	end
	
	# Substracts the vector _other_ from _self_ and returns the result.
	def -(other)
		raise ArgumentError.new("You can only substract vector - vector!") unless other.kind_of? Vector
		return self.class.new(x - other.x, y - other.y)
	end
	
	# Multiplies _self_ with _other_.
	# 
	# If _other_ is an Integer, the result is a new Vector(x * _other_, y * _other_).
	# If _other_ is a Vector, the result is the dot product of _self_ and _other_.
	# 
	# *Sidenote*: The dot product of two vectors is <tt>x1 * x2 + y1 * y2</tt>.
	def *(other)
		if other.kind_of?(Integer) || other.kind_of?(Float)
			return self.class.new(x * other, y * other)
		elsif other.kind_of?(Vector)
			return x * other.x + y * other.y
		else
			raise ArgumentError.new("Invalid parameter class (valid are Integers and Vectors)!")
		end
	end
	
	# Returns a new Vector(x / other, y / other)
	def /(other)
		unless other.kind_of?(Integer) || other.kind_of?(Float)
			raise ArgumentError.new("You can only divide vector / number!")
		end
		return self.class.new(x / other, y / other)
	end
	
	# Calculates the cross product of _self_ and _other_. The Vector this
	# method returns is pretty much useless, but it's length is the area
	# of a paralellogram enclosed by _self_ and _other_. If you want the
	# area of a triangle, divide by two.
	def cross(other)
		raise ArgumentError.new("You can only cross two vectors!") unless other.kind_of? Vector
		return self.class.new(x * other.y, y * other.x)
	end
	
	# Scales the vector on both the x and the y axis or both if the _sy_ - parameter
	# is left out.
	def scale!(sx, sy = nil)
		sy ||= sx
		self.x *= sx
		self.y *= sy
		_recalculate_polar
		return self
	end
	
	# Like _scale!_, but doesn't change _self_.
	def scale(sx, sy = nil)
		sy ||= sx
		return self.class.new(x * sx, y * sy)
	end
	
	# Changes the length of the vector to 1.
	def unit!
		self.m = 1
		return self
	end
	
	# Like _unit!_, but doesn't change self.
	def unit
		return self.class.new(:polar, self.a, 1)
	end
	
	# Checks if _self_ is normal at _other_.
	def normal_at?(other)
		return self * other == 0
	end
	
	# Returns a vector that is normal at _self_.
	def normal
		return self.class.new(y, -x)
	end
	
	# Returns the angle enclosed by _self_ and _other_.
	# Returns only the first possibile result, to get the second one substract
	# the angle form TWO_PI.
	def enclosed_angle(other)
		return Math.acos(self.unit * other.unit)
	end
end
