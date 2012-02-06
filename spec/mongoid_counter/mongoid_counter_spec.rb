# -*- encoding : utf-8 -*-
require File.expand_path(File.join(File.dirname(__FILE__), '../spec_helper'))

describe Resource do
  before(:each) do
    yesterday_str = Time.now.utc.yesterday.to_date.to_time.to_i.to_s
    @pr = Fabricate :parent_resource
    @r1 = Fabricate(:resource, cached_downloads: 2, parent_resource: @pr, cnt: {yesterday_str => {'do' => 5}} )
    @r2 = Fabricate(:resource, cached_downloads: 1, cached_views: 1, parent_resource: @pr)
  end

  it "should respond to counter hash" do
    @r1.should respond_to(:cnt)
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

  it "should increase counter by 3 for downloads at once" do
    @r1.get_count(:downloads).should == 2
    @r1.add_count(:downloads, 3)
    @r1.cached_downloads.should == 5
    @r1.get_count(:downloads).should == 5
    @r1.get_count(:downloads, false).should == 8
  end

  it "should increase counter by 3 for downloads" do
    @r1.get_count(:downloads).should == 2
    3.times { @r1.add_count(:downloads)}
    @r1.get_count(:downloads).should == 5
    @r1.get_count(:downloads, false).should == 8
  end

  it "should update counter value on add_count for nested embeding" do
    @r1.add_count(:downloads)
    @r1.cnt[Time.now.utc.to_date.to_time.to_i.to_s]['do'].should == 1
  end

  it "should increase counter by 3 and create only one record" do
    lambda{ 3.times { |x|
        @r1.add_count(:views)
        @r1.reload.cached_views.should == x + 1
      }
    }.should change{@r1.cnt.keys.size}.by(1)
  end

  it "should be able to redefine counter method and not use default mechanism of counters" do
    @r2.add_count(:samples, 3)
    @r2.cnt.should be_nil
    @r2.cached_samples.should == 3
    @r2.get_count(:samples).should == 3
    @r2.get_count(:samples, false).should == 999
    @r2.cached_samples.should == 999
  end

  it "shoulg not add ResourceCounter" do
    expect{@r1.add_count(:views)}.to change{@r1.cnt.keys.size}.by(1)
  end

end

