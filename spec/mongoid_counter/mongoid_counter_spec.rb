# -*- encoding : utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Resource do
  before(:each) do
    @pr = Fabricate :parent_resource
    @r1 = Fabricate(:resource, cached_downloads: 2, parent_resource: @pr)
    @r2 = Fabricate(:resource, cached_downloads: 1, cached_views: 1, parent_resource: @pr)
    Fabricate :resource_counter, :resource => @r1
  end

  it "should respond to resource_counters" do
    @r1.should respond_to(:resource_counters)
  end

  it "should respond to counters" do
    @r1.should respond_to(:counters)
  end

  it "should return counters" do
    @r1.counters_options.should == { 'samples_method' => :calculate }
    @r1.counters.should == [:views, :downloads, :samples]
  end

  it "should respond to counter" do
    @r1.should respond_to(:get_count)
  end

  it "should return 0 if counters == nil" do
    @r1.get_count(:views).should == 0
    @r1.get_count(:views, false).should == 0
  end

  it "should return downloads count from cached column" do
    @r1.get_count(:downloads).should == 2
  end

  it "should return downloads count and recalculate value(not use cached column)" do
    @r1.get_count(:downloads, false).should == 5
  end

  it "should increase counter by 1 for downloads" do
    @r1.add_count(:downloads)
    @r1.get_count(:downloads).should == 3
  end

  it "should increase counter by 3 for downloads" do
    @r1.add_count(:downloads, 3).should_not be_nil
    @r1.get_count(:downloads).should == 5
  end

  it "should increase counter by 3 for downloads" do
    3.times { @r1.add_count(:downloads)}
    @r1.get_count(:downloads).should == 5
  end

  it "should update counter value on add_count for nested embeding" do
    @r1.add_count(:downloads)
    @r1.resource_counters.first.downloads.should == 6
  end

  it "should increase counter by 3 and create only one record" do
    lambda{ 3.times { |x|
        @r1.add_count(:views)
        @r1.reload.cached_views.should == x + 1
      }
    }.should change{@r1.resource_counters.count}.by(0)
  end

  it "should be able to redefine counter method and not use default mechanism of counters" do
    expect{@r2.add_count(:samples, 3)}.to change{@r2.resource_counters.count}.by(0)
    @r2.cached_samples.should == 3
    @r2.get_count(:samples).should == 3
    @r2.get_count(:samples, false).should == 999
    @r2.cached_samples.should == 999
  end

  it "shoulg not add ResourceCounter" do
    expect{@r1.add_count(:views)}.to change{@r1.resource_counters.count}.by(0)
  end

end

