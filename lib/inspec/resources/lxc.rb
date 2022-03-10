require "inspec/resources/command"
module Inspec::Resources
  class Lxc < Inspec.resource(1)
    name "lxc"
    # Restrict to only run on the below platforms
    supports platform: "linux"
    desc "Use the lxc InSpec audit resource to test if container exists and/or is running for linux container"
    example <<~EXAMPLE
      describe lxc("ubuntu-container") do
        it { should exist }
        it { should be_running }
      end
    EXAMPLE

    # Resource initialization.
    def initialize(container_name)
      
      skip_resource "The `lxc` resource is not yet available on your OS." unless inspec.os.linux?
      @container_name = container_name
      @lxc_info_cmd = lxc_info_cmd 
      @container_info = []
    end

    def resource_id
      @container_name
    end

    def to_s
      "lxc #{resource_id}"
    end

    def exists?
      return @lxc_info_cmd.exit_status.to_i == 0
    end

    def running?
      exists?
      @container_info = @lxc_info_cmd.stdout.split(":").map(&:strip)
      return @container_info[0] == "Status" && @container_info[1] == "Running"
    end

    private

    # Method to find lxc
    def find_lxc_or_error
      %w{/usr/sbin/lxc /sbin/lxc lxc}.each do |cmd|
        return cmd if inspec.command(cmd).exist?
      end

      raise Inspec::Exceptions::ResourceFailed, "Could not find `iptables`"
    end

    def lxc_info_cmd
      bin = find_lxc_or_error
      info_cmd = "info #{@container_name} | grep -i Status"
      lxc_cmd = format("%s %s", bin, info_cmd).strip
      cmd = inspec.command(lxc_cmd)
    end
  end
end
