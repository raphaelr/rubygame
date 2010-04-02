# This is mostly for regression testing and bugfix confirmation at the moment.

# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

SDL_PATHS = ["e:/libs/sdl-1.2.14/sdl-bin/"]
require 'rubygame'
include Rubygame

samples_dir = File.join( File.dirname(__FILE__), "..", "samples", "")
test_dir = File.join( File.dirname(__FILE__), "" )

test_image = test_dir + "image.png"
test_image_8bit = test_dir + "image_8bit.png"
not_image = test_dir + "short.ogg"
panda = samples_dir + "panda.png"
dne = test_dir + "does_not_exist.png"


describe Surface, "(creation)" do
  before(:each) do
    Rubygame.init()
    @screen = Screen.new([100,100])
  end

  after(:each) do
    Rubygame.quit()
  end

  it "should raise TypeError when #new size is not an Array" do
    lambda {
      Surface.new("not an array")
    }.should raise_error(TypeError)
  end

  it "should raise ArgumentError when #new size is an Array of non-Numerics" do
    lambda {
      Surface.new(["not", "numerics"])
    }.should raise_error(ArgumentError)
  end

  it "should raise ArgumentError when #new size is too short" do
    lambda {
      Surface.new([1])
    }.should raise_error(ArgumentError)
  end
end

describe Surface, "(marshalling)" do
  it "should duplicate" do
    srf_a = Surface.new([10, 20], 24)
    srf_b = srf_a.dup
    
    srf_a.__id__.should_not == srf_b.__id__
  end
  
  it "should duplicate the SDL_Surface" do
    srf_a = Surface.new([10, 20], 23)
    srf_a.fill([0, 0, 255, 255])
    srf_b = srf_a.dup
    
    srf_a.get_at([0, 0]).should == [0, 0, 255, 255]
    srf_b.get_at([0, 0]).should == [0, 0, 255, 255]
    srf_b.fill([0, 255, 0])
    srf_a.get_at([0, 0]).should == [0, 0, 255, 255]
    srf_b.get_at([0, 0]).should == [0, 255, 0, 255]
  end
  
  it "should marshal" do
    srf_a = Surface.new([10, 20], 24)
    srf_a.fill([255, 0, 0, 255])
    
    str = Marshal.dump(srf_a)
    srf_b = Marshal.load(str)
    
    srf_a.w.should == srf_b.w
    srf_a.h.should == srf_b.h
    srf_a.depth.should == srf_b.depth
    srf_b.get_at([0, 0]).should == [255, 0, 0, 255]
  end
end

describe Surface, "(loading)" do
  before :each do
    unless( Rubygame::VERSIONS[:sdl_image] )
      raise "Can't test image loading, no SDL_image installed."
    end
  end

  it "should load image to a new Surface" do
    surface = Surface.load( test_image )
  end

  it "should raise an error if file is not an image" do
    lambda{ Surface.load( not_image ) }.should raise_error( SDLError )
  end

  it "should raise an error if file doesn't exist" do
    lambda{ Surface.load( dne ) }.should raise_error( SDLError )
  end
end


describe Surface, "(loading from string)" do
  before :each do
    unless( Rubygame::VERSIONS[:sdl_image] )
      raise "Can't test image loading, no SDL_image installed."
    end

    @data = "\x42\x4d\x3a\x00\x00\x00\x00\x00"+
            "\x00\x00\x36\x00\x00\x00\x28\x00"+
            "\x00\x00\x01\x00\x00\x00\x01\x00"+
            "\x00\x00\x01\x00\x18\x00\x00\x00"+
            "\x00\x00\x04\x00\x00\x00\x13\x0b"+
            "\x00\x00\x13\x0b\x00\x00\x00\x00"+
            "\x00\x00\x00\x00\x00\x00\x00\x00"+
            "\xff\x00"
  end
  
  it "should be able to load from string" do
    surf = Surface.load_from_string(@data)
    surf.get_at(0,0).should == [255,0,0,255]
  end
  
  it "should be able to load from string (typed)" do
    surf = Surface.load_from_string(@data,"BMP")
    surf.get_at(0,0).should == [255,0,0,255]
  end
end


describe Surface, "(named resource)" do
  before :each do
    Surface.autoload_dirs = [samples_dir]
  end

  after :each do
    Surface.autoload_dirs = []
    Surface.instance_eval { @resources = {} }
  end

  it "should include NamedResource" do
    Surface.included_modules.should include(NamedResource)
  end

  it "should respond to :[]" do
    Surface.should respond_to(:[])
  end

  it "should respond to :[]=" do
    Surface.should respond_to(:[]=)
  end

  it "should allow setting resources" do
    s = Surface.load(panda)
    Surface["panda"] = s
    Surface["panda"].should == s
  end

  it "should reject non-Surface resources" do
    lambda { Surface["foo"] = "bar" }.should raise_error(TypeError)
  end

  it "should autoload images as Surface instances" do
    unless( Rubygame::VERSIONS[:sdl_image] )
      raise "Can't test image loading, no SDL_image installed."
    end

    Surface["panda.png"].should be_instance_of(Surface)
  end

  it "should return nil for nonexisting files" do
    unless( Rubygame::VERSIONS[:sdl_image] )
      raise "Can't test image loading, no SDL_image installed."
    end

    Surface["foobar.png"].should be_nil
  end

  it "should set names of autoload Surfaces" do
    unless( Rubygame::VERSIONS[:sdl_image] )
      raise "Can't test image loading, no SDL_image installed."
    end

    Surface["panda.png"].name.should == "panda.png"
  end
end



describe Surface, "(blit)" do
  before(:each) do
    Rubygame.init()
    @screen = Screen.new([100,100])
    @surface = Surface.new([100,100])
  end

  after(:each) do
    Rubygame.quit
  end

  it "should raise TypeError when #blit target is not a Surface" do
    lambda {
      @surface.blit("not a surface", [0,0])
    }.should raise_error(TypeError)
  end

  it "should raise TypeError when #blit dest is not an Array" do
    lambda {
      @surface.blit(@screen, "foo")
    }.should raise_error(TypeError)
  end

  it "should raise TypeError when #blit src is not an Array" do
    lambda { 
      @surface.blit(@screen, [0,0], "foo")
    }.should raise_error(TypeError)
  end
end



describe Surface, "(fill)" do 
  before(:each) do
    Rubygame.init()
    @surface = Surface.new([100,100])
  end

  after(:each) do
    Rubygame.quit
  end

  it "should raise TypeError when #fill color is not an Array" do
    lambda {
      @surface.fill(nil)
    }.should raise_error(TypeError)
  end

  it "should raise TypeError when #fill color is an Array of non-Numerics" do
    lambda {
      @surface.fill(["non", "numeric", "members"])
    }.should raise_error(TypeError)
  end

  it "should raise ArgumentError when #fill color is too short" do
    lambda {
      @surface.fill([0xff, 0xff])
    }.should raise_error(TypeError)
  end

  it "should raise TypeError when #fill rect is not an Array" do
    lambda {
      @surface.fill([0xff, 0xff, 0xff], "not_an_array")
    }.should raise_error(TypeError)
  end
end



describe Surface, "(colorkey)" do 
  before(:each) do
    Rubygame.init()
    @surface = Surface.new([100,100])
  end

  after(:each) do
    Rubygame.quit
  end


  it "colorkey should be nil by default" do
    @surface.colorkey.should be_nil
  end

  it "should not have colorkey flag by default" do
    (@surface.flags & SRCCOLORKEY).should == 0
  end


  it "colorkey should be a color after it is set" do
    @surface.set_colorkey([1,2,3])
    @surface.colorkey.should == [1,2,3]
  end

  it "should have colorkey flag after colorkey is set" do
    @surface.set_colorkey([1,2,3])
    (@surface.flags & SRCCOLORKEY).should == SRCCOLORKEY
  end


  it "colorkey should be nil after it is set to nil" do
    @surface.set_colorkey([1,2,3])
    @surface.set_colorkey( nil )
    @surface.colorkey.should be_nil
  end
 
  it "should not have colorkey flag after colorkey is set to nil" do
    @surface.set_colorkey([1,2,3])
    @surface.set_colorkey( nil )
    (@surface.flags & SRCCOLORKEY).should == 0
  end
end




describe Surface, "(get_at)" do 
  before(:each) do
    Rubygame.init()
    @surface = Surface.new([100,100])
  end

  after(:each) do
    Rubygame.quit
  end

  it "get_at should get [0,0,0,255] on a new non-alpha surface" do
    @surface.get_at(0,0).should == [0,0,0,255]
  end

#   it "get_at should get [0,0,0,0] on a new alpha surface" do
#     @surface = Surface.new([100,100], 0, [SRCALPHA])
#     @surface.get_at(0,0).should == [0,0,0,0]
#   end

  it "get_at should get the color of a filled surface" do
    @surface.fill([255,0,0])
    @surface.get_at(0,0).should == [255,0,0,255]
  end


  describe "(8-bit)" do
    before(:each) do
      Rubygame.init()
      @surface = Surface.load( test_image_8bit )
    end

    it "get_at should get the color of the pixel" do
      @surface.get_at(0,0).should == [255,0,0,255]
    end

  end
end
