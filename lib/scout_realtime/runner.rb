module Scout
  module Realtime
    class Runner
      attr_accessor :num_runs
      attr_accessor :latest_run

      def initialize
        @latest_run = {}
        @num_runs=0

        @collectors={:disks => ServerMetrics::Disk.new(), :cpu => ServerMetrics::Cpu.new(), :memory => ServerMetrics::Memory.new(), :network => ServerMetrics::Network.new() , :processes=>ServerMetrics::Processes.new() }

        @system_info = ServerMetrics::SystemInfo.to_h
      end

      def run
        collector_res={}
        collector_meta={}
        @collectors.each_pair do |name, collector|
          start_time=Time.now
          begin
            collector_res[name] = collector.run
          rescue => e
            raise e
          end
          collector_meta[name] = {
              :duration => ((Time.now-start_time)*1000).to_i # milliseconds
          }
        end

        latest_run = collector_res
        latest_run.merge!(:collector_meta => collector_meta)
        latest_run.merge!(:system_info => @system_info.merge(:server_time => Time.now.strftime("%I:%M:%S %p"), :server_unixtime => Time.now.to_i))

        @latest_run=latest_run
        @num_runs +=1
      end
    end
  end
end