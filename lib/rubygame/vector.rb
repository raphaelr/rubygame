# A realistic 2D Vector class.
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
	
	attr_reader :x, :y
	attr_reader :r, :w
	
	# Initializes a new vector.
	# 
	# args are in one of the following formats:
	#   * two ints, _x_ and _y_
	#   * one array, [_x_, _y_]
	#   * one vector
	#   * three parameters, _:cartesian_, _x_, _y_
	#   * three parameters, _:polar_, _r_, _w_
	def initialize(*args)
		@@phase ||= 0.0
		
		if args.size == 2
			@x = args[0]
			@y = args[0]
			_recalculate_polar
		elsif args.size == 1 && args[0].kind_of? Array
			@x = args[0][0]
			@y = args[0][1]
			_recalculate_polar
		elsif args.size == 1 && args[0].kind_of? Vector
			@x = args[0].x
			@y = args[0].y
			_recalculate_polar
		elsif args.size == 3 && args[0] == :cartesian
			@x = args[1]
			@y = args[2]
			_recalculate_polar
		elsif args.size == 3 && args[0] == :polar
			@r = args[1]
			@w = args[2]
			_recalculate_cartesian
		end
	end
	
	# Simplifies the vector and returns _self_.
	def simplify!
		simp = Rational(x, y)
		x = simp.numerator
		y = simp.denumerator
		_recalculate_polar
		return self
	end
	
	# Like _simplify!_, but doesn't change _self_.
	def simplify
		simp = Rational(x, y)
		return self.class.new(simp.numerator, simp.denumerator)
	end
	
	private :_recalculate_cartesian
	def _recalculate_cartesian
		x = r * Math.cos(w - @@phase)
		y = r * Math.sin(w - @@phase)
	end
	
	private :_recalculate_polar
	def _recalculate_polar
		@r = Math.sqrt(x * x + y * y)
		@w = Math.atan2(w - @@phase)
	end
	
	# Sets the x-Coordinate of the vector to _other_.
	def x=(other)
		@x = other
		_recalculate_polar
	end
	
	# Sets the y-Coordinate of the vector to _other_.
	def y=(other)
		@y = other
		_recalculate_polar
	end
	
	alias :length= :r=
	alias :length :r
	# Sets the length of the vector to _other_.
	def r=(other)
		@r = other
		_recalculate_cartesian
	end
	
	alias :angle= :w=
	alias :angle :w
	# Sets the angle of the vector to _other_.
	def w=(other)
		@w = other
		_recalculate_cartesian
	end
	
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
		if other.kind_of? Integer || other.kind_of? Float
			return self.class.new(x * other, y * other)
		elsif other.kind_of? Vector
			return x * other.x + y * other.y
		else
			raise ArgumentError.new("Invalid parameter class (valid are Integers and Vectors)!")
		end
	end
	
	# Returns a new Vector(x / other, y / other)
	def /(other)
		unless other.kind_of? Integer || other.kind_of? Float
			raise ArgumentError.new("You can only divide vector / number!")
		end
		return self.class.new(x / other, y / other)
	end
	
	# Calculates the cross product of _self_ and _other_. Useful only for calculating
	# the area of a parallelogram enclosed by two vectors.
	def cross(other)
		raise ArgumentError.new("You can only cross two vectors!") unless other.kind_of? Vector
		return self.class.new(x - other.y, -y + other.x)
	end
	
	# Scales the vector on both the x and the y axis or both if the _sy_ - parameter
	# is left out.
	def scale!(sx, sy = nil)
		sy ||= sx
		x *= sx
		y *= sy
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
		r = 1
		_recalculate_cartesian
		return self
	end
	
	# Like _unit!_, but doesn't change self.
	def unit
		return self.class.new(:polar, 1, w)
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
	# Returns only the first possibility, to get the second one substract
	# the angle form TWO_PI.
	def enclosed_angle(other)
		return Math.acos(self.unit * other.unit)
	end
end

module Rubygame
	def Vector(*args)
		return Vector.new(*args)
	end
end
