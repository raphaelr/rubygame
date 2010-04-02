require File.join(File.dirname(__FILE__), "..", "lib", "rubygame", "vector")
include Rubygame

describe Vector do
	it "should accept documented constructor parameter layouts" do
		proc { Vector(48, 49) }.should_not raise_error
		proc { Vector([49, 49]) }.should_not raise_error
		proc { Vector(Vector(48, 49)) }.should_not raise_error
		proc { Vector(:cartesian, 48, 49) }.should_not raise_error
		proc { Vector(:polar, 48, 49) }.should_not raise_error
	end
	
	it "should raise an error for other parameters" do
		proc { Vector(48) }.should raise_error
		proc { Vector(:raphaels_coordinate_system, :in, :sane) }.should raise_error
		proc { Vector() }.should raise_error
	end
	
	it "should create the same data for all parameter layouts" do
		a = Vector(4, 3)
		b = Vector([4, 3])
		c = Vector(Vector(4, 3))
		d = Vector(:cartesian, 4, 3)
		
		a.should == b
		b.should == c
		c.should == d
	end
	
	it "should calculate polar coordinates" do
		a = Vector(4, 3)
		a.m.should == 5
		a.a.should be_close(Math.atan2(3, 4), 0.1)
	end
	
	it "should calculate cartesian coordinates" do
		a = Vector(:polar, Vector::PI / 4, 5)
		a.x.should be_close(5 * Math.cos(Vector::PI / 4), 0.1)
		a.y.should be_close(5 * Math.sin(Vector::PI / 4), 0.1)
	end
	
	it "should simplify" do
		a = Vector(10, 5)
		b = a.simplify
		
		a.x.should == 10
		a.y.should == 5
		b.x.should == 2
		b.y.should == 1
	end
	
	it "should unary-minus vectors" do
		a = Vector(2, 1)
		b = -a
		
		b.x.should == -2
		b.y.should == -1
	end
	
	it "should add vectors" do
		a = Vector(4, 8)
		b = Vector(4, 9)
		c = a + b
		
		c.x.should == 8
		c.y.should == 17
	end
	
	it "should substract vectors" do
		a = Vector(4, 8)
		b = Vector(9, 4)
		c = a - b
		
		c.x.should == -5
		c.y.should == 4
	end
	
	it "should multiply vectors with scalars" do
		a = Vector(3, 4)
		b = a * 10
		
		b.x.should == 30
		b.y.should == 40
	end
	
	it "should dot-multiply vectors" do
		a = Vector(4, 3)
		b = Vector(1, 2)
		c = a * b
		
		c.should == 10
	end
	
	it "should divide vectors by scalars" do
		a = Vector(21, 28)
		b = a / 7
		
		b.x.should == 3
		b.y.should == 4
	end
	
	it "shouldn't divide two vectors" do
		a = Vector(4, 8)
		b = Vector(4, 9)
		
		proc { a / b }.should raise_error
	end
	
	it "should cross-multiply two vectors" do
		a = Vector(2, 0)
		b = Vector(0, 1)
		c = a.cross(b)
		
		c.m.should == 2
	end
	
	it "should scale two vectors" do
		a = Vector(4, 8)
		b = a.scale(2, 3)
		c = a.scale(4)
		
		b.x.should == 8
		b.y.should == 24
		c.x.should == 16
		c.y.should == 32
	end
	
	it "should calculate the unit vectors" do
		a = Vector(15, 36)
		b = a.unit
		
		b.m.should == 1
		b.a.should == a.a
	end
	
	it "should calculate the enclosed angle" do
		a = Vector(5, 0)
		b = Vector(0, 5)
		c = a.enclosed_angle(b)
		c.should be_close(Vector::HALF_PI, 0.1)
	end
	
	it "should support simplify-bang" do
		a = Vector(10, 5)
		a.simplify!
		
		a.x.should == 2
		a.y.should == 1
	end
	
	it "should support scale-bang" do
		a = Vector(2, 3)
		a.scale!(4)
		b = Vector(2, 3)
		b.scale!(5, 2)
		
		a.x.should == 8
		a.y.should == 12
		b.x.should == 10
		b.y.should == 6
	end
	
	it "should support unit-bang" do
		a = Vector(2, 3)
		b = Vector(2, 3)
		a.unit!
		
		a.m.should == 1
		a.a.should == b.a
	end
	
	it "should check if two vectors are normal" do
		a = Vector(5, 0)
		b = Vector(0, 5)
		c = Vector(48, 49)
		
		a.normal_at?(b).should == true
		a.normal_at?(c).should == false
	end
	
	it "should handle phases correctly" do
		Vector.rubygame
		a = Vector(5, 0)
		b = Vector(0, 5)
		
		a.a.should be_close(-Vector::HALF_PI, 0.1)
		b.a.should == 0.0
		Vector.phase(0.0)
	end
end
