class Rubygame::Vector
	PI = Math::PI
	HALF_PI = PI / 2
	QUARTER_PI = PI / 4
	DOUBLE_PI = PI * 2
	FOUR_PI = PI * 4
	
	def self.rubygame
		@@phase = -HALF_PI
	end
	
	def self.phase(pv)
		@@phase = pv
	end
	
	attr_accessor :x, :y
	
	def initialize(x, y)
		@@phase ||= 0.0
		@x = x
		@y = y
	end
	
	def simplify
		simp = Rational(x, y)
		return self.class.new(simp.numerator, simp.denumerator)
	end
	
	def r
		return Math.sqrt(x *x + y * y)
	end
	
	def w
		return Math.atan2(x, y) + @@phase
	end
	
	def r=(other)
		y = other * Math.sin(w - @@phase)
		x = other * Math.cos(w - @@phase)
	end
	
	def w=(other)
		x = r * Math.sin(other - @@phase)
		y = r * Math.cos(other - @@phase)
	end
	
	def -@
		return self.class.new(-x, -y)
	end
	
	def +(other)
		raise ArgumentError.new("You can only add vector + vector!") unless other.kind_of? Vector
		return self.class.new(x + other.x, y + other.y)
	end
	
	def -(other)
		raise ArgumentError.new("You can only substract vector - vector!") unless other.kind_of? Vector
		return self.class.new(x - other.x, y - other.y)
	end
	
	def *(other)
		if other.kind_of? Integer || other.kind_of? Float
			return self.class.new(x * other, y * other)
		elsif other.kind_of? Vector
			return x * other.x + y * other.y
		else
			raise ArgumentError.new("Invalid parameter class (valid are Integers, Floats and Vectors)!")
		end
	end
	
	def /(other)
		unless other.kind_of? Integer || other.kind_of? Float
			raise ArgumentError.new("You can only divide vector / number!")
		end
		return self.class.new(x / other, y / other)
	end
	
	def cross(other)
		raise ArgumentError.new("You can only cross two vectors!") unless other.kind_of? Vector
		return self.class.new(x - other.y, -y + other.x)
	end
	
	def scale(sx, sy = nil)
		sy ||= sx
		return self.class.new(x * sx, y * sy)
	end
	
	def normal_at?(other)
		return self * other == 0
	end
	
	def normal
		return self.class.new(y, -x)
	end
end
