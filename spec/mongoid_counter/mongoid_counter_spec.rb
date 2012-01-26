# -*- encoding : utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Resource do
  before(:each) do
    @p1 = Fabricate(:resource, :cached_downloads => 2)
    @p2 = Fabricate(:resource, :cached_downloads => 1, :cached_views => 1)
    Fabricate :resource_counter, :resource => @p1
  end

  it "should respond to resource_counters" do
    @p1.should respond_to(:resource_counters)
  end

  it "should respond to counters" do
    @p1.should respond_to(:counters)
  end

  it "should return counters" do
    @p1.counters_options.should == { 'samples_method' => :calculate }
    @p1.counters.should == [:views, :downloads, :samples]
  end

  it "should respond to counter" do
    @p1.should respond_to(:get_count)
  end

  it "should return 0 if counters == nil" do
    @p1.get_count(:views).should == 0
    @p1.get_count(:views, false).should == 0
  end

  it "should return downloads count from cached column" do
    @p1.get_count(:downloads).should == 2
  end

  it "should return downloads count" do
    @p1.get_count(:downloads, false).should == 5
  end

  it "should return downloads count and not use cached column" do
    @p1.get_count(:downloads, false).should == 5
  end

  #it "should update cached column for downloads" do
    #@p1.update_cached_column(:downloads)
    #@p1.get_count(:downloads).should == 5
  #end

  it "should increase counter by 1 for downloads" do
    @p1.add_count(:downloads)
    @p1.get_count(:downloads).should == 3
  end

  it "should increase counter by 3 for downloads" do
    @p1.add_count(:downloads, 3).should_not be_nil
    @p1.get_count(:downloads).should == 5
  end

  it "should increase counter by 3 for downloads" do
    3.times { @p1.add_count(:downloads)}
    @p1.get_count(:downloads).should == 5
  end

  it "should increase counter by 3 and create only one record" do
    lambda{ 3.times {|x| 
      @p1.add_count(:views)
      @p1.reload.cached_views.should == x + 1
    }
    }.should change{@p1.resource_counters.count}.from(1).to(2)
  end

  it "should be able to redefine counter method and not use default mechanism of counters" do
    expect{@p2.add_count(:samples, 3)}.to change{@p2.resource_counters.count}.by(0)
    @p2.cached_samples.should == 3
    @p2.get_count(:samples).should == 3
    @p2.get_count(:samples, false).should == 999
    @p2.cached_samples.should == 999
  end
end

