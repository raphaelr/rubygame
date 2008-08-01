
# Prefer local library over installed version.
$:.unshift( File.join( File.dirname(__FILE__), "..", "lib" ) )
$:.unshift( File.join( File.dirname(__FILE__), "..", "ext", "rubygame" ) )

require 'rubygame'
include Rubygame


describe EventQueue do
  
  before :each do
    @queue = EventQueue.new
  end



  #############
  # AUTOFETCH #
  #############

  it "autofetch should be on by default" do
    @queue.autofetch.should be_true
  end

  it "should have autofetch read-write accessors" do
    @queue.should respond_to(:autofetch)
    @queue.should respond_to(:autofetch=)
  end



  ########
  # EACH #
  ########

  it "#each should yield each event in the queue in order" do 
    collect = []
    @queue.push( [1,2,3] )
    @queue.each { |e| collect << e}
    collect.should == [1,2,3]
  end

  it "#each should flush the buffer afterwards" do
    @queue.push( [1,2,3] )
    @queue.each {}
    @queue.should be_empty
  end

  it "#each should fetch SDL events if autofetch is on" do
    @queue.autofetch = true

    @queue.should_receive(:fetch_sdl_events).and_return([:foo])
    @queue.each {}
  end

  it "#each should not fetch SDL events if autofetch is off" do
    @queue.autofetch = false

    @queue.should_not_receive(:fetch_sdl_events)
    @queue.each {}
  end



  #############
  # PEEK EACH #
  #############

  it "#peek_each should yield each event in the queue in order" do 
    collect = []
    @queue.push( [1,2,3] )
    @queue.peek_each { |e| collect << e}
    collect.should == [1,2,3]
  end

  it "#peek_each should not flush the buffer afterwards" do
    @queue.push( [1,2,3] )
    @queue.peek_each {}
    @queue.should_not be_empty
  end

  it "#peek_each should fetch SDL events if autofetch is on" do
    @queue.autofetch = true

    @queue.should_receive(:fetch_sdl_events).and_return([:foo])
    @queue.peek_each {}
  end

  it "#peek_each should not fetch SDL events if autofetch is off" do
    @queue.autofetch = false

    @queue.should_not_receive(:fetch_sdl_events)
    @queue.peek_each {}
  end



  ###############
  # PUSH / POST #
  ###############

  it "should accept pushes" do
    @queue.push( :foo )
    @queue.to_ary.should == [:foo]
  end

  it "should accept posts" do
    @queue.post( :foo )
    @queue.to_ary.should == [:foo]
  end

end
